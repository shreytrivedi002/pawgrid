import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawgrid/main.dart';
import 'package:pawgrid/data/database.dart';
import 'package:pawgrid/state/app_controller.dart';
import 'package:pawgrid/ui/board.dart';
import 'package:pawgrid/ui/design.dart';
import 'package:pawgrid/ui/first_garden.dart';
import 'package:pawgrid/ui/puzzle_screen.dart';

void main() {
  for (final large in [false, true]) {
    testWidgets('first garden walkthrough and resume, large text $large', (
      tester,
    ) async {
      final screenSize = large ? const Size(320, 568) : const Size(412, 892);
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = PawDatabase(NativeDatabase.memory());
      final services = (await tester.runAsync(
        () => loadServices(database: db),
      ))!;
      final container = ProviderContainer(
        overrides: [servicesProvider.overrideWithValue(services)],
      );
      final controller = container.read(appProvider.notifier);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        await tester.runAsync(db.close);
      });
      await tester.runAsync(
        () => controller.open('journey-001', 'journey', restart: true),
      );
      Widget game() => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: gardenTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: screenSize,
              textScaler: TextScaler.linear(large ? 2 : 1),
              padding: const EdgeInsets.only(top: 24, bottom: 20),
            ),
            child: const PuzzleScreen(),
          ),
        ),
      );
      Future<void> ready() async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(game());
      await ready();
      expect(find.byType(FirstGardenCard), findsOneWidget);
      if (large) {
        await tester.tap(find.byTooltip('Read tutorial instruction'));
        await tester.pumpAndSettle();
        expect(find.text(FirstGarden.bodies[0]), findsOneWidget);
        await tester.tap(find.text('Got it'));
        await ready();
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('start-lesson')));
      await ready();
      expect(tester.widget<PuzzleBoard>(find.byType(PuzzleBoard)).lessonCells, {
        0,
      });
      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await ready();
      expect(FirstGarden.step(container.read(appProvider)), 2);
      final swipe = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('cell-2'))),
      );
      await swipe.moveTo(
        tester.getCenter(find.byKey(const ValueKey('cell-3'))),
      );
      await swipe.up();
      await ready();
      expect(FirstGarden.step(container.read(appProvider)), 3);
      await tester.tap(find.text('Undo'));
      await ready();
      expect(FirstGarden.step(container.read(appProvider)), 4);
      expect(
        (await tester.runAsync(
          services.repository.settings,
        ))!['firstGardenStep'],
        4,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(game());
      await ready();
      expect(tester.widget<PuzzleBoard>(find.byType(PuzzleBoard)).lessonCells, {
        8,
      });
      await tester.longPress(find.byKey(const ValueKey('cell-8')));
      await ready();
      expect(FirstGarden.step(container.read(appProvider)), 5);
      await tester.longPress(find.byKey(const ValueKey('cell-14')));
      await ready();
      expect(find.text('Everyone’s home.'), findsOneWidget);
      expect(
        container.read(appProvider).progress.containsKey('journey-001'),
        true,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Scrollable), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PawgridApp(),
        ),
      );
      await ready();
      expect(find.byType(PuzzleScreen), findsNothing);
    });
  }
  testWidgets('skip persists and suppresses automatic lesson next launch', (
    tester,
  ) async {
    final db = PawDatabase(NativeDatabase.memory());
    final services = (await tester.runAsync(() => loadServices(database: db)))!;
    final container = ProviderContainer(
      overrides: [servicesProvider.overrideWithValue(services)],
    );
    final controller = container.read(appProvider.notifier);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.runAsync(db.close);
    });
    await tester.runAsync(() => controller.open('journey-001', 'journey'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: gardenTheme(), home: const PuzzleScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('skip-lesson')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FirstGardenCard), findsNothing);
    expect(
      (await tester.runAsync(
        services.repository.settings,
      ))!['firstGardenSkipped'],
      true,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PawgridApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PuzzleScreen), findsNothing);
  });
}
