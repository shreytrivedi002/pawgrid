import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pawgrid/main.dart' as app;
import 'package:pawgrid/state/app_controller.dart';
import 'package:pawgrid/l10n/strings.dart';
import 'package:pawgrid/ui/board.dart';
import 'package:pawgrid/ui/game_scenery.dart';
import 'package:pawgrid/ui/puzzle_screen.dart';
import 'package:puzzle_core/puzzle_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'device: tutorial, undo, completion, replay ledger, pause and resume',
    (tester) async {
      await app.main();
      for (
        var i = 0;
        i < 30 && find.byType(PuzzleScreen).evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      // A prior smoke run may have completed onboarding; enter via Continue.
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
      final controller = container.read(appProvider.notifier);
      Future<void> ready() async {
        for (var i = 0; i < 30 && container.read(appProvider).busy; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();
      }

      // A legal guess must survive touch input and a saved-session reopen,
      // even though it is absent from the unique answer.
      await controller.open('practice-5-01', 'practice', restart: true);
      await ready();
      final exploratory = controller.puzzle!;
      expect(exploratory.solution[0], isNot(0));
      await tester.longPress(find.byKey(const ValueKey('cell-0')));
      await ready();
      expect(
        container.read(appProvider).game!.session.marks[0],
        CellMark.token,
      );
      expect(container.read(appProvider).placementFeedback, isNull);
      await controller.open('practice-5-01', 'practice');
      await ready();
      expect(
        container.read(appProvider).game!.session.marks[0],
        CellMark.token,
      );
      final duplicate = List.generate(25, (i) => i).firstWhere(
        (i) => i != 0 && exploratory.regionAt(i) == exploratory.regionAt(0),
      );
      final beforeDuplicate = container
          .read(appProvider)
          .game!
          .session
          .moveCount;
      await tester.longPress(find.byKey(ValueKey('cell-$duplicate')));
      await ready();
      expect(
        container.read(appProvider).game!.session.marks[duplicate],
        CellMark.unknown,
      );
      expect(
        container.read(appProvider).game!.session.moveCount,
        beforeDuplicate,
      );
      expect(
        container.read(appProvider).placementFeedback!.issue,
        PlacementIssue.gardenOccupied,
      );
      await tester.tap(find.text('Undo'));
      await ready();
      expect(
        container.read(appProvider).game!.session.marks[0],
        CellMark.unknown,
      );

      for (final code in ['row', 'column', 'touching']) {
        await controller.open('practice-5-01', 'practice', restart: true);
        await ready();
        final q = controller.puzzle!;
        final pair = [
          for (var a = 0; a < q.n * q.n; a++)
            for (var b = a + 1; b < q.n * q.n; b++)
              if (q.regionAt(a) != q.regionAt(b) &&
                  (code == 'row'
                      ? a ~/ q.n == b ~/ q.n && (a % q.n - b % q.n).abs() > 1
                      : code == 'column'
                      ? a % q.n == b % q.n && (a ~/ q.n - b ~/ q.n).abs() > 1
                      : (a ~/ q.n - b ~/ q.n).abs() == 1 &&
                            (a % q.n - b % q.n).abs() == 1))
                (a, b),
        ].first;
        for (final cell in [pair.$1, pair.$2]) {
          await tester.longPress(find.byKey(ValueKey('cell-$cell')));
          await ready();
        }
        expect(
          container.read(appProvider).game!.session.marks[pair.$2],
          CellMark.token,
        );
        expect(container.read(appProvider).placementFeedback, isNull);
        expect(find.text(AppText.conflict(code)), findsOneWidget);
        expect(
          find.byKey(ValueKey('conflict-warning-${pair.$1}')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('conflict-warning-${pair.$2}')),
          findsOneWidget,
        );
        await controller.open(q.levelId, 'practice');
        await ready();
        expect(
          container.read(appProvider).game!.session.marks[pair.$2],
          CellMark.token,
        );
        expect(find.text(AppText.conflict(code)), findsOneWidget);
        await tester.tap(find.text('Undo'));
        await ready();
        expect(
          container.read(appProvider).game!.session.marks[pair.$2],
          CellMark.unknown,
        );
        expect(
          find.byKey(ValueKey('conflict-warning-${pair.$1}')),
          findsNothing,
        );
      }

      final first = controller.catalog.journey.first;
      await controller.open(first, 'journey', restart: true);
      await ready();
      final originalBalance = container.read(appProvider).balance;
      final p = controller.catalog.levels[first]!;
      expect(find.byKey(const ValueKey('mode-place')), findsNothing);
      final mutable = List.generate(
        p.n,
        (r) => r * p.n + p.solution[r],
      ).firstWhere((i) => !p.isGiven(i));
      final wrong = List.generate(p.n * p.n, (i) => i).firstWhere(
        (i) =>
            !p.isGiven(i) &&
            const PlacementPolicy().check(
                  p,
                  container.read(appProvider).game!.session.marks,
                  i,
                ) !=
                null,
      );
      final beforeRejected = container
          .read(appProvider)
          .game!
          .session
          .moveCount;
      await tester.longPress(find.byKey(ValueKey('cell-$wrong')));
      await ready();
      expect(
        container.read(appProvider).game!.session.marks[wrong],
        isNot(CellMark.token),
      );
      expect(
        container.read(appProvider).game!.session.moveCount,
        beforeRejected,
      );
      expect(
        find.byTooltip('Enlarge board; scroll to reach all cells'),
        findsNothing,
      );

      await tester.ensureVisible(find.byKey(ValueKey('cell-$mutable')));
      await tester.longPress(find.byKey(ValueKey('cell-$mutable')));
      await ready();
      expect(
        container.read(appProvider).game!.session.marks[mutable],
        CellMark.token,
      );
      await tester.ensureVisible(find.text('Undo'));
      await tester.tap(find.text('Undo'));
      await ready();
      expect(
        container.read(appProvider).game!.session.marks[mutable],
        CellMark.unknown,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('cell-8')));
      final stroke = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('cell-8'))),
      );
      await stroke.moveTo(
        tester.getCenter(find.byKey(const ValueKey('cell-11'))),
      );
      await stroke.up();
      await ready();
      expect(
        container.read(appProvider).game!.session.marks.sublist(8, 12),
        everyElement(CellMark.excluded),
      );
      final afterPaint = container.read(appProvider).game!.session.moveCount;
      await tester.ensureVisible(find.text('Undo'));
      await tester.tap(find.text('Undo'));
      await ready();
      expect(
        container.read(appProvider).game!.session.marks.sublist(8, 12),
        everyElement(CellMark.unknown),
      );
      expect(container.read(appProvider).game!.session.moveCount, afterPaint);
      for (var r = 0; r < p.n; r++) {
        final i = r * p.n + p.solution[r];
        if (p.isGiven(i)) continue;
        await tester.ensureVisible(find.byKey(ValueKey('cell-$i')));
        await tester.longPress(find.byKey(ValueKey('cell-$i')));
        await ready();
      }
      expect(find.text('Everyone’s home.'), findsOneWidget);
      final firstBalance = container.read(appProvider).balance;
      expect(firstBalance, anyOf(originalBalance, originalBalance + 12));
      await controller.open(first, 'journey', restart: true);
      await ready();
      for (var r = 0; r < p.n; r++) {
        final i = r * p.n + p.solution[r];
        if (p.isGiven(i)) continue;
        await tester.ensureVisible(find.byKey(ValueKey('cell-$i')));
        await tester.longPress(find.byKey(ValueKey('cell-$i')));
        await ready();
      }
      expect(container.read(appProvider).balance, firstBalance);
      await tester.ensureVisible(find.text('Next garden'));
      await tester.tap(find.text('Next garden'));
      await ready();
      expect(find.byType(PuzzleBoard), findsOneWidget);
      await tester.tap(find.byTooltip('Pause game'));
      await ready();
      expect(find.text('Take a little breath.'), findsOneWidget);
      final pausedMs = controller.elapsedMs;
      await tester.pump(const Duration(seconds: 2));
      expect(controller.elapsedMs, pausedMs);
      await tester.tap(find.text('Keep growing'));
      await ready();
      expect(container.read(appProvider).paused, false);
      await tester.tap(find.byTooltip('Pause game'));
      await ready();
      await tester.tap(find.text('Back to garden'));
      await ready();
      expect(find.byType(PuzzleScreen), findsNothing);
      expect(find.byType(GardenWorld), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
