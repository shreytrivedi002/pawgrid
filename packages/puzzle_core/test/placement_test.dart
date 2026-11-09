import 'dart:convert';
import 'dart:io';
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
  test(
    'non-answer tile is allowed, even when the guess leads to a dead end',
    () {
      final s = PuzzleSession.start(p);
      expect(p.solution[0], isNot(0));
      expect(const PlacementPolicy().check(p, s.marks, 0), isNull);
      final accepted = s.placeCreature(p, 0);
      expect(accepted.marks[0], CellMark.token);
      expect(accepted.moveCount, 1);
      expect(Rules.conflicts(p, accepted.marks), isEmpty);
      expect(const ExactSolver().solve(p, marks: accepted.marks), isEmpty);
      expect(s.tap(p, 0, InputMode.place).marks, accepted.marks);
      expect(accepted.undo(p).marks, s.marks);
      expect(accepted.placeCreature(p, 0).marks, s.marks);
    },
  );
  test(
    'a garden cannot accept a second companion and rejection is non-destructive',
    () {
      final s = PuzzleSession.start(p).placeCreature(p, 1);
      expect(
        const PlacementPolicy().check(p, s.marks, 5),
        PlacementIssue.gardenOccupied,
      );
      expect(identical(s.placeCreature(p, 5), s), true);
      expect(s.marks.where((m) => m == CellMark.token).length, 1);
      expect(s.placeCreature(p, 1).marks[1], CellMark.unknown);
    },
  );
  test(
    'row, column and touching conflicts remain placed with detectable warnings',
    () {
      final s = PuzzleSession.start(p).placeCreature(p, 1);
      for (final (cell, code) in [
        (3, 'row'),
        (11, 'column'),
        (7, 'touching'),
      ]) {
        expect(const PlacementPolicy().check(p, s.marks, cell), isNull);
        final placed = s.placeCreature(p, cell);
        expect(placed.marks[cell], CellMark.token);
        expect(placed.moveCount, s.moveCount + 1);
        expect(
          Rules.conflicts(p, placed.marks).map((c) => c.code),
          contains(code),
        );
        expect(PuzzleSession.fromJson(p, placed.toJson()).marks, placed.marks);
        expect(placed.undo(p).marks, s.marks);
        expect(placed.placeCreature(p, cell).marks, s.marks);
      }
    },
  );
  test('legacy tentative marks load unchanged and can be removed', () {
    final old = PuzzleSession.start(
      p,
    ).change(p, 0, CellMark.token).change(p, 5, CellMark.token);
    final loaded = PuzzleSession.fromJson(p, old.toJson());
    expect(loaded.marks, old.marks);
    expect(loaded.placeCreature(p, 0).marks[0], CellMark.unknown);
    expect(loaded.placeCreature(p, 5).marks[5], CellMark.unknown);
    expect(identical(loaded.placeCreature(p, 1), loaded), true);
  });
  test('all 298 boards precheck only garden capacity and still solve', () {
    final pack =
        jsonDecode(File('../../content/catalog.json').readAsStringSync())
            as Map;
    for (final json in pack['levels'] as List) {
      final q = PuzzleDefinition.fromJson(
        (json as Map).cast<String, dynamic>(),
      );
      var s = PuzzleSession.start(q);
      for (var cell = 0; cell < q.n * q.n; cell++) {
        if (q.isGiven(cell)) continue;
        final gardenFree = !List.generate(q.n * q.n, (i) => i).any(
          (i) =>
              s.marks[i] == CellMark.token && q.regionAt(i) == q.regionAt(cell),
        );
        expect(
          const PlacementPolicy().check(q, s.marks, cell) == null,
          gardenFree,
          reason: '${q.levelId} cell $cell',
        );
      }
      for (var r = 0; r < q.n; r++) {
        final cell = r * q.n + q.solution[r];
        if (q.isGiven(cell)) continue;
        s = s.placeCreature(q, cell);
        for (var garden = 0; garden < q.n; garden++) {
          expect(
            [
              for (var i = 0; i < s.marks.length; i++)
                if (s.marks[i] == CellMark.token && q.regionAt(i) == garden) i,
            ].length,
            lessThanOrEqualTo(1),
          );
        }
      }
      expect(Rules.isWon(q, s.marks), true, reason: q.levelId);
    }
  });
  test('every exploratory pair is blocked only by garden capacity', () {
    final initial = PuzzleSession.start(p);
    for (var first = 0; first < p.n * p.n; first++) {
      final s = initial.placeCreature(p, first);
      for (var next = 0; next < p.n * p.n; next++) {
        if (next == first) continue;
        final legal = p.regionAt(first) != p.regionAt(next);
        expect(
          const PlacementPolicy().check(p, s.marks, next) == null,
          legal,
          reason: 'exploration $first -> $next',
        );
        final result = s.placeCreature(p, next);
        expect(
          legal ? result.marks[next] == CellMark.token : identical(result, s),
          true,
        );
      }
    }
  });
  test(
    'a full set of companions with line or touching conflicts cannot win',
    () {
      var s = PuzzleSession.start(p);
      for (final cell in [0, 2, 7, 10, 18]) {
        s = s.placeCreature(p, cell);
      }
      expect(s.marks.where((m) => m == CellMark.token).length, p.n);
      expect(Rules.conflicts(p, s.marks), isNotEmpty);
      expect(Rules.isWon(p, s.marks), false);
      expect(const HumanDeductionEngine().next(p, s.marks), isNull);
    },
  );
}
