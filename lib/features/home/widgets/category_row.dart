import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tebiyu/core/constants/categories.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_shadows.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';

/// A horizontal strip of top level categories.
///
/// Duplicates the Categories tab, deliberately. The tab is where someone
/// goes when they already know they want to browse; this row is what
/// catches someone who was only scrolling. Every classifieds app carries
/// both for that reason.
class CategoryRow extends StatelessWidget {
  /// Creates the row.
  const CategoryRow({super.key});

  /// How many categories appear before the row runs out.
  ///
  /// The full taxonomy is thirteen entries, which is a long scroll for a
  /// glance-level control. The rest are one tap away behind View all.
  static const int visibleCount = 8;

  @override
  Widget build(BuildContext context) {
    final shown = Categories.all.take(visibleCount).toList();

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenHorizontal,
        itemCount: shown.length,
        separatorBuilder: (_, _) => AppSpacing.hGapMd,
        itemBuilder: (context, index) => _CategoryTile(category: shown[index]),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final TebiyuCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 76,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.allMd,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.categories),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: context.cardSurface(radius: AppRadius.allMd),
                child: Icon(category.icon, color: colors.primaryIcon),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                Categories.shortNameOf(category.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
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
