import 'package:flutter/material.dart';

import 'package:tebiyu/core/theme/app_theme.dart';
import 'package:tebiyu/features/onboarding/screens/onboarding_screen.dart';

/// Temporary theme mode holder.
///
/// Replaced by a Riverpod provider in P5.2 when account settings land.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.light,
);

void main() {
  runApp(const TebiyuApp());
}

/// The root widget for Tebiyu.
class TebiyuApp extends StatelessWidget {
  /// Creates the root widget.
  const TebiyuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Tebiyu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
