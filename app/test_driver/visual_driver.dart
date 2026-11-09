import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final directory = Directory('../docs/visual-quality-v0.6.1')
      ..createSync(recursive: true);
    File('${directory.path}/$name.png').writeAsBytesSync(bytes);
    return bytes.isNotEmpty;
  },
);
