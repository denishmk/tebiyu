import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tebiyu/core/models/tebiyu_user.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_shadows.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/core/widgets/listing_card.dart';
import 'package:tebiyu/features/results/providers/results_providers.dart';
import 'package:tebiyu/features/seller_profile/providers/'
    'seller_profile_providers.dart';

/// A seller's public profile and their listings.
class SellerProfileScreen extends ConsumerWidget {
  /// Creates the profile screen.
  const SellerProfileScreen({required this.sellerId, super.key});

  /// Whose profile to show.
  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seller = ref.watch(sellerProvider(sellerId));
    final scope = ResultsScope(sellerId: sellerId);
    final results = ref.watch(resultsProvider(scope));
    final scaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () => _shareProfile(context, seller.valueOrNull),
            tooltip: 'Share profile',
            icon: const Icon(Icons.ios_share),
          ),
          AppSpacing.hGapSm,
        ],
      ),
      body: seller.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const _Centred(
          icon: Icons.wifi_off_outlined,
          message: 'Could not load this profile.',
        ),
        data: (value) {
          if (value == null) {
            return const _Centred(
              icon: Icons.person_off_outlined,
              message: 'This account is no longer available.',
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final available = constraints.maxWidth - AppSpacing.lg * 2;
              final columns = (available / 180).ceil().clamp(2, 6);
              final cellWidth =
                  (available - AppSpacing.md * (columns - 1)) / columns;
              final extent = ListingCard.extentFor(cellWidth, scaler: scaler);
              final isWide = constraints.maxWidth >= 600;

              return CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: _Header(seller: value, isWide: isWide),
                  ),
                  SliverToBoxAdapter(
                    child: _Stats(seller: value, isWide: isWide),
                  ),
                  SliverToBoxAdapter(
                    child: _ListingsHeader(
                      scope: scope,
                      total: results.valueOrNull?.totalCount,
                    ),
                  ),
                  ..._grid(context, results, columns, extent),
                  const SliverToBoxAdapter(child: AppSpacing.gapXxl),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _grid(
    BuildContext context,
    AsyncValue<ResultsFeed> results,
    int columns,
    double extent,
  ) {
    return switch (results) {
      AsyncLoading<ResultsFeed>() => <Widget>[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      AsyncError<ResultsFeed>(:final error) => <Widget>[
          SliverToBoxAdapter(
            child: _Centred(
              icon: Icons.wifi_off_outlined,
              message: error is ListingFailure
                  ? error.message
                  : 'Could not load these listings.',
            ),
          ),
        ],
      AsyncValue<ResultsFeed>(:final value?) => value.listings.isEmpty
          ? <Widget>[
              const SliverToBoxAdapter(
                child: _Centred(
                  icon: Icons.inventory_2_outlined,
                  message: 'This seller has nothing listed right now.',
                ),
              ),
            ]
          : <Widget>[
              SliverPadding(
                padding: AppSpacing.screenHorizontal,
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    mainAxisExtent: extent,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListingCard(
                      listing: value.listings[index],
                      onTap: () => context.push(
                        Routes.listingPath(value.listings[index].id),
                      ),
                    ),
                    childCount: value.listings.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _LoadMore(sellerId: sellerId, feed: value),
              ),
            ],
      _ => const <Widget>[],
    };
  }

  Future<void> _shareProfile(BuildContext context, TebiyuUser? seller) async {
    if (seller == null) return;
    await Clipboard.setData(
      ClipboardData(text: '${seller.name} on Tebiyu (ref ${seller.id})'),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile details copied')),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.seller, required this.isWide});

  final TebiyuUser seller;
  final bool isWide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      padding: AppSpacing.card,
      decoration: context.cardSurface(),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          _Avatar(seller: seller),
          AppSpacing.gapMd,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  seller.name,
                  style: AppTextStyles.h2.copyWith(color: colors.primaryText),
                ),
              ),
              if (seller.verified) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.verified, size: 20, color: colors.info),
              ],
            ],
          ),
          if (seller.verified) ...<Widget>[
            AppSpacing.gapSm,
            Container(
              padding: AppSpacing.chip,
              decoration: BoxDecoration(
                color: colors.infoBackground,
                borderRadius: AppRadius.allXs,
              ),
              child: Text(
                'Verified seller',
                style: AppTextStyles.label.copyWith(color: colors.info),
              ),
            ),
          ],
          if (seller.bio != null) ...<Widget>[
            AppSpacing.gapSm,
            Text(
              seller.bio!,
              textAlign: isWide ? TextAlign.start : TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.secondaryText,
              ),
            ),
          ],
          AppSpacing.gapMd,
          _ContactRows(seller: seller, centred: !isWide),
          AppSpacing.gapLg,
          _Actions(seller: seller),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.seller});

  final TebiyuUser seller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CircleAvatar(
      radius: 44,
      backgroundColor: colors.secondaryBackground,
      foregroundImage: seller.avatarUrl == null
          ? null
          : CachedNetworkImageProvider(seller.avatarUrl!),
      child: Text(
        seller.initial,
        style: AppTextStyles.h1.copyWith(color: colors.brand),
      ),
    );
  }
}

class _ContactRows extends StatelessWidget {
  const _ContactRows({required this.seller, required this.centred});

  final TebiyuUser seller;
  final bool centred;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = AppTextStyles.bodySmall.copyWith(
      color: colors.secondaryText,
    );

    Widget row(IconData icon, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: colors.primaryIcon),
            const SizedBox(width: AppSpacing.sm),
            Flexible(child: Text(text, style: style)),
          ],
        );

    return Wrap(
      alignment: centred ? WrapAlignment.center : WrapAlignment.start,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        if (seller.city != null)
          row(Icons.location_on_outlined, seller.city!),
        if (seller.email != null) row(Icons.mail_outline, seller.email!),
        if (seller.phone != null) row(Icons.call_outlined, seller.phone!),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.seller});

  final TebiyuUser seller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final following = ref.watch(followProvider(seller.id)).valueOrNull ?? false;

    return Row(
      children: <Widget>[
        Expanded(
          child: following
              ? OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(followProvider(seller.id).notifier).toggle(),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Following'),
                )
              : ElevatedButton(
                  onPressed: () =>
                      ref.read(followProvider(seller.id).notifier).toggle(),
                  child: const Text('Follow'),
                ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push(Routes.messages),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Message'),
          ),
        ),
      ],
    );
  }
}

/// Follower, listing and rating counts.
///
/// Four cards on a wide screen, a single compact row on a phone. Stacking
/// four cards vertically would push the listings, which are what a buyer
/// came for, below the fold.
class _Stats extends StatelessWidget {
  const _Stats({required this.seller, required this.isWide});

  final TebiyuUser seller;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final entries = <({String value, String label, IconData icon})>[
      (
        value: '${seller.followers}',
        label: 'Followers',
        icon: Icons.group_outlined,
      ),
      (
        value: '${seller.following}',
        label: 'Following',
        icon: Icons.person_outline,
      ),
      (
        value: '${seller.activeListings}',
        label: 'Listings',
        icon: Icons.shopping_bag_outlined,
      ),
      (
        // An unrated seller shows a dash, not 0.0. A zero average reads as
        // "rated badly" when it means "not rated yet".
        value: seller.hasRating
            ? seller.sellerRating.toStringAsFixed(1)
            : '\u2013',
        label: seller.hasRating
            ? '${seller.reviewCount} reviews'
            : 'No reviews',
        icon: Icons.star_outline,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              for (final entry in entries) ...<Widget>[
                Expanded(
                  child: Container(
                    padding: isWide
                        ? AppSpacing.card
                        : const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                    decoration:
                        isWide ? context.cardSurface() : const BoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        if (isWide)
                          Icon(entry.icon, color: colors.primaryIcon),
                        if (isWide) AppSpacing.gapSm,
                        Text(
                          entry.value,
                          style: AppTextStyles.h3.copyWith(
                            color: colors.primaryText,
                          ),
                        ),
                        Text(
                          entry.label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (entry != entries.last && isWide) AppSpacing.hGapMd,
              ],
            ],
          ),
          AppSpacing.gapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: colors.secondaryIcon,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Member since ${_monthYear(seller.memberSince)}',
                style: AppTextStyles.caption.copyWith(
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const List<String> _months = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String _monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';
}

class _ListingsHeader extends ConsumerWidget {
  const _ListingsHeader({required this.scope, required this.total});

  static const Map<ListingSort, String> _labels = <ListingSort, String>{
    ListingSort.latest: 'Latest',
    ListingSort.priceLowToHigh: 'Price: low to high',
    ListingSort.priceHighToLow: 'Price: high to low',
    ListingSort.mostViewed: 'Most viewed',
  };

  final ResultsScope scope;
  final int? total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final sort = ref.watch(resultsFiltersProvider(scope)).sort;

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
              total == null ? 'Listings' : 'Listings ($total)',
              style: AppTextStyles.h3.copyWith(color: colors.primaryText),
            ),
          ),
          PopupMenuButton<ListingSort>(
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
                    style: AppTextStyles.label.copyWith(
                      color: colors.primaryText,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: colors.secondaryIcon,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMore extends ConsumerWidget {
  const _LoadMore({required this.sellerId, required this.feed});

  final String sellerId;
  final ResultsFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!feed.hasMore) return const SizedBox.shrink();
    final scope = ResultsScope(sellerId: sellerId);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
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
    );
  }
}

class _Centred extends StatelessWidget {
  const _Centred({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 32, color: colors.secondaryIcon),
          AppSpacing.gapSm,
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
