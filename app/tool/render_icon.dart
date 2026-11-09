// Authoring utility: uses Flutter's own vector renderer, no image generator.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_test/flutter_test.dart';
import 'package:pawgrid/ui/art.dart';

// App Store icon files must have no alpha channel, even when fully opaque.
// Encode RGB PNG using the standard-library zlib; Android foregrounds keep alpha.
Uint8List rgbPng(Uint8List rgba, int size) {
  final rows = BytesBuilder();
  for (var y = 0; y < size; y++) {
    rows.addByte(1); // PNG Sub filter.
    for (var x = 0; x < size; x++) {
      for (var c = 0; c < 3; c++) {
        final i = (y * size + x) * 4 + c;
        rows.addByte((rgba[i] - (x == 0 ? 0 : rgba[i - 4])) & 255);
      }
    }
  }
  final out = BytesBuilder()..add([137, 80, 78, 71, 13, 10, 26, 10]);
  void chunk(String name, List<int> data) {
    final bytes = [...ascii.encode(name), ...data];
    var crc = 0xffffffff;
    for (final byte in bytes) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        crc = (crc & 1) != 0 ? (crc >>> 1) ^ 0xedb88320 : crc >>> 1;
      }
    }
    final length = ByteData(4)..setUint32(0, data.length);
    final checksum = ByteData(4)..setUint32(0, (crc ^ 0xffffffff) & 0xffffffff);
    out
      ..add(length.buffer.asUint8List())
      ..add(bytes)
      ..add(checksum.buffer.asUint8List());
  }

  final header = ByteData(13)
    ..setUint32(0, size)
    ..setUint32(4, size)
    ..setUint8(8, 8)
    ..setUint8(9, 2);
  chunk('IHDR', header.buffer.asUint8List());
  chunk('IDAT', ZLibEncoder().convert(rows.takeBytes()));
  chunk('IEND', []);
  return out.takeBytes();
}

void main() {
  test('render original vector launcher artwork', () async {
    Future<void> render(
      int size,
      String output, {
      bool foreground = false,
      bool ios = false,
    }) async {
      final recorder = ui.PictureRecorder();
      final c = Canvas(recorder);
      c.scale(size / 100);
      if (!foreground) {
        c.drawRect(
          const Rect.fromLTWH(0, 0, 100, 100),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF37314E), Color(0xFF191B2B)],
            ).createShader(const Rect.fromLTWH(0, 0, 100, 100)),
        );
      } else {
        // Keep the entire mark inside Android's central adaptive safe area.
        c.translate(50, 50);
        c.scale(.64);
        c.translate(-50, -50);
      }
      c.drawCircle(
        const Offset(50, 48),
        37,
        Paint()..color = const Color(0xFFD7F985),
      );
      c.save();
      c.translate(50, 49);
      c.rotate(-.45);
      c.drawOval(
        const Rect.fromLTWH(-44, -14, 88, 28),
        Paint()
          ..color = const Color(0xFFC8B5F7).withValues(alpha: .65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
      c.restore();
      c.drawOval(
        const Rect.fromLTWH(22, 78, 60, 8),
        Paint()..color = const Color(0xFF101320).withValues(alpha: .3),
      );
      c.save();
      c.translate(6, 5);
      c.scale(.88);
      drawSprout(c, 'moss', false);
      c.restore();
      final star = Path()
        ..moveTo(82, 16)
        ..lineTo(84, 21)
        ..lineTo(89, 23)
        ..lineTo(84, 25)
        ..lineTo(82, 30)
        ..lineTo(80, 25)
        ..lineTo(75, 23)
        ..lineTo(80, 21)
        ..close();
      c.drawPath(star, Paint()..color = const Color(0xFFF4F1E8));
      final picture = recorder.endRecording();
      final image = await picture.toImage(size, size);
      final bytes = await image.toByteData(
        format: ios ? ui.ImageByteFormat.rawRgba : ui.ImageByteFormat.png,
      );
      File(output).parent.createSync(recursive: true);
      final encoded = ios
          ? rgbPng(bytes!.buffer.asUint8List(), size)
          : bytes!.buffer.asUint8List();
      File(output).writeAsBytesSync(encoded);
      if (ios) {
        expect(encoded[25], 2, reason: 'iOS PNG must be RGB without alpha');
        final codec = await ui.instantiateImageCodec(encoded);
        final decoded = (await codec.getNextFrame()).image;
        final pixels = await decoded.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        expect(
          listEquals(pixels!.buffer.asUint8List(), bytes.buffer.asUint8List()),
          true,
          reason: 'RGB export must decode to exactly the rendered pixels',
        );
        decoded.dispose();
        codec.dispose();
      }
      if (foreground) {
        final pixels = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!.buffer.asUint8List();
        for (var y = 0; y < size; y++) {
          for (var x = 0; x < size; x++) {
            if (pixels[(y * size + x) * 4 + 3] == 0) continue;
            final dx = x + .5 - size / 2, dy = y + .5 - size / 2;
            final safeRadius = size * 66 / 108 / 2 + 1;
            expect(
              dx * dx + dy * dy <= safeRadius * safeRadius,
              true,
              reason: 'adaptive mark must stay inside mask-safe circle',
            );
          }
        }
      }
      image.dispose();
      picture.dispose();
    }

    for (final entry in {
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    }.entries) {
      await render(
        entry.value,
        'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
      );
      await render(
        (entry.value * 2.25).round(),
        'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_foreground.png',
        foreground: true,
      );
    }
    final folder = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
    final manifest =
        jsonDecode(File('${folder.path}/Contents.json').readAsStringSync())
            as Map;
    for (final image in manifest['images'] as List) {
      final filename = image['filename'] as String?;
      if (filename == null) continue;
      final points = double.parse((image['size'] as String).split('x').first),
          scale = double.parse((image['scale'] as String).replaceAll('x', ''));
      await render(
        (points * scale).round(),
        '${folder.path}/$filename',
        ios: true,
      );
    }
    await render(512, '../docs/icons-v0.5.1/pawgrid-icon.png');
    await render(1024, '../docs/icons-v0.5.1/pawgrid-icon-1024.png');
    await render(48, '../docs/icons-v0.5.1/pawgrid-icon-48.png');
  });
}
