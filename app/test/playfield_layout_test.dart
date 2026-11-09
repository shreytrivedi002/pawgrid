import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawgrid/main.dart';
import 'package:pawgrid/data/database.dart';
import 'package:pawgrid/state/app_controller.dart';
import 'package:pawgrid/ui/board.dart';
import 'package:pawgrid/ui/board_effects.dart';
import 'package:pawgrid/ui/design.dart';
import 'package:pawgrid/ui/puzzle_screen.dart';
import 'package:puzzle_core/puzzle_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final scenario in <(Size, double, int, bool)>[
    (const Size(320, 568), 1, 4, false),
    (const Size(320, 568), 2, 9, false),
    (const Size(320, 568), 2, 9, true),
    (const Size(412, 892), 1, 5, false),
    (const Size(640, 360), 1, 9, false),
    (const Size(800, 1024), 2, 9, true),
  ]) {
    testWidgets(
      'fixed playfield ${scenario.$1} ${scenario.$2}x text ${scenario.$3}x${scenario.$3} inspector ${scenario.$4}',
      (tester) async {
        tester.view.physicalSize = scenario.$1;
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
        final p = services.catalog.levels.values.firstWhere(
          (p) => p.n == scenario.$3,
        );
        await tester.runAsync(
          () => controller.setting('cellControls', scenario.$4),
        );
        await tester.runAsync(
          () => controller.open(p.levelId, 'practice', restart: true),
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: gardenTheme(),
              home: MediaQuery(
                data: MediaQueryData(
                  size: scenario.$1,
                  textScaler: TextScaler.linear(scenario.$2),
                  padding: const EdgeInsets.only(top: 24, bottom: 20),
                ),
                child: const PuzzleScreen(),
              ),
            ),
          ),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(Scrollable), findsNothing);
        expect(find.byTooltip('Fit board'), findsNothing);
        final board = tester.getRect(find.byKey(const ValueKey('board-frame'))),
            guide = tester.getRect(find.byKey(const ValueKey('gesture-guide')));
        expect((board.center.dx - guide.center.dx).abs(), lessThan(.1));
        expect(board.width, guide.width);
        for (final label in ['Undo', 'Hint', 'Rules']) {
          final rect = tester.getRect(find.text(label));
          expect(rect.top, greaterThanOrEqualTo(24));
          expect(rect.bottom, lessThanOrEqualTo(scenario.$1.height - 20));
        }
        final last = tester.getRect(
          find.byKey(ValueKey('cell-${p.n * p.n - 1}')),
        );
        expect(last.right, lessThanOrEqualTo(scenario.$1.width));
        expect(last.bottom, lessThanOrEqualTo(scenario.$1.height - 20));
        expect(find.byType(PuzzleBoard), findsOneWidget);
        if (scenario.$1 == const Size(320, 568) &&
            scenario.$2 == 2 &&
            !scenario.$4) {
          await tester.runAsync(() => controller.pause(true));
          await tester.pumpAndSettle();
          expect(find.byType(Scrollable), findsNothing);
          expect(tester.takeException(), isNull);
          expect(
            tester.getRect(find.text('Resume')).bottom,
            lessThan(scenario.$1.height - 20),
          );
          await tester.runAsync(() => controller.pause(false));
          await tester.runAsync(() async {
            for (var r = 0; r < p.n; r++) {
              final cell = r * p.n + p.solution[r];
              if (!p.isGiven(cell)) await controller.placeCreature(cell);
            }
          });
          await tester.pumpAndSettle();
          expect(find.text('Everyone’s home.'), findsOneWidget);
          expect(tester.takeException(), isNull);
          expect(find.byType(Scrollable), findsNothing);
          expect(
            tester.getRect(find.text('Home')).bottom,
            lessThanOrEqualTo(scenario.$1.height - 20),
          );
        }

        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets(
    'reduced motion keeps reactions static and wrong placement non-mutating',
    (tester) async {
      // The standalone effect follows the OS/inherited preference independently of app state.
      var mark = CellMark.unknown;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return Center(
                  child: SizedBox.square(
                    dimension: 80,
                    child: CellEffects(mark: mark, size: 80, variant: 'moss'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      update(() => mark = CellMark.token);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.hasRunningAnimations, false);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('move reactions animate and then return to an idle frame', (
    tester,
  ) async {
    var mark = CellMark.unknown;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, set) {
            update = set;
            return Center(
              child: SizedBox.square(
                dimension: 80,
                child: CellEffects(mark: mark, size: 80, variant: 'moss'),
              ),
            );
          },
        ),
      ),
    );
    update(() => mark = CellMark.token);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.hasRunningAnimations, true);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, false);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
