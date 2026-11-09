import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawgrid/main.dart';
import 'package:pawgrid/data/database.dart';
import 'package:pawgrid/state/app_controller.dart';
import 'package:pawgrid/ui/board.dart';
import 'package:pawgrid/ui/design.dart';
import 'package:puzzle_core/puzzle_core.dart';

class Harness {
  Harness(this.db, this.container, this.puzzle);
  final PawDatabase db;
  final ProviderContainer container;
  final PuzzleDefinition puzzle;
  AppController get controller => container.read(appProvider.notifier);
  PuzzleSession get session => container.read(appProvider).game!.session;
  static Future<Harness> create(
    WidgetTester tester, {
    bool large = false,
    bool givens = false,
  }) async {
    final db = PawDatabase(NativeDatabase.memory());
    final services = (await tester.runAsync(() => loadServices(database: db)))!;
    final p =
        services.catalog.levels[givens
            ? services.catalog.journey.first
            : large
            ? 'practice-9-01'
            : 'practice-5-01']!;
    final container = ProviderContainer(
      overrides: [servicesProvider.overrideWithValue(services)],
    );
    final h = Harness(db, container, p);
    await tester.runAsync(
      () => h.controller.open(p.levelId, 'practice', restart: true),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: gardenTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 350,
                child: Consumer(
                  builder: (context, ref, _) => PuzzleBoard(
                    puzzle: p,
                    session: ref.watch(appProvider).game!.session,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.runAsync(db.close);
    });
    return h;
  }

  static Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pumpAndSettle();
  }

  Offset center(WidgetTester tester, int cell) =>
      tester.getCenter(find.byKey(ValueKey('cell-$cell')));
  Future<void> stroke(
    WidgetTester tester,
    List<int> cells, {
    bool cancel = false,
  }) async {
    final gesture = await tester.startGesture(center(tester, cells.first));
    for (final cell in cells.skip(1)) {
      await gesture.moveTo(center(tester, cell));
      await tester.pump(const Duration(milliseconds: 20));
    }
    if (cancel) {
      await gesture.cancel();
    } else {
      await gesture.up();
    }
    await settle(tester);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'tap toggles cross; long press places/removes without an extra cross',
    (tester) async {
      final h = await Harness.create(tester);
      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await Harness.settle(tester);
      expect(h.session.marks[1], CellMark.excluded);
      expect(h.session.moveCount, 1);
      await tester.longPress(find.byKey(const ValueKey('cell-1')));
      await Harness.settle(tester);
      expect(h.session.marks[1], CellMark.token);
      expect(h.session.moveCount, 2);
      await tester.longPress(find.byKey(const ValueKey('cell-1')));
      await Harness.settle(tester);
      expect(h.session.marks[1], CellMark.unknown);
      expect(h.session.moveCount, 3);
    },
  );
  testWidgets(
    'fast sparse drag paints skipped cells once; one undo reverses the whole stroke',
    (tester) async {
      final h = await Harness.create(tester);
      await h.stroke(tester, [0, 4, 0, 4]);
      expect(h.session.marks.take(5), everyElement(CellMark.excluded));
      expect(h.session.moveCount, 1);
      expect(h.session.history.length, 5);
      await tester.runAsync(h.controller.undo);
      await Harness.settle(tester);
      expect(h.session.marks, everyElement(CellMark.unknown));
      expect(h.session.undoCount, 1);
    },
  );
  testWidgets(
    'starting on a cross erases and protects creatures; saved stroke reopens exactly',
    (tester) async {
      final h = await Harness.create(tester);
      await tester.runAsync(() => h.controller.placeCreature(1));
      await Harness.settle(tester);
      await h.stroke(tester, [0, 4]);
      expect(h.session.marks[1], CellMark.token);
      expect(h.session.marks[0], CellMark.excluded);
      final painted = h.session.marks.toList();
      await h.stroke(tester, [0, 4]);
      expect(h.session.marks[1], CellMark.token);
      expect(h.session.marks[0], CellMark.unknown);
      await tester.runAsync(h.controller.undo);
      await Harness.settle(tester);
      expect(h.session.marks, painted);
      final loaded = await tester.runAsync(
        () => h.container
            .read(servicesProvider)
            .repository
            .load(h.puzzle, 'practice'),
      );
      expect(loaded!.session.marks, painted);
      expect(loaded.session.history.last.group, isNotNull);
    },
  );
  testWidgets('cancelled stroke leaves no marks or durable history', (
    tester,
  ) async {
    final h = await Harness.create(tester);
    await h.stroke(tester, [0, 4], cancel: true);
    expect(h.session.marks, everyElement(CellMark.unknown));
    expect(h.session.history, isEmpty);
  });
  testWidgets('fixed clues ignore tap, hold and drag', (tester) async {
    final h = await Harness.create(tester, givens: true);
    final given = h.puzzle.givens.first,
        cell = given.row * h.puzzle.n + given.col;
    await tester.tap(find.byKey(ValueKey('cell-$cell')));
    await Harness.settle(tester);
    await tester.longPress(find.byKey(ValueKey('cell-$cell')));
    await Harness.settle(tester);
    await h.stroke(tester, [cell, cell + 1]);
    expect(h.session.marks, h.puzzle.initialMarks());
    expect(h.session.history, isEmpty);
  });
  testWidgets('9x9 board has no scroll or enlargement controls', (
    tester,
  ) async {
    final h = await Harness.create(tester, large: true);
    expect(find.byType(Scrollable), findsNothing);
    expect(find.byKey(const ValueKey('move-board')), findsNothing);
    expect(find.byKey(const ValueKey('cell-80')), findsOneWidget);
    expect(h.session.marks, everyElement(CellMark.unknown));
  });
  testWidgets('hold accepts a non-answer tile and Undo allows rethinking', (
    tester,
  ) async {
    final h = await Harness.create(tester);
    await tester.longPress(find.byKey(const ValueKey('cell-0')));
    await Harness.settle(tester);
    expect(h.puzzle.solution[0], isNot(0));
    expect(h.session.marks[0], CellMark.token);
    expect(h.session.moveCount, 1);
    expect(h.session.history, isNotEmpty);
    expect(h.container.read(appProvider).placementFeedback, isNull);
    await tester.runAsync(h.controller.undo);
    await Harness.settle(tester);
    expect(h.session.marks[0], CellMark.unknown);
  });
  testWidgets('holding a second tile in an occupied garden is rejected', (
    tester,
  ) async {
    final h = await Harness.create(tester);
    await tester.runAsync(() => h.controller.placeCreature(1));
    await Harness.settle(tester);
    final other = List.generate(
      25,
      (i) => i,
    ).firstWhere((i) => i != 1 && h.puzzle.regionAt(i) == h.puzzle.regionAt(1));
    await tester.longPress(find.byKey(ValueKey('cell-$other')));
    await Harness.settle(tester);
    expect(h.session.marks.where((m) => m == CellMark.token).length, 1);
    expect(
      h.container.read(appProvider).placementFeedback!.issue,
      PlacementIssue.gardenOccupied,
    );
  });
  for (final code in ['row', 'column', 'touching']) {
    testWidgets('$code conflict stays placed, indicated, saved and undoable', (
      tester,
    ) async {
      final h = await Harness.create(tester);
      final p = h.puzzle;
      final pair = [
        for (var a = 0; a < p.n * p.n; a++)
          for (var b = a + 1; b < p.n * p.n; b++)
            if (p.regionAt(a) != p.regionAt(b) &&
                (code == 'row'
                    ? a ~/ p.n == b ~/ p.n && (a % p.n - b % p.n).abs() > 1
                    : code == 'column'
                    ? a % p.n == b % p.n && (a ~/ p.n - b ~/ p.n).abs() > 1
                    : (a ~/ p.n - b ~/ p.n).abs() == 1 &&
                          (a % p.n - b % p.n).abs() == 1))
              (a, b),
      ].first;
      final semantics = tester.ensureSemantics();
      await tester.longPress(find.byKey(ValueKey('cell-${pair.$1}')));
      await Harness.settle(tester);
      await tester.longPress(find.byKey(ValueKey('cell-${pair.$2}')));
      await Harness.settle(tester);
      expect(h.session.marks[pair.$1], CellMark.token);
      expect(h.session.marks[pair.$2], CellMark.token);
      expect(h.container.read(appProvider).placementFeedback, isNull);
      expect(
        Rules.conflicts(p, h.session.marks).map((c) => c.code),
        contains(code),
      );
      for (final cell in [pair.$1, pair.$2]) {
        expect(
          find.byKey(ValueKey('conflict-indicator-$cell')),
          findsOneWidget,
        );
        expect(find.byKey(ValueKey('conflict-warning-$cell')), findsOneWidget);
        expect(
          tester.getSemantics(find.byKey(ValueKey('cell-$cell'))).label,
          contains('conflict'),
        );
      }
      await tester.runAsync(() => h.controller.open(p.levelId, 'practice'));
      await Harness.settle(tester);
      expect(h.session.marks[pair.$2], CellMark.token);
      expect(
        find.byKey(ValueKey('conflict-warning-${pair.$2}')),
        findsOneWidget,
      );
      await tester.runAsync(h.controller.undo);
      await Harness.settle(tester);
      expect(h.session.marks[pair.$2], CellMark.unknown);
      expect(find.byKey(ValueKey('conflict-warning-${pair.$1}')), findsNothing);
      semantics.dispose();
    });
  }
  testWidgets(
    'queued rapid taps are preserved while earlier SQLite saves finish',
    (tester) async {
      final h = await Harness.create(tester);
      await tester.runAsync(
        () => Future.wait(List.generate(20, (i) => h.controller.tap(i % 5))),
      );
      await Harness.settle(tester);
      expect(h.session.moveCount, 20);
      expect(h.session.marks, everyElement(CellMark.unknown));
    },
  );
  testWidgets('keyboard placement and clearing work without holding', (
    tester,
  ) async {
    final h = await Harness.create(tester);
    final detector = tester.widget<FocusableActionDetector>(
      find.descendant(
        of: find.byKey(const ValueKey('cell-0')),
        matching: find.byType(FocusableActionDetector),
      ),
    );
    detector.focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await Harness.settle(tester);
    expect(h.session.marks[0], CellMark.token);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await Harness.settle(tester);
    expect(h.session.marks[0], CellMark.unknown);
  });
  testWidgets(
    'screen-reader Actions can place a creature without a timed gesture',
    (tester) async {
      final h = await Harness.create(tester);
      final semantics = tester.ensureSemantics();
      await tester.pump();
      final node = tester.getSemantics(find.byKey(const ValueKey('cell-0')));
      final actions = node.getSemanticsData().customSemanticsActionIds!;
      final place = actions.firstWhere(
        (id) =>
            CustomSemanticsAction.getAction(id)!.label ==
            'Place or remove creature',
      );
      tester.binding.renderViews.first.owner!.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.customAction,
        place,
      );
      await Harness.settle(tester);
      expect(h.session.marks[0], CellMark.token);
      semantics.dispose();
    },
  );
  testWidgets(
    'winning hold can dispose the board safely before finger release',
    (tester) async {
      final h = await Harness.create(tester);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: h.container,
          child: MaterialApp(
            theme: gardenTheme(),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 350,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final session = ref.watch(appProvider).game!.session;
                      return Rules.isWon(h.puzzle, session.marks)
                          ? const Text('All home')
                          : PuzzleBoard(puzzle: h.puzzle, session: session);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        for (var r = 0; r < h.puzzle.n - 1; r++) {
          await h.controller.placeCreature(
            r * h.puzzle.n + h.puzzle.solution[r],
          );
        }
      });
      await Harness.settle(tester);
      expect(h.session.marks.where((m) => m == CellMark.token).length, 4);
      final last = (h.puzzle.n - 1) * h.puzzle.n + h.puzzle.solution.last;
      final hold = await tester.startGesture(h.center(tester, last));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      expect(h.session.marks[last], CellMark.token);
      expect(find.text('All home'), findsOneWidget);
      await hold.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
