import 'definition.dart';
import 'rules.dart';

class ExactSolver {
  const ExactSolver();
  List<List<int>> solve(
    PuzzleDefinition p, {
    List<CellMark>? marks,
    int limit = 2,
  }) {
    if (limit < 1) throw ArgumentError.value(limit);
    final state = marks ?? p.initialMarks();
    if (state.length != p.n * p.n || Rules.conflicts(p, state).isNotEmpty)
      return [];
    final solutions = <List<int>>[], path = <int>[];
    void search(int row, int columns, int regions, int previous) {
      if (solutions.length >= limit) return;
      if (row == p.n) {
        solutions.add(List.unmodifiable(path));
        return;
      }
      final fixed = [
        for (var c = 0; c < p.n; c++)
          if (state[row * p.n + c] == CellMark.token) c,
      ];
      for (var col = 0; col < p.n; col++) {
        final region = p.regions[row][col];
        if ((fixed.isNotEmpty && fixed.single != col) ||
            state[row * p.n + col] == CellMark.excluded ||
            (columns & (1 << col)) != 0 ||
            (regions & (1 << region)) != 0 ||
            (row > 0 && (previous - col).abs() <= 1))
          continue;
        path.add(col);
        search(row + 1, columns | (1 << col), regions | (1 << region), col);
        path.removeLast();
        if (solutions.length >= limit) break;
      }
    }

    search(0, 0, 0, -1);
    return List.unmodifiable(solutions);
  }

  List<String> validate(PuzzleDefinition p) {
    final errors = Rules.validateSchema(p);
    if (errors.isNotEmpty) return errors;
    final solutions = solve(p);
    if (solutions.length != 1) return ['not unique'];
    if (solutions.single.join(',') != p.solution.join(','))
      return ['solution mismatch'];
    return [];
  }
}
