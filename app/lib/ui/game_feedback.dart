import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_controller.dart';
import '../feedback/audio_gateway.dart';
import '../feedback/feedback_cue.dart';

class GameFeedbackHost extends ConsumerStatefulWidget {
  const GameFeedbackHost({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<GameFeedbackHost> createState() => _GameFeedbackHostState();
}

class _GameFeedbackHostState extends ConsumerState<GameFeedbackHost>
    with WidgetsBindingObserver {
  bool _active = true;
  late final GameAudioGateway audio;
  static double volume(AppState state) =>
      ((state.settings['soundVolume'] as num?)?.toDouble() ?? .7).clamp(0, 1);
  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } on Object {
      /* Feedback must not block play. */
    }
  }

  @override
  void initState() {
    super.initState();
    audio = ref.read(servicesProvider).audio;
    WidgetsBinding.instance.addObserver(this);
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    unawaited(_safe(audio.prepare));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    setState(() => _active = state == AppLifecycleState.resumed);
    if (!_active) unawaited(_safe(audio.stop));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_safe(audio.stop));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppState>(appProvider, (before, after) {
      if (before == null) return;
      if ((before.enabled('sound', fallback: true) &&
              !after.enabled('sound', fallback: true)) ||
          (volume(before) > 0 && volume(after) == 0) ||
          (!before.paused && after.paused)) {
        unawaited(_safe(audio.stop));
      }
      if (!_active ||
          after.busy ||
          !after.enabled('sound', fallback: true) ||
          volume(after) == 0) {
        return;
      }
      FeedbackCue? cue;
      if (after.placementFeedback != null &&
          before.placementFeedback?.sequence !=
              after.placementFeedback!.sequence) {
        cue = FeedbackCue.warning;
      } else if (before.game != null &&
          after.game != null &&
          before.game!.levelId == after.game!.levelId &&
          before.gameEpoch == after.gameEpoch) {
        final p = ref.read(appProvider.notifier).puzzle!;
        cue = cueForChange(p, before.game!.session, after.game!.session);
      }
      if (cue == null ||
          (after.paused && cue != FeedbackCue.hint && cue != FeedbackCue.win)) {
        return;
      }
      final effect = cue;
      unawaited(_safe(() => audio.play(effect, volume(after))));
    });
    return TickerMode(enabled: _active, child: widget.child);
  }
}
