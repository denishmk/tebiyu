import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/providers/saved_listings_provider.dart';
import 'package:tebiyu/core/repositories/listing_repository_provider.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/core/widgets/listing_card.dart';

/// Listings the user has saved.
///
/// Resolves ids to listings on each visit rather than caching the listings
/// themselves. A saved item's price or availability can change, and showing
/// a stale copy of something a buyer is still considering is worse than a
/// short wait.
final FutureProvider<List<Listing>> savedListingsFeedProvider =
    FutureProvider<List<Listing>>((ref) async {
  final ids = await ref.watch(savedListingsProvider.future);
  if (ids.isEmpty) return const <Listing>[];
  return ref.watch(listingRepositoryProvider).fetchByIds(ids);
});

/// The Saved tab.
class SavedScreen extends ConsumerWidget {
  /// Creates the saved screen.
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedListingsFeedProvider);
    final ids =
        ref.watch(savedListingsProvider).valueOrNull ?? const <String>[];
    final scaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        actions: <Widget>[
          if (ids.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: const Text('Clear all'),
            ),
          AppSpacing.hGapSm,
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxWidth - AppSpacing.lg * 2;
            final columns = (available / 180).ceil().clamp(2, 6);
            final cellWidth =
                (available - AppSpacing.md * (columns - 1)) / columns;
            final extent = ListingCard.extentFor(cellWidth, scaler: scaler);

            return saved.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const _Empty(
                icon: Icons.wifi_off_outlined,
                title: 'Could not load your saved items',
                body: 'Check your connection and try again.',
              ),
              data: (listings) {
                if (listings.isEmpty) {
                  return _Empty(
                    icon: Icons.favorite_border,
                    title: 'Nothing saved yet',
                    body: 'Tap the heart on any listing to keep it here.',
                    action: FilledButton(
                      onPressed: () => context.go(Routes.home),
                      child: const Text('Browse listings'),
                    ),
                  );
                }

                // Some saved ids may have been sold or taken down, so the
                // list can be shorter than the saved count. Said plainly
                // rather than silently, otherwise the number looks wrong.
                final missing = ids.length - listings.length;

                return CustomScrollView(
                  slivers: <Widget>[
                    if (missing > 0)
                      SliverToBoxAdapter(
                        child: _Notice(count: missing),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        0,
                      ),
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
                            listing: listings[index],
                            onTap: () => context.push(
                              Routes.listingPath(listings[index].id),
                            ),
                          ),
                          childCount: listings.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: AppSpacing.gapXxl),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear saved listings?'),
        content: const Text('This removes every item from your saved list.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(savedListingsProvider.notifier).clear();
    }
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.warningBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline, size: 16, color: colors.warning),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              count == 1
                  ? '1 saved listing is no longer available.'
                  : '$count saved listings are no longer available.',
              style: AppTextStyles.caption.copyWith(color: colors.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 40, color: colors.secondaryIcon),
            AppSpacing.gapMd,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(color: colors.primaryText),
            ),
            AppSpacing.gapSm,
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.secondaryText,
              ),
            ),
            if (action != null) ...<Widget>[AppSpacing.gapLg, action!],
          ],
        ),
      ),
    );
  }
}
