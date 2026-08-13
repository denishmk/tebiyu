import 'package:flutter/material.dart';

import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';

/// Tebiyu's elevation tokens, exposed as a [ThemeExtension].
///
/// Light and dark mode achieve elevation through different mechanisms. In
/// light mode a shadow separates a card from the canvas. In dark mode shadows
/// are effectively invisible against `#0E1316`, so separation comes from the
/// surface being lighter than what sits behind it, reinforced by a hairline
/// border.
///
/// Every list here is empty in dark mode. Rather than reading the lists
/// directly, prefer the decoration helpers on [AppElevationX], which pick the
/// right mechanism for the active theme.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  /// Creates an elevation token set. Prefer [AppShadows.light] or
  /// [AppShadows.dark].
  const AppShadows({
    required this.card,
    required this.elevated,
    required this.fab,
    required this.bottomSheet,
    required this.useBorderForElevation,
  });

  /// Light mode elevation. Shadows are tinted with the palette's darkest
  /// neutral rather than pure black, so they read as cool grey instead of
  /// muddy brown against the `#EEEDED` canvas.
  factory AppShadows.light() => const AppShadows(
    card: [
      BoxShadow(color: Color(0x0D14181B), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x0A14181B), blurRadius: 8, offset: Offset(0, 2)),
    ],
    elevated: [
      BoxShadow(color: Color(0x1414181B), blurRadius: 6, offset: Offset(0, 2)),
      BoxShadow(color: Color(0x1414181B), blurRadius: 24, offset: Offset(0, 8)),
    ],
    fab: [
      BoxShadow(color: Color(0x1A1A7A3A), blurRadius: 4, offset: Offset(0, 2)),
      BoxShadow(color: Color(0x261A7A3A), blurRadius: 12, offset: Offset(0, 4)),
    ],
    bottomSheet: [
      BoxShadow(
        color: Color(0x1A14181B),
        blurRadius: 24,
        offset: Offset(0, -4),
      ),
    ],
    useBorderForElevation: false,
  );

  /// Dark mode elevation. All shadow lists are empty because lightness carries
  /// the elevation instead.
  factory AppShadows.dark() => const AppShadows(
    card: [],
    elevated: [],
    fab: [],
    bottomSheet: [],
    useBorderForElevation: true,
  );

  /// Resting elevation for listing cards, list tiles and stat cards.
  final List<BoxShadow> card;

  /// Elevation for modals, menus, dropdowns and dialogs.
  final List<BoxShadow> elevated;

  /// Elevation for the floating action button. Tinted with the brand green so
  /// the FAB glows rather than casting a grey smudge.
  final List<BoxShadow> fab;

  /// Upward elevation for bottom sheets.
  final List<BoxShadow> bottomSheet;

  /// Whether this theme separates surfaces with a border instead of a shadow.
  ///
  /// True in dark mode. Read this only when writing a custom surface; the
  /// helpers on [AppElevationX] already account for it.
  final bool useBorderForElevation;

  @override
  AppShadows copyWith({
    List<BoxShadow>? card,
    List<BoxShadow>? elevated,
    List<BoxShadow>? fab,
    List<BoxShadow>? bottomSheet,
    bool? useBorderForElevation,
  }) {
    return AppShadows(
      card: card ?? this.card,
      elevated: elevated ?? this.elevated,
      fab: fab ?? this.fab,
      bottomSheet: bottomSheet ?? this.bottomSheet,
      useBorderForElevation:
          useBorderForElevation ?? this.useBorderForElevation,
    );
  }

  @override
  AppShadows lerp(covariant ThemeExtension<AppShadows>? other, double t) {
    if (other is! AppShadows) return this;
    return AppShadows(
      card: BoxShadow.lerpList(card, other.card, t) ?? const [],
      elevated: BoxShadow.lerpList(elevated, other.elevated, t) ?? const [],
      fab: BoxShadow.lerpList(fab, other.fab, t) ?? const [],
      bottomSheet:
          BoxShadow.lerpList(bottomSheet, other.bottomSheet, t) ?? const [],
      useBorderForElevation: t < 0.5
          ? useBorderForElevation
          : other.useBorderForElevation,
    );
  }
}

/// Ready made surface decorations that resolve elevation correctly for the
/// active theme.
///
/// Reach for these rather than assembling a [BoxDecoration] by hand. They keep
/// the shadow versus border decision in one place, so a card written once
/// behaves correctly in both themes.
extension AppElevationX on BuildContext {
  /// The active elevation tokens.
  AppShadows get shadows => Theme.of(this).extension<AppShadows>()!;

  /// Decoration for a listing card, list tile or stat card.
  ///
  /// Casts a soft shadow in light mode and draws a hairline border in dark
  /// mode. Pass [radius] to override the default 12px corners.
  BoxDecoration cardSurface({BorderRadius? radius}) {
    final shadow = shadows;
    return BoxDecoration(
      color: colors.primaryBackground,
      borderRadius: radius ?? AppRadius.allMd,
      border: shadow.useBorderForElevation
          ? Border.all(color: colors.border, width: 0.5)
          : null,
      boxShadow: shadow.card,
    );
  }

  /// Decoration for a modal, menu, dropdown or dialog.
  ///
  /// Uses the elevated surface colour so that in dark mode the panel is
  /// visibly lighter than the cards behind it.
  BoxDecoration elevatedSurface({BorderRadius? radius}) {
    final shadow = shadows;
    return BoxDecoration(
      color: colors.elevatedBackground,
      borderRadius: radius ?? AppRadius.allLg,
      border: shadow.useBorderForElevation
          ? Border.all(color: colors.border, width: 0.5)
          : null,
      boxShadow: shadow.elevated,
    );
  }

  /// Decoration for a bottom sheet, rounded on the top corners only.
  BoxDecoration bottomSheetSurface() {
    final shadow = shadows;
    return BoxDecoration(
      color: colors.elevatedBackground,
      borderRadius: AppRadius.topLg,
      border: shadow.useBorderForElevation
          ? Border(top: BorderSide(color: colors.border, width: 0.5))
          : null,
      boxShadow: shadow.bottomSheet,
    );
  }

  /// Decoration for a product image container.
  ///
  /// Always draws a hairline border, in both themes. Listing photos with white
  /// or near white backgrounds are extremely common in electronics and phone
  /// categories, and without an outline they punch hard against a dark card
  /// and read as a floating rectangle. The border costs nothing in light mode
  /// and rescues the dark grid.
  BoxDecoration imageSurface({BorderRadius? radius}) {
    return BoxDecoration(
      color: colors.secondaryBackground,
      borderRadius: radius ?? AppRadius.allSm,
      border: Border.all(color: colors.border, width: 0.5),
    );
  }
}
