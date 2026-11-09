import 'package:flutter/material.dart';
import 'package:puzzle_core/puzzle_core.dart';
import '../state/app_controller.dart';
import 'design.dart';

/// Authored coaching for the unchanged, prevalidated first Journey board.
class FirstGarden {
  static bool active(AppState state, PuzzleDefinition p) =>
      p.levelId == 'journey-001' &&
      p.contentHash ==
          'e5f23c9f5a4add9664a22d116d2c6356ba0746ce525e33f0280074e7242b96af' &&
      state.game?.mode == 'journey' &&
      state.game?.levelId == p.levelId &&
      !state.enabled('firstGardenSkipped') &&
      !state.enabled('tutorialSeen') &&
      !state.progress.containsKey(p.levelId);
  static int step(AppState state) =>
      ((state.settings['firstGardenStep'] as int?) ?? 0).clamp(0, 5);
  static int advance(int step, PuzzleSession s) => switch (step) {
    1 when s.marks[0] == CellMark.excluded => 2,
    2 when s.marks[2] == CellMark.excluded && s.marks[3] == CellMark.excluded =>
      3,
    3
        when s.undoCount > 0 &&
            s.marks[2] == CellMark.unknown &&
            s.marks[3] == CellMark.unknown =>
      4,
    4 when s.marks[8] == CellMark.token => 5,
    _ => step,
  };
  static Set<int> targets(int step) => switch (step) {
    1 => {0},
    2 => {2, 3},
    4 => {8},
    5 => {14},
    _ => {},
  };
  static const titles = [
    'Your first little garden',
    '1/5 · Tap to mark ×',
    '2/5 · Swipe to mark a row',
    '3/5 · Try Undo',
    '4/5 · Hold to settle a friend',
    '5/5 · Bring the last friend home',
  ];
  static const bodies = [
    'Let’s learn by playing! Two locked friends are already home. We’ll find homes for two more.',
    'Row 1 already has a friend. Tap the gold-outlined tile (row 1, column 1) to mark it ×.',
    'The rest of row 1 is empty. Slide across the two gold-outlined tiles to mark both ×.',
    'Tap Undo below. Your whole swipe disappears together. You can always rethink a move.',
    'Hold the gold-outlined tile in row 3, column 1. Other columns share a friend’s column or touch a friend.',
    'Hold row 4, column 3. One friend per row, column and lettered garden. Friends cannot touch, even at corners.',
  ];
}

class FirstGardenCard extends StatelessWidget {
  const FirstGardenCard({
    super.key,
    required this.step,
    required this.onStart,
    required this.onSkip,
    this.compact = false,
  });
  final bool compact;
  final int step;
  final VoidCallback onStart, onSkip;
  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Semantics(
        liveRegion: true,
        label: '${FirstGarden.titles[step]}. ${FirstGarden.bodies[step]}',
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  const [
                    'Learn to play',
                    'Tap ×: row 1, col 1',
                    'Swipe: row 1, col 3 to 4',
                    'Tap Undo below',
                    'Hold: row 3, col 1',
                    'Hold: row 4, col 3',
                  ][step],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (step == 0)
                TextButton(
                  key: const ValueKey('start-lesson'),
                  onPressed: onStart,
                  child: const Text('Start'),
                ),
              IconButton(
                tooltip: 'Read tutorial instruction',
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(FirstGarden.titles[step]),
                    content: SingleChildScrollView(
                      child: Text(FirstGarden.bodies[step]),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.help_outline_rounded),
              ),
              IconButton(
                key: const ValueKey('skip-lesson'),
                tooltip: 'Skip guide',
                onPressed: onSkip,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      );
    }
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('first-garden-coach'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF303448),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF687449)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FirstGarden.titles[step],
              style: const TextStyle(
                fontSize: 14,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: ink,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              FirstGarden.bodies[step],
              style: const TextStyle(fontSize: 12, height: 1.15, color: ink),
            ),
            Row(
              children: [
                if (step == 0)
                  TextButton(
                    key: const ValueKey('start-lesson'),
                    onPressed: onStart,
                    child: const Text('Let’s play'),
                  ),
                const Spacer(),
                TextButton(
                  key: const ValueKey('skip-lesson'),
                  onPressed: onSkip,
                  child: const Text('Skip guide'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
