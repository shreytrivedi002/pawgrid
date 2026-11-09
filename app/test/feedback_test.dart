import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawgrid/main.dart';
import 'package:pawgrid/data/database.dart';
import 'package:pawgrid/state/app_controller.dart';
import 'package:pawgrid/feedback/audio_gateway.dart';
import 'package:pawgrid/feedback/feedback_cue.dart';
import 'package:pawgrid/ui/game_feedback.dart';
import 'package:pawgrid/ui/board_motion.dart';
import 'package:pawgrid/ui/game_scenery.dart';
import 'package:puzzle_core/puzzle_core.dart';

class RecordingAudio extends GameAudioGateway {
  final cues = <FeedbackCue>[];
  final volumes = <double>[];
  var stops = 0, prepares = 0;
  bool fail = false;
  @override
  Future<void> prepare() async {
    prepares++;
  }

  @override
  Future<void> play(FeedbackCue cue, double volume) async {
    cues.add(cue);
    volumes.add(volume);
    if (fail) throw StateError('unavailable');
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

class AudioHarness {
  AudioHarness(this.db, this.container, this.audio, this.services);
  final PawDatabase db;
  final ProviderContainer container;
  final RecordingAudio audio;
  final AppServices services;
  AppController get controller => container.read(appProvider.notifier);
  static Future<AudioHarness> create(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final db = PawDatabase(NativeDatabase.memory()), audio = RecordingAudio();
    final services = (await tester.runAsync(
      () => loadServices(database: db, audio: audio),
    ))!;
    final container = ProviderContainer(
      overrides: [servicesProvider.overrideWithValue(services)],
    );
    final h = AudioHarness(db, container, audio, services);
    addTearDown(() async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.runAsync(db.close);
    });
    await tester.runAsync(
      () => h.controller.open('practice-5-01', 'practice', restart: true),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GameFeedbackHost(child: MaterialApp(home: SizedBox())),
      ),
    );
    await tester.pump();
    return h;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = PuzzleDefinition.fromJson(
    jsonDecode(
          File('../test-fixtures/Pawgrid_sample_level.json').readAsStringSync(),
        )
        as Map<String, dynamic>,
  );
  test('cues reflect commands, not clock ticks or a hidden answer', () {
    final s = PuzzleSession.start(p),
        guess = PuzzleSession.start(p).placeCreature(p, 0);
    expect(cueForChange(p, s, guess), FeedbackCue.place);
    expect(cueForChange(p, s, s.withTime(2000)), isNull);
    final mark = s.tap(p, 0, InputMode.mark);
    expect(cueForChange(p, s, mark), FeedbackCue.mark);
    expect(
      cueForChange(p, mark, mark.tap(p, 0, InputMode.mark)),
      FeedbackCue.erase,
    );
    final stroke = s.paintCrosses(p, [0, 2, 3], CellMark.excluded);
    expect(cueForChange(p, s, stroke), FeedbackCue.swipe);
    expect(cueForChange(p, stroke, stroke.undo(p)), FeedbackCue.undo);
    expect(
      cueForChange(p, s, s.change(p, 1, CellMark.token, hint: true)),
      FeedbackCue.hint,
    );
    final a = s.placeCreature(p, 1);
    expect(cueForChange(p, a, a.placeCreature(p, 3)), FeedbackCue.warning);
    expect(cueForChange(p, a, a.placeCreature(p, 5)), isNull);
    var solved = s;
    for (var r = 0; r < p.n - 1; r++) {
      solved = solved.placeCreature(p, r * p.n + p.solution[r]);
    }
    expect(
      cueForChange(
        p,
        solved,
        solved.placeCreature(p, 4 * p.n + p.solution.last),
      ),
      FeedbackCue.win,
    );
    expect(cueForChange(p, stroke, s), isNull);
  });
  test(
    'native gateway clamps volume, throttles repeats and survives missing audio',
    () async {
      final calls = <MethodCall>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(ChannelGameAudio.channel, (
        call,
      ) async {
        calls.add(call);
        return call.method == 'play' ? true : null;
      });
      final audio = ChannelGameAudio();
      await audio.prepare();
      await audio.play(FeedbackCue.mark, 2);
      await audio.play(FeedbackCue.mark, 2);
      await audio.play(FeedbackCue.place, .4);
      await audio.stop();
      expect(calls.where((c) => c.method == 'play').length, 2);
      expect(
        (calls.firstWhere((c) => c.method == 'play').arguments
            as Map)['volume'],
        1,
      );
      messenger.setMockMethodCallHandler(ChannelGameAudio.channel, (
        call,
      ) async {
        throw MissingPluginException();
      });
      final missing = ChannelGameAudio();
      await missing.prepare();
      await missing.play(FeedbackCue.win, 1);
      await missing.stop();
      messenger.setMockMethodCallHandler(ChannelGameAudio.channel, null);
    },
  );
  testWidgets(
    'saved commands sound once; mute, volume, reload and failure stay safe',
    (tester) async {
      final h = await AudioHarness.create(tester),
          c = h.controller,
          a = h.audio;
      expect(a.prepares, 1);
      expect(a.cues, isEmpty);
      await tester.runAsync(() => c.tap(0));
      expect(a.cues, [FeedbackCue.mark]);
      await tester.runAsync(c.tick);
      expect(a.cues.length, 1);
      await tester.runAsync(() => c.paintCrosses([2, 3, 4], CellMark.excluded));
      expect(a.cues.last, FeedbackCue.swipe);
      expect(a.cues.length, 2);
      await tester.runAsync(c.undo);
      expect(a.cues.last, FeedbackCue.undo);
      await tester.runAsync(() => c.placeCreature(1));
      expect(a.cues.last, FeedbackCue.place);
      final count = a.cues.length;
      await tester.runAsync(() => c.open('practice-5-01', 'practice'));
      expect(a.cues.length, count);
      final q = c.puzzle!,
          duplicate = List.generate(25, (i) => i).firstWhere(
            (i) => i != 1 && c.puzzle!.regionAt(i) == c.puzzle!.regionAt(1),
          );
      await tester.runAsync(() => c.placeCreature(duplicate));
      expect(a.cues.last, FeedbackCue.warning);
      await tester.runAsync(() => c.setting('sound', false));
      final muted = a.cues.length;
      await tester.runAsync(() => c.tap(0));
      expect(a.cues.length, muted);
      expect(a.stops, greaterThan(0));
      await tester.runAsync(() => c.setting('sound', true));
      await tester.runAsync(() => c.setting('soundVolume', 0.0));
      await tester.runAsync(() => c.tap(0));
      expect(a.cues.length, muted);
      await tester.runAsync(() => c.setting('soundVolume', .3));
      a.fail = true;
      await tester.runAsync(() => c.tap(0));
      await tester.pump();
      expect(a.volumes.last, .3);
      expect(
        h.container.read(appProvider).game!.session.marks[0],
        CellMark.unknown,
      );
      expect(tester.takeException(), isNull);
      expect(
        (await tester.runAsync(h.services.repository.settings))!['soundVolume'],
        .3,
      );
      expect(
        (await tester.runAsync(
          () => h.services.repository.load(q, 'practice'),
        ))!.session.marks[0],
        CellMark.unknown,
      );
    },
  );
  testWidgets('background and pause stop sound without stale replay', (
    tester,
  ) async {
    final h = await AudioHarness.create(tester), c = h.controller, a = h.audio;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    await tester.runAsync(() => c.tap(0));
    expect(a.cues, isEmpty);
    expect(a.stops, greaterThan(0));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(a.cues, isEmpty);
    await tester.runAsync(() => c.pause(true));
    expect(a.stops, greaterThan(1));
    await tester.runAsync(() => c.pause(false));
    expect(a.cues, isEmpty);
    await tester.runAsync(() => c.tap(0));
    expect(a.cues, [FeedbackCue.erase]);
  });
  for (final reduced in [false, true]) {
    testWidgets(
      'motion keeps hit geometry fixed, settles, respects reduced $reduced',
      (tester) async {
        var session = PuzzleSession.start(p);
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: StatefulBuilder(
                builder: (context, set) {
                  update = set;
                  return Center(
                    child: SizedBox.square(
                      dimension: 320,
                      child: BoardMotion(
                        puzzle: p,
                        session: session,
                        epoch: 1,
                        paused: false,
                        child: Container(key: const ValueKey('stable-grid')),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        final bounds = tester.getRect(
          find.byKey(const ValueKey('stable-grid')),
        );
        update(() => session = session.placeCreature(p, 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 120));
        expect(tester.hasRunningAnimations, !reduced);
        expect(
          tester.getRect(find.byKey(const ValueKey('stable-grid'))),
          bounds,
        );
        await tester.pump(const Duration(seconds: 2));
        expect(tester.hasRunningAnimations, false);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: const GardenCelebration(creature: 'moss'),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.hasRunningAnimations, !reduced);
        await tester.pump(const Duration(seconds: 3));
        expect(tester.hasRunningAnimations, false);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
