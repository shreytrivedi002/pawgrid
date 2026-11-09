import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'art.dart';
import 'contour.dart';

/// Static vector scenery: no background animation loop or image downloads.
class GardenBackdrop extends StatelessWidget {
  const GardenBackdrop({super.key});
  @override
  Widget build(BuildContext context) => const Positioned.fill(
    child: IgnorePointer(child: CustomPaint(painter: _BackdropPainter())),
  );
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();
  @override
  void paint(Canvas c, Size s) {
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.9, -.9),
          radius: 1.9,
          colors: [Color(0xFF2A2942), Color(0xFF191B2B)],
        ).createShader(Offset.zero & s),
    );
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => false;
}

void drawFlower(Canvas c, Offset center, double radius, Color color) {
  for (var p = 0; p < 5; p++) {
    final angle = p * math.pi * 2 / 5;
    c.drawCircle(
      center + Offset(math.cos(angle), math.sin(angle)) * radius * .62,
      radius * .45,
      Paint()..color = color,
    );
  }
  c.drawCircle(center, radius * .29, Paint()..color = const Color(0xFFEBA744));
}

class GardenWorld extends StatelessWidget {
  const GardenWorld({
    super.key,
    this.height = 280,
    this.creature = 'moss',
    this.chapter = 0,
  });
  final double height;
  final String creature;
  final int chapter;
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: reduce ? 1 : 0, end: 1),
        duration: Duration(milliseconds: reduce ? 0 : 1000),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: RepaintBoundary(
            child: CustomPaint(painter: _WorldPainter(creature, chapter)),
          ),
        ),
        builder: (context, t, child) => Opacity(
          opacity: .7 + .3 * t,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - t)),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _WorldPainter extends CustomPainter {
  const _WorldPainter(this.creature, this.chapter);
  final String creature;
  final int chapter;
  @override
  void paint(Canvas c, Size size) {
    c.save();
    c.drawPath(
      gardenContour(Offset.zero & size, 24),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF37314E), Color(0xFF242438)],
        ).createShader(Offset.zero & size),
    );
    containArtwork(c, size, const Size(400, 300));
    c.drawCircle(
      const Offset(224, 143),
      87,
      Paint()
        ..color = chapter >= 6
            ? const Color(0xFFC8B5F7)
            : const Color(0xFFD7F985),
    );
    c.save();
    c.translate(220, 145);
    c.rotate(-.4);
    c.drawOval(
      const Rect.fromLTWH(-145, -30, 290, 60),
      Paint()
        ..color = const Color(0xFFC8B5F7).withValues(alpha: .3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    c.restore();
    c.drawOval(
      const Rect.fromLTWH(95, 260, 235, 18),
      Paint()..color = const Color(0xFF131521).withValues(alpha: .6),
    );
    Path polygon(List<Offset> points) => Path()..addPolygon(points, true);
    c.drawPath(
      polygon(const [
        Offset(68, 214),
        Offset(213, 164),
        Offset(349, 214),
        Offset(203, 270),
      ]),
      Paint()..color = const Color(0xFF75B99B),
    );
    c.drawPath(
      polygon(const [
        Offset(68, 214),
        Offset(203, 270),
        Offset(203, 288),
        Offset(68, 233),
      ]),
      Paint()..color = const Color(0xFF63518C),
    );
    c.drawPath(
      polygon(const [
        Offset(203, 270),
        Offset(349, 214),
        Offset(349, 233),
        Offset(203, 288),
      ]),
      Paint()..color = const Color(0xFF8D6ABB),
    );
    c.drawPath(
      Path()
        ..moveTo(203, 268)
        ..cubicTo(135, 239, 179, 232, 220, 220)
        ..cubicTo(249, 211, 256, 194, 233, 185),
      Paint()
        ..color = const Color(0xFFE8D8A0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 17,
    );
    for (final x in [115.0, 315.0]) {
      c.drawLine(
        Offset(x, 220),
        Offset(x - 5, 142),
        Paint()
          ..color = const Color(0xFF364F48)
          ..strokeWidth = 3,
      );
      for (var i = 0; i < 3; i++) {
        c.save();
        c.translate(x - 2, 168 + i * 18);
        c.rotate(i.isEven ? -.6 : .7);
        c.drawOval(
          const Rect.fromLTWH(-16, -20, 17, 30),
          Paint()
            ..color = i.isEven
                ? const Color(0xFFB8D781)
                : const Color(0xFF7FC5AD),
        );
        c.restore();
      }
    }
    for (final x in [130.0, 292.0, 310.0]) {
      c.drawLine(
        Offset(x, 245),
        Offset(x, 224),
        Paint()
          ..color = const Color(0xFFF4F1E8)
          ..strokeWidth = 3,
      );
      c.drawArc(
        Rect.fromCenter(center: Offset(x, 225), width: 23, height: 20),
        math.pi,
        math.pi,
        true,
        Paint()
          ..color = x == 130
              ? const Color(0xFFF5A47D)
              : const Color(0xFFC8B5F7),
      );
      c.drawCircle(
        Offset(x - 4, 220),
        1.5,
        Paint()..color = const Color(0xFFF4F1E8),
      );
    }
    c.save();
    c.translate(161, 121);
    c.scale(1.2);
    drawSprout(c, creature, false);
    c.restore();
    for (final point in const [
      Offset(110, 85),
      Offset(318, 104),
      Offset(338, 164),
      Offset(145, 58),
    ]) {
      final star = Path()
        ..moveTo(point.dx, point.dy - 7)
        ..lineTo(point.dx + 2, point.dy - 2)
        ..lineTo(point.dx + 7, point.dy)
        ..lineTo(point.dx + 2, point.dy + 2)
        ..lineTo(point.dx, point.dy + 7)
        ..lineTo(point.dx - 2, point.dy + 2)
        ..lineTo(point.dx - 7, point.dy)
        ..lineTo(point.dx - 2, point.dy - 2)
        ..close();
      c.drawPath(star, Paint()..color = const Color(0xFFC8B5F7));
    }
    c.restore();
  }

  @override
  bool shouldRepaint(_WorldPainter old) =>
      old.creature != creature || old.chapter != chapter;
}

class GardenCelebration extends StatelessWidget {
  const GardenCelebration({super.key, required this.creature});
  final String creature;
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, bounds) => TweenAnimationBuilder<double>(
        tween: Tween(begin: reduce ? 1 : 0, end: 1),
        duration: Duration(milliseconds: reduce ? 0 : 1800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, 26 * (1 - value)),
              child: Transform.scale(scale: .82 + value * .18, child: child),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _PetalPainter(value)),
              ),
            ),
          ],
        ),
        child: GardenWorld(
          height: math.min(bounds.maxHeight, bounds.maxWidth * .75),
          creature: creature,
        ),
      ),
    );
  }
}

class _PetalPainter extends CustomPainter {
  const _PetalPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas c, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final fade = math.pow(1 - progress, .7).toDouble();
    final palette = [
      const Color(0xFFD7F985),
      const Color(0xFFC8B5F7),
      const Color(0xFFF5B99E),
      const Color(0xFFF4F1E8),
    ];
    final origin = Offset(size.width * .5, size.height * .47);
    for (var ring = 0; ring < 2; ring++) {
      final rect = Rect.fromCenter(
        center: origin,
        width: size.width * (.34 + .52 * progress),
        height: size.height * (.16 + .46 * progress),
      );
      c.save();
      c.translate(origin.dx, origin.dy);
      c.rotate((ring == 0 ? 1 : -1) * .4);
      c.translate(-origin.dx, -origin.dy);
      c.drawArc(
        rect,
        ring * math.pi + progress * math.pi,
        math.pi * 1.15,
        false,
        Paint()
          ..color = palette[ring].withValues(alpha: fade * .65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      c.restore();
    }
    for (var i = 0; i < 42; i++) {
      final a = i * 2.39996;
      final spread = .2 + .8 * progress;
      final p =
          origin +
          Offset(
            math.cos(a) * size.width * .43 * spread,
            math.sin(a) * size.height * .4 * spread +
                size.height * .12 * progress * progress,
          );
      c.save();
      c.translate(p.dx, p.dy);
      c.rotate(a + progress * math.pi * (i.isEven ? 1 : -1));
      final paint = Paint()
        ..color = palette[i % palette.length].withValues(alpha: fade);
      if (i % 3 == 0) {
        final r = 3.0 + (i % 4);
        final star = Path()
          ..moveTo(0, -r)
          ..lineTo(r * .3, -r * .3)
          ..lineTo(r, 0)
          ..lineTo(r * .3, r * .3)
          ..lineTo(0, r)
          ..lineTo(-r * .3, r * .3)
          ..lineTo(-r, 0)
          ..lineTo(-r * .3, -r * .3)
          ..close();
        c.drawPath(star, paint);
      } else {
        c.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: 4 + (i % 3).toDouble(),
            height: 8 + (i % 5).toDouble(),
          ),
          paint,
        );
      }
      c.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalPainter old) => old.progress != progress;
}
