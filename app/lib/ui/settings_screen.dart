import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_controller.dart';
import 'design.dart';
import 'sound_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier);
    Widget toggle(
      String key,
      String title,
      String detail, {
      bool fallback = false,
    }) => SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      subtitle: Text(
        detail,
        style: const TextStyle(color: muted, fontSize: 13),
      ),
      value: state.enabled(key, fallback: fallback),
      onChanged: (value) => controller.setting(key, value),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Make yourself at home')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 35),
            children: [
              const Eyebrow('Your garden, your pace'),
              const SizedBox(height: 20),
              Surface(
                child: Column(
                  children: [
                    toggle(
                      'patterns',
                      'Garden letters',
                      'Identify every region without relying on color.',
                      fallback: true,
                    ),
                    const Divider(),
                    toggle(
                      'contrast',
                      'Stronger garden contrast',
                      'Darker labels for clearer garden boundaries.',
                    ),
                    const Divider(),
                    toggle(
                      'reduceMotion',
                      'Reduce motion',
                      'Keep transitions still and gentle.',
                    ),
                    const Divider(),
                    const SoundPreferences(),
                    const Divider(),
                    toggle(
                      'haptics',
                      'Gentle haptics',
                      'A light response when you mark or place.',
                      fallback: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Eyebrow('A helping hand'),
              const SizedBox(height: 13),
              Surface(
                child: Column(
                  children: [
                    toggle(
                      'cellControls',
                      'Selected-cell controls',
                      'Previous / next, place, mark and clear without a precise hold.',
                    ),
                    const Divider(),
                    toggle(
                      'errors',
                      'Show rule conflicts',
                      'Explain when creatures share a space or touch.',
                      fallback: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Eyebrow('Privacy & your progress'),
              const SizedBox(height: 13),
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: green),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'A private little garden',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'This build works entirely offline. Your moves, progress, seeds and preferences are stored only on this device. No account, tracking, advertising or purchases are active.',
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Deleting app data or uninstalling removes your local garden. Cross-device backup is not available.',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete your local garden?'),
                            content: const Text(
                              'This permanently removes all moves, completed levels, seeds, companions and preferences on this device. This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Keep my garden'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete all local data'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await controller.deleteData();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          }
                        }
                      },
                      child: const Text(
                        'Delete all local data',
                        style: TextStyle(color: Color(0xFF9A473A)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pawgrid · 0.6.1',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Made for quiet moments. Original garden artwork, built-in puzzles, and logic you can trust.',
                      style: TextStyle(color: muted),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: 'Pawgrid',
                        applicationVersion: '0.6.1',
                      ),
                      child: const Text('Open-source licenses'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
