import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/providers/saved_listings_provider.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_shadows.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/core/utils/formatters.dart';

/// How a [ListingCard] is laid out.
enum ListingCardVariant {
  /// Fills its parent's width, for use inside a grid.
  grid,

  /// Fixed width, for use inside a horizontally scrolling rail.
  rail,
}

/// A single listing, rendered as a tappable card.
///
/// Shared by Home, Category Results, Search, Saved, My Store and Seller
/// Profile. Written once and parameterised rather than copied per screen,
/// because a marketplace grid reads as broken the moment two surfaces
/// disagree about how a price or a condition chip looks.
///
/// Navigation is left to the caller through [onTap] so the card carries no
/// routing knowledge and stays usable in previews and tests.
class ListingCard extends ConsumerWidget {
  /// Creates a listing card.
  const ListingCard({
    required this.listing,
    this.onTap,
    this.variant = ListingCardVariant.grid,
    this.showSaveButton = true,
    super.key,
  });

  /// Width of a card in the [ListingCardVariant.rail] layout.
  static const double railWidth = 168;

  /// Aspect ratio of the card image, matching the design's 4:3 crop.
  static const double imageAspectRatio = 4 / 3;

  /// The listing being shown.
  final Listing listing;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Layout to use.
  final ListingCardVariant variant;

  /// Whether to show the save heart.
  ///
  /// Turned off on My Store, where saving your own listing is meaningless.
  final bool showSaveButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    final card = Container(
      decoration: context.cardSurface(),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _CardImage(
                listing: listing,
                showSaveButton: showSaveButton,
              ),
              Padding(
                padding: AppSpacing.cardCompact,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(
                        color: colors.primaryText,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      Formatters.price(listing.price, listing.currency),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.priceSmall.copyWith(
                        color: colors.brand,
                      ),
                    ),
                    AppSpacing.gapSm,
                    _MetaRow(listing: listing),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return switch (variant) {
      ListingCardVariant.grid => card,
      ListingCardVariant.rail => SizedBox(width: railWidth, child: card),
    };
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.listing, required this.showSaveButton});

  final Listing listing;
  final bool showSaveButton;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cover = listing.coverImage;

    return AspectRatio(
      aspectRatio: ListingCard.imageAspectRatio,
      child: DecoratedBox(
        // Always bordered, in both themes. Phone and electronics photos
        // are overwhelmingly shot on white, and without an outline they
        // bleed into a light card and glare against a dark one.
        decoration: context.imageSurface(radius: AppRadius.topMd),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (cover == null)
              Icon(
                Icons.image_not_supported_outlined,
                color: colors.secondaryIcon,
              )
            else
              CachedNetworkImage(
                imageUrl: cover,
                fit: BoxFit.cover,
                placeholder: (context, url) => ColoredBox(
                  color: colors.secondaryBackground,
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image_outlined,
                  color: colors.secondaryIcon,
                ),
              ),
            PositionedDirectional(
              top: AppSpacing.sm,
              start: 0,
              child: _ConditionChip(condition: listing.condition),
            ),
            if (showSaveButton)
              PositionedDirectional(
                top: AppSpacing.sm,
                end: AppSpacing.sm,
                child: _SaveButton(listingId: listing.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.condition});

  /// Fixed dark ink for chip labels.
  ///
  /// The warning fill is a mid orange in light mode and a lighter orange in
  /// dark mode, so dark text is the readable choice against both. Using
  /// `primaryText` would flip to near-white in dark mode and drop the
  /// contrast to roughly 2:1.
  static const Color _label = Color(0xFF14181B);

  final ListingCondition condition;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.chip,
      decoration: BoxDecoration(
        color: context.colors.warning,
        borderRadius: const BorderRadiusDirectional.horizontal(
          end: Radius.circular(AppRadius.xs),
        ),
      ),
      child: Text(
        condition.label,
        style: AppTextStyles.label.copyWith(color: _label),
      ),
    );
  }
}

class _SaveButton extends ConsumerWidget {
  const _SaveButton({required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isSaved = ref.watch(isListingSavedProvider(listingId));

    return Material(
      color: colors.primaryBackground,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            ref.read(savedListingsProvider.notifier).toggle(listingId),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isSaved ? colors.brand : colors.secondaryIcon,
            semanticLabel: isSaved ? 'Remove from saved' : 'Save listing',
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final caption = AppTextStyles.caption.copyWith(
      color: colors.secondaryText,
    );

    return Row(
      children: <Widget>[
        Icon(
          Icons.location_on_outlined,
          size: 12,
          color: colors.secondaryIcon,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: Text(
            listing.locationLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: caption,
          ),
        ),
        AppSpacing.hGapXs,
        Text(Formatters.timeAgo(listing.createdAt), style: caption),
      ],
    );
  }
}
