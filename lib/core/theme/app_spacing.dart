import 'package:flutter/widgets.dart';

/// Tebiyu's spacing scale, built on a 4px base unit.
///
/// Use these instead of literal numbers so padding stays consistent across
/// screens. If a gap needs a value that is not on the scale, the layout is
/// usually the thing to reconsider, not the token.
abstract final class AppSpacing {
  /// 2px. Hairline gaps, such as between a chip icon and its label.
  static const double xxs = 2;

  /// 4px. Base unit. Tight gaps inside a single component.
  static const double xs = 4;

  /// 8px. Gap between closely related elements, such as an icon and text.
  static const double sm = 8;

  /// 12px. Gap between grid items and inside compact cards.
  static const double md = 12;

  /// 16px. Default screen padding and standard card padding.
  static const double lg = 16;

  /// 24px. Gap between sections, such as Recommended and Trending.
  static const double xl = 24;

  /// 32px. Large section breaks and empty state padding.
  static const double xxl = 32;

  /// 48px. Hero spacing on splash and onboarding screens.
  static const double xxxl = 48;

  /// Default horizontal padding for screen content. 16px each side.
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: lg,
  );

  /// Default padding inside a card. 16px all round.
  static const EdgeInsets card = EdgeInsets.all(lg);

  /// Padding inside a compact listing card. 12px all round.
  static const EdgeInsets cardCompact = EdgeInsets.all(md);

  /// Padding inside a chip or badge.
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );

  /// Padding inside a primary button.
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );

  /// Vertical gap of 4px, for use inside a [Column].
  static const Widget gapXs = SizedBox(height: xs);

  /// Vertical gap of 8px.
  static const Widget gapSm = SizedBox(height: sm);

  /// Vertical gap of 12px.
  static const Widget gapMd = SizedBox(height: md);

  /// Vertical gap of 16px.
  static const Widget gapLg = SizedBox(height: lg);

  /// Vertical gap of 24px.
  static const Widget gapXl = SizedBox(height: xl);

  /// Vertical gap of 32px.
  static const Widget gapXxl = SizedBox(height: xxl);

  /// Horizontal gap of 4px, for use inside a [Row].
  static const Widget hGapXs = SizedBox(width: xs);

  /// Horizontal gap of 8px.
  static const Widget hGapSm = SizedBox(width: sm);

  /// Horizontal gap of 12px.
  static const Widget hGapMd = SizedBox(width: md);

  /// Horizontal gap of 16px.
  static const Widget hGapLg = SizedBox(width: lg);

  /// Horizontal gap of 24px.
  static const Widget hGapXl = SizedBox(width: xl);
}
