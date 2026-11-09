import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pawgrid/main.dart' as app;
import 'package:pawgrid/state/app_controller.dart';
import 'package:pawgrid/ui/puzzle_screen.dart';
import 'package:pawgrid/ui/game_scenery.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android native sound load/play/mute/stop and motion lifecycle', (
    tester,
  ) async {
    await app.main();
    for (
      var i = 0;
      i < 40 && find.byType(PuzzleScreen).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    if (find.byType(PuzzleScreen).evaluate().isEmpty) {
      final start = find.bySemanticsLabel(
        RegExp('Play next level|Continue puzzle'),
      );
      if (start.evaluate().isNotEmpty) await tester.tap(start.first);
      await tester.pumpAndSettle();
    }
    expect(find.byType(PuzzleScreen), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PuzzleScreen)),
    );
    final c = container.read(appProvider.notifier);
    const channel = MethodChannel('pawgrid/feedback');
    Future<Map<String, dynamic>> status() async =>
        (await channel.invokeMapMethod<String, dynamic>('prepare'))!;
    var info = await status();
    for (var i = 0; i < 60 && (info['loaded'] as List).length < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      info = await status();
    }
    expect(
      info['loaded'],
      unorderedEquals([
        'mark',
        'erase',
        'place',
        'swipe',
        'undo',
        'warning',
        'hint',
        'win',
      ]),
    );
    expect(info['active'], true);
    final osMuted = info['muted'] as bool;
    var accepted = 0;
    for (final cue in [
      'mark',
      'erase',
      'place',
      'swipe',
      'undo',
      'warning',
      'hint',
      'win',
    ]) {
      final played = await channel.invokeMethod<bool>('play', {
        'cue': cue,
        'volume': .5,
      });
      expect(played, !osMuted);
      if (played!) accepted++;
      await tester.pump(const Duration(milliseconds: 100));
    }
    debugPrint(
      'NATIVE_AUDIO: 8 loaded, $accepted accepted streams, OS muted=$osMuted',
    );
    await channel.invokeMethod<void>('stop');
    expect((await status())['voices'], 0);
    expect(
      await channel.invokeMethod<bool>('play', {'cue': 'place', 'volume': 0.0}),
      false,
    );
    await c.open('practice-5-01', 'practice', restart: true);
    await tester.pumpAndSettle();
    await c.setting('sound', false);
    await c.tap(0);
    await tester.pumpAndSettle();
    expect((await status())['voices'], 0);
    await c.setting('sound', true);
    await c.setting('soundVolume', .4);
    await c.tap(0);
    await tester.pumpAndSettle();
    expect((await status())['voices'], osMuted ? 0 : greaterThan(0));
    await c.pause(true);
    await tester.pumpAndSettle();
    expect((await status())['voices'], 0);
    await c.pause(false);
    await c.setting('reduceMotion', true);
    await tester.pumpAndSettle();
    await c.tap(0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(tester.hasRunningAnimations, false);
    await c.setting('reduceMotion', false);
    await c.open(c.catalog.journey.first, 'journey', restart: true);
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const ValueKey('cell-8')));
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const ValueKey('cell-14')));
    await tester.pump();
    expect(find.byType(GardenCelebration), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.hasRunningAnimations, true);
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, false);
    expect(find.text('Everyone’s home.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await c.setting('sound', false);
    await tester.pumpAndSettle();
    expect((await status())['voices'], 0);
  });
}
