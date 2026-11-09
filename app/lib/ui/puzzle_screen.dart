import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puzzle_core/puzzle_core.dart';
import '../state/app_controller.dart';
import '../l10n/strings.dart';
import 'art.dart';
import 'game_scenery.dart';
import 'contour.dart';
import 'board_effects.dart';
import 'board.dart';
import 'design.dart';
import 'settings_screen.dart';
import 'first_garden.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key, this.replay = false});
  final bool replay;
  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _allowPop = false;
  int? _hintCell;
  bool _lessonSaving = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => ref.read(appProvider.notifier).tick(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      ref.read(appProvider.notifier).pause(true);
    }
  }

  Future<void> _exit() async {
    await ref.read(appProvider.notifier).pause(true);
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _reset() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start this garden again?'),
        content: const Text(
          'Your marks and timer will reset. Your earned rewards and finished gardens stay safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep playing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start again'),
          ),
        ],
      ),
    );
    if (accepted == true && mounted) {
      final game = ref.read(appProvider).game!;
      await ref
          .read(appProvider.notifier)
          .open(game.levelId, game.mode, restart: true);
      if (mounted) setState(() => _hintCell = null);
    }
  }

  Future<void> _help() async {
    await ref.read(appProvider.notifier).pause(true);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 4, 26, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('A few gentle rules'),
              const SizedBox(height: 10),
              Text(
                'Room for everyone.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 22),
              for (final item in <(IconData, String, String)>[
                (
                  Icons.table_rows_outlined,
                  'One in each row',
                  'Every horizontal row gets exactly one creature.',
                ),
                (
                  Icons.view_column_outlined,
                  'One in each column',
                  'Every vertical column gets exactly one creature.',
                ),
                (
                  Icons.filter_vintage_outlined,
                  'One in each garden',
                  'Every lettered garden, inside its thick border, gets one.',
                ),
                (
                  Icons.open_with_rounded,
                  'A little breathing room',
                  'Creatures cannot touch, including at corners. Distant diagonals are allowed.',
                ),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sage,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.$1, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$2,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(item.$3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const Text(
                'Tap to mark ×, hold to place a companion, and swipe to paint or erase crosses. Each garden accepts one friend. You can try placements that share a row, column or touch: warning marks explain the conflict while your companions stay put. To finish, settle one friend per row, column and garden, with no touching. Hold a friend again to remove it, or use Undo to rethink. Screen-reader Actions or keyboard P can place without holding.',
              ),
              const SizedBox(height: 24),
              GardenButton('Got it', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
    if (mounted) await ref.read(appProvider.notifier).pause(false);
  }

  Future<void> _hint() async {
    final controller = ref.read(appProvider.notifier), p = controller.puzzle!;
    await controller.pause(true);
    final marks = ref.read(appProvider).game!.session.marks;
    final d = const HumanDeductionEngine().next(p, marks);
    if (!mounted) return;
    setState(() => _hintCell = d?.cell);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: green),
                  SizedBox(width: 9),
                  Eyebrow('A little nudge • free'),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                d == null ? 'Let’s retrace a step.' : 'Here’s the reasoning.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                d == null
                    ? 'These tentative marks leave no complete arrangement, or the simple deductions are exhausted. Try Undo or clear a tentative mark. Your choices will stay on the board.'
                    : AppText.hint(d, p),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (d != null) ...[
                const SizedBox(height: 15),
                const Tag('Explained by the garden rules'),
              ],
              const SizedBox(height: 24),
              GardenButton(
                d == null
                    ? 'Back to my garden'
                    : d.mark == CellMark.token
                    ? 'Place this creature'
                    : 'Mark this cell ×',
                onPressed: () async {
                  if (d != null) await controller.applyHint(d);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              if (d != null)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Center(child: Text('I’ll work it out')),
                ),
            ],
          ),
        ),
      ),
    );
    if (mounted) await controller.pause(false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier),
        game = state.game;
    if (game == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final p = controller.catalog.levels[game.levelId]!, session = game.session;
    ref.listen<AppState>(appProvider, (previous, next) {
      if (_lessonSaving ||
          next.busy ||
          next.game == null ||
          !FirstGarden.active(next, p)) {
        return;
      }
      final step = FirstGarden.step(next);
      final advanced = FirstGarden.advance(step, next.game!.session);
      if (advanced != step) {
        _lessonSaving = true;
        controller
            .setting('firstGardenStep', advanced)
            .whenComplete(() => _lessonSaving = false);
      }
    });
    final index = controller.catalog.journey.indexOf(p.levelId),
        chapter = math.max(0, index) ~/ 20;
    final won = Rules.isWon(p, session.marks);
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.pause(true);
      },
      child: Scaffold(
        body: Stack(
          children: [
            const GardenBackdrop(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final scale = MediaQuery.textScalerOf(context).scale(1),
                      compact = bounds.maxHeight < 690 || scale > 1.35;
                  final landscape =
                      bounds.maxWidth > bounds.maxHeight * 1.2 &&
                      bounds.maxWidth > 520;
                  final tools = _tools(compact: compact);
                  final status = _status(p, index, compact: compact);
                  final inspector = state.enabled('cellControls')
                      ? _cellControls(p)
                      : const SizedBox.shrink();
                  return Stack(
                    children: [
                      if (won)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _completion(p, index, compact: compact),
                        )
                      else
                        Padding(
                          key: const ValueKey('playfield'),
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 12 : 20,
                            vertical: 8,
                          ),
                          child: landscape
                              ? Row(
                                  children: [
                                    Expanded(child: _boardArea(p, session)),
                                    const SizedBox(width: 18),
                                    SizedBox(
                                      width: 260,
                                      child: Column(
                                        children: [
                                          _topBar(chapter, game.mode),
                                          _hud(p, index, compact: true),
                                          const Spacer(),
                                          status,
                                          inspector,
                                          const SizedBox(height: 8),
                                          tools,
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _topBar(chapter, game.mode),
                                    _hud(p, index, compact: compact),
                                    Expanded(child: _boardArea(p, session)),
                                    status,
                                    inspector,
                                    const SizedBox(height: 6),
                                    tools,
                                    if (!compact)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Text(
                                          'One per row, column & garden. No touching.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: muted,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      if (state.paused && !won)
                        Positioned.fill(
                          child: ColoredBox(
                            color: paper.withValues(alpha: .98),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 380,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (bounds.maxHeight > 600)
                                        Sprout(
                                          size: compact ? 55 : 90,
                                          variant: state.equipped,
                                          sleeping: true,
                                        ),
                                      Text(
                                        compact
                                            ? 'Paused'
                                            : 'Take a little breath.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: compact ? 20 : 28,
                                          height: 1,
                                          fontWeight: FontWeight.w900,
                                          color: ink,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      GardenButton(
                                        compact ? 'Resume' : 'Keep growing',
                                        icon: compact
                                            ? null
                                            : Icons.play_arrow_rounded,
                                        onPressed: () =>
                                            controller.pause(false),
                                      ),
                                      const SizedBox(height: 10),
                                      GardenButton(
                                        compact ? 'Home' : 'Back to garden',
                                        secondary: true,
                                        onPressed: _exit,
                                      ),
                                      TextButton(
                                        onPressed: _reset,
                                        child: Text(
                                          compact
                                              ? 'Restart'
                                              : 'Start this level again',
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const SettingsScreen(),
                                          ),
                                        ),
                                        child: const Text('Settings'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(int chapter, String mode) => SizedBox(
    height: 44,
    child: Row(
      children: [
        IconButton(
          tooltip: 'Pause and go back',
          onPressed: () => ref.read(appProvider.notifier).pause(true),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Text(
            mode == 'journey'
                ? AppText.chapters[chapter]
                : mode == 'daily'
                ? 'Daily Garden'
                : 'Practice',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: green,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Pause game',
          onPressed: () => ref.read(appProvider.notifier).pause(true),
          icon: const Icon(Icons.pause_rounded),
        ),
      ],
    ),
  );

  Widget _hud(PuzzleDefinition p, int index, {required bool compact}) {
    final state = ref.watch(appProvider), game = state.game!;
    final count = game.session.marks.where((m) => m == CellMark.token).length;
    final label = game.mode == 'journey'
        ? 'Level ${(index + 1).toString().padLeft(2, '0')}'
        : game.mode == 'daily'
        ? 'Daily Garden'
        : 'Find your flow';
    return SizedBox(
      height: compact ? 52 : 76,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: '$label, ${p.difficulty}, ${p.n} by ${p.n}',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    key: const ValueKey('level-title'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: compact ? 22 : 30,
                      fontWeight: FontWeight.w900,
                      color: ink,
                      height: 1.05,
                    ),
                  ),
                  if (!compact)
                    Text(
                      '${p.difficulty[0].toUpperCase() + p.difficulty.substring(1)} · ${p.n} × ${p.n}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ReactiveBuddy(
            count: count,
            variant: state.equipped,
            rejectionSequence: state.placementFeedback?.sequence ?? 0,
            size: compact ? 38 : 52,
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count / ${p.n}',
                semanticsLabel: '$count of ${p.n} companions at home',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: ink,
                ),
              ),
              Text(
                timeLabel(game.session.activeMs),
                style: const TextStyle(fontSize: 11, height: 1, color: muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boardArea(PuzzleDefinition p, PuzzleSession session) => LayoutBuilder(
    builder: (context, bounds) {
      final state = ref.watch(appProvider),
          controller = ref.read(appProvider.notifier);
      final lesson = FirstGarden.active(state, p),
          step = FirstGarden.step(state);
      final scale = MediaQuery.textScalerOf(context).scale(1),
          guideHeight = scale > 1.35 ? 52.0 : 42.0;
      final coach = lesson
          ? FirstGardenCard(
              compact: scale > 1.35 || bounds.maxHeight < 310,
              step: step,
              onStart: () => controller.setting('firstGardenStep', 1),
              onSkip: () => controller.setting('firstGardenSkipped', true),
            )
          : null;
      // Let the text choose its own height; the board takes the remaining room.
      if (lesson) {
        return Column(
          children: [
            coach!,
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PuzzleBoard(
                    puzzle: p,
                    session: session,
                    hintCell: _hintCell,
                    lessonCells: FirstGarden.targets(step),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }
      final side = math.max(
        40.0,
        math.min(bounds.maxWidth, bounds.maxHeight - guideHeight - 16),
      );
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: const ValueKey('gesture-guide'),
              width: side,
              height: guideHeight,
              child: const GestureGuide(),
            ),
            const SizedBox(height: 8),
            SizedBox.square(
              key: const ValueKey('board-frame'),
              dimension: side,
              child: TickerMode(
                enabled: !ref.watch(appProvider).paused,
                child: PuzzleBoard(
                  puzzle: p,
                  session: session,
                  hintCell: _hintCell,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  Widget _status(PuzzleDefinition p, int index, {required bool compact}) {
    final state = ref.watch(appProvider), feedback = state.placementFeedback;
    final conflicts = Rules.conflicts(p, state.game!.session.marks);
    final tutorial =
        state.game!.mode == 'journey' &&
        index >= 0 &&
        index < 5 &&
        !state.enabled('tutorialSeen');
    final message =
        state.error ??
        (feedback != null
            ? AppText.placement(
                feedback.issue,
                p.regionAt(feedback.cell.clamp(0, p.n * p.n - 1)),
              )
            : conflicts.isNotEmpty
            ? AppText.conflict(conflicts.first.code)
            : tutorial
            ? AppText.tutorialTitles[index]
            : 'One friend per garden. Hold to find their home.');
    final hasWarning =
        state.error != null || feedback != null || conflicts.isNotEmpty;
    return SizedBox(
      height: compact ? 52 : 58,
      child: Semantics(
        liveRegion: hasWarning,
        label: message,
        child: Tooltip(
          message: message,
          child: Center(
            child: AnimatedSwitcher(
              duration: Duration(
                milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 180,
              ),
              child: Text(
                message,
                key: ValueKey('${feedback?.sequence}:$message'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.05,
                  color: hasWarning ? warning : green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tools({required bool compact}) {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier);
    return SizedBox(
      height: MediaQuery.textScalerOf(context).scale(1) > 1.4
          ? 90
          : compact
          ? 66
          : 78,
      child: Row(
        children: [
          Expanded(
            child: _tool(
              Icons.undo_rounded,
              'Undo',
              state.game!.session.history.isEmpty ? null : controller.undo,
              compact: compact,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _tool(
              Icons.lightbulb_outline_rounded,
              'Hint',
              _hint,
              compact: compact,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _tool(
              Icons.menu_book_outlined,
              'Rules',
              _help,
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tool(
    IconData icon,
    String label,
    VoidCallback? onPressed, {
    required bool compact,
  }) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      side: const BorderSide(color: line, width: 2),
      backgroundColor: label == 'Hint' ? const Color(0xFF383C32) : panel,
      elevation: 0,
      shadowColor: const Color(0x4411121D),
      foregroundColor: ink,
      shape: const GardenOutline(),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 20 : 24),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    ),
  );

  Widget _cellControls(PuzzleDefinition p) {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier),
        cell = state.selectedCell.clamp(0, p.n * p.n - 1);
    return SizedBox(
      height: 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: 'Previous cell',
            onPressed: () =>
                controller.selectCell((cell - 1 + p.n * p.n) % (p.n * p.n)),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              'R${cell ~/ p.n + 1} C${cell % p.n + 1}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            tooltip: 'Next cell',
            onPressed: () => controller.selectCell((cell + 1) % (p.n * p.n)),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          IconButton(
            tooltip: 'Place or remove selected companion',
            onPressed: () => controller.placeCreature(cell),
            icon: const Icon(Icons.spa_outlined),
          ),
          IconButton(
            tooltip: 'Mark or remove selected cross',
            onPressed: () => controller.tap(cell),
            icon: const Icon(Icons.close_rounded),
          ),
          IconButton(
            tooltip: 'Clear selected cell',
            onPressed: () => controller.clearCell(cell),
            icon: const Icon(Icons.backspace_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _completion(PuzzleDefinition p, int index, {required bool compact}) {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier),
        game = state.game!,
        session = game.session;
    final stars =
        1 +
        (session.hintCount == 0 ? 1 : 0) +
        (session.activeMs < p.targetSeconds * 1000 ? 1 : 0);
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          'Everyone’s home.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 20 : 34,
            fontWeight: FontWeight.w900,
            color: ink,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GardenCelebration(creature: state.equipped),
            ),
          ),
        ),
        Semantics(
          label: '$stars of 3 stars',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Icon(
                    i < stars
                        ? Icons.local_florist_rounded
                        : Icons.local_florist_outlined,
                    size: compact ? 28 : 36,
                    color: const Color(0xFFC29C47),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Surface(
          padding: EdgeInsets.all(compact ? 12 : 18),
          child: Row(
            children: [
              for (final stat in [
                ('Time', timeLabel(session.activeMs)),
                ('Seeds', '+${state.lastReward}'),
                ('Hints', '${session.hintCount}'),
              ])
                Expanded(
                  child: Column(
                    children: [
                      if (compact)
                        Tooltip(
                          message: stat.$1,
                          child: Icon(
                            stat.$1 == 'Time'
                                ? Icons.timer_outlined
                                : stat.$1 == 'Seeds'
                                ? Icons.spa_outlined
                                : Icons.lightbulb_outline_rounded,
                            size: 18,
                            color: green,
                          ),
                        )
                      else
                        Text(
                          stat.$1,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1,
                            color: muted,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        stat.$2,
                        style: TextStyle(
                          fontSize: compact ? 17 : 21,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GardenButton(
          game.mode == 'journey' && index < 199
              ? (compact ? 'Next' : 'Next garden')
              : (compact ? 'Home' : 'Back to garden'),
          icon: Icons.arrow_forward_rounded,
          onPressed: () async {
            if (game.mode == 'journey' && index < 199) {
              if (index == 4) await controller.setting('tutorialSeen', true);
              await controller.open(
                controller.catalog.journey[index + 1],
                'journey',
              );
              if (mounted) setState(() => _hintCell = null);
            } else {
              await _exit();
            }
          },
        ),
        if (game.mode == 'journey')
          TextButton(onPressed: _exit, child: const Text('Back to garden')),
      ],
    );
  }
}
