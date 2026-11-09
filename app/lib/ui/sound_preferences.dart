import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_controller.dart';
import '../feedback/feedback_cue.dart';
import 'design.dart';

class SoundPreferences extends ConsumerStatefulWidget {
  const SoundPreferences({super.key});
  @override
  ConsumerState<SoundPreferences> createState() => _SoundPreferencesState();
}

class _SoundPreferencesState extends ConsumerState<SoundPreferences> {
  double? _drag;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier);
    final enabled = state.enabled('sound', fallback: true);
    final volume =
        (_drag ?? (state.settings['soundVolume'] as num?)?.toDouble() ?? .7)
            .clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 4,
          ),
          title: const Text(
            'Sound effects',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          subtitle: const Text(
            'Soft taps, companion plinks and a little win fanfare.',
            style: TextStyle(color: muted, fontSize: 13),
          ),
          value: enabled,
          onChanged: (v) => controller.setting('sound', v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Effect volume · ${(volume * 100).round()}%',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
        ),
        Slider(
          value: volume,
          divisions: 10,
          label: '${(volume * 100).round()}%',
          semanticFormatterCallback: (v) => '${(v * 100).round()} percent',
          onChanged: enabled ? (v) => setState(() => _drag = v) : null,
          onChangeEnd: enabled
              ? (v) async {
                  await controller.setting('soundVolume', v);
                  if (mounted) setState(() => _drag = null);
                }
              : null,
        ),
        TextButton.icon(
          icon: const Icon(Icons.volume_up_outlined, size: 18),
          label: const Text('Preview sound'),
          onPressed: enabled && volume > 0
              ? () async {
                  try {
                    await ref
                        .read(servicesProvider)
                        .audio
                        .play(FeedbackCue.hint, volume);
                  } on Object {
                    /* Optional sound. */
                  }
                }
              : null,
        ),
      ],
    );
  }
}
