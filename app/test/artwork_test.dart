import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawgrid/ui/art.dart';
import 'package:pawgrid/ui/game_scenery.dart';

void main() {
  testWidgets(
    'garden companion keeps its proportions in wide and short panels',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      double? reference;
      for (final size in [
        const Size(400, 300),
        const Size(420, 225),
        const Size(360, 265),
        const Size(800, 180),
        const Size(280, 300),
      ]) {
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Center(
                child: RepaintBoundary(
                  key: key,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: GardenWorld(height: size.height),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final image = await tester.runAsync(
          () =>
              (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
                  .toImage(),
        );
        final data = (await tester.runAsync(
          () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
        ))!;
        var minX = image!.width, minY = image.height, maxX = 0, maxY = 0;
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            final i = (y * image.width + x) * 4;
            if (data.getUint8(i) == 246 &&
                data.getUint8(i + 1) == 234 &&
                data.getUint8(i + 2) == 203) {
              if (x < minX) minX = x;
              if (x > maxX) maxX = x;
              if (y < minY) minY = y;
              if (y > maxY) maxY = y;
            }
          }
        }
        expect(maxX, greaterThan(minX));
        expect(maxY, greaterThan(minY));
        final ratio = (maxX - minX + 1) / (maxY - minY + 1);
        reference ??= ratio;
        expect(
          ratio,
          closeTo(reference, .08),
          reason: 'Companion distorted at $size',
        );
        image.dispose();
      }
    },
  );
  test(
    'mascot painter centers a square illustration in non-square constraints',
    () async {
      Future<ByteData> render(Size size) async {
        final recorder = ui.PictureRecorder();
        SproutPainter('moss', false).paint(Canvas(recorder), size);
        final picture = recorder.endRecording();
        final image = await picture.toImage(
          size.width.toInt(),
          size.height.toInt(),
        );
        final data = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        image.dispose();
        picture.dispose();
        return data;
      }

      Rect bounds(ByteData pixels, int width, int height) {
        var left = width, top = height, right = 0, bottom = 0;
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            if (pixels.getUint8((y * width + x) * 4 + 3) < 128) continue;
            if (x < left) left = x;
            if (x > right) right = x;
            if (y < top) top = y;
            if (y > bottom) bottom = y;
          }
        }
        return Rect.fromLTRB(
          left.toDouble(),
          top.toDouble(),
          right + 1.0,
          bottom + 1.0,
        );
      }

      final square = bounds(await render(const Size(100, 100)), 100, 100);
      for (final size in [const Size(300, 100), const Size(100, 300)]) {
        final actual = bounds(
          await render(size),
          size.width.toInt(),
          size.height.toInt(),
        );
        final expected = square.shift(
          Offset((size.width - 100) / 2, (size.height - 100) / 2),
        );
        expect(actual.left, closeTo(expected.left, 1));
        expect(actual.top, closeTo(expected.top, 1));
        expect(actual.width, closeTo(expected.width, 1));
        expect(actual.height, closeTo(expected.height, 1));
      }
    },
  );
}
