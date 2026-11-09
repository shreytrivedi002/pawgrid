import 'definition.dart';

class RuleConflict {
  const RuleConflict(this.code, this.cells);
  final String code;
  final List<int> cells;
}

class Rules {
  static List<RuleConflict> conflicts(
    PuzzleDefinition p,
    List<CellMark> marks,
  ) {
    final tokens = [
      for (var i = 0; i < marks.length; i++)
        if (marks[i] == CellMark.token) i,
    ];
    final found = <RuleConflict>[];
    for (var a = 0; a < tokens.length; a++) {
      for (var b = a + 1; b < tokens.length; b++) {
        final i = tokens[a], j = tokens[b];
        if (i ~/ p.n == j ~/ p.n) found.add(RuleConflict('row', [i, j]));
        if (i % p.n == j % p.n) found.add(RuleConflict('column', [i, j]));
        if (p.regionAt(i) == p.regionAt(j))
          found.add(RuleConflict('region', [i, j]));
        if ((i ~/ p.n - j ~/ p.n).abs() <= 1 &&
            (i % p.n - j % p.n).abs() <= 1) {
          found.add(RuleConflict('touching', [i, j]));
        }
      }
    }
    for (final g in p.givens) {
      final i = g.row * p.n + g.col;
      if (marks[i] != g.mark) found.add(RuleConflict('given', [i]));
    }
    return List.unmodifiable(found);
  }

  static bool incompatible(PuzzleDefinition p, int a, int b) =>
      a != b &&
      (a ~/ p.n == b ~/ p.n ||
          a % p.n == b % p.n ||
          p.regionAt(a) == p.regionAt(b) ||
          ((a ~/ p.n - b ~/ p.n).abs() <= 1 && (a % p.n - b % p.n).abs() <= 1));

  static bool isWon(PuzzleDefinition p, List<CellMark> marks) =>
      marks.length == p.n * p.n &&
      marks.where((m) => m == CellMark.token).length == p.n &&
      conflicts(p, marks).isEmpty;

  static List<String> validateSchema(PuzzleDefinition p) {
    final errors = <String>[];
    if (p.n < 4 || p.n > 9) return ['size'];
    if (p.levelId.isEmpty || p.levelId.length > 80) errors.add('id');
    if (p.rulesetVersion != 'territory-v1') errors.add('ruleset');
    if (p.contentVersion < 1) errors.add('version');
    if (p.regions.length != p.n || p.regions.any((r) => r.length != p.n))
      return [...errors, 'shape'];
    if (p.regions.expand((r) => r).any((r) => r < 0 || r >= p.n))
      return [...errors, 'region ID'];
    for (var region = 0; region < p.n; region++) {
      final cells = {
        for (var i = 0; i < p.n * p.n; i++)
          if (p.regionAt(i) == region) i,
      };
      if (cells.isEmpty) {
        errors.add('missing region');
        continue;
      }
      final visited = <int>{}, queue = [cells.first];
      while (queue.isNotEmpty) {
        final i = queue.removeLast();
        if (!visited.add(i)) continue;
        for (final j in cells) {
          if (!visited.contains(j) &&
              (i ~/ p.n - j ~/ p.n).abs() + (i % p.n - j % p.n).abs() == 1)
            queue.add(j);
        }
      }
      if (visited.length != cells.length) errors.add('disconnected region');
    }
    if (p.solution.length != p.n || p.solution.any((c) => c < 0 || c >= p.n))
      return [...errors, 'solution shape'];
    final indices = <int>{};
    for (final g in p.givens) {
      if (g.row < 0 ||
          g.row >= p.n ||
          g.col < 0 ||
          g.col >= p.n ||
          g.mark == CellMark.unknown)
        errors.add('given bounds');
      if (!indices.add(g.row * p.n + g.col)) errors.add('duplicate given');
    }
    if (errors.any((e) => e == 'given bounds')) return errors;
    final solved = List.filled(p.n * p.n, CellMark.unknown);
    for (var r = 0; r < p.n; r++) {
      solved[r * p.n + p.solution[r]] = CellMark.token;
    }
    for (final g in p.givens.where((g) => g.mark == CellMark.excluded)) {
      final i = g.row * p.n + g.col;
      if (solved[i] == CellMark.token) errors.add('given solution mismatch');
      solved[i] = CellMark.excluded;
    }
    if (!isWon(p, solved)) errors.add('invalid solution');
    if (p.contentHash != p.computedHash) errors.add('hash');
    return List.unmodifiable(errors);
  }
}
