import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawgrid/data/catalog.dart';
import 'package:pawgrid/data/database.dart';
import 'package:puzzle_core/puzzle_core.dart';

void main() {
  late PawDatabase db;
  late GameRepository repo;
  final raw =
      jsonDecode(
            File(
              '../test-fixtures/Pawgrid_sample_level.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final p = PuzzleDefinition.fromJson(raw);
  setUp(() {
    db = PawDatabase(NativeDatabase.memory());
    repo = GameRepository(db);
  });
  tearDown(() async {
    await db.close();
  });
  test('move, undo, contradictory save and history restore exactly', () async {
    var s = PuzzleSession.start(p)
        .change(p, 0, CellMark.token)
        .change(p, 1, CellMark.token)
        .tap(p, 2, InputMode.mark);
    await repo.save(p, 'journey', s);
    expect((await repo.load(p, 'journey'))!.session.marks, s.marks);
    s = s.undo(p);
    await repo.save(p, 'journey', s);
    final loaded = (await repo.load(p, 'journey'))!.session;
    expect(loaded.history.length, 2);
    expect(loaded.marks[2], CellMark.unknown);
    expect(Rules.conflicts(p, loaded.marks), isNotEmpty);
  });
  test('corrupt latest snapshot recovers redundant prior snapshot', () async {
    final a = PuzzleSession.start(p).tap(p, 0, InputMode.mark);
    await repo.save(p, 'journey', a);
    await repo.save(p, 'journey', a.tap(p, 1, InputMode.mark));
    await (db.update(db.savedSessions)
          ..where((t) => t.levelId.equals(p.levelId)))
        .write(const SavedSessionsCompanion(payload: Value('corrupt')));
    final recovered = (await repo.load(p, 'journey'))!;
    expect(recovered.recovered, true);
    expect(recovered.session.marks, a.marks);
  });
  test('completion replay and duplicate save cannot grant twice', () async {
    var s = PuzzleSession.start(p);
    for (var r = 0; r < p.n; r++) {
      s = s.change(p, r * p.n + p.solution[r], CellMark.token);
    }
    await repo.save(p, 'journey', s, completedUtc: '2026-11-08T00:00:00Z');
    await repo.save(p, 'journey', s, completedUtc: '2026-11-09T00:00:00Z');
    expect(await repo.balance(), 12);
    expect((await repo.progress()).length, 1);
    expect(
      (await repo.progress())[p.levelId]!.firstCompletedUtc,
      '2026-11-08T00:00:00Z',
    );
    expect((await db.select(db.walletTransactions).get()).length, 1);
  });
  test(
    'practice grants nothing; concurrent cosmetic requests spend once',
    () async {
      var s = PuzzleSession.start(p);
      for (var r = 0; r < p.n; r++) {
        s = s.change(p, r * p.n + p.solution[r], CellMark.token);
      }
      await repo.save(p, 'practice', s);
      expect(await repo.balance(), 0);
      expect(await repo.unlock('peach', 60), false);
      await db
          .into(db.walletTransactions)
          .insert(
            WalletTransactionsCompanion.insert(
              id: 'test-grant',
              amount: 100,
              reason: 'test',
            ),
          );
      await Future.wait([repo.unlock('peach', 60), repo.unlock('peach', 60)]);
      expect(await repo.balance(), 40);
      expect((await repo.settings())['equipped'], 'peach');
    },
  );
  test('reopen SQLite file preserves grouped swipe and atomic undo', () async {
    final temp = await Directory.systemTemp.createTemp('pawgrid-test-');
    final file = File('${temp.path}/game.sqlite');
    await db.close();
    db = PawDatabase(NativeDatabase(file));
    repo = GameRepository(db);
    final before = PuzzleSession.start(p).tap(p, 9, InputMode.place);
    final s = before.paintCrosses(p, [0, 1, 2, 3, 4], CellMark.excluded);
    await repo.save(p, 'journey', s);
    await db.close();
    db = PawDatabase(NativeDatabase(file));
    repo = GameRepository(db);
    final loaded = (await repo.load(p, 'journey'))!.session;
    expect(loaded.toJson(), s.toJson());
    expect(loaded.undo(p).marks, before.marks);
    await db.close();
    await temp.delete(recursive: true);
  });
  test('catalog corruption rejected without changing progress', () async {
    final payload = File('assets/content/catalog.json').readAsStringSync(),
        hash = File('assets/content/catalog.sha256').readAsStringSync();
    expect(ContentCatalog.parse(payload, hash).levels.length, 298);
    expect(
      () => ContentCatalog.parse('$payload ', hash),
      throwsFormatException,
    );
    expect(await repo.balance(), 0);
  });
  test('delete data removes all local records', () async {
    await repo.setSetting('patterns', false);
    await repo.save(p, 'journey', PuzzleSession.start(p));
    await repo.deleteAll();
    expect(await repo.settings(), isEmpty);
    expect(await repo.progress(), isEmpty);
    expect(await repo.load(p, 'journey'), isNull);
    expect(await repo.balance(), 0);
  });
}
