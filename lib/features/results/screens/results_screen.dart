import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tebiyu/core/constants/listing_filters.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/core/widgets/listing_card.dart';
import 'package:tebiyu/features/results/providers/results_providers.dart';
import 'package:tebiyu/features/results/widgets/results_filter_sheet.dart';

/// Listings matching a category, subcategory or search term.
///
/// The scope comes from the route and cannot be cleared here; filters are
/// the user's own and reset when the screen closes.
class ResultsScreen extends ConsumerWidget {
  /// Creates the results screen.
  const ResultsScreen({required this.scope, super.key});

  /// Target tile width driving the column count.
  static const double _targetTileWidth = 180;

  /// What is being listed.
  final ResultsScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(resultsProvider(scope));
    final filters = ref.watch(resultsFiltersProvider(scope));
    final scaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(scope.title)),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxWidth - AppSpacing.lg * 2;
            final columns =
                (available / _targetTileWidth).ceil().clamp(2, 6);
            final cellWidth =
                (available - AppSpacing.md * (columns - 1)) / columns;
            final extent = ListingCard.extentFor(cellWidth, scaler: scaler);

            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _FilterGrid(scope: scope, filters: filters),
                ),
                SliverToBoxAdapter(
                  child: _Toolbar(
                    scope: scope,
                    filters: filters,
                    totalCount: results.valueOrNull?.totalCount,
                  ),
                ),
                ...switch (results) {
                  AsyncLoading<ResultsFeed>() => <Widget>[
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  AsyncError<ResultsFeed>(:final error) => <Widget>[
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _Message(
                          icon: Icons.wifi_off_outlined,
                          text: error is ListingFailure
                              ? error.message
                              : 'Could not load listings.',
                        ),
                      ),
                    ],
                  AsyncValue<ResultsFeed>(:final value?) =>
                    value.listings.isEmpty
                        ? <Widget>[
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyResults(scope: scope),
                            ),
                          ]
                        : <Widget>[
                            SliverPadding(
                              padding: AppSpacing.screenHorizontal,
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: AppSpacing.md,
                                  mainAxisSpacing: AppSpacing.md,
                                  mainAxisExtent: extent,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => ListingCard(
                                    listing: value.listings[index],
                                    onTap: () => context.push(
                                      Routes.listingPath(
                                        value.listings[index].id,
                                      ),
                                    ),
                                  ),
                                  childCount: value.listings.length,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: _LoadMore(scope: scope, feed: value),
                            ),
                          ],
                  _ => const <Widget>[],
                },
                const SliverToBoxAdapter(child: AppSpacing.gapXxl),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The grid of filter buttons above the results.
///
/// Which filters appear depends on the subcategory: Cars offers year and
/// transmission, Houses offers bedrooms. Anything uncharacterised falls
/// back to the generic set rather than showing nothing.
class _FilterGrid extends StatelessWidget {
  const _FilterGrid({required this.scope, required this.filters});

  /// Buttons shown before the overflow. Six cells fit two or three rows on
  /// a phone without pushing the listings off the first screen.
  static const int _visible = 5;

  final ResultsScope scope;
  final ResultsFilters filters;

  @override
  Widget build(BuildContext context) {
    final definitions = ListingFilters.forSubcategory(scope.subcategory);
    final shown = definitions.take(_visible).toList();
    final hasMore = definitions.length > _visible;
    final columns = MediaQuery.sizeOf(context).width >= 600 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Filter by',
            style: AppTextStyles.h4.copyWith(
              color: context.colors.primaryText,
            ),
          ),
          AppSpacing.gapSm,
          GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 3.2,
            children: <Widget>[
              for (final definition in shown)
                _FilterTile(
                  icon: definition.icon,
                  label: definition.label,
                  isActive: filters.isActive(definition),
                  onTap: () => showResultsFilterSheet(
                    context,
                    scope: scope,
                    definitions: <FilterDefinition>[definition],
                    title: definition.label,
                  ),
                ),
              if (hasMore)
                _FilterTile(
                  icon: Icons.more_horiz,
                  label: 'More filters',
                  isActive: false,
                  trailing: Icons.chevron_right,
                  onTap: () => showResultsFilterSheet(
                    context,
                    scope: scope,
                    definitions: definitions,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: isActive ? colors.secondaryBackground : colors.primaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.allSm,
        side: BorderSide(
          color: isActive ? colors.brand : colors.border,
          width: isActive ? 1 : 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: isActive ? colors.brand : colors.primaryIcon,
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.primaryText,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (trailing != null)
                Icon(trailing, size: 16, color: colors.secondaryIcon),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar({
    required this.scope,
    required this.filters,
    required this.totalCount,
  });

  final ResultsScope scope;
  final ResultsFilters filters;
  final int? totalCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              // Silent while the count is unknown. "Available: 0 items"
              // during a load reads as an empty category rather than a
              // pending request.
              totalCount == null
                  ? ''
                  : 'Available: $totalCount '
                      '${totalCount == 1 ? 'item' : 'items'}',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.secondaryText,
              ),
            ),
          ),
          _SortButton(scope: scope, sort: filters.sort),
          AppSpacing.hGapSm,
          _FilterButton(scope: scope, activeCount: filters.activeCount),
        ],
      ),
    );
  }
}

class _SortButton extends ConsumerWidget {
  const _SortButton({required this.scope, required this.sort});

  static const Map<ListingSort, String> _labels = <ListingSort, String>{
    ListingSort.latest: 'Latest',
    ListingSort.priceLowToHigh: 'Price: low to high',
    ListingSort.priceHighToLow: 'Price: high to low',
    ListingSort.mostViewed: 'Most viewed',
  };

  final ResultsScope scope;
  final ListingSort sort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return PopupMenuButton<ListingSort>(
      initialValue: sort,
      tooltip: 'Sort',
      position: PopupMenuPosition.under,
      onSelected: (value) =>
          ref.read(resultsFiltersProvider(scope).notifier).sortBy(value),
      itemBuilder: (context) => <PopupMenuEntry<ListingSort>>[
        for (final entry in _labels.entries)
          PopupMenuItem<ListingSort>(
            value: entry.key,
            child: Text(entry.value),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.primaryBackground,
          borderRadius: AppRadius.allPill,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _labels[sort] ?? 'Latest',
              style: AppTextStyles.label.copyWith(color: colors.primaryText),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: colors.secondaryIcon,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.scope, required this.activeCount});

  final ResultsScope scope;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = activeCount > 0;

    return Material(
      color: isActive ? colors.brand : colors.primaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.allPill,
        side: BorderSide(
          color: isActive ? colors.brand : colors.border,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showResultsFilterSheet(
          context,
          scope: scope,
          definitions: ListingFilters.forSubcategory(scope.subcategory),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.tune,
                size: 18,
                color: isActive ? colors.onBrand : colors.secondaryIcon,
              ),
              if (isActive) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$activeCount',
                  style: AppTextStyles.label.copyWith(color: colors.onBrand),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMore extends ConsumerWidget {
  const _LoadMore({required this.scope, required this.feed});

  final ResultsScope scope;
  final ResultsFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    if (!feed.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            "That's everything",
            style: AppTextStyles.caption.copyWith(
              color: colors.secondaryText,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: <Widget>[
          if (feed.loadMoreFailed) ...<Widget>[
            Text(
              'Could not load more. Try again.',
              style: AppTextStyles.caption.copyWith(color: colors.error),
            ),
            AppSpacing.gapSm,
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: feed.isLoadingMore
                  ? null
                  : () => ref.read(resultsProvider(scope).notifier).loadMore(),
              child: feed.isLoadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load more'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends ConsumerWidget {
  const _EmptyResults({required this.scope});

  final ResultsScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFilters = ref.watch(resultsFiltersProvider(scope)).activeCount > 0;

    return _Message(
      icon: Icons.search_off_outlined,
      // Distinguishing the two matters. "Nothing here" when a filter is
      // hiding results sends people away from a category that has plenty.
      text: hasFilters
          ? 'No listings match these filters.'
          : 'Nothing listed here yet. Check back soon.',
      action: hasFilters
          ? TextButton(
              onPressed: () =>
                  ref.read(resultsFiltersProvider(scope).notifier).clear(),
              child: const Text('Clear filters'),
            )
          : null,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 32, color: colors.secondaryIcon),
          AppSpacing.gapSm,
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.secondaryText,
            ),
          ),
          if (action != null) ...<Widget>[AppSpacing.gapSm, action!],
        ],
      ),
    );
  }
}
