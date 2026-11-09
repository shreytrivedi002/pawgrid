import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pawgrid/main.dart' as app;
import 'package:pawgrid/state/app_controller.dart';
import 'package:pawgrid/ui/first_garden.dart';
import 'package:pawgrid/ui/puzzle_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('fresh install guides a whole garden', (tester) async {
    await app.main();
    for (
      var i = 0;
      i < 40 && find.byType(PuzzleScreen).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pumpAndSettle();
    expect(find.byType(FirstGardenCard), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PuzzleScreen)),
    );
    Future<void> ready() async {
      await tester.pump(const Duration(milliseconds: 100));
      for (var i = 0; i < 40 && container.read(appProvider).busy; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byKey(const ValueKey('start-lesson')));
    await ready();
    await tester.tap(find.byKey(const ValueKey('cell-0')));
    await ready();
    expect(FirstGarden.step(container.read(appProvider)), 2);
    final swipe = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('cell-2'))),
    );
    await swipe.moveTo(tester.getCenter(find.byKey(const ValueKey('cell-3'))));
    await swipe.up();
    await ready();
    expect(FirstGarden.step(container.read(appProvider)), 3);
    await tester.tap(find.text('Undo'));
    await ready();
    expect(FirstGarden.step(container.read(appProvider)), 4);
    for (final cell in [8, 14]) {
      await tester.longPress(find.byKey(ValueKey('cell-$cell')));
      await ready();
    }
    expect(find.text('Everyone’s home.'), findsOneWidget);
    await tester.tap(find.text('Next garden'));
    await ready();
    expect(container.read(appProvider).game!.levelId, 'journey-002');
    expect(find.byType(FirstGardenCard), findsNothing);
  });
}
