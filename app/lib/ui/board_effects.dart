import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'art.dart';
import 'design.dart';

/// Bounded reaction to a mark change/rejection. There is no idle animation loop.
class CellEffects extends StatefulWidget {
  const CellEffects({
    super.key,
    required this.mark,
    required this.size,
    required this.variant,
    this.rejectionSequence = 0,
    this.pressed = false,
    this.holdProgress = 0,
  });
  final CellMark mark;
  final double size;
  final String variant;
  final int rejectionSequence;
  final bool pressed;
  final double holdProgress;
  @override
  State<CellEffects> createState() => _CellEffectsState();
}

class _CellEffectsState extends State<CellEffects>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
    value: 1,
  );
  CellMark _previous = CellMark.unknown;
  bool _reject = false;
  @override
  void didUpdateWidget(CellEffects old) {
    super.didUpdateWidget(old);
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 1;
      return;
    }
    if (widget.rejectionSequence > 0 &&
        widget.rejectionSequence != old.rejectionSequence) {
      _reject = true;
      _motion.duration = const Duration(milliseconds: 440);
      _motion.forward(from: 0);
    } else if (widget.mark != old.mark) {
      _previous = old.mark;
      _reject = false;
      _motion.duration = Duration(
        milliseconds: widget.mark == CellMark.token ? 680 : 360,
      );
      _motion.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, _) {
        final t = reduce ? 1.0 : _motion.value,
            active = !reduce && _motion.isAnimating;
        final mark = widget.mark;
        Widget content = const SizedBox.shrink();
        if (mark == CellMark.token) {
          final landing = 1 + math.sin(t * math.pi * 3) * (1 - t) * .19;
          content = Transform.translate(
            offset: Offset(
              0,
              active && !_reject
                  ? -math.sin(t * math.pi) * widget.size * .19
                  : 0,
            ),
            child: Transform.scale(
              scale: active && !_reject ? (.55 + .45 * t) * landing : 1,
              child: Transform.rotate(
                angle: active && !_reject
                    ? math.sin(t * math.pi * 2) * (1 - t) * .11
                    : 0,
                child: Sprout(size: widget.size * .88, variant: widget.variant),
              ),
            ),
          );
        } else if (mark == CellMark.excluded) {
          content = SizedBox.square(
            dimension: widget.size * .45,
            child: CustomPaint(
              painter: _CrossPainter(
                active && !_reject ? Curves.easeOutCubic.transform(t) : 1,
              ),
            ),
          );
        } else if (active && !_reject && _previous != CellMark.unknown) {
          content = Opacity(
            opacity: 1 - t,
            child: Transform.scale(
              scale: 1 - t * .55,
              child: Transform.rotate(
                angle: t * .25,
                child: _previous == CellMark.token
                    ? Sprout(size: widget.size * .88, variant: widget.variant)
                    : SizedBox.square(
                        dimension: widget.size * .45,
                        child: CustomPaint(painter: const _CrossPainter(1)),
                      ),
              ),
            ),
          );
        }
        final shake = active && _reject
            ? math.sin(t * math.pi * 6) * (1 - t) * 6
            : 0.0;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (active && _reject)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE7886E,
                    ).withValues(alpha: (1 - t) * .36),
                    border: Border.all(
                      color: const Color(
                        0xFFB65349,
                      ).withValues(alpha: 1 - t * .6),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            AnimatedScale(
              scale: widget.pressed ? .94 : 1,
              duration: Duration(milliseconds: reduce ? 0 : 90),
              child: Transform.translate(
                offset: Offset(shake, 0),
                child: content,
              ),
            ),
            if (active && !_reject && mark != CellMark.unknown)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _MoveSparkles(t, mark == CellMark.token),
                  ),
                ),
              ),
            if (widget.pressed && widget.holdProgress > .1 && !reduce)
              SizedBox.square(
                dimension: widget.size * .76,
                child: CircularProgressIndicator(
                  value: widget.holdProgress,
                  strokeWidth: 2.5,
                  color: const Color(0xFFD7F985),
                  backgroundColor: Colors.white.withValues(alpha: .22),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CrossPainter extends CustomPainter {
  const _CrossPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas c, Size size) {
    final pen = Paint()
      ..color = boardInk.withValues(alpha: .66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, size.width * .12)
      ..strokeCap = StrokeCap.round;
    final a = Offset(size.width * .20, size.height * .20),
        b = Offset(size.width * .80, size.height * .80);
    c.drawLine(a, Offset.lerp(a, b, (progress * 2).clamp(0, 1))!, pen);
    if (progress > .5) {
      final d = Offset(size.width * .8, size.height * .2),
          e = Offset(size.width * .2, size.height * .8);
      c.drawLine(d, Offset.lerp(d, e, ((progress - .5) * 2).clamp(0, 1))!, pen);
    }
  }

  @override
  bool shouldRepaint(_CrossPainter old) => old.progress != progress;
}

class _MoveSparkles extends CustomPainter {
  const _MoveSparkles(this.progress, this.placed);
  final double progress;
  final bool placed;
  @override
  void paint(Canvas c, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.center(Offset.zero),
        radius = size.shortestSide * (.12 + .35 * progress);
    final paint = Paint()
      ..color = (placed ? const Color(0xFFD7F985) : Colors.white).withValues(
        alpha: (1 - progress) * .9,
      );
    for (var i = 0; i < (placed ? 7 : 4); i++) {
      final angle = i * math.pi * 2 / (placed ? 7 : 4) - math.pi / 2;
      final p = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      c.drawCircle(p, (placed ? 2.4 : 1.8) * (1 - progress * .5), paint);
    }
    if (placed) {
      c.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: (1 - progress) * .5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_MoveSparkles old) =>
      old.progress != progress || old.placed != placed;
}

class ReactiveBuddy extends StatefulWidget {
  const ReactiveBuddy({
    super.key,
    required this.count,
    required this.variant,
    required this.rejectionSequence,
    this.size = 44,
  });
  final int count, rejectionSequence;
  final String variant;
  final double size;
  @override
  State<ReactiveBuddy> createState() => _ReactiveBuddyState();
}

class _ReactiveBuddyState extends State<ReactiveBuddy>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );
  bool _worried = false;
  @override
  void didUpdateWidget(ReactiveBuddy old) {
    super.didUpdateWidget(old);
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 1;
      return;
    }
    if (widget.count != old.count ||
        widget.rejectionSequence != old.rejectionSequence) {
      _worried =
          widget.rejectionSequence > 0 &&
          widget.rejectionSequence != old.rejectionSequence;
      _motion.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _motion,
    builder: (context, _) {
      final t = MediaQuery.disableAnimationsOf(context) ? 1.0 : _motion.value;
      return Transform.translate(
        offset: Offset(
          _worried ? math.sin(t * math.pi * 5) * (1 - t) * 3 : 0,
          _worried ? 0 : -math.sin(t * math.pi) * 7,
        ),
        child: Transform.rotate(
          angle: _worried ? 0 : math.sin(t * math.pi * 2) * (1 - t) * .12,
          child: Sprout(
            size: widget.size,
            variant: widget.variant,
            sleeping: _worried && t < .55,
          ),
        ),
      );
    },
  );
}
