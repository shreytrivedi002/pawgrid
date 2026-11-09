import 'definition.dart';
import 'rules.dart';

enum PlacementIssue { outside, fixed, finished, gardenOccupied }

/// Enforces garden capacity while other conflicts remain tentative warnings.
/// Does not change territory-v1 or a puzzle's canonical definition.
class PlacementPolicy {
  const PlacementPolicy();
  static const version = 'garden-capacity-v1';
  PlacementIssue? check(PuzzleDefinition p, List<CellMark> marks, int cell) {
    if (cell < 0 || cell >= p.n * p.n) return PlacementIssue.outside;
    if (p.isGiven(cell)) return PlacementIssue.fixed;
    if (Rules.isWon(p, marks)) return PlacementIssue.finished;
    // Removal of an old tentative companion is always available.
    if (marks[cell] == CellMark.token) return null;
    final tokens = [
      for (var i = 0; i < marks.length; i++)
        if (marks[i] == CellMark.token) i,
    ];
    if (tokens.any((i) => p.regionAt(i) == p.regionAt(cell)))
      return PlacementIssue.gardenOccupied;
    return null;
  }
}
