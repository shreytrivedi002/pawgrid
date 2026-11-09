import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puzzle_core/puzzle_core.dart';
import '../state/app_controller.dart';
import 'board_effects.dart';
import 'board_motion.dart';
import 'design.dart';
import 'contour.dart';

class PuzzleBoard extends ConsumerStatefulWidget {
  const PuzzleBoard({
    super.key,
    required this.puzzle,
    required this.session,
    this.hintCell,
    this.lessonCells = const {},
  });
  final PuzzleDefinition puzzle;
  final PuzzleSession session;
  final int? hintCell;
  final Set<int> lessonCells;
  @override
  ConsumerState<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends ConsumerState<PuzzleBoard>
    with SingleTickerProviderStateMixin {
  final Set<int> _stroke = <int>{};
  List<FocusNode> _focus = [];
  CellMark? _paintMark;
  Offset? _down, _previous, _rawPosition;
  int? _pressed;
  double _tile = 0;
  bool _committing = false;
  late final AnimationController _hold =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..addListener(() {
        if (mounted) setState(() {});
      });
  @override
  void initState() {
    super.initState();
    _makeFocus();
  }

  void _makeFocus() {
    _focus = List.generate(
      widget.puzzle.n * widget.puzzle.n,
      (_) => FocusNode(),
    );
  }

  @override
  void didUpdateWidget(PuzzleBoard old) {
    super.didUpdateWidget(old);
    if (old.puzzle.contentHash != widget.puzzle.contentHash) {
      for (final node in _focus) {
        node.dispose();
      }
      _makeFocus();
      _stroke.clear();
      _paintMark = null;
      _pressed = null;
      _down = null;
      _previous = null;
    }
  }

  @override
  void dispose() {
    _hold.dispose();
    for (final node in _focus) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _canEdit {
    final state = ref.read(appProvider);
    return !_committing &&
        !state.paused &&
        state.game?.levelId == widget.puzzle.levelId &&
        !Rules.isWon(widget.puzzle, state.game!.session.marks);
  }

  int? _cellAt(Offset position) {
    final n = widget.puzzle.n;
    if (_tile <= 0 ||
        position.dx < 0 ||
        position.dy < 0 ||
        position.dx >= _tile * n ||
        position.dy >= _tile * n) {
      return null;
    }
    return (position.dy / _tile).floor() * n + (position.dx / _tile).floor();
  }

  void _feedback({bool hold = false}) {
    if (ref.read(appProvider).enabled('haptics', fallback: true)) {
      if (hold) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _tap(Offset position) {
    if (!_canEdit) return;
    final cell = _cellAt(position);
    if (cell == null || widget.puzzle.isGiven(cell)) return;
    _focus[cell].requestFocus();
    ref.read(appProvider.notifier).selectCell(cell);
    _feedback();
    ref.read(appProvider.notifier).tap(cell);
  }

  void _place(int cell) {
    if (!_canEdit || widget.puzzle.isGiven(cell)) return;
    _focus[cell].requestFocus();
    ref.read(appProvider.notifier).selectCell(cell);
    ref.read(appProvider.notifier).placeCreature(cell).then((_) {
      if (mounted && ref.read(appProvider).placementFeedback == null) {
        _feedback(hold: true);
      }
    });
  }

  void _visit(Offset position) {
    final cell = _cellAt(position);
    if (cell == null ||
        widget.puzzle.isGiven(cell) ||
        widget.session.marks[cell] == CellMark.token) {
      return;
    }
    _stroke.add(cell);
  }

  void _segment(Offset from, Offset to) {
    final steps = math
        .max(1, ((to - from).distance / (_tile * .25)).ceil())
        .clamp(1, 2048);
    for (var i = 0; i <= steps; i++) {
      _visit(Offset.lerp(from, to, i / steps)!);
    }
  }

  void _startStroke(DragStartDetails details) {
    _hold.stop();
    if (!_canEdit) return;
    final start = _down ?? details.localPosition, cell = _cellAt(start);
    if (cell == null ||
        widget.puzzle.isGiven(cell) ||
        widget.session.marks[cell] == CellMark.token) {
      return;
    }
    setState(() {
      _paintMark = widget.session.marks[cell] == CellMark.excluded
          ? CellMark.unknown
          : CellMark.excluded;
      _stroke.clear();
      _pressed = null;
      _previous = _rawPosition ?? details.localPosition;
      _segment(start, _previous!);
    });
    _feedback();
  }

  void _moveStroke(DragUpdateDetails details) {
    if (_paintMark == null) return;
    setState(() {
      _segment(_previous ?? details.localPosition, details.localPosition);
      _previous = details.localPosition;
    });
  }

  Future<void> _finishStroke() async {
    if (!mounted) return;
    if (_paintMark == null) return;
    final cells = List<int>.of(_stroke), mark = _paintMark!;
    setState(() => _committing = true);
    try {
      await ref.read(appProvider.notifier).paintCrosses(cells, mark);
    } finally {
      if (mounted) {
        setState(() {
          _committing = false;
          _stroke.clear();
          _paintMark = null;
          _previous = null;
          _pressed = null;
        });
      }
    }
  }

  void _cancel() {
    if (!mounted) return;
    _hold.stop();
    _hold.value = 0;
    if (_stroke.isNotEmpty || _pressed != null) {
      setState(() {
        _stroke.clear();
        _paintMark = null;
        _pressed = null;
        _previous = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier),
        p = widget.puzzle;
    final marks = widget.session.marks;
    final conflicts = state.enabled('errors', fallback: true)
        ? Rules.conflicts(p, marks)
        : <RuleConflict>[];
    final conflictCells = conflicts.expand((c) => c.cells).toSet();
    final patterns = state.enabled('patterns', fallback: true),
        contrast = state.enabled('contrast');
    ref.listen(appProvider.select((s) => s.placementFeedback), (
      previous,
      next,
    ) {
      if (next != null &&
          next.sequence != previous?.sequence &&
          state.enabled('haptics', fallback: true)) {
        HapticFeedback.mediumImpact();
      }
    });
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth;
        final frame = side < 280 ? 8.0 : 12.0;
        _tile = (side - frame * 2) / p.n;
        final grid = FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var r = 0; r < p.n; r++)
                Row(
                  children: [
                    for (var c = 0; c < p.n; c++)
                      Builder(
                        builder: (context) {
                          final i = r * p.n + c,
                              region = p.regionAt(i),
                              fixed = p.isGiven(i);
                          final mark = _stroke.contains(i) && _paintMark != null
                              ? _paintMark!
                              : marks[i];
                          final conflict = conflictCells.contains(i);
                          final label =
                              'Row ${r + 1}, column ${c + 1}, garden ${String.fromCharCode(65 + region)}, '
                              '${mark == CellMark.token
                                  ? 'creature'
                                  : mark == CellMark.excluded
                                  ? 'excluded'
                                  : 'empty'}'
                              '${fixed ? ', fixed clue' : ''}${conflict ? ', conflict' : ''}${widget.lessonCells.contains(i) ? ', tutorial target' : ''}';
                          final base = contrast
                              ? Color.lerp(
                                  regionColors[region],
                                  Colors.white,
                                  .18,
                                )!
                              : regionColors[region];
                          final enabled =
                              !fixed && !state.paused && !Rules.isWon(p, marks);
                          return FocusTraversalOrder(
                            order: NumericFocusOrder(i.toDouble()),
                            child: Semantics(
                              key: ValueKey('cell-$i'),
                              label: label,
                              selected: state.selectedCell == i,
                              button: !fixed,
                              enabled: enabled,
                              hint: fixed
                                  ? null
                                  : 'Tap to mark. Use Actions to place or clear a creature.',
                              onTap: enabled ? () => controller.tap(i) : null,
                              onLongPress: enabled ? () => _place(i) : null,
                              customSemanticsActions: enabled
                                  ? {
                                      const CustomSemanticsAction(
                                        label: 'Place or remove creature',
                                      ): () =>
                                          _place(i),
                                      const CustomSemanticsAction(
                                        label: 'Mark or remove cross',
                                      ): () =>
                                          controller.tap(i),
                                      const CustomSemanticsAction(
                                        label: 'Clear cell',
                                      ): () =>
                                          controller.clearCell(i),
                                    }
                                  : null,
                              child: ExcludeSemantics(
                                child: FocusableActionDetector(
                                  focusNode: _focus[i],
                                  enabled: enabled,
                                  onFocusChange: (focused) {
                                    if (focused) controller.selectCell(i);
                                  },
                                  shortcuts: const {
                                    SingleActivator(LogicalKeyboardKey.enter):
                                        ActivateIntent(),
                                    SingleActivator(LogicalKeyboardKey.space):
                                        ActivateIntent(),
                                    SingleActivator(LogicalKeyboardKey.keyP):
                                        _PlaceIntent(),
                                    SingleActivator(
                                      LogicalKeyboardKey.backspace,
                                    ): _ClearIntent(),
                                  },
                                  actions: {
                                    ActivateIntent:
                                        CallbackAction<ActivateIntent>(
                                          onInvoke: (_) {
                                            controller.tap(i);
                                            return null;
                                          },
                                        ),
                                    _PlaceIntent: CallbackAction<_PlaceIntent>(
                                      onInvoke: (_) {
                                        _place(i);
                                        return null;
                                      },
                                    ),
                                    _ClearIntent: CallbackAction<_ClearIntent>(
                                      onInvoke: (_) {
                                        controller.clearCell(i);
                                        return null;
                                      },
                                    ),
                                  },
                                  child: ListenableBuilder(
                                    listenable: _focus[i],
                                    builder: (context, child) => Container(
                                      width: _tile,
                                      height: _tile,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color.lerp(
                                              base,
                                              Colors.white,
                                              .18,
                                            )!,
                                            base,
                                          ],
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (patterns)
                                            Positioned(
                                              top: 3,
                                              left: 4,
                                              child: Text(
                                                String.fromCharCode(
                                                  65 + region,
                                                ),
                                                textScaler:
                                                    TextScaler.noScaling,
                                                style: TextStyle(
                                                  fontSize: math.min(
                                                    9,
                                                    _tile * .25,
                                                  ),
                                                  fontWeight: FontWeight.w900,
                                                  color: boardInk.withValues(
                                                    alpha: contrast ? .9 : .55,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Positioned.fill(
                                            child: CellEffects(
                                              mark: mark,
                                              size: _tile,
                                              variant: state.equipped,
                                              pressed: _pressed == i,
                                              holdProgress: _pressed == i
                                                  ? _hold.value
                                                  : 0,
                                              rejectionSequence:
                                                  state
                                                          .placementFeedback
                                                          ?.cell ==
                                                      i
                                                  ? state
                                                        .placementFeedback!
                                                        .sequence
                                                  : 0,
                                            ),
                                          ),
                                          if (fixed)
                                            Positioned(
                                              bottom: 3,
                                              right: 4,
                                              child: Icon(
                                                Icons.lock_rounded,
                                                size: 9,
                                                color: boardInk.withValues(
                                                  alpha: .48,
                                                ),
                                              ),
                                            ),
                                          if (conflict ||
                                              widget.lessonCells.contains(i) ||
                                              _pressed == i ||
                                              widget.hintCell == i ||
                                              _focus[i].hasFocus)
                                            Positioned.fill(
                                              child: IgnorePointer(
                                                child: Container(
                                                  key: conflict
                                                      ? ValueKey(
                                                          'conflict-indicator-$i',
                                                        )
                                                      : null,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 3,
                                                      color: conflict
                                                          ? const Color(
                                                              0xFFB64C43,
                                                            )
                                                          : const Color(
                                                              0xFFD2A126,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (conflict)
                                            Positioned(
                                              left: 3,
                                              bottom: 3,
                                              child: Icon(
                                                Icons.error_outline_rounded,
                                                key: ValueKey(
                                                  'conflict-warning-$i',
                                                ),
                                                size: math.min(15, _tile * .29),
                                                color: const Color(0xFFB64C43),
                                              ),
                                            ),
                                          if (widget.lessonCells.contains(i))
                                            const Positioned(
                                              right: 3,
                                              top: 3,
                                              child: Icon(
                                                Icons.touch_app_rounded,
                                                size: 15,
                                                color: Color(0xFF986B12),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
            ],
          ),
        );
        final board = DecoratedBox(
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3A3A50), Color(0xFF292A3D)],
            ),
            shape: const GardenOutline(
              side: BorderSide(color: Color(0xFF656178), width: 2),
            ),
            shadows: const [
              BoxShadow(color: Color(0xFF11121D), offset: Offset(0, 6)),
              BoxShadow(
                color: Color(0x22344C39),
                blurRadius: 16,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(frame),
            child: ClipPath(
              clipper: const ShapeBorderClipper(
                shape: GardenOutline(radius: 5),
              ),
              child: Listener(
                onPointerDown: (event) {
                  if (!mounted) return;
                  _down = event.localPosition;
                  _rawPosition = event.localPosition;
                  if (_canEdit) {
                    setState(() => _pressed = _cellAt(event.localPosition));
                    if (!MediaQuery.disableAnimationsOf(context)) {
                      _hold.forward(from: 0);
                    }
                  }
                },
                onPointerMove: (event) => _rawPosition = event.localPosition,
                onPointerUp: (_) {
                  if (!mounted) return;
                  _hold.stop();
                  _hold.value = 0;
                  if (mounted) setState(() => _pressed = null);
                },
                onPointerCancel: (_) => _cancel(),
                child: GestureDetector(
                  key: const ValueKey('board-gesture'),
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  dragStartBehavior: DragStartBehavior.down,
                  onTapUp: (d) {
                    _tap(d.localPosition);
                  },
                  onLongPressStart: (d) {
                    _hold.stop();
                    final cell = _cellAt(d.localPosition);
                    if (cell != null) _place(cell);
                  },
                  onPanStart: _startStroke,
                  onPanUpdate: _moveStroke,
                  onPanEnd: (_) => _finishStroke(),
                  onPanCancel: _cancel,
                  child: CustomPaint(
                    foregroundPainter: _GridLines(
                      p,
                      MediaQuery.devicePixelRatioOf(context),
                    ),
                    child: grid,
                  ),
                ),
              ),
            ),
          ),
        );
        return SizedBox.square(
          dimension: side,
          child: BoardMotion(
            puzzle: p,
            session: widget.session,
            epoch: state.gameEpoch,
            paused: state.paused,
            child: board,
          ),
        );
      },
    );
  }
}

class _PlaceIntent extends Intent {
  const _PlaceIntent();
}

class _ClearIntent extends Intent {
  const _ClearIntent();
}

/// Draw each shared edge once, with filled rectangles aligned to device pixels.
class _GridLines extends CustomPainter {
  const _GridLines(this.puzzle, this.dpr);
  final PuzzleDefinition puzzle;
  final double dpr;
  @override
  void paint(Canvas c, Size size) {
    final tile = size.width / puzzle.n;
    double snap(double v) => (v * dpr).round() / dpr;
    void edge(Rect rect, bool boundary) {
      c.drawRect(
        Rect.fromLTRB(
          snap(rect.left),
          snap(rect.top),
          snap(rect.right),
          snap(rect.bottom),
        ),
        Paint()
          ..color = boardInk.withValues(alpha: boundary ? .85 : .25)
          ..isAntiAlias = false,
      );
    }

    for (var r = 0; r < puzzle.n; r++) {
      for (var col = 0; col < puzzle.n; col++) {
        final region = puzzle.regions[r][col];
        if (col < puzzle.n - 1) {
          final boundary = region != puzzle.regions[r][col + 1];
          final width = boundary ? 3.0 : 1.0;
          edge(
            Rect.fromLTWH((col + 1) * tile - width / 2, r * tile, width, tile),
            boundary,
          );
        }
        if (r < puzzle.n - 1) {
          final boundary = region != puzzle.regions[r + 1][col];
          final width = boundary ? 3.0 : 1.0;
          edge(
            Rect.fromLTWH(col * tile, (r + 1) * tile - width / 2, tile, width),
            boundary,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GridLines old) =>
      old.puzzle.contentHash != puzzle.contentHash || old.dpr != dpr;
}
