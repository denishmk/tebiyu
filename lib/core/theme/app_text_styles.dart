import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tebiyu's type scale, built on Inter via `google_fonts`.
///
/// Styles here carry size, weight, height and letter spacing only. Colour is
/// applied by [ThemeData] or at the call site with `.copyWith(color: ...)`, so
/// the same style composes against either the light or dark palette.
///
/// Sizes follow a 2px rhythm and line heights are set as multipliers so text
/// stays legible when the user scales system font size, which matters on the
/// mid range Android devices common in South Sudan.
abstract final class AppTextStyles {
  /// Screen titles and hero headings. 28px, semi bold.
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.5,
  );

  /// Section headings such as Trending or Recommended for you. 22px.
  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// Card titles and sub section headings. 18px.
  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.2,
  );

  /// Listing titles and emphasised rows. 16px, medium.
  static TextStyle get h4 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// Default body copy. 15px.
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Secondary body copy, list subtitles and metadata. 13px.
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Timestamps, item counts and helper text. 11px.
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Chip and badge labels such as New, Used or Verified seller. 11px, medium.
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
  );

  /// Button labels. 15px, semi bold.
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  /// Prices on listing cards and item detail. 18px, bold.
  ///
  /// Tabular figures keep SSP amounts aligned when stacked in a grid.
  static TextStyle get price => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Smaller price used inside compact cards and search results. 15px.
  static TextStyle get priceSmall => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.25,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Maps the scale onto a Material [TextTheme].
  ///
  /// Widgets that read `Theme.of(context).textTheme` pick up Inter without
  /// naming a style explicitly. Direct references to [AppTextStyles] remain
  /// the clearer choice inside Tebiyu widgets.
  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: h1.copyWith(color: primary),
      headlineMedium: h2.copyWith(color: primary),
      headlineSmall: h3.copyWith(color: primary),
      titleMedium: h4.copyWith(color: primary),
      bodyLarge: body.copyWith(color: primary),
      bodyMedium: body.copyWith(color: primary),
      bodySmall: bodySmall.copyWith(color: secondary),
      labelLarge: button.copyWith(color: primary),
      labelMedium: label.copyWith(color: secondary),
      labelSmall: caption.copyWith(color: secondary),
    );
  }
}
