import 'definition.dart';
import 'rules.dart';
import 'placement.dart';

enum InputMode { mark, place }

class CellChange {
  const CellChange(this.cell, this.before, this.after, {this.group});
  final int? group;
  final int cell;
  final CellMark before, after;
  Map<String, dynamic> toJson() => {
    'cell': cell,
    'before': before.index,
    'after': after.index,
    if (group != null) 'group': group,
  };
  factory CellChange.fromJson(Map<String, dynamic> j) => CellChange(
    j['cell'] as int,
    CellMark.values[j['before'] as int],
    CellMark.values[j['after'] as int],
    group: j['group'] as int?,
  );
}

class PuzzleSession {
  PuzzleSession({
    required this.puzzleHash,
    required List<CellMark> marks,
    List<CellChange> history = const [],
    this.moveCount = 0,
    this.undoCount = 0,
    this.hintCount = 0,
    this.activeMs = 0,
  }) : marks = List.unmodifiable(marks),
       history = List.unmodifiable(history);
  factory PuzzleSession.start(PuzzleDefinition p) =>
      PuzzleSession(puzzleHash: p.contentHash, marks: p.initialMarks());
  final String puzzleHash;
  final List<CellMark> marks;
  final List<CellChange> history;
  final int moveCount, undoCount, hintCount, activeMs;

  PuzzleSession change(
    PuzzleDefinition p,
    int cell,
    CellMark mark, {
    bool hint = false,
  }) {
    if (p.contentHash != puzzleHash) throw StateError('Puzzle hash mismatch');
    if (cell < 0 ||
        cell >= marks.length ||
        p.isGiven(cell) ||
        marks[cell] == mark ||
        Rules.isWon(p, marks))
      return this;
    final next = List<CellMark>.of(marks)..[cell] = mark;
    return PuzzleSession(
      puzzleHash: puzzleHash,
      marks: next,
      history: [...history, CellChange(cell, marks[cell], mark)],
      moveCount: moveCount + 1,
      undoCount: undoCount,
      hintCount: hintCount + (hint ? 1 : 0),
      activeMs: activeMs,
    );
  }

  PuzzleSession tap(PuzzleDefinition p, int cell, InputMode mode) {
    if (mode == InputMode.place) return placeCreature(p, cell);
    if (cell < 0 || cell >= marks.length) return this;
    return change(
      p,
      cell,
      marks[cell] == CellMark.excluded ? CellMark.unknown : CellMark.excluded,
    );
  }

  PuzzleSession placeCreature(PuzzleDefinition p, int cell) {
    if (const PlacementPolicy().check(p, marks, cell) != null) return this;
    return change(
      p,
      cell,
      marks[cell] == CellMark.token ? CellMark.unknown : CellMark.token,
    );
  }

  /// A drag paints a fixed value, never toggles repeatedly when revisiting.
  /// Existing creatures and givens are protected. One stroke is one command.
  PuzzleSession paintCrosses(
    PuzzleDefinition p,
    Iterable<int> cells,
    CellMark mark,
  ) {
    if (p.contentHash != puzzleHash) throw StateError('Puzzle hash mismatch');
    if (mark == CellMark.token)
      throw ArgumentError('A cross stroke cannot place creatures');
    if (Rules.isWon(p, marks)) return this;
    final next = List<CellMark>.of(marks), changes = <CellChange>[];
    final visited = <int>{}, group = moveCount + 1;
    for (final cell in cells) {
      if (!visited.add(cell) ||
          cell < 0 ||
          cell >= marks.length ||
          p.isGiven(cell) ||
          marks[cell] == CellMark.token ||
          marks[cell] == mark)
        continue;
      changes.add(CellChange(cell, marks[cell], mark, group: group));
      next[cell] = mark;
    }
    if (changes.isEmpty) return this;
    return PuzzleSession(
      puzzleHash: puzzleHash,
      marks: next,
      history: [...history, ...changes],
      moveCount: moveCount + 1,
      undoCount: undoCount,
      hintCount: hintCount,
      activeMs: activeMs,
    );
  }

  PuzzleSession undo(PuzzleDefinition p) {
    if (history.isEmpty || Rules.isWon(p, marks)) return this;
    final group = history.last.group, next = List<CellMark>.of(marks);
    var boundary = history.length - 1;
    if (group != null) {
      while (boundary > 0 && history[boundary - 1].group == group) {
        boundary--;
      }
    }
    for (var i = history.length - 1; i >= boundary; i--) {
      next[history[i].cell] = history[i].before;
    }
    return PuzzleSession(
      puzzleHash: puzzleHash,
      marks: next,
      history: history.sublist(0, boundary),
      moveCount: moveCount,
      undoCount: undoCount + 1,
      hintCount: hintCount,
      activeMs: activeMs,
    );
  }

  PuzzleSession withTime(int elapsed) => PuzzleSession(
    puzzleHash: puzzleHash,
    marks: marks,
    history: history,
    moveCount: moveCount,
    undoCount: undoCount,
    hintCount: hintCount,
    activeMs: elapsed,
  );

  Map<String, dynamic> toJson() => {
    'schemaVersion': 2,
    'puzzleHash': puzzleHash,
    'marks': marks.map((m) => m.index).toList(),
    'history': history.map((m) => m.toJson()).toList(),
    'moveCount': moveCount,
    'undoCount': undoCount,
    'hintCount': hintCount,
    'activeMs': activeMs,
  };
  factory PuzzleSession.fromJson(PuzzleDefinition p, Map<String, dynamic> j) {
    if ((j['schemaVersion'] != 1 && j['schemaVersion'] != 2) ||
        j['puzzleHash'] != p.contentHash)
      throw const FormatException('Incompatible save');
    final marks = (j['marks'] as List)
        .map((v) => CellMark.values[v as int])
        .toList();
    if (marks.length != p.n * p.n)
      throw const FormatException('Save board size');
    for (final g in p.givens) {
      if (marks[g.row * p.n + g.col] != g.mark)
        throw const FormatException('Altered given');
    }
    final history = (j['history'] as List)
        .map((h) => CellChange.fromJson((h as Map).cast<String, dynamic>()))
        .toList();
    final replay = p.initialMarks();
    final closedGroups = <int>{}, groupCells = <int>{};
    int? activeGroup;
    for (final h in history) {
      if (h.group != activeGroup) {
        if (activeGroup != null) closedGroups.add(activeGroup);
        groupCells.clear();
        activeGroup = h.group;
      }
      if (h.group != null &&
          (j['schemaVersion'] == 1 ||
              h.group! <= 0 ||
              h.group! > (j['moveCount'] as int) ||
              closedGroups.contains(h.group) ||
              !groupCells.add(h.cell))) {
        throw const FormatException('Invalid stroke group');
      }
      if (h.cell < 0 ||
          h.cell >= marks.length ||
          p.isGiven(h.cell) ||
          replay[h.cell] != h.before)
        throw const FormatException('Invalid history');
      replay[h.cell] = h.after;
    }
    if (replay.asMap().entries.any((e) => marks[e.key] != e.value))
      throw const FormatException('History does not match board');
    final activeMs = j['activeMs'] as int;
    if (activeMs < 0) throw const FormatException('Negative clock');
    return PuzzleSession(
      puzzleHash: p.contentHash,
      marks: marks,
      history: history,
      moveCount: j['moveCount'] as int,
      undoCount: j['undoCount'] as int,
      hintCount: j['hintCount'] as int,
      activeMs: activeMs,
    );
  }
}
