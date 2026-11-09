import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'design.dart';
import 'contour.dart';

class Sprout extends StatelessWidget {
  const Sprout({
    super.key,
    this.size = 64,
    this.variant = 'moss',
    this.sleeping = false,
  });
  final double size;
  final String variant;
  final bool sleeping;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: SproutPainter(variant, sleeping)),
    ),
  );
}

class SproutPainter extends CustomPainter {
  const SproutPainter(this.variant, this.sleeping);
  final String variant;
  final bool sleeping;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    containArtwork(canvas, size, const Size(100, 100));
    drawSprout(canvas, variant, sleeping);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SproutPainter old) =>
      old.variant != variant || old.sleeping != sleeping;
}

void drawSprout(Canvas c, String variant, bool sleeping) {
  final body = variant == 'peach'
      ? const Color(0xFFF5C7A6)
      : variant == 'moon'
      ? const Color(0xFFD6D9EE)
      : const Color(0xFFF6EACB);
  final leaf = variant == 'peach'
      ? const Color(0xFFB56B49)
      : variant == 'moon'
      ? const Color(0xFF7F89AE)
      : const Color(0xFF78985A);
  final p = Paint()..color = const Color(0xFF374E3A);
  c.drawOval(
    const Rect.fromLTWH(13, 82, 76, 10),
    Paint()..color = boardInk.withValues(alpha: .10),
  );
  final tail = Path()
    ..moveTo(74, 75)
    ..cubicTo(104, 75, 99, 47, 86, 56)
    ..cubicTo(99, 68, 81, 66, 74, 62)
    ..close();
  c.drawPath(tail, Paint()..color = leaf);
  c.drawOval(const Rect.fromLTWH(19, 37, 62, 48), Paint()..color = body);
  c.drawOval(const Rect.fromLTWH(20, 75, 22, 12), Paint()..color = body);
  c.drawOval(const Rect.fromLTWH(58, 75, 22, 12), Paint()..color = body);
  final left = Path()
    ..moveTo(31, 47)
    ..cubicTo(13, 38, 19, 16, 27, 9)
    ..cubicTo(45, 18, 49, 35, 42, 46)
    ..close();
  final right = Path()
    ..moveTo(55, 43)
    ..cubicTo(52, 20, 69, 12, 81, 13)
    ..cubicTo(82, 32, 73, 45, 64, 48)
    ..close();
  c.drawPath(left, Paint()..color = leaf);
  c.drawPath(right, Paint()..color = leaf);
  final vein = Paint()
    ..color = Colors.white.withValues(alpha: .28)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;
  c.drawLine(const Offset(28, 18), const Offset(37, 42), vein);
  c.drawLine(const Offset(73, 20), const Offset(61, 40), vein);
  c.drawPath(
    gardenContour(const Rect.fromLTWH(17, 36, 64, 43), 22),
    Paint()..color = body,
  );
  c.drawOval(
    const Rect.fromLTWH(26, 59, 13, 7),
    Paint()..color = const Color(0xFFE9AA91).withValues(alpha: .55),
  );
  c.drawOval(
    const Rect.fromLTWH(61, 59, 13, 7),
    Paint()..color = const Color(0xFFE9AA91).withValues(alpha: .55),
  );
  if (sleeping) {
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    c.drawArc(const Rect.fromLTWH(34, 51, 8, 7), 0, math.pi, false, p);
    c.drawArc(const Rect.fromLTWH(57, 51, 8, 7), 0, math.pi, false, p);
  } else {
    c.drawOval(const Rect.fromLTWH(35, 52, 5, 7), p);
    c.drawOval(const Rect.fromLTWH(59, 52, 5, 7), p);
    c.drawCircle(const Offset(37, 54), .9, Paint()..color = Colors.white);
    c.drawCircle(const Offset(61, 54), .9, Paint()..color = Colors.white);
  }
  p
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  final mouth = Path()
    ..moveTo(44, 63)
    ..quadraticBezierTo(48, 68, 51, 63)
    ..quadraticBezierTo(54, 67, 57, 63);
  c.drawPath(mouth, p);
  c.drawOval(
    const Rect.fromLTWH(47, 59, 6, 4),
    Paint()..color = const Color(0xFF926D52),
  );
}

class GardenArt extends StatelessWidget {
  const GardenArt({
    super.key,
    this.height = 190,
    this.variant = 0,
    this.creature = 'moss',
  });
  final double height;
  final int variant;
  final String creature;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: GardenPainter(variant, creature)),
    ),
  );
}

class GardenPainter extends CustomPainter {
  GardenPainter(this.variant, this.creature);
  final int variant;
  final String creature;
  @override
  void paint(Canvas c, Size size) {
    c.save();
    c.drawPath(
      gardenContour(Offset.zero & size, 28),
      Paint()..color = const Color(0xFFEAF0E1),
    );
    containArtwork(c, size, const Size(400, 220));
    final sky = Paint()..color = const Color(0xFFEAF0E1);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 400, 220),
        const Radius.circular(28),
      ),
      sky,
    );
    c.save();
    c.clipRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 400, 220),
        const Radius.circular(28),
      ),
    );
    c.drawCircle(
      const Offset(305, 45),
      27,
      Paint()..color = const Color(0xFFF0D99A),
    );
    for (final cloud in [
      const Offset(70, 35),
      const Offset(215, 29),
      const Offset(365, 78),
    ]) {
      final p = Paint()..color = const Color(0xFFF8F7EB).withValues(alpha: .85);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cloud.dx - 20, cloud.dy, 47, 10),
          const Radius.circular(9),
        ),
        p,
      );
      c.drawOval(Rect.fromLTWH(cloud.dx - 9, cloud.dy - 9, 23, 17), p);
    }
    final hill = Path()
      ..moveTo(-20, 142)
      ..cubicTo(55, 75, 130, 128, 193, 139)
      ..cubicTo(291, 73, 350, 108, 430, 141)
      ..lineTo(430, 230)
      ..lineTo(-20, 230)
      ..close();
    c.drawPath(hill, Paint()..color = const Color(0xFFCBDAB6));
    final near = Path()
      ..moveTo(-10, 172)
      ..cubicTo(82, 125, 178, 180, 241, 150)
      ..cubicTo(303, 125, 356, 153, 418, 168)
      ..lineTo(418, 230)
      ..lineTo(-10, 230)
      ..close();
    c.drawPath(near, Paint()..color = const Color(0xFFADBF8E));
    final soil = Path()
      ..moveTo(140, 220)
      ..cubicTo(142, 193, 232, 190, 260, 220)
      ..close();
    c.drawPath(soil, Paint()..color = const Color(0xFFEAE2BE));
    void leaf(Offset root, double angle, double length, Color color) {
      c.save();
      c.translate(root.dx, root.dy);
      c.rotate(angle);
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(
          -length * .6,
          -length * .35,
          -length * .5,
          -length * .9,
          0,
          -length,
        )
        ..cubicTo(length * .5, -length * .65, length * .4, -length * .2, 0, 0)
        ..close();
      c.drawPath(path, Paint()..color = color);
      c.restore();
    }

    void plant(double x, double y, double h, Color color) {
      final stem = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      c.drawLine(Offset(x, y), Offset(x - 3, y - h), stem);
      for (var j = 0; j < 3; j++) {
        leaf(Offset(x - 1, y - h * .22 - j * h * .24), -.8, 18 - j * 2, color);
        leaf(Offset(x - 2, y - h * .32 - j * h * .23), .85, 20 - j * 2, color);
      }
    }

    plant(48, 185, 88, const Color(0xFF647F4F));
    plant(82, 191, 60, const Color(0xFF7E9961));
    plant(338, 196, 92, const Color(0xFF5D794B));
    plant(367, 193, 54, const Color(0xFF7C9660));
    // An original little garden fence and stepping stones.
    final fence = Paint()
      ..color = const Color(0xFFEFE6C7)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(100, 138), const Offset(168, 131), fence);
    c.drawLine(const Offset(100, 153), const Offset(168, 146), fence);
    for (var i = 0; i < 4; i++) {
      c.drawLine(
        Offset(102 + i * 20, 127 - i * 2),
        Offset(102 + i * 20, 163 - i * 2),
        fence,
      );
    }
    c.save();
    c.translate(190, 79);
    c.scale(1.15);
    drawSprout(c, creature, false);
    c.restore();
    for (final point in [
      const Offset(115, 192),
      const Offset(299, 184),
      const Offset(324, 210),
      const Offset(27, 214),
      const Offset(154, 175),
    ]) {
      final col = variant % 2 == 0
          ? const Color(0xFFF4E8BD)
          : const Color(0xFFEAC1B8);
      for (var j = 0; j < 5; j++) {
        final a = j * math.pi * 2 / 5;
        c.drawCircle(
          Offset(point.dx + math.cos(a) * 4, point.dy + math.sin(a) * 4),
          3.3,
          Paint()..color = col,
        );
      }
      c.drawCircle(point, 2, Paint()..color = const Color(0xFFD0A64F));
    }
    for (var i = 0; i < 20; i++) {
      final x = (i * 83 % 391).toDouble(), y = 183 + (i * 13 % 30).toDouble();
      c.drawLine(
        Offset(x, y),
        Offset(x - 2, y - 5),
        Paint()
          ..color = const Color(0xFF839B64)
          ..strokeWidth = 1.3,
      );
    }
    c.restore();
    c.restore();
  }

  @override
  bool shouldRepaint(GardenPainter old) =>
      old.variant != variant || old.creature != creature;
}
