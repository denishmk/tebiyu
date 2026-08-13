import 'package:flutter/widgets.dart';

/// Tebiyu's corner radius tokens.
///
/// Values are deliberately few. A marketplace grid reads as coherent when
/// cards, images and chips share a small set of radii rather than each screen
/// inventing its own.
abstract final class AppRadius {
  /// 4px. Condition chips and small badges.
  static const double xs = 4;

  /// 8px. Text fields, dropdowns and image thumbnails.
  static const double sm = 8;

  /// 12px. Listing cards and list tiles.
  static const double md = 12;

  /// 16px. Bottom sheets, modals and large containers.
  static const double lg = 16;

  /// 24px. Search bars and the promotional banner.
  static const double xl = 24;

  /// 999px. Fully rounded, for pills, avatars and the FAB.
  static const double pill = 999;

  /// 4px on every corner.
  static const BorderRadius allXs = BorderRadius.all(Radius.circular(xs));

  /// 8px on every corner.
  static const BorderRadius allSm = BorderRadius.all(Radius.circular(sm));

  /// 12px on every corner.
  static const BorderRadius allMd = BorderRadius.all(Radius.circular(md));

  /// 16px on every corner.
  static const BorderRadius allLg = BorderRadius.all(Radius.circular(lg));

  /// 24px on every corner.
  static const BorderRadius allXl = BorderRadius.all(Radius.circular(xl));

  /// Fully rounded on every corner.
  static const BorderRadius allPill = BorderRadius.all(Radius.circular(pill));

  /// 16px on the top corners only, for bottom sheets.
  static const BorderRadius topLg = BorderRadius.vertical(
    top: Radius.circular(lg),
  );

  /// 12px on the top corners only, for card images that sit flush with the
  /// card edge.
  static const BorderRadius topMd = BorderRadius.vertical(
    top: Radius.circular(md),
  );
}
