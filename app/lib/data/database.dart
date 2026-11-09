import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:puzzle_core/puzzle_core.dart';
part 'database.g.dart';

class SavedSessions extends Table {
  TextColumn get slot => text()();
  TextColumn get levelId => text()();
  TextColumn get mode => text()();
  TextColumn get payload => text()();
  TextColumn get checksum => text()();
  TextColumn get previousPayload => text().nullable()();
  TextColumn get previousChecksum => text().nullable()();
  @override
  Set<Column> get primaryKey => {slot};
}

class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class LevelProgress extends Table {
  TextColumn get levelId => text()();
  TextColumn get mode => text()();
  IntColumn get stars => integer()();
  IntColumn get bestMs => integer()();
  BoolColumn get clean => boolean()();
  TextColumn get firstCompletedUtc => text()();
  @override
  Set<Column> get primaryKey => {levelId};
}

class WalletTransactions extends Table {
  TextColumn get id => text()();
  IntColumn get amount => integer()();
  TextColumn get reason => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [SavedSessions, Preferences, LevelProgress, WalletTransactions],
)
class PawDatabase extends _$PawDatabase {
  PawDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'pawgrid'));
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = FULL');
    },
  );
}

class SavedGame {
  const SavedGame(
    this.levelId,
    this.mode,
    this.session, {
    this.recovered = false,
  });
  final String levelId, mode;
  final PuzzleSession session;
  final bool recovered;
}

class GameRepository {
  GameRepository(this.db);
  final PawDatabase db;
  static String digest(String payload) =>
      sha256.convert(utf8.encode(payload)).toString();

  Future<Map<String, dynamic>> settings() async => {
    for (final row in await db.select(db.preferences).get())
      row.key: jsonDecode(row.value),
  };
  Future<void> setSetting(String key, dynamic value) => db
      .into(db.preferences)
      .insertOnConflictUpdate(
        PreferencesCompanion.insert(key: key, value: jsonEncode(value)),
      );
  Future<Map<String, LevelProgressData>> progress() async => {
    for (final row in await db.select(db.levelProgress).get()) row.levelId: row,
  };
  Future<int> balance() async => (await db.select(db.walletTransactions).get())
      .fold<int>(0, (sum, row) => sum + row.amount);

  Future<SavedGame?> load(PuzzleDefinition p, String mode) async {
    final row = await (db.select(
      db.savedSessions,
    )..where((t) => t.slot.equals('$mode:${p.levelId}'))).getSingleOrNull();
    if (row == null) return null;
    PuzzleSession? decode(String? text, String? checksum) {
      if (text == null || digest(text) != checksum) return null;
      try {
        return PuzzleSession.fromJson(
          p,
          (jsonDecode(text) as Map).cast<String, dynamic>(),
        );
      } on Object {
        return null;
      }
    }

    final latest = decode(row.payload, row.checksum);
    if (latest != null) return SavedGame(p.levelId, mode, latest);
    final previous = decode(row.previousPayload, row.previousChecksum);
    if (previous != null) {
      return SavedGame(p.levelId, mode, previous, recovered: true);
    }
    throw const FormatException(
      'Neither saved snapshot passed integrity checks',
    );
  }

  Future<int> save(
    PuzzleDefinition p,
    String mode,
    PuzzleSession session, {
    String? completedUtc,
    bool reset = false,
  }) => db.transaction(() async {
    var granted = 0;
    final slot = '$mode:${p.levelId}';
    final old = await (db.select(
      db.savedSessions,
    )..where((t) => t.slot.equals(slot))).getSingleOrNull();
    final payload = jsonEncode(session.toJson());
    await db
        .into(db.savedSessions)
        .insertOnConflictUpdate(
          SavedSessionsCompanion.insert(
            slot: slot,
            levelId: p.levelId,
            mode: mode,
            payload: payload,
            checksum: digest(payload),
            previousPayload: Value(reset ? null : old?.payload),
            previousChecksum: Value(reset ? null : old?.checksum),
          ),
        );
    await setSetting('lastGame', {'levelId': p.levelId, 'mode': mode});
    if (Rules.isWon(p, session.marks)) {
      final prior = await (db.select(
        db.levelProgress,
      )..where((t) => t.levelId.equals(p.levelId))).getSingleOrNull();
      final stars =
          1 +
          (session.hintCount == 0 ? 1 : 0) +
          (session.activeMs < p.targetSeconds * 1000 ? 1 : 0);
      await db
          .into(db.levelProgress)
          .insertOnConflictUpdate(
            LevelProgressCompanion.insert(
              levelId: p.levelId,
              mode: mode,
              stars: prior == null || stars > prior.stars ? stars : prior.stars,
              bestMs: prior == null || session.activeMs < prior.bestMs
                  ? session.activeMs
                  : prior.bestMs,
              clean: session.hintCount == 0 || (prior?.clean ?? false),
              firstCompletedUtc: prior?.firstCompletedUtc ?? completedUtc ?? '',
            ),
          );
      if (mode != 'practice') {
        final rewardId = 'solve:${p.levelId}';
        final existing = await (db.select(
          db.walletTransactions,
        )..where((t) => t.id.equals(rewardId))).getSingleOrNull();
        if (existing == null) {
          granted = mode == 'daily'
              ? 20
              : 10 + (session.hintCount == 0 ? 2 : 0);
        }
        await db
            .into(db.walletTransactions)
            .insert(
              WalletTransactionsCompanion.insert(
                id: 'solve:${p.levelId}',
                amount: mode == 'daily'
                    ? 20
                    : 10 + (session.hintCount == 0 ? 2 : 0),
                reason: 'First $mode completion',
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
    return granted;
  });

  Future<bool> unlock(String id, int cost) => db.transaction(() async {
    final owned = await settings();
    if (owned['owned:$id'] == true) {
      await setSetting('equipped', id);
      return true;
    }
    if (await balance() < cost) return false;
    await db
        .into(db.walletTransactions)
        .insert(
          WalletTransactionsCompanion.insert(
            id: 'cosmetic:$id',
            amount: -cost,
            reason: 'Garden companion $id',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await setSetting('owned:$id', true);
    await setSetting('equipped', id);
    return true;
  });

  Future<void> deleteAll() => db.transaction(() async {
    await db.delete(db.savedSessions).go();
    await db.delete(db.levelProgress).go();
    await db.delete(db.walletTransactions).go();
    await db.delete(db.preferences).go();
  });
}
