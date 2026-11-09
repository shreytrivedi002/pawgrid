import 'package:puzzle_core/puzzle_core.dart';

/// English is the initial reviewed locale. Rule engine returns stable codes only.
class AppText {
  static const chapters = [
    'Clover Meadow',
    'Fern Hollow',
    'Sunflower Rise',
    'Willow Creek',
    'Lavender Lane',
    'Mushroom Grove',
    'Moonlit Pond',
    'Wildflower Hill',
    'Golden Orchard',
    'Secret Garden',
  ];
  static const chapterNotes = [
    'Every journey begins with a little green.',
    'Find your rhythm among the ferns.',
    'Let a little sunshine in.',
    'Follow the quiet water.',
    'A slower kind of afternoon.',
    'Small wonders, hidden in plain sight.',
    'Make room for a little mystery.',
    'A beautiful tangle of possibilities.',
    'Good things take a little patience.',
    'Your very own pocket of peace.',
  ];
  static const tutorialTitles = [
    'A place for every sprout',
    'A little room to grow',
    'One friend in each garden',
    'Everyone needs their space',
    'Make yourself at home',
  ];
  static const tutorialBodies = [
    'One creature per row. Locked friends are already home. Hold an empty tile to settle another friend.',
    'Each column needs one creature too. Tap a tile to mark ×. Swipe across empty tiles to mark several at once.',
    'Each colored garden, labeled with a letter, needs exactly one creature. Follow the thick garden borders.',
    'Creatures cannot touch, even corner to corner. Distant diagonals are perfectly fine.',
    'Bring the rules together. Tap for ×, hold for a friend. One Undo reverses your whole swipe. Hint explains the next step. There is no rush.',
  ];
  static String placement(PlacementIssue issue, int garden) => switch (issue) {
    PlacementIssue.gardenOccupied =>
      'Garden ${String.fromCharCode(65 + garden)} already has a friend. Remove that friend first.',
    PlacementIssue.fixed => 'This friend is a fixed clue.',
    _ => 'This garden is already complete.',
  };
  static String conflict(String code) => switch (code) {
    'row' => 'These creatures share a row. Each row needs just one.',
    'column' => 'These creatures share a column. Each column needs just one.',
    'region' =>
      'This garden already has a creature. Each garden needs just one.',
    'touching' =>
      'These creatures are touching. Leave a little space, including at corners.',
    _ => 'This is a fixed tutorial cell.',
  };
  static String unit(String type, int index) => type == 'garden'
      ? 'garden ${String.fromCharCode(65 + index)}'
      : '$type ${index + 1}';
  static String hint(Deduction d, PuzzleDefinition p) {
    final location = 'row ${d.cell ~/ p.n + 1}, column ${d.cell % p.n + 1}';
    final name = unit(d.unit, d.unitIndex);
    return switch (d.tactic) {
      'H1' =>
        'A placed creature rules out $location: creatures cannot share a row, column or garden, or touch. You can mark this cell ×.',
      'H2' =>
        'Only one possible home remains in $name: $location. A creature must live here.',
      'H3' =>
        'All remaining homes in $name lie on one line. That line cannot hold a creature in another garden, so $location can be marked ×.',
      'H4' =>
        'Every remaining home in $name belongs to the same garden. The rest of that garden, including $location, can be marked ×.',
      _ =>
        'Every possible home in $name conflicts with $location. Since $name needs a creature, this cell can be marked ×.',
    };
  }
}
