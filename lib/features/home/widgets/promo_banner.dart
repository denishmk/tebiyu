import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';

/// Whether the user has dismissed the promo banner this session.
///
/// Session scoped on purpose. Persisting a dismissal would hide the banner
/// permanently after one tap, and this space becomes paid campaign
/// inventory later. If it does become permanent, it should expire.
final StateProvider<bool> promoBannerDismissedProvider =
    StateProvider<bool>((ref) => false);

/// One slide in the promo carousel.
@immutable
class PromoSlide {
  /// Creates a slide.
  const PromoSlide({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.route,
  });

  /// Headline.
  final String title;

  /// Supporting copy.
  final String body;

  /// Label on the call to action.
  final String actionLabel;

  /// Route the call to action opens.
  final String route;
}

/// The promotional banner carousel.
///
/// Copy is hardcoded for now. These slides become admin-managed campaign
/// content, so treat this list as a placeholder rather than a design.
///
/// No artwork: the illustration in the design is not yet an asset, and an
/// empty image slot looks broken in a way a plain tinted card does not.
class PromoBanner extends ConsumerStatefulWidget {
  /// Creates the banner.
  const PromoBanner({super.key});

  /// The slides shown, in order.
  static const List<PromoSlide> slides = <PromoSlide>[
    PromoSlide(
      title: 'Sell faster on Tebiyu',
      body: 'Post your ad in minutes and reach buyers near you.',
      actionLabel: 'Create Listing',
      route: Routes.sell,
    ),
    PromoSlide(
      title: 'Buy with confidence',
      body: 'Look for the verified badge before you pay for anything.',
      actionLabel: 'Browse listings',
      route: Routes.categories,
    ),
  ];

  @override
  ConsumerState<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends ConsumerState<PromoBanner> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(promoBannerDismissedProvider)) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return Container(
      height: 168,
      margin: AppSpacing.screenHorizontal,
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: AppRadius.allLg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _controller,
            itemCount: PromoBanner.slides.length,
            onPageChanged: (value) => setState(() => _page = value),
            itemBuilder: (context, index) => _Slide(
              slide: PromoBanner.slides[index],
            ),
          ),
          PositionedDirectional(
            top: AppSpacing.xs,
            end: AppSpacing.xs,
            child: IconButton(
              onPressed: () =>
                  ref.read(promoBannerDismissedProvider.notifier).state = true,
              tooltip: 'Dismiss',
              iconSize: 18,
              icon: Icon(Icons.close, color: colors.secondaryIcon),
            ),
          ),
          PositionedDirectional(
            bottom: AppSpacing.md,
            start: AppSpacing.lg,
            child: _Dots(count: PromoBanner.slides.length, active: _page),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final PromoSlide slide;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        end: AppSpacing.xxl,
        top: AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            slide.title,
            style: AppTextStyles.h3.copyWith(color: colors.primaryText),
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: Text(
              slide.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.secondaryText,
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () => context.push(slide.route),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                minimumSize: Size.zero,
              ),
              child: Text(slide.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < count; i++)
          Container(
            width: i == active ? 16 : 6,
            height: 6,
            margin: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
            decoration: BoxDecoration(
              color: i == active ? colors.brand : colors.border,
              borderRadius: AppRadius.allPill,
            ),
          ),
      ],
    );
  }
}
