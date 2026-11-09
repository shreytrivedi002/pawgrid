import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'contour.dart';

// Figma Make design tokens. Board ink stays dark against the pastel gardens.
const paper = Color(0xFF191B2B);
const ink = Color(0xFFF4F1E8);
const green = Color(0xFFD7F985);
const muted = Color(0xFFACAABD);
const line = Color(0xFF444457);
const sage = Color(0xFF2B2C41);
const panel = Color(0xFF252638);
const boardInk = Color(0xFF293B37);
const lavender = Color(0xFFC8B5F7);
const warning = Color(0xFFFFAD9C);
const gardenSystemUi = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemStatusBarContrastEnforced: false,
  systemNavigationBarColor: paper,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: true,
  systemNavigationBarDividerColor: Colors.transparent,
);
const regionColors = [
  Color(0xFFD9E7AE),
  Color(0xFFA5CCD5),
  Color(0xFFE8BE94),
  Color(0xFFCEBCF6),
  Color(0xFFF2E6A7),
  Color(0xFFBFD3EA),
  Color(0xFFEBC7BA),
  Color(0xFFD4D0EC),
  Color(0xFFCCE0C5),
];

ThemeData gardenTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: paper,
  fontFamily: 'DMSans',
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: green,
    onSurface: ink,
    onPrimary: paper,
    surface: paper,
    primary: green,
  ),
  textTheme: const TextTheme(
    displaySmall: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 35,
      height: 1.18,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 23,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 21,
      fontWeight: FontWeight.w800,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: ink,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: ink),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: ink),
    bodySmall: TextStyle(fontSize: 12, height: 1.4, color: muted),
  ),
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: gardenSystemUi,
    backgroundColor: paper,
    foregroundColor: ink,
    surfaceTintColor: Colors.transparent,
  ),
  iconTheme: const IconThemeData(color: ink),
  dividerTheme: const DividerThemeData(color: line, space: 1),
  dialogTheme: const DialogThemeData(
    backgroundColor: paper,
    surfaceTintColor: Colors.transparent,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: paper,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((s) => paper),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? green : line,
    ),
  ),
);

class GardenButton extends StatelessWidget {
  const GardenButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.secondary = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: secondary ? panel : green,
      foregroundColor: secondary ? ink : paper,
      minimumSize: const Size.fromHeight(58),
      elevation: 0,
      shadowColor: const Color(0xFF11121D),
      side: BorderSide(color: secondary ? line : green, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      shape: const GardenOutline(),
      textStyle: const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Text(label)),
        if (icon != null) ...[const SizedBox(width: 12), Icon(icon, size: 20)],
      ],
    ),
  );
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.color = panel,
    this.padding = const EdgeInsets.all(20),
    this.border = true,
  });
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final bool border;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: GardenOutline(
      radius: 24,
      side: border ? const BorderSide(color: line, width: 2) : BorderSide.none,
    ),
    elevation: border ? 1 : 0,
    shadowColor: const Color(0x4411121D),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = muted});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 10,
      letterSpacing: 1.6,
      fontWeight: FontWeight.w800,
      color: color,
    ),
  );
}

class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.color = sage, this.icon});
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 13), const SizedBox(width: 5)],
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ],
    ),
  );
}

String timeLabel(int milliseconds) {
  final seconds = milliseconds ~/ 1000;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class SeedBadge extends StatelessWidget {
  const SeedBadge(this.amount, {super.key});
  final int amount;
  @override
  Widget build(BuildContext context) =>
      Tag('$amount', icon: Icons.spa_outlined, color: panel);
}

class GestureGuide extends StatelessWidget {
  const GestureGuide({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (final hint in <(IconData, String, String)>[
        (Icons.close_rounded, 'Tap', 'Tap to mark a cross'),
        (
          Icons.touch_app_rounded,
          'Hold',
          'Hold to place or remove a companion',
        ),
        (Icons.swipe_rounded, 'Swipe', 'Swipe to paint or erase crosses'),
      ])
        Expanded(
          child: Tooltip(
            message: hint.$3,
            child: Semantics(
              label: hint.$3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                decoration: ShapeDecoration(
                  color: panel,
                  shape: const GardenOutline(
                    radius: 14,
                    side: BorderSide(color: line),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(hint.$1, size: 16, color: green),
                    const SizedBox(height: 1),
                    Text(
                      hint.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
