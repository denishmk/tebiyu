import 'package:flutter/material.dart';

import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_shadows.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';

/// Builds Tebiyu's [ThemeData] for both brightness modes.
///
/// Both themes register [AppColors] and [AppShadows] as theme extensions, so
/// `context.colors` and `context.cardSurface()` resolve correctly wherever
/// they are called.
///
/// Component themes below exist so that stock Material widgets inherit Tebiyu
/// styling without per widget overrides. A [TextField] dropped anywhere in the
/// app already has the right fill, radius and focus colour.
abstract final class AppTheme {
  /// The light theme.
  static ThemeData light() => _build(
    colors: AppColors.light(),
    shadows: AppShadows.light(),
    brightness: Brightness.light,
  );

  /// The dark theme.
  static ThemeData dark() => _build(
    colors: AppColors.dark(),
    shadows: AppShadows.dark(),
    brightness: Brightness.dark,
  );

  static ThemeData _build({
    required AppColors colors,
    required AppShadows shadows,
    required Brightness brightness,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.brand,
      onPrimary: colors.onBrand,
      secondary: colors.primaryIcon,
      onSecondary: colors.onBrand,
      error: colors.error,
      onError: colors.onBrand,
      surface: colors.primaryBackground,
      onSurface: colors.primaryText,
    );

    final textTheme = AppTextStyles.textTheme(
      colors.primaryText,
      colors.secondaryText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.appBackground,
      canvasColor: colors.appBackground,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors, shadows],

      appBarTheme: AppBarTheme(
        backgroundColor: colors.appBackground,
        foregroundColor: colors.primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3.copyWith(color: colors.primaryText),
        iconTheme: IconThemeData(color: colors.primaryText, size: 24),
      ),

      iconTheme: IconThemeData(color: colors.secondaryIcon, size: 24),
      primaryIconTheme: IconThemeData(color: colors.primaryIcon, size: 24),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 0.5,
        space: 0.5,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.primaryBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: colors.secondaryText),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: colors.secondaryText,
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: colors.error),
        prefixIconColor: colors.secondaryIcon,
        suffixIconColor: colors.secondaryIcon,
        border: OutlineInputBorder(
          borderRadius: AppRadius.allSm,
          borderSide: BorderSide(color: colors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.allSm,
          borderSide: BorderSide(color: colors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.allSm,
          borderSide: BorderSide(color: colors.brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allSm,
          borderSide: BorderSide(color: colors.error, width: 0.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allSm,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.brand,
          foregroundColor: colors.onBrand,
          disabledBackgroundColor: colors.brandDisabled,
          disabledForegroundColor: colors.disabledText,
          elevation: 0,
          padding: AppSpacing.button,
          minimumSize: const Size(0, 48),
          textStyle: AppTextStyles.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.brand,
          disabledForegroundColor: colors.disabledText,
          padding: AppSpacing.button,
          minimumSize: const Size(0, 48),
          textStyle: AppTextStyles.button,
          side: BorderSide(color: colors.brand),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.brand,
          disabledForegroundColor: colors.disabledText,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(0, 40),
          textStyle: AppTextStyles.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.brand,
        foregroundColor: colors.onBrand,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allPill),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colors.secondaryBackground,
        disabledColor: colors.brandDisabled,
        selectedColor: colors.brand,
        secondarySelectedColor: colors.brand,
        padding: AppSpacing.chip,
        labelStyle: AppTextStyles.label.copyWith(color: colors.primaryText),
        secondaryLabelStyle: AppTextStyles.label.copyWith(
          color: colors.onBrand,
        ),
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allXs),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.primaryBackground,
        selectedItemColor: colors.brand,
        unselectedItemColor: colors.secondaryIcon,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.elevatedBackground,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.elevatedBackground,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.topLg),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.primaryText,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(
          color: colors.primaryBackground,
        ),
        actionTextColor: colors.brand,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.brand,
        linearTrackColor: colors.secondaryBackground,
        circularTrackColor: colors.secondaryBackground,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.disabledText;
          if (states.contains(WidgetState.selected)) return colors.onBrand;
          return colors.secondaryIcon;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.brandDisabled;
          }
          if (states.contains(WidgetState.selected)) return colors.brand;
          return colors.border;
        }),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: colors.brand,
        unselectedLabelColor: colors.secondaryText,
        labelStyle: AppTextStyles.h4,
        unselectedLabelStyle: AppTextStyles.h4,
        indicatorColor: colors.brand,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: colors.border,
      ),

      splashColor: colors.secondaryBackground,
      highlightColor: colors.secondaryBackground,
    );
  }
}
