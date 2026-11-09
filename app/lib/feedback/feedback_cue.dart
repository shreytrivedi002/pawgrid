import 'package:puzzle_core/puzzle_core.dart';

enum FeedbackCue { mark, erase, place, swipe, undo, warning, hint, win }

/// Presentation-only classification of committed commands, never an answer check.
FeedbackCue? cueForChange(
  PuzzleDefinition p,
  PuzzleSession before,
  PuzzleSession after,
) {
  if (before.puzzleHash != after.puzzleHash ||
      before.puzzleHash != p.contentHash) {
    return null;
  }
  if (before.moveCount == after.moveCount &&
      before.undoCount == after.undoCount &&
      before.hintCount == after.hintCount) {
    return null;
  }
  if (after.moveCount < before.moveCount ||
      after.undoCount < before.undoCount ||
      after.hintCount < before.hintCount) {
    return null;
  }
  if (Rules.isWon(p, after.marks) && !Rules.isWon(p, before.marks)) {
    return FeedbackCue.win;
  }
  if (after.undoCount > before.undoCount) return FeedbackCue.undo;
  if (after.hintCount > before.hintCount) return FeedbackCue.hint;
  final changed = [
    for (var i = 0; i < after.marks.length; i++)
      if (before.marks[i] != after.marks[i]) i,
  ];
  if (changed.isEmpty) return null;
  if (changed.any((i) => after.marks[i] == CellMark.token)) {
    return Rules.conflicts(p, after.marks).isEmpty
        ? FeedbackCue.place
        : FeedbackCue.warning;
  }
  if (changed.length > 1 &&
      changed.any((i) => after.marks[i] == CellMark.excluded)) {
    return FeedbackCue.swipe;
  }
  return after.marks[changed.first] == CellMark.excluded
      ? FeedbackCue.mark
      : FeedbackCue.erase;
}
