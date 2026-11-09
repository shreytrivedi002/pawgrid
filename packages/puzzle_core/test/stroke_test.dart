import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

void main() {
  final p = PuzzleDefinition.fromJson(
    jsonDecode(
          File(
            '../../test-fixtures/Pawgrid_sample_level.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>,
  );
  test('one paint stroke is one undo and survives serialization', () {
    final start = PuzzleSession.start(p);
    final painted = start.paintCrosses(p, [
      0,
      1,
      2,
      3,
      4,
      3,
      2,
      1,
      0,
    ], CellMark.excluded);
    expect(painted.moveCount, 1);
    expect(painted.history.length, 5);
    expect(painted.marks.take(5), everyElement(CellMark.excluded));
    expect(start.marks, everyElement(CellMark.unknown));
    final loaded = PuzzleSession.fromJson(
      p,
      jsonDecode(jsonEncode(painted.toJson())) as Map<String, dynamic>,
    );
    expect(loaded.undo(p).marks, start.marks);
    expect(loaded.undo(p).history, isEmpty);
    expect(loaded.undo(p).undoCount, 1);
  });
  test(
    'erase stroke skips creatures, applies a fixed value and undoes atomically',
    () {
      final initial = PuzzleSession.start(p)
          .change(p, 2, CellMark.token)
          .paintCrosses(p, [0, 1, 3, 4], CellMark.excluded);
      final erased = initial.paintCrosses(p, [
        0,
        0,
        1,
        2,
        3,
        4,
        25,
        -1,
      ], CellMark.unknown);
      expect(erased.marks[2], CellMark.token);
      expect(erased.history.length, initial.history.length + 4);
      expect(erased.undo(p).marks, initial.marks);
      expect(
        identical(initial.paintCrosses(p, [2], CellMark.excluded), initial),
        true,
      );
      expect(
        () => initial.paintCrosses(p, [0], CellMark.token),
        throwsArgumentError,
      );
    },
  );
  test('legacy v1 saves retain every mark, counter and single-cell undo', () {
    final old = PuzzleSession.start(p)
        .tap(p, 0, InputMode.mark)
        .tap(p, 1, InputMode.mark)
        .undo(p)
        .withTime(2345);
    final legacy = {...old.toJson(), 'schemaVersion': 1};
    final migrated = PuzzleSession.fromJson(p, legacy);
    expect(migrated.marks, old.marks);
    expect(migrated.activeMs, 2345);
    expect(migrated.undoCount, 1);
    expect(migrated.toJson()['schemaVersion'], 2);
    expect(migrated.undo(p).marks, PuzzleSession.start(p).marks);
    final mixed = migrated.paintCrosses(p, [2, 3, 4], CellMark.excluded);
    expect(
      PuzzleSession.fromJson(p, mixed.toJson()).undo(p).marks,
      migrated.marks,
    );
  });
  test('invalid group IDs and noncontiguous reused groups are rejected', () {
    final s = PuzzleSession.start(p).paintCrosses(p, [0, 1], CellMark.excluded);
    final raw = jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>;
    (raw['history'] as List).first['group'] = -1;
    expect(() => PuzzleSession.fromJson(p, raw), throwsFormatException);
    final raw2 = jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>;
    raw2['schemaVersion'] = 1;
    expect(() => PuzzleSession.fromJson(p, raw2), throwsFormatException);
  });
  test(
    '10,000 randomized paint/erase commands restore exactly with one undo',
    () {
      final rng = Random(921);
      for (var run = 0; run < 10000; run++) {
        var s = PuzzleSession.start(p);
        for (var i = 0; i < 4; i++) {
          s = s.tap(
            p,
            rng.nextInt(25),
            rng.nextBool() ? InputMode.mark : InputMode.place,
          );
        }
        final cells = List.generate(30, (_) => rng.nextInt(25));
        final next = s.paintCrosses(
          p,
          cells,
          rng.nextBool() ? CellMark.excluded : CellMark.unknown,
        );
        final loaded = PuzzleSession.fromJson(
          p,
          jsonDecode(jsonEncode(next.toJson())) as Map<String, dynamic>,
        );
        if (!identical(next, s)) expect(loaded.undo(p).marks, s.marks);
      }
    },
  );
}
