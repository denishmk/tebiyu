import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/constants/categories.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_shadows.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/core/widgets/category_image.dart';
import 'package:tebiyu/features/category/providers/category_providers.dart';

/// The category browser.
///
/// Two panels: every top level category down the leading edge, and the
/// selected category's subcategories in a photo grid beside it. Both scroll
/// independently, so a long subcategory list never pushes the categories
/// out of reach.
class CategoryScreen extends ConsumerWidget {
  /// Creates the category screen.
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final category = Categories.all[selected];
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      // No back button: this is a root tab in the shell, not a pushed
      // route. A back arrow here would have nowhere to go.
      appBar: AppBar(title: const Text('Category')),
      body: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _CategorySidebar(
              selected: selected,
              width: isWide ? 148 : 96,
              onSelect: (index) =>
                  ref.read(selectedCategoryProvider.notifier).index = index,
            ),
            Expanded(child: _SubcategoryGrid(category: category)),
          ],
        ),
      ),
    );
  }
}

class _CategorySidebar extends StatelessWidget {
  const _CategorySidebar({
    required this.selected,
    required this.width,
    required this.onSelect,
  });

  final int selected;
  final double width;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: Categories.all.length,
        itemBuilder: (context, index) => _SidebarTile(
          category: Categories.all[index],
          isSelected: index == selected,
          onTap: () => onSelect(index),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final TebiyuCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      // The selected tile takes the grid panel's colour so the two read as
      // one continuous surface, rather than as a button sitting on top of
      // the sidebar.
      color: isSelected ? colors.primaryBackground : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: AppRadius.allSm,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CategoryImage(
                    path: category.imagePath,
                    fallbackIcon: category.icon,
                    renderSize: 44,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? colors.brand : colors.secondaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubcategoryGrid extends ConsumerWidget {
  const _SubcategoryGrid({required this.category});

  /// Tile width the grid aims for before adding another column.
  static const double _targetTileWidth = 180;

  /// Line height of a subcategory name, from `bodySmall` at weight 600.
  static const double _nameHeight = 13 * 1.45;

  /// Line height of the count line, from `caption`.
  static const double _countHeight = 11 * 1.4;

  final TebiyuCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(subcategoryCountsProvider);
    final colors = context.colors;
    final scaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Columns follow a target tile width rather than a breakpoint. A
        // fixed count has no upper bound, so on a wide window four columns
        // means 320px tiles: the artwork stretches to fill whatever space
        // exists and the gutters look tight by comparison.
        final available = constraints.maxWidth - AppSpacing.lg * 2;
        final columns =
            (available / _targetTileWidth).ceil().clamp(3, 8);
        final cellWidth =
            (available - AppSpacing.lg * (columns - 1)) / columns;

        // Square image, then two lines of name and one of count.
        final extent = cellWidth +
            scaler.scale(_nameHeight * 2 + _countHeight) +
            AppSpacing.sm;

        return ColoredBox(
          color: colors.primaryBackground,
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.xl,
              mainAxisExtent: extent,
            ),
            itemCount: category.subcategories.length,
            itemBuilder: (context, index) {
              final subcategory = category.subcategories[index];
              return _SubcategoryTile(
                imagePath: category.subImagePath(subcategory),
                subcategory: subcategory,
                count: counts.valueOrNull?[subcategory.name] ?? 0,
                imageSize: cellWidth,
              );
            },
          ),
        );
      },
    );
  }
}

class _SubcategoryTile extends StatelessWidget {
  const _SubcategoryTile({
    required this.imagePath,
    required this.subcategory,
    required this.count,
    required this.imageSize,
  });

  /// Artwork path, built by the parent category.
  final String imagePath;

  final TebiyuSubcategory subcategory;

  /// Rendered width of the tile image, used to decode at display size.
  final double imageSize;

  /// Active listings in this subcategory.
  ///
  /// Zero hides the line rather than printing "0 items". An empty
  /// subcategory is a normal state in a young marketplace, and a visible
  /// zero reads as a fault where silence reads as nothing here yet.
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.allSm,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Opens the filtered results screen in P2.3.
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: context.imageSurface(radius: AppRadius.allSm),
                child: ClipRRect(
                  borderRadius: AppRadius.allSm,
                  child: CategoryImage(
                    path: imagePath,
                    renderSize: imageSize,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subcategory.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0)
              Text(
                count == 1 ? '1 item' : '$count items',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: AppTextStyles.caption.copyWith(
                  color: colors.secondaryText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
