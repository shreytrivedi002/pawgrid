import 'package:flutter/services.dart';
import 'feedback_cue.dart';

abstract class GameAudioGateway {
  const GameAudioGateway();
  Future<void> prepare();
  Future<void> play(FeedbackCue cue, double volume);
  Future<void> stop();
}

class SilentGameAudio extends GameAudioGateway {
  const SilentGameAudio();
  @override
  Future<void> prepare() async {}
  @override
  Future<void> play(FeedbackCue cue, double volume) async {}
  @override
  Future<void> stop() async {}
}

/// Optional platform adapter. No audio error may interrupt offline play.
class ChannelGameAudio extends GameAudioGateway {
  static const channel = MethodChannel('pawgrid/feedback');
  final Stopwatch _clock = Stopwatch()..start();
  FeedbackCue? _last;
  int _lastMs = -100;
  bool _unavailable = false;
  @override
  Future<void> prepare() async {
    try {
      await channel.invokeMethod<Object?>('prepare');
    } on Object {
      _unavailable = true;
    }
  }

  @override
  Future<void> play(FeedbackCue cue, double volume) async {
    if (_unavailable || volume <= 0) return;
    if (_last == cue && _clock.elapsedMilliseconds - _lastMs < 45) return;
    _last = cue;
    _lastMs = _clock.elapsedMilliseconds;
    try {
      await channel.invokeMethod<bool>('play', {
        'cue': cue.name,
        'volume': volume.clamp(0, 1),
      });
    } on Object {
      /* Missing/unavailable audio never gates gameplay. */
    }
  }

  @override
  Future<void> stop() async {
    try {
      await channel.invokeMethod<void>('stop');
    } on Object {
      /* Optional adapter. */
    }
  }
}
