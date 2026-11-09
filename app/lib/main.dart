import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/catalog.dart';
import 'data/database.dart';
import 'state/app_controller.dart';
import 'ui/design.dart';
import 'ui/shell.dart';
import 'ui/game_feedback.dart';
import 'feedback/audio_gateway.dart';

Future<AppServices> loadServices({
  PawDatabase? database,
  GameAudioGateway audio = const SilentGameAudio(),
}) async {
  final catalog = await ContentCatalog.load();
  final repository = GameRepository(database ?? PawDatabase());
  final settings = await repository.settings();
  final progress = await repository.progress();
  final balance = await repository.balance();
  return AppServices(
    catalog,
    repository,
    settings,
    progress,
    balance,
    audio: audio,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final font in ['Lora', 'NunitoSans', 'SpaceGrotesk', 'DMSans']) {
      yield LicenseEntryWithLineBreaks([
        font,
      ], await rootBundle.loadString('assets/fonts/$font-LICENSE.txt'));
    }
  });
  SystemChrome.setSystemUIOverlayStyle(gardenSystemUi);
  runApp(const Bootstrap());
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  late Future<AppServices> _services = loadServices(audio: ChannelGameAudio());
  @override
  Widget build(BuildContext context) => FutureBuilder<AppServices>(
    future: _services,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ProviderScope(
          overrides: [servicesProvider.overrideWithValue(snapshot.data!)],
          child: const PawgridApp(),
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: gardenTheme(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.spa_outlined, size: 48, color: green),
                  const SizedBox(height: 20),
                  Text(
                    'pawgrid',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 18),
                  if (snapshot.hasError) ...[
                    const Text(
                      'Your garden could not be opened safely. Your saved progress has been kept.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GardenButton(
                      'Try again',
                      onPressed: () => setState(
                        () =>
                            _services = loadServices(audio: ChannelGameAudio()),
                      ),
                    ),
                  ] else
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class PawgridApp extends ConsumerWidget {
  const PawgridApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Pawgrid',
    theme: gardenTheme(),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('en')],
    builder: (context, child) {
      final reduce = ref.watch(
        appProvider.select((s) => s.enabled('reduceMotion')),
      );
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(
          disableAnimations: reduce || media.disableAnimations,
        ),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: gardenSystemUi,
          child: GameFeedbackHost(child: child!),
        ),
      );
    },
    home: const GardenShell(),
  );
}
