import 'package:flutter/material.dart';

/// Tebiyu's colour tokens, exposed as a [ThemeExtension] so that light and
/// dark values share identical names.
///
/// Read them from any widget with `Theme.of(context).extension<AppColors>()!`,
/// or more conveniently via the `context.colors` getter defined at the bottom
/// of this file.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates a colour token set. Prefer [AppColors.light] or [AppColors.dark].
  const AppColors({
    required this.appBackground,
    required this.primaryBackground,
    required this.elevatedBackground,
    required this.secondaryBackground,
    required this.border,
    required this.scrim,
    required this.primaryText,
    required this.secondaryText,
    required this.disabledText,
    required this.onBrand,
    required this.primaryIcon,
    required this.secondaryIcon,
    required this.brand,
    required this.brandPressed,
    required this.brandDisabled,
    required this.error,
    required this.errorBackground,
    required this.warning,
    required this.warningBackground,
    required this.success,
    required this.successBackground,
    required this.info,
    required this.infoBackground,
  });

  /// The light theme token set.
  factory AppColors.light() => const AppColors(
    appBackground: Color(0xFFEEEDED),
    primaryBackground: Color(0xFFFFFFFF),
    elevatedBackground: Color(0xFFFFFFFF),
    secondaryBackground: Color(0x3E09832A),
    border: Color(0xFFD9DEE2),
    scrim: Color(0x800E1316),
    primaryText: Color(0xFF14181B),
    secondaryText: Color(0xFF57636C),
    disabledText: Color(0xFFA8B2B9),
    onBrand: Color(0xFFFFFFFF),
    primaryIcon: Color(0xFF4CAF50),
    secondaryIcon: Color(0xFF57636C),
    brand: Color(0xFF1A7A3A),
    brandPressed: Color(0xFF145C2C),
    brandDisabled: Color(0xFFBFD6C6),
    error: Color(0xFFD32F2F),
    errorBackground: Color(0xFFFDECEC),
    warning: Color(0xFFF57C00),
    warningBackground: Color(0xFFFFF3E0),
    success: Color(0xFF2E7D32),
    successBackground: Color(0xFFE8F5E9),
    info: Color(0xFF1976D2),
    infoBackground: Color(0xFFE3F2FD),
  );

  /// The dark theme token set.
  factory AppColors.dark() => const AppColors(
    appBackground: Color(0xFF0E1316),
    primaryBackground: Color(0xFF181E22),
    elevatedBackground: Color(0xFF222A2F),
    secondaryBackground: Color(0x2E6ABF6E),
    border: Color(0xFF2E373D),
    scrim: Color(0xB30E1316),
    primaryText: Color(0xFFE8EBED),
    secondaryText: Color(0xFF97A5AF),
    disabledText: Color(0xFF5A666E),
    onBrand: Color(0xFF0E1316),
    primaryIcon: Color(0xFF6ABF6E),
    secondaryIcon: Color(0xFF97A5AF),
    brand: Color(0xFF6ABF6E),
    brandPressed: Color(0xFF57A85B),
    brandDisabled: Color(0xFF2F4034),
    error: Color(0xFFEF8080),
    errorBackground: Color(0xFF3A2020),
    warning: Color(0xFFFFB74D),
    warningBackground: Color(0xFF3D2E14),
    success: Color(0xFF81C784),
    successBackground: Color(0xFF1B2E1D),
    info: Color(0xFF64B5F6),
    infoBackground: Color(0xFF152838),
  );

  /// Screen canvas sitting behind all cards and sheets.
  final Color appBackground;

  /// Card, list tile and sheet surfaces.
  final Color primaryBackground;

  /// Modals, bottom sheets, menus and dropdowns.
  ///
  /// In light mode this matches [primaryBackground] and elevation is carried
  /// by a shadow. In dark mode shadows are invisible, so the lighter value
  /// itself is the elevation cue.
  final Color elevatedBackground;

  /// Translucent green tint for selected states, chip fills and tinted rows.
  ///
  /// Carries alpha, so it composites differently over [appBackground] than
  /// over [primaryBackground]. Verify both.
  final Color secondaryBackground;

  /// Hairline borders and dividers. Also used to outline product images so
  /// light photos do not punch against dark cards.
  final Color border;

  /// Overlay behind modals and image viewers.
  final Color scrim;

  /// Headings and body copy.
  final Color primaryText;

  /// Supporting copy, metadata and timestamps.
  final Color secondaryText;

  /// Text on disabled controls.
  final Color disabledText;

  /// Text and icons sitting on top of [brand].
  final Color onBrand;

  /// Icons and accents only. Never use as a fill behind [onBrand] text.
  final Color primaryIcon;

  /// Inactive icons.
  final Color secondaryIcon;

  /// Filled buttons, FAB, active navigation and price text.
  final Color brand;

  /// Pressed state for [brand] surfaces.
  final Color brandPressed;

  /// Disabled state for [brand] surfaces.
  final Color brandDisabled;

  /// Destructive actions and validation failures.
  final Color error;

  /// Tinted background pairing with [error].
  final Color errorBackground;

  /// Condition chips such as New and Used.
  final Color warning;

  /// Tinted background pairing with [warning].
  final Color warningBackground;

  /// Confirmations and sold badges.
  final Color success;

  /// Tinted background pairing with [success].
  final Color successBackground;

  /// Verified seller chips and informational banners.
  final Color info;

  /// Tinted background pairing with [info].
  final Color infoBackground;

  @override
  AppColors copyWith({
    Color? appBackground,
    Color? primaryBackground,
    Color? elevatedBackground,
    Color? secondaryBackground,
    Color? border,
    Color? scrim,
    Color? primaryText,
    Color? secondaryText,
    Color? disabledText,
    Color? onBrand,
    Color? primaryIcon,
    Color? secondaryIcon,
    Color? brand,
    Color? brandPressed,
    Color? brandDisabled,
    Color? error,
    Color? errorBackground,
    Color? warning,
    Color? warningBackground,
    Color? success,
    Color? successBackground,
    Color? info,
    Color? infoBackground,
  }) {
    return AppColors(
      appBackground: appBackground ?? this.appBackground,
      primaryBackground: primaryBackground ?? this.primaryBackground,
      elevatedBackground: elevatedBackground ?? this.elevatedBackground,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      border: border ?? this.border,
      scrim: scrim ?? this.scrim,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      disabledText: disabledText ?? this.disabledText,
      onBrand: onBrand ?? this.onBrand,
      primaryIcon: primaryIcon ?? this.primaryIcon,
      secondaryIcon: secondaryIcon ?? this.secondaryIcon,
      brand: brand ?? this.brand,
      brandPressed: brandPressed ?? this.brandPressed,
      brandDisabled: brandDisabled ?? this.brandDisabled,
      error: error ?? this.error,
      errorBackground: errorBackground ?? this.errorBackground,
      warning: warning ?? this.warning,
      warningBackground: warningBackground ?? this.warningBackground,
      success: success ?? this.success,
      successBackground: successBackground ?? this.successBackground,
      info: info ?? this.info,
      infoBackground: infoBackground ?? this.infoBackground,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      primaryBackground: Color.lerp(
        primaryBackground,
        other.primaryBackground,
        t,
      )!,
      elevatedBackground: Color.lerp(
        elevatedBackground,
        other.elevatedBackground,
        t,
      )!,
      secondaryBackground: Color.lerp(
        secondaryBackground,
        other.secondaryBackground,
        t,
      )!,
      border: Color.lerp(border, other.border, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      primaryIcon: Color.lerp(primaryIcon, other.primaryIcon, t)!,
      secondaryIcon: Color.lerp(secondaryIcon, other.secondaryIcon, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandPressed: Color.lerp(brandPressed, other.brandPressed, t)!,
      brandDisabled: Color.lerp(brandDisabled, other.brandDisabled, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBackground: Color.lerp(
        warningBackground,
        other.warningBackground,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      successBackground: Color.lerp(
        successBackground,
        other.successBackground,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
    );
  }
}

/// Shorthand access to [AppColors] from a [BuildContext].
extension AppColorsX on BuildContext {
  /// The active Tebiyu colour tokens for the current theme.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
