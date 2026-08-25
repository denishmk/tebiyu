import 'package:flutter/material.dart';
import 'package:tebiyu/core/theme/app_colors.dart';

/// A bundled category or subcategory image.
///
/// Falls back to an icon when the asset is missing. Artwork lands over
/// time, and an absent file should leave a tidy placeholder rather than
/// Flutter's grey error box in the middle of a grid.
///
/// Lives in `core` because both the Category screen and the Home category
/// row draw these, and a widget shared across features has no business
/// living inside one of them.
class CategoryImage extends StatelessWidget {
  /// Creates a category image.
  const CategoryImage({
    required this.path,
    this.fallbackIcon,
    this.fit = BoxFit.cover,
    this.renderSize,
    this.fallbackIconSize = 18,
    super.key,
  });

  /// Asset path to load, usually from `TebiyuCategory.imagePath`.
  final String path;

  /// Icon shown when the asset is not bundled.
  final IconData? fallbackIcon;

  /// How the image fills its slot.
  ///
  /// `cover` for grid tiles where the image is the tile. `contain` for the
  /// Home row, where the artwork sits inside a padded card and cropping it
  /// would cut the subject.
  final BoxFit fit;

  /// Logical size of the slot this image is drawn into.
  ///
  /// Supplied so the image decodes at display size rather than full
  /// resolution. A hundred grid tiles decoding 256px artwork into 100px
  /// slots holds several times the pixels the screen can show, which is
  /// felt as jank on the low-RAM devices this targets.
  final double? renderSize;

  /// Size of [fallbackIcon].
  final double fallbackIconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = renderSize;
    final cacheWidth = size == null
        ? null
        : (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Image.asset(
      path,
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (context, error, stack) => ColoredBox(
        color: colors.secondaryBackground,
        child: Icon(
          fallbackIcon ?? Icons.image_outlined,
          size: fallbackIconSize,
          color: colors.primaryIcon,
        ),
      ),
    );
  }
}
