import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawgrid/main.dart';
import 'package:pawgrid/data/database.dart';
import 'package:pawgrid/state/app_controller.dart';
import 'package:pawgrid/ui/board.dart';
import 'package:pawgrid/ui/design.dart';
import 'package:pawgrid/ui/puzzle_screen.dart';
import 'package:puzzle_core/puzzle_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('first launch supports hold placement, tap crosses and undo', (
    tester,
  ) async {
    final db = PawDatabase(NativeDatabase.memory());
    final services = (await tester.runAsync(() => loadServices(database: db)))!;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [servicesProvider.overrideWithValue(services)],
        child: const PawgridApp(),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PuzzleScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('mode-mark')), findsNothing);
    final board = tester.widget<PuzzleBoard>(find.byType(PuzzleBoard));
    final cell = List.generate(
      board.puzzle.n,
      (r) => r * board.puzzle.n + board.puzzle.solution[r],
    ).firstWhere((i) => !board.puzzle.isGiven(i));
    await tester.longPress(find.byKey(ValueKey('cell-$cell')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<PuzzleBoard>(find.byType(PuzzleBoard)).session.marks[cell],
      CellMark.token,
    );
    await tester.ensureVisible(find.text('Undo'));
    await tester.tap(find.text('Undo'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<PuzzleBoard>(find.byType(PuzzleBoard)).session.marks[cell],
      CellMark.unknown,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
  testWidgets(
    '9x9 fitted board at small screen and 200% text has semantic cells',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = PawDatabase(NativeDatabase.memory());
      final services = (await tester.runAsync(
        () => loadServices(database: db),
      ))!;
      final q = services.catalog.levels.values.firstWhere((p) => p.n == 9);
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [servicesProvider.overrideWithValue(services)],
          child: MaterialApp(
            theme: gardenTheme(),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 568),
                textScaler: TextScaler.linear(2),
              ),
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PuzzleBoard(
                    puzzle: q,
                    session: PuzzleSession.start(q),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp(r'Row 1, column 1, garden [A-I], empty')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('cell-80')), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(db.close);
    },
  );
  testWidgets('home and settings fit 320px at 200% text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final db = PawDatabase(NativeDatabase.memory());
    final loaded = (await tester.runAsync(() => loadServices(database: db)))!;
    final services = AppServices(
      loaded.catalog,
      loaded.repository,
      {...loaded.initialSettings, 'tutorialSeen': true},
      loaded.initialProgress,
      loaded.initialBalance,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [servicesProvider.overrideWithValue(services)],
        child: const PawgridApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}
