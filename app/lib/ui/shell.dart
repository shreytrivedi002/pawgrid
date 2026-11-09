import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_controller.dart';
import '../l10n/strings.dart';
import 'art.dart';
import 'game_scenery.dart';
import 'design.dart';
import 'puzzle_screen.dart';
import 'settings_screen.dart';

class GardenShell extends ConsumerStatefulWidget {
  const GardenShell({super.key});
  @override
  ConsumerState<GardenShell> createState() => _GardenShellState();
}

class _GardenShellState extends ConsumerState<GardenShell> {
  int _tab = 0;
  int? _openChapter;
  Timer? _dateTimer;
  DateTime _month = DateTime.utc(
    DateTime.now().toUtc().year,
    DateTime.now().toUtc().month,
  );
  String _selectedDate = DateTime.now().toUtc().toIso8601String().substring(
    0,
    10,
  );
  @override
  void initState() {
    super.initState();
    _dateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(appProvider);
      if (!state.enabled('tutorialSeen') &&
          !state.enabled('firstGardenSkipped') &&
          !state.progress.containsKey(
            ref.read(appProvider.notifier).catalog.journey.first,
          )) {
        ref.read(appProvider.notifier).setting('tutorialStarted', true);
        _play(ref.read(appProvider.notifier).catalog.journey.first, 'journey');
      }
    });
  }

  @override
  void dispose() {
    _dateTimer?.cancel();
    super.dispose();
  }

  Future<void> _play(String id, String mode, {bool restart = false}) async {
    final replay = ref.read(appProvider).progress.containsKey(id);
    final success = await ref
        .read(appProvider.notifier)
        .open(id, mode, restart: restart);
    if (!mounted) return;
    if (success) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => PuzzleScreen(replay: replay)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(appProvider).error ??
                'Your garden could not be opened. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 12, 18, 0),
                  child: Row(
                    children: [
                      Sprout(size: 43, variant: state.equipped),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'pawgrid',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(fontSize: 27),
                        ),
                      ),
                      SeedBadge(state.balance),
                      const SizedBox(width: 7),
                      IconButton(
                        tooltip: 'Settings',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.tune_rounded, size: 22),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: [_home(), _journey(), _daily(), _collection()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Color(0xFF252638),
          border: Border(top: BorderSide(color: Color(0xFF444457), width: 2)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A436C42),
              blurRadius: 14,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 6),
            child: Row(
              children: [
                for (final item in <(IconData, String)>[
                  (Icons.cottage_outlined, 'Garden'),
                  (Icons.route_outlined, 'Journey'),
                  (Icons.wb_sunny_outlined, 'Daily'),
                  (Icons.local_florist_outlined, 'Friends'),
                ])
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final index = [
                              'Garden',
                              'Journey',
                              'Daily',
                              'Friends',
                            ].indexOf(item.$2),
                            selected = _tab == index;
                        return Semantics(
                          selected: selected,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => setState(() => _tab = index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFF373D35)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      item.$1,
                                      size: 23,
                                      color: selected ? green : muted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.$2,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: selected ? green : muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _home() {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier),
        index = controller.nextJourneyIndex;
    final last = state.settings['lastGame'];
    final lastId = last is Map ? last['levelId'] as String? : null;
    final lastMode = last is Map ? last['mode'] as String? : null;
    final resume =
        lastId != null &&
        controller.catalog.levels.containsKey(lastId) &&
        !state.progress.containsKey(lastId);
    final targetId = resume ? lastId : controller.catalog.journey[index];
    final targetMode = resume ? lastMode ?? 'journey' : 'journey';
    final chapter = index ~/ 20;
    final chapterDone = controller.catalog.journey
        .skip(chapter * 20)
        .take(20)
        .where(state.progress.containsKey)
        .length;
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final dailyDone = state.progress.containsKey(
      controller.catalog.daily[today],
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 15, 22, 25),
      children: [
        const Eyebrow('YOUR DAILY DOSE OF WONDER', color: green),
        const SizedBox(height: 12),
        const Text(
          'Small puzzles.\nWild little worlds.',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 34,
            height: 1.04,
            letterSpacing: -1.4,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Switch off the noise. Find your next happy place.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 26),
        Surface(
          color: const Color(0xFF37314E),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.chapters[chapter],
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(fontSize: 29),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'WORLD ${(chapter + 1).toString().padLeft(2, '0')} · GROW AT YOUR PACE',
                            style: const TextStyle(
                              fontSize: 12,
                              color: muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: const Color(0xFF353A32),
                        border: Border.all(
                          color: const Color(0xFF555A43),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: const Icon(
                        Icons.local_florist_rounded,
                        color: Color(0xFFD7F985),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
              GardenWorld(
                height: 265,
                creature: state.equipped,
                chapter: chapter,
              ),
              const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.spa_outlined, color: green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A little room to grow',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '20 GARDENS',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Eyebrow('YOUR NEXT LITTLE ESCAPE', color: lavender),
              const SizedBox(height: 10),
              const Text(
                'Make room for\ngood company.',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 29,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A fresh start for your mind.',
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$chapterDone / 20 gardens',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _tab = 1),
                    child: const Text(
                      'Explore path',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: chapterDone / 20,
                  minHeight: 10,
                  backgroundColor: const Color(0xFF373849),
                  color: const Color(0xFFD7F985),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: resume ? 'Continue puzzle' : 'Play next level',
                button: true,
                child: GardenButton(
                  resume && targetMode == 'daily'
                      ? 'Continue Daily Garden'
                      : resume && targetMode == 'practice'
                      ? 'Continue practice'
                      : '${resume ? 'Continue' : 'Play'} level ${index + 1}',
                  icon: Icons.play_arrow_rounded,
                  onPressed: state.busy
                      ? null
                      : () => _play(targetId, targetMode),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _modeTile(
                dailyDone
                    ? Icons.local_florist_rounded
                    : Icons.wb_sunny_rounded,
                'Daily garden',
                const Color(0xFF3B302E),
                () => setState(() => _tab = 2),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _modeTile(
                Icons.extension_rounded,
                'Practice',
                const Color(0xFF2B3643),
                _practice,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _modeTile(
                Icons.emoji_events_rounded,
                'My growth',
                const Color(0xFF39314C),
                _stats,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => setState(() => _tab = 3),
          child: Surface(
            color: const Color(0xFF30362F),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Sprout(size: 59, variant: state.equipped),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your garden crew',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Meet a new little friend',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _modeTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) => InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: onPressed,
    child: Surface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 17),
      child: Column(
        children: [
          Icon(icon, size: 29, color: ink),
          const SizedBox(height: 9),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ),
  );

  Widget _journey() {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier),
        next = controller.nextJourneyIndex;
    final active = _openChapter ?? next ~/ 20;
    return ListView(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 30),
      children: [
        const Eyebrow('One peaceful puzzle at a time'),
        const SizedBox(height: 10),
        Text(
          'The garden path',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 9),
        Text(
          '${state.progress.values.where((p) => p.mode == 'journey').length} of 200 little moments collected',
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 25),
        for (var chapter = 0; chapter < 10; chapter++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Surface(
              color: chapter * 20 <= next ? panel : const Color(0xFF202131),
              padding: const EdgeInsets.all(19),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: chapter * 20 <= next
                        ? () => setState(
                            () =>
                                _openChapter = active == chapter ? -1 : chapter,
                          )
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 47,
                          height: 47,
                          decoration: BoxDecoration(
                            color: regionColors[chapter % 9].withValues(
                              alpha: .55,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            chapter * 20 <= next
                                ? Icons.spa_outlined
                                : Icons.lock_outline_rounded,
                            size: 24,
                            color: green,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Eyebrow(
                                'Chapter ${(chapter + 1).toString().padLeft(2, '0')}',
                              ),
                              const SizedBox(height: 5),
                              Text(
                                AppText.chapters[chapter],
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Levels ${chapter * 20 + 1}–${chapter * 20 + 20}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          chapter * 20 > next
                              ? Icons.lock_outline_rounded
                              : active == chapter
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 21,
                          color: muted,
                        ),
                      ],
                    ),
                  ),
                  if (active == chapter && chapter * 20 <= next) ...[
                    const SizedBox(height: 17),
                    Text(
                      AppText.chapterNotes[chapter],
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 20,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 10,
                          ),
                      itemBuilder: (context, i) {
                        final index = chapter * 20 + i,
                            id = controller.catalog.journey[index],
                            progress = state.progress[id],
                            unlocked = index <= next;
                        return Semantics(
                          label:
                              'Level ${index + 1}${progress != null
                                  ? ', completed, ${progress.stars} stars'
                                  : unlocked
                                  ? ', available'
                                  : ', locked'}',
                          button: true,
                          child: InkWell(
                            onTap: unlocked && !state.busy
                                ? () => _play(id, 'journey')
                                : null,
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: progress != null
                                    ? sage
                                    : index == next
                                    ? green
                                    : paper,
                                borderRadius: BorderRadius.circular(15),
                                border: index == next
                                    ? null
                                    : Border.all(color: line),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!unlocked)
                                    const Icon(
                                      Icons.lock_outline_rounded,
                                      size: 15,
                                      color: muted,
                                    )
                                  else
                                    Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: index == next ? paper : ink,
                                      ),
                                    ),
                                  if (progress != null)
                                    Text(
                                      '•' * progress.stars,
                                      style: const TextStyle(
                                        color: green,
                                        fontSize: 9,
                                        height: 1,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _daily() {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier),
        catalog = controller.catalog;
    final today = DateTime.now().toUtc(),
        todayKey = today.toIso8601String().substring(0, 10);
    final selected = catalog.daily[_selectedDate],
        canPlay = selected != null && _selectedDate.compareTo(todayKey) <= 0;
    final done = selected != null && state.progress.containsKey(selected);
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final first = DateTime.utc(_month.year, _month.month),
        offset = first.weekday - 1,
        days = DateTime.utc(_month.year, _month.month + 1, 0).day;
    return ListView(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 30),
      children: [
        const Eyebrow('A new day. A fresh perspective.'),
        const SizedBox(height: 10),
        Text('Daily Garden', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 9),
        const Text(
          'A small ritual to make a little room for yourself.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 23),
        GardenWorld(height: 180, creature: state.equipped),
        const SizedBox(height: 21),
        Surface(
          padding: const EdgeInsets.all(17),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: () => setState(
                      () =>
                          _month = DateTime.utc(_month.year, _month.month - 1),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '${months[_month.month - 1]} ${_month.year}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    onPressed: () => setState(
                      () =>
                          _month = DateTime.utc(_month.year, _month.month + 1),
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final label in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: offset + days,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 7,
                  crossAxisSpacing: 3,
                ),
                itemBuilder: (context, index) {
                  if (index < offset) return const SizedBox.shrink();
                  final date = DateTime.utc(
                        _month.year,
                        _month.month,
                        index - offset + 1,
                      ),
                      key = date.toIso8601String().substring(0, 10);
                  final available =
                          catalog.daily.containsKey(key) &&
                          key.compareTo(todayKey) <= 0,
                      solved = state.progress.containsKey(catalog.daily[key]),
                      isSelected = key == _selectedDate;
                  return Semantics(
                    label:
                        '$key${solved
                            ? ', completed'
                            : available
                            ? ', available'
                            : ', unavailable'}',
                    selected: isSelected,
                    button: true,
                    child: InkWell(
                      onTap: () => setState(() => _selectedDate = key),
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? green
                              : solved
                              ? sage
                              : key == todayKey
                              ? const Color(0xFF343646)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        alignment: Alignment.center,
                        child: solved && !isSelected
                            ? const Icon(
                                Icons.local_florist_rounded,
                                color: green,
                                size: 18,
                              )
                            : Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? paper
                                      : available
                                      ? ink
                                      : muted.withValues(alpha: .45),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Puzzle dates follow UTC · Your progress stays local',
                style: TextStyle(fontSize: 10, color: muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (canPlay)
          GardenButton(
            done
                ? 'Revisit this garden'
                : 'Play ${_selectedDate == todayKey ? 'today’s' : 'this'} garden',
            icon: done ? Icons.replay_rounded : Icons.arrow_forward_rounded,
            onPressed: state.busy
                ? null
                : () => _play(selected, 'daily', restart: done),
          )
        else
          Surface(
            color: sage,
            border: false,
            child: Column(
              children: [
                Text(
                  _selectedDate.compareTo(todayKey) > 0
                      ? 'This garden is still growing.'
                      : 'This date isn’t in your offline garden.',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Enjoy a practice puzzle in the meantime.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                GardenButton('Just practice', onPressed: _practice),
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (done)
          const Center(
            child: Text(
              'Beautifully done. Replay rewards are already collected.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ),
      ],
    );
  }

  Widget _collection() {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier);
    return ListView(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 30),
      children: [
        const Eyebrow('Good company, little by little'),
        const SizedBox(height: 10),
        Text(
          'Garden friends',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 9),
        const Text(
          'Let your logic grow into something lovely. Companions are just for the joy of it.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 23),
        for (final companion in <(String, String, String, int, Color)>[
          (
            'moss',
            'Moss',
            'A curious little leaf-lover. Your very first friend.',
            0,
            Color(0xFF2C3531),
          ),
          (
            'peach',
            'Peaches',
            'A sunny soul with a soft spot for wildflowers.',
            60,
            Color(0xFF3A3032),
          ),
          (
            'moon',
            'Luna',
            'A quiet dreamer, happiest under the evening sky.',
            120,
            Color(0xFF302F44),
          ),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Surface(
              color: companion.$5,
              border: false,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Sprout(size: 100, variant: companion.$1),
                      const SizedBox(width: 17),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companion.$2,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              companion.$3,
                              style: const TextStyle(
                                fontSize: 13,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GardenButton(
                    state.equipped == companion.$1
                        ? 'At home in your garden'
                        : companion.$1 == 'moss' ||
                              state.settings['owned:${companion.$1}'] == true
                        ? 'Invite to my garden'
                        : 'Invite for ${companion.$4} seeds',
                    secondary: true,
                    onPressed: state.busy || state.equipped == companion.$1
                        ? null
                        : () => controller.equip(companion.$1, companion.$4),
                  ),
                ],
              ),
            ),
          ),
        if (state.error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              state.error!,
              style: const TextStyle(color: Color(0xFFFFAD9C)),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Earn seeds from your first Journey and Daily solves. Replaying and Practice never spend or farm seeds.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: muted),
        ),
      ],
    );
  }

  Future<void> _practice() async {
    final controller = ref.read(appProvider.notifier),
        catalog = controller.catalog;
    var size = 5;
    var difficulty = catalog.levels[catalog.practice.first]!.difficulty;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          final available = catalog.practice
              .map((id) => catalog.levels[id]!)
              .where((p) => p.n == size)
              .map((p) => p.difficulty)
              .toSet()
              .toList();
          if (!available.contains(difficulty)) difficulty = available.first;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 8, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Eyebrow('No destination necessary'),
                  const SizedBox(height: 12),
                  Text(
                    'Find your own pace.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A quiet patch to think, experiment and grow. No rewards, no pressure.',
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 26),
                  const Eyebrow('Your patch size'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      for (var n = 5; n <= 9; n++)
                        ChoiceChip(
                          label: Text('$n × $n'),
                          selected: n == size,
                          onSelected: (_) => setSheet(() => size = n),
                        ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  const Eyebrow('A little challenge'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      for (final d in available)
                        ChoiceChip(
                          label: Text(d[0].toUpperCase() + d.substring(1)),
                          selected: d == difficulty,
                          onSelected: (_) => setSheet(() => difficulty = d),
                        ),
                    ],
                  ),
                  const SizedBox(height: 27),
                  GardenButton(
                    'Plant a little possibility',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () async {
                      final options = catalog.practice.where((id) {
                        final p = catalog.levels[id]!;
                        return p.n == size && p.difficulty == difficulty;
                      }).toList();
                      final key = 'practiceIndex:$size:$difficulty',
                          index =
                              (ref.read(appProvider).settings[key] as int? ??
                                  0) %
                              options.length;
                      await controller.setting(key, index + 1);
                      if (context.mounted) Navigator.pop(context);
                      await _play(options[index], 'practice', restart: true);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _stats() async {
    final progress = ref.read(appProvider).progress.values.toList(),
        journey = progress.where((p) => p.mode == 'journey').toList(),
        clean = progress.where((p) => p.clean).length;
    final times = progress.map((p) => p.bestMs).toList()..sort();
    final median = times.isEmpty ? null : times[times.length ~/ 2];
    final dailyDates =
        progress
            .where((p) => p.mode == 'daily')
            .map((p) => DateTime.tryParse(p.levelId.substring(6)))
            .whereType<DateTime>()
            .toList()
          ..sort();
    var streak = 0, longest = 0;
    DateTime? previous;
    for (final date in dailyDates) {
      streak = previous != null && date.difference(previous).inDays == 1
          ? streak + 1
          : 1;
      if (streak > longest) longest = streak;
      previous = date;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Look how far you’ve grown'),
              const SizedBox(height: 12),
              Text(
                'Small moments add up.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 25),
              for (final item in <(String, String)>[
                ('Journey gardens', '${journey.length} / 200'),
                ('All unique gardens', '${progress.length}'),
                ('Without a hint', '$clean'),
                ('Longest daily streak', '$longest days'),
                (
                  'Typical best time',
                  median == null ? 'A fresh start' : timeLabel(median),
                ),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.$1)),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              const Text(
                'Your history is personal to this device. Practice and replays never inflate your unique garden count.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
