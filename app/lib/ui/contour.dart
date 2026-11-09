import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Explicit curves keep long edges straight on GPU rounded-rectangle paths.
Path gardenContour(Rect rect, double radius) {
  final r = math.min(radius, rect.shortestSide / 2).clamp(0.0, double.infinity);
  final k = r * .5522847498307936;
  final l = rect.left, t = rect.top, b = rect.bottom, e = rect.right;
  return Path()
    ..moveTo(l + r, t)
    ..lineTo(e - r, t)
    ..cubicTo(e - r + k, t, e, t + r - k, e, t + r)
    ..lineTo(e, b - r)
    ..cubicTo(e, b - r + k, e - r + k, b, e - r, b)
    ..lineTo(l + r, b)
    ..cubicTo(l + r - k, b, l, b - r + k, l, b - r)
    ..lineTo(l, t + r)
    ..cubicTo(l, t + r - k, l + r - k, t, l + r, t)
    ..close();
}

class GardenOutline extends OutlinedBorder {
  const GardenOutline({this.radius = 18, super.side});
  final double radius;
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);
  @override
  GardenOutline copyWith({BorderSide? side}) =>
      GardenOutline(radius: radius, side: side ?? this.side);
  @override
  ShapeBorder scale(double t) =>
      GardenOutline(radius: radius * t, side: side.scale(t));
  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) => a is GardenOutline
      ? GardenOutline(
          radius: a.radius + (radius - a.radius) * t,
          side: BorderSide.lerp(a.side, side, t),
        )
      : super.lerpFrom(a, t);
  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) => b is GardenOutline
      ? GardenOutline(
          radius: radius + (b.radius - radius) * t,
          side: BorderSide.lerp(side, b.side, t),
        )
      : super.lerpTo(b, t);
  @override
  bool operator ==(Object other) =>
      other is GardenOutline && other.radius == radius && other.side == side;
  @override
  int get hashCode => Object.hash(radius, side);
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      gardenContour(rect, radius);
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      gardenContour(rect.deflate(side.width), math.max(0, radius - side.width));
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addPath(getOuterPath(rect), Offset.zero)
        ..addPath(getInnerPath(rect), Offset.zero),
      Paint()..color = side.color,
    );
  }
}

/// Contain vector artwork without changing the proportions of its features.
void containArtwork(Canvas canvas, Size viewport, Size art) {
  final scale = math.min(
    viewport.width / art.width,
    viewport.height / art.height,
  );
  canvas.translate(
    (viewport.width - art.width * scale) / 2,
    (viewport.height - art.height * scale) / 2,
  );
  canvas.scale(scale);
}
