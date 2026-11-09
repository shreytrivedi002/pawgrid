import 'dart:convert';
import 'package:crypto/crypto.dart';

enum CellMark { unknown, excluded, token }

class GivenCell {
  const GivenCell(this.row, this.col, this.mark);
  final int row, col;
  final CellMark mark;
  Map<String, Object> toJson() => {
    'col': col,
    'mark': mark == CellMark.token ? 'Token' : 'Excluded',
    'row': row,
  };
}

class PuzzleDefinition {
  PuzzleDefinition({
    required this.levelId,
    required this.n,
    required List<List<int>> regions,
    required List<int> solution,
    List<GivenCell> givens = const [],
    this.contentVersion = 1,
    this.rulesetVersion = 'territory-v1',
    this.difficulty = 'easy',
    this.difficultyScore = 10,
    required this.contentHash,
    this.targetSeconds = 180,
  }) : regions = List.unmodifiable(
         regions.map((r) => List<int>.unmodifiable(r)),
       ),
       solution = List.unmodifiable(solution),
       givens = List.unmodifiable(givens);

  factory PuzzleDefinition.fromJson(Map<String, dynamic> j) => PuzzleDefinition(
    levelId: j['levelId'] as String,
    n: j['n'] as int,
    regions: (j['regions'] as List)
        .map((r) => (r as List).cast<int>())
        .toList(),
    solution: (j['solutionColumnsByRow'] as List).cast<int>(),
    givens: (j['givens'] as List).map((g) {
      if (g['mark'] != 'Token' && g['mark'] != 'Excluded') {
        throw const FormatException('Unknown given mark');
      }
      return GivenCell(
        g['row'] as int,
        g['col'] as int,
        g['mark'] == 'Token' ? CellMark.token : CellMark.excluded,
      );
    }).toList(),
    contentVersion: j['contentVersion'] as int,
    rulesetVersion: j['rulesetVersion'] as String,
    difficulty: j['difficulty'] as String,
    difficultyScore: j['difficultyScore'] as int,
    contentHash: j['contentHash'] as String,
    targetSeconds: j['targetSeconds'] as int? ?? 180,
  );

  final String levelId, rulesetVersion, difficulty, contentHash;
  final int n, contentVersion, difficultyScore, targetSeconds;
  final List<List<int>> regions;
  final List<int> solution;
  final List<GivenCell> givens;
  int regionAt(int index) => regions[index ~/ n][index % n];
  bool isGiven(int index) => givens.any((g) => g.row * n + g.col == index);
  List<CellMark> initialMarks() {
    final marks = List.filled(n * n, CellMark.unknown);
    for (final g in givens) {
      marks[g.row * n + g.col] = g.mark;
    }
    return marks;
  }

  Map<String, Object> get canonicalFields => {
    'contentVersion': contentVersion,
    'givens': givens.map((g) => g.toJson()).toList(),
    'levelId': levelId,
    'n': n,
    'regions': regions,
    'rulesetVersion': rulesetVersion,
    'solutionColumnsByRow': solution,
  };
  String get computedHash =>
      sha256.convert(utf8.encode(jsonEncode(canonicalFields))).toString();
}
