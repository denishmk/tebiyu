import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_shadows.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/core/utils/formatters.dart';
import 'package:tebiyu/core/widgets/listing_card.dart';
import 'package:tebiyu/features/home/providers/home_feed_providers.dart';
import 'package:tebiyu/features/home/widgets/category_row.dart';
import 'package:tebiyu/features/home/widgets/home_header.dart';
import 'package:tebiyu/features/home/widgets/promo_banner.dart';
import 'package:tebiyu/features/location/data/location_providers.dart';

/// The Home feed.
///
/// Watches [locationProvider] and passes the city into the feed families, so
/// changing location in the picker re-keys the providers and the feed
/// follows without any explicit refresh.
class HomeScreen extends ConsumerWidget {
  /// Creates the Home screen.
  const HomeScreen({super.key});

  /// Columns in the Trending grid at a given viewport [width].
  ///
  /// Phones get two. Tablets get three, which at 768px leaves each cell
  /// around 237px, wider than a phone cell rather than narrower, so titles
  /// and prices have more room, not less. Desktop widths get four, since
  /// three columns stretched across 1400px reads as a list of billboards.
  static int _columnsFor(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(locationProvider).city;
    final recommended = ref.watch(recommendedListingsProvider(city));
    final trending = ref.watch(trendingListingsProvider(city));

    final width = MediaQuery.sizeOf(context).width;
    final scaler = MediaQuery.textScalerOf(context);
    final columns = _columnsFor(width);

    // Cell width after screen padding and the gaps between columns. The
    // card's height follows from this, so both the grid and the rail read
    // it rather than carrying a tuned constant.
    final cellWidth =
        (width - AppSpacing.lg * 2 - AppSpacing.md * (columns - 1)) / columns;
    final extent = ListingCard.extentFor(cellWidth, scaler: scaler);

    // Keep rail cards phone-sized on phones, and matched to the grid below
    // on anything wider.
    final railWidth = width < 600 ? ListingCard.railWidth : cellWidth;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => refreshHomeFeed(ref, city),
          child: CustomScrollView(
            slivers: <Widget>[
              const SliverToBoxAdapter(child: HomeHeader()),
              SliverToBoxAdapter(
                child: _OfflineBanner(
                  recommended: recommended.valueOrNull,
                  trending: trending.valueOrNull,
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.gapLg),
              const SliverToBoxAdapter(child: PromoBanner()),
              const SliverToBoxAdapter(child: AppSpacing.gapXl),
              const SliverToBoxAdapter(
                child: _SectionHeader(title: 'Browse categories'),
              ),
              const SliverToBoxAdapter(child: CategoryRow()),
              const SliverToBoxAdapter(child: AppSpacing.gapXl),
              const SliverToBoxAdapter(
                child: _SectionHeader(title: 'Recommended for you'),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: ListingCard.extentFor(railWidth, scaler: scaler),
                  child: _RecommendedRail(
                    feed: recommended,
                    cardWidth: railWidth,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.gapXl),
              const SliverToBoxAdapter(
                child: _SectionHeader(title: 'Trending'),
              ),
              _TrendingGrid(
                feed: trending,
                extent: extent,
                columns: columns,
              ),
              const SliverToBoxAdapter(child: AppSpacing.gapXxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        end: AppSpacing.sm,
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: context.colors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedRail extends StatelessWidget {
  const _RecommendedRail({required this.feed, required this.cardWidth});

  final AsyncValue<FeedResult> feed;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return feed.when(
      loading: () => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenHorizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => AppSpacing.hGapMd,
        itemBuilder: (_, _) => _CardSkeleton(width: cardWidth),
      ),
      error: (error, stack) => _FeedError(error: error),
      data: (result) {
        if (result.listings.isEmpty) {
          return const _FeedEmpty(message: 'Nothing to recommend just yet.');
        }
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.screenHorizontal,
          itemCount: result.listings.length,
          separatorBuilder: (_, _) => AppSpacing.hGapMd,
          itemBuilder: (context, index) => ListingCard(
            listing: result.listings[index],
            variant: ListingCardVariant.rail,
            width: cardWidth,
          ),
        );
      },
    );
  }
}

class _TrendingGrid extends StatelessWidget {
  const _TrendingGrid({
    required this.feed,
    required this.extent,
    required this.columns,
  });

  final AsyncValue<FeedResult> feed;
  final double extent;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      mainAxisExtent: extent,
    );

    return feed.when(
      loading: () => SliverPadding(
        padding: AppSpacing.screenHorizontal,
        sliver: SliverGrid(
          gridDelegate: delegate,
          delegate: SliverChildBuilderDelegate(
            (_, _) => const _CardSkeleton(),
            childCount: 4,
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: _FeedError(error: error),
      ),
      data: (result) {
        if (result.listings.isEmpty) {
          return const SliverToBoxAdapter(
            child: _FeedEmpty(message: 'No listings here yet.'),
          );
        }
        return SliverPadding(
          padding: AppSpacing.screenHorizontal,
          sliver: SliverGrid(
            gridDelegate: delegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListingCard(
                listing: result.listings[index],
              ),
              childCount: result.listings.length,
            ),
          ),
        );
      },
    );
  }
}

/// Tells the user the feed came off disk, and how old it is.
///
/// Silence here would be the wrong call. A cached price or a sold item read
/// as current is how a buyer ends up phoning a seller about something that
/// went yesterday, and blaming the app rather than the connection.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({this.recommended, this.trending});

  final FeedResult? recommended;
  final FeedResult? trending;

  @override
  Widget build(BuildContext context) {
    final cachedAt = <DateTime>[
      if (recommended?.isStale ?? false) recommended!.cachedAt!,
      if (trending?.isStale ?? false) trending!.cachedAt!,
    ];

    if (cachedAt.isEmpty) return const SizedBox.shrink();

    // Two feeds can be cached at different moments. Report the older one,
    // since that is the weaker claim the screen is making.
    cachedAt.sort();
    final age = Formatters.age(DateTime.now().difference(cachedAt.first));
    final colors = context.colors;

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.warningBackground,
        borderRadius: AppRadius.allSm,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.cloud_off_outlined, size: 16, color: colors.warning),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              'Showing listings saved $age ago. Pull down to refresh.',
              style: AppTextStyles.caption.copyWith(color: colors.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final message = error is ListingFailure
        ? (error as ListingFailure).message
        : 'Could not load listings. Pull down to try again.';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: <Widget>[
          Icon(Icons.wifi_off_outlined, color: colors.secondaryIcon, size: 32),
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

class _FeedEmpty extends StatelessWidget {
  const _FeedEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.colors.secondaryText,
          ),
        ),
      ),
    );
  }
}

/// A pulsing placeholder in the shape of a listing card.
///
/// Hand rolled rather than pulling in `shimmer`. The effect is a single
/// opacity tween, and a skeleton that matches the real card's proportions
/// matters far more than the sweep animation a package would add.
class _CardSkeleton extends StatefulWidget {
  const _CardSkeleton({this.width});

  final double? width;

  @override
  State<_CardSkeleton> createState() => _CardSkeletonState();
}

class _CardSkeletonState extends State<_CardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final card = Container(
      width: widget.width,
      decoration: context.cardSurface(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AspectRatio(
            aspectRatio: ListingCard.imageAspectRatio,
            child: ColoredBox(color: colors.secondaryBackground),
          ),
          Padding(
            padding: AppSpacing.cardCompact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _bar(colors.secondaryBackground, widthFactor: 0.9, height: 12),
                AppSpacing.gapSm,
                _bar(colors.secondaryBackground, widthFactor: 0.5, height: 12),
                AppSpacing.gapSm,
                _bar(colors.secondaryBackground, widthFactor: 0.7, height: 10),
              ],
            ),
          ),
        ],
      ),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: card,
    );
  }

  Widget _bar(Color color, {required double widthFactor, required double
      height}) {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.allXs,
        ),
      ),
    );
  }
}
