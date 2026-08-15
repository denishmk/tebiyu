import 'package:flutter/material.dart';

import 'package:tebiyu/core/theme/theme.dart';

/// A stand in for a screen that has not been built yet.
///
/// Exists so the shell and router can be exercised end to end before the real
/// screens land. Each is replaced by its actual implementation in P2 onward.
class PlaceholderScreen extends StatelessWidget {
  /// Creates a placeholder.
  const PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.phase,
    super.key,
  });

  /// Screen name, shown in the app bar and body.
  final String title;

  /// Icon shown in the body.
  final IconData icon;

  /// The roadmap phase that replaces this placeholder.
  final String phase;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.appBackground,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenHorizontal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.secondaryBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: colors.primaryIcon),
              ),
              AppSpacing.gapLg,
              Text(
                title,
                style: AppTextStyles.h3.copyWith(color: colors.primaryText),
              ),
              AppSpacing.gapXs,
              Text(
                'Coming in $phase',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
