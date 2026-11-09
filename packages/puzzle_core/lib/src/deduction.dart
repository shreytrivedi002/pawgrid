import 'definition.dart';
import 'rules.dart';
import 'solver.dart';

class Deduction {
  const Deduction({
    required this.tactic,
    required this.cell,
    required this.mark,
    required this.unit,
    required this.unitIndex,
    this.evidence = const [],
  });
  final String tactic, unit;
  final int cell, unitIndex;
  final CellMark mark;
  final List<int> evidence;
}

class HumanDeductionEngine {
  const HumanDeductionEngine();

  /// Returns only a deduction entailed by the displayed rules and tentative marks.
  /// The exact solver is a consistency guard, never the source of a hint.
  Deduction? next(PuzzleDefinition p, List<CellMark> marks) {
    if (const ExactSolver().solve(p, marks: marks, limit: 1).isEmpty)
      return null;
    final n = p.n;
    final tokens = [
      for (var i = 0; i < marks.length; i++)
        if (marks[i] == CellMark.token) i,
    ];
    final candidates = <int>{};
    for (var i = 0; i < marks.length; i++) {
      if (marks[i] != CellMark.unknown) continue;
      final blockers = tokens
          .where((t) => Rules.incompatible(p, t, i))
          .toList();
      if (blockers.isNotEmpty) {
        return Deduction(
          tactic: 'H1',
          cell: i,
          mark: CellMark.excluded,
          unit: 'creature',
          unitIndex: blockers.first,
          evidence: blockers,
        );
      }
      candidates.add(i);
    }
    final units = <(String, int, Set<int>)>[];
    for (var k = 0; k < n; k++) {
      units.add(('row', k, {for (var c = 0; c < n; c++) k * n + c}));
      units.add(('column', k, {for (var r = 0; r < n; r++) r * n + k}));
      units.add((
        'garden',
        k,
        {
          for (var i = 0; i < n * n; i++)
            if (p.regionAt(i) == k) i,
        },
      ));
    }
    for (final (name, k, cells) in units) {
      if (tokens.any(cells.contains)) continue;
      final options = cells.intersection(candidates);
      if (options.length == 1)
        return Deduction(
          tactic: 'H2',
          cell: options.single,
          mark: CellMark.token,
          unit: name,
          unitIndex: k,
          evidence: options.toList(),
        );
    }
    // H3 and H4: two exact-one units whose remaining candidates are contained
    // in their intersection eliminate candidates in the second unit outside it.
    for (final (aName, aIndex, aCells) in units) {
      if (tokens.any(aCells.contains)) continue;
      final options = aCells.intersection(candidates);
      if (options.isEmpty) continue;
      for (final (bName, _, bCells) in units) {
        if (aName == bName || (aName != 'garden' && bName != 'garden'))
          continue;
        if (!options.every(bCells.contains)) continue;
        final removals = bCells.intersection(candidates).difference(aCells);
        if (removals.isNotEmpty)
          return Deduction(
            tactic: aName == 'garden' ? 'H3' : 'H4',
            cell: removals.first,
            mark: CellMark.excluded,
            unit: aName,
            unitIndex: aIndex,
            evidence: options.toList(),
          );
      }
    }
    // H5 generalized local arc consistency: a candidate needs a compatible
    // partner in every exact-one unit. This uses visible constraints only.
    for (final i in candidates) {
      for (final (name, k, cells) in units) {
        final options = cells.intersection({...candidates, ...tokens});
        if (options.isNotEmpty &&
            options.every((j) => Rules.incompatible(p, i, j))) {
          return Deduction(
            tactic: 'H5',
            cell: i,
            mark: CellMark.excluded,
            unit: name,
            unitIndex: k,
            evidence: options.toList(),
          );
        }
      }
    }
    return null;
  }

  List<Deduction> trace(PuzzleDefinition p, {List<CellMark>? marks}) {
    final state = List<CellMark>.of(marks ?? p.initialMarks());
    final trace = <Deduction>[];
    for (var step = 0; step < p.n * p.n; step++) {
      if (Rules.isWon(p, state)) break;
      final d = next(p, state);
      if (d == null) break;
      trace.add(d);
      state[d.cell] = d.mark;
    }
    return List.unmodifiable(trace);
  }

  bool isDeducible(PuzzleDefinition p) {
    final marks = p.initialMarks();
    for (final d in trace(p)) {
      marks[d.cell] = d.mark;
    }
    return Rules.isWon(p, marks);
  }

  int difficultyScore(PuzzleDefinition p) {
    final steps = trace(p);
    if (!isDeducible(p)) return 100;
    final strongest = steps.fold<int>(1, (v, d) {
      final tactic = int.parse(d.tactic.substring(1));
      return tactic > v ? tactic : v;
    });
    return ((p.n - 4) * 7 + strongest * 8 + steps.length ~/ 8).clamp(0, 99);
  }
}
