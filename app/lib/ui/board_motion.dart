import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:puzzle_core/puzzle_core.dart';
import '../feedback/feedback_cue.dart';
import 'design.dart';

/// A finite command flourish. Keeps the child's original hit testing/semantics.
class BoardMotion extends StatefulWidget {
  const BoardMotion({
    super.key,
    required this.puzzle,
    required this.session,
    required this.epoch,
    required this.paused,
    required this.child,
  });
  final PuzzleDefinition puzzle;
  final PuzzleSession session;
  final int epoch;
  final bool paused;
  final Widget child;
  @override
  State<BoardMotion> createState() => _BoardMotionState();
}

class _BoardMotionState extends State<BoardMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
    value: 1,
  );
  FeedbackCue? _cue;
  List<int> _cells = [];
  @override
  void didUpdateWidget(BoardMotion old) {
    super.didUpdateWidget(old);
    if (widget.paused ||
        MediaQuery.disableAnimationsOf(context) ||
        old.epoch != widget.epoch ||
        old.puzzle.contentHash != widget.puzzle.contentHash) {
      _motion.value = 1;
      return;
    }
    final cue = cueForChange(widget.puzzle, old.session, widget.session);
    if (cue == null) return;
    _cue = cue;
    _cells = [
      for (var i = 0; i < widget.session.marks.length; i++)
        if (old.session.marks[i] != widget.session.marks[i]) i,
    ];
    _motion.forward(from: 0);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _motion,
    child: widget.child,
    builder: (context, child) {
      final t = MediaQuery.disableAnimationsOf(context) ? 1.0 : _motion.value;
      final bounce = math.sin(t * math.pi) * (1 - t);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          child!,
          if (t > 0 && t < 1)
            Positioned.fill(
              child: IgnorePointer(
                child: Transform.scale(
                  scale: 1 + .035 * bounce,
                  child: CustomPaint(
                    painter: _CommandFlourish(t, _cue, _cells, widget.puzzle),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _CommandFlourish extends CustomPainter {
  const _CommandFlourish(this.t, this.cue, this.cells, this.puzzle);
  final double t;
  final FeedbackCue? cue;
  final List<int> cells;
  final PuzzleDefinition puzzle;
  @override
  void paint(Canvas c, Size size) {
    if (cells.isEmpty || t <= 0 || t >= 1) return;
    final frame = size.width < 280 ? 8.0 : 12.0,
        tile = (size.width - 2 * frame) / puzzle.n;
    Offset center(int i) => Offset(
      frame + (i % puzzle.n + .5) * tile,
      frame + (i ~/ puzzle.n + .5) * tile,
    );
    final color = cue == FeedbackCue.warning
        ? warning
        : cue == FeedbackCue.undo
        ? lavender
        : green;
    final fade = (1 - t) * (1 - t);
    if (cue == FeedbackCue.place ||
        cue == FeedbackCue.warning ||
        cue == FeedbackCue.hint) {
      final p = center(cells.first),
          radius = tile * (.18 + .54 * Curves.easeOutCubic.transform(t));
      c.drawCircle(
        p,
        radius,
        Paint()
          ..color = color.withValues(alpha: fade * .75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * (1 - t) + .5,
      );
      for (var i = 0; i < 10; i++) {
        final a = i * math.pi / 5 + t * .55;
        final q = p + Offset(math.cos(a), math.sin(a)) * radius;
        c.save();
        c.translate(q.dx, q.dy);
        c.rotate(a + t);
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 2.5,
              height: 6 * (1 - t) + 1,
            ),
            const Radius.circular(2),
          ),
          Paint()..color = color.withValues(alpha: fade),
        );
        c.restore();
      }
      final region = puzzle.regionAt(cells.first);
      final edge = Paint()
        ..color = color.withValues(alpha: fade * .8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      for (var r = 0; r < puzzle.n; r++) {
        for (var col = 0; col < puzzle.n; col++) {
          final i = r * puzzle.n + col;
          if (puzzle.regionAt(i) != region) continue;
          final x = frame + col * tile, y = frame + r * tile;
          if (r == 0 || puzzle.regions[r - 1][col] != region) {
            c.drawLine(Offset(x, y), Offset(x + tile, y), edge);
          }
          if (r == puzzle.n - 1 || puzzle.regions[r + 1][col] != region) {
            c.drawLine(Offset(x, y + tile), Offset(x + tile, y + tile), edge);
          }
          if (col == 0 || puzzle.regions[r][col - 1] != region) {
            c.drawLine(Offset(x, y), Offset(x, y + tile), edge);
          }
          if (col == puzzle.n - 1 || puzzle.regions[r][col + 1] != region) {
            c.drawLine(Offset(x + tile, y), Offset(x + tile, y + tile), edge);
          }
        }
      }
    } else {
      final trail = Path()
        ..moveTo(center(cells.first).dx, center(cells.first).dy);
      for (final cell in cells.skip(1)) {
        final p = center(cell);
        trail.lineTo(p.dx, p.dy);
      }
      for (final metric in trail.computeMetrics()) {
        c.drawPath(
          metric.extractPath(0, metric.length * Curves.easeOut.transform(t)),
          Paint()
            ..color = color.withValues(alpha: fade * .65)
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 3,
        );
      }
      for (final cell in cells) {
        final p = center(cell);
        c.drawCircle(
          p,
          tile * (.08 + .22 * t),
          Paint()
            ..color = color.withValues(alpha: fade * .55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CommandFlourish old) =>
      old.t != t || old.cue != cue || old.cells != cells;
}
