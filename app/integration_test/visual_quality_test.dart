import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pawgrid/main.dart' as app;
import 'package:pawgrid/state/app_controller.dart';
import 'package:pawgrid/ui/game_scenery.dart';
import 'package:pawgrid/ui/puzzle_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('GPU board, header, artwork and completion visual review', (
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
      await tester.tap(
        find.bySemanticsLabel(RegExp('Play next level|Continue puzzle')).first,
      );
      await tester.pumpAndSettle();
    }
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PuzzleScreen)),
    );
    final c = container.read(appProvider.notifier);
    await c.setting('firstGardenSkipped', true);
    await c.open('journey-002', 'journey', restart: true);
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('android-board');
    final frame = tester.getRect(find.byKey(const ValueKey('board-frame')));
    expect(frame.width, closeTo(frame.height, .01));
    expect(
      tester.getRect(find.byKey(const ValueKey('level-title'))).top,
      greaterThanOrEqualTo(
        MediaQuery.paddingOf(tester.element(find.byType(PuzzleScreen))).top,
      ),
    );
    final p = c.puzzle!;
    for (var r = 0; r < p.n; r++) {
      final cell = r * p.n + p.solution[r];
      if (!p.isGiven(cell)) {
        await tester.longPress(find.byKey(ValueKey('cell-$cell')));
        await tester.pump(const Duration(milliseconds: 100));
        for (var i = 0; i < 40 && container.read(appProvider).busy; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();
      }
    }
    expect(find.byType(GardenCelebration), findsOneWidget);
    await binding.takeScreenshot('android-completion');
    expect(tester.hasRunningAnimations, false);
    await tester.tap(find.text('Back to garden'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('android-home');
    await tester.tap(find.text('Daily').last);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('android-daily');
    await tester.tap(find.text('Friends').last);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('android-friends');
    expect(tester.takeException(), isNull);
  });
}
