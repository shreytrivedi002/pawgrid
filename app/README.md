# Pawgrid mobile client

The Flutter app root. See [the project README](../README.md) for architecture, content authoring, build evidence and the remaining store-release gates.

```sh
flutter pub get
flutter run -d emulator-5554
flutter analyze
flutter test
flutter test integration_test/game_flow_test.dart -d emulator-5554
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release --target-platform android-arm64 --analyze-size
flutter build appbundle --release
```

Use release commands with their default dependency/tooling regeneration after a debug or integration-test build. In Flutter 3.47.5, `--no-pub` skips plugin-registrant regeneration; that can leave the integration-test plugin referenced by Java while it is correctly omitted from release dependencies. Do not run Flutter commands concurrently while building.
