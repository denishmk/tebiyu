import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tebiyu/core/constants/listing_filters.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/providers/currency_provider.dart';
import 'package:tebiyu/core/providers/saved_listings_provider.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_shadows.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/core/utils/formatters.dart';
import 'package:tebiyu/core/widgets/listing_card.dart';
import 'package:tebiyu/features/listing_detail/providers/'
    'listing_detail_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// A single listing in full.
class ListingDetailScreen extends ConsumerStatefulWidget {
  /// Creates the detail screen.
  const ListingDetailScreen({required this.listingId, super.key});

  /// Which listing to show.
  final String listingId;

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame, so the count is not recorded for a screen the
    // user never actually sees when a route redirect fires.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recordListingViewProvider(widget.listingId))();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listing = ref.watch(listingByIdProvider(widget.listingId));

    return Scaffold(
      body: listing.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>const _Centred(
          icon: Icons.wifi_off_outlined,
          message: 'Could not load this listing.',
        ),
        data: (value) => value == null
            ? const _Centred(
                icon: Icons.search_off_outlined,
                message: 'This listing is no longer available.',
              )
            : _Body(listing: value),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: <Widget>[
        _Gallery(listing: listing),
        SliverToBoxAdapter(child: _Headline(listing: listing)),
        SliverToBoxAdapter(child: _Overview(listing: listing)),
        SliverToBoxAdapter(child: _Description(listing: listing)),
        SliverToBoxAdapter(child: _Features(listing: listing)),
        SliverToBoxAdapter(child: _SellerCard(listing: listing)),
        SliverToBoxAdapter(child: _ReportAbuse(listing: listing)),
        SliverToBoxAdapter(child: _LocationCard(listing: listing)),
        SliverToBoxAdapter(child: _SimilarAds(listing: listing)),
        const SliverToBoxAdapter(child: AppSpacing.gapXxl),
      ],
    );
  }
}

class _Gallery extends ConsumerStatefulWidget {
  const _Gallery({required this.listing});

  final Listing listing;

  @override
  ConsumerState<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends ConsumerState<_Gallery> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final images = widget.listing.images;
    final isSaved = ref.watch(isListingSavedProvider(widget.listing.id));

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: colors.appBackground,
      surfaceTintColor: Colors.transparent,
      leading: _RoundIcon(
        icon: Icons.arrow_back,
        onTap: () => context.pop(),
        semanticLabel: 'Back',
      ),
      actions: <Widget>[
        _RoundIcon(
          icon: isSaved ? Icons.favorite : Icons.favorite_border,
          tint: isSaved ? colors.brand : null,
          onTap: () => ref
              .read(savedListingsProvider.notifier)
              .toggle(widget.listing.id),
          semanticLabel: isSaved ? 'Remove from saved' : 'Save listing',
        ),
        _RoundIcon(
          icon: Icons.ios_share,
          onTap: () => _share(context),
          semanticLabel: 'Share',
        ),
        AppSpacing.hGapSm,
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (images.isEmpty)
              ColoredBox(
                color: colors.secondaryBackground,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: colors.secondaryIcon,
                ),
              )
            else
              PageView.builder(
                controller: _controller,
                itemCount: images.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) => CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      ColoredBox(color: colors.secondaryBackground),
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image_outlined,
                    color: colors.secondaryIcon,
                  ),
                ),
              ),
            if (images.length > 1)
              PositionedDirectional(
                bottom: AppSpacing.md,
                start: 0,
                end: 0,
                child: _Dots(count: images.length, active: _page),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    // Copies rather than opening the system share sheet. A share sheet
    // needs another dependency, and there is no public listing page to
    // point at yet, so a copied reference is the honest version.
    await Clipboard.setData(
      ClipboardData(
        text: '${widget.listing.title} on Tebiyu '
            '(ref ${widget.listing.id})',
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing details copied')),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.tint,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: colors.primaryBackground,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 20,
              color: tint ?? colors.primaryText,
              semanticLabel: semanticLabel,
            ),
          ),
        ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (var i = 0; i < count; i++)
          Container(
            width: i == active ? 16 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == active ? colors.onBrand : colors.onBrand
                  .withValues(alpha: 0.5),
              borderRadius: AppRadius.allPill,
            ),
          ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      padding: padding ?? AppSpacing.card,
      decoration: context.cardSurface(),
      width: double.infinity,
      child: child,
    );
  }
}

class _Headline extends ConsumerWidget {
  const _Headline({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final price = ref.watch(priceConverterProvider).format(listing);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colors.primaryIcon,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    listing.locationLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                ),
                Text(
                  Formatters.timeAgo(listing.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
            AppSpacing.gapSm,
            Text(
              listing.title,
              style: AppTextStyles.h2.copyWith(color: colors.primaryText),
            ),
            AppSpacing.gapSm,
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  price.text,
                  style: AppTextStyles.price.copyWith(color: colors.brand),
                ),
                if (listing.negotiable)
                  _Divided(text: 'Negotiable', colors: colors),
                if (listing.exchangePossible)
                  _Divided(text: 'Exchange possible', colors: colors),
              ],
            ),
            AppSpacing.gapXs,
            Text(
              listing.condition.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.secondaryText,
              ),
            ),
            AppSpacing.gapLg,
            _ContactButtons(listing: listing),
          ],
        ),
      ),
    );
  }
}

class _Divided extends StatelessWidget {
  const _Divided({required this.text, required this.colors});

  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 1,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          color: colors.border,
        ),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(color: colors.secondaryText),
        ),
      ],
    );
  }
}

class _ContactButtons extends StatelessWidget {
  const _ContactButtons({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final phone = listing.contactPhone;

    final chat = ElevatedButton.icon(
      onPressed: () => context.push(Routes.messages),
      icon: const Icon(Icons.chat_bubble_outline, size: 18),
      label: const Text('Chat seller'),
    );

    // No number means no call. A disabled button in the brand's washed-out
    // green reads as a fault rather than an absence, and it costs half the
    // row for something nobody can use, so Chat simply takes the width.
    if (phone == null) {
      return SizedBox(width: double.infinity, child: chat);
    }

    return Row(
      children: <Widget>[
        Expanded(child: chat),
        AppSpacing.hGapMd,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _call(context, phone),
            icon: const Icon(Icons.call_outlined, size: 18),
            label: const Text('Call seller'),
          ),
        ),
      ],
    );
  }

  Future<void> _call(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not start a call to $phone')),
    );
  }
}

/// The spec grid.
///
/// Reads the same filter schema the results screen uses, so a Car shows
/// Body Type, Year and Transmission with the icons a buyer already met on
/// the filter buttons. Attributes with no schema entry still appear, just
/// with a generic icon, so nothing a seller filled in is hidden.
class _Overview extends StatelessWidget {
  const _Overview({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    if (listing.attributes.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final definitions = ListingFilters.forSubcategory(listing.subcategory);
    final icons = <String, IconData>{
      for (final definition in definitions)
        if (definition.attributeKey != null)
          definition.attributeKey!: definition.icon,
    };

    final ordered = <MapEntry<String, String>>[
      for (final definition in definitions)
        if (definition.attributeKey != null &&
            listing.attributes.containsKey(definition.attributeKey))
          MapEntry(
            definition.attributeKey!,
            listing.attributes[definition.attributeKey]!,
          ),
      for (final entry in listing.attributes.entries)
        if (!icons.containsKey(entry.key)) entry,
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Overview',
            style: AppTextStyles.h3.copyWith(color: colors.primaryText),
          ),
          AppSpacing.gapMd,
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 420 ? 3 : 2;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: <Widget>[
                  for (final entry in ordered)
                    SizedBox(
                      width: (constraints.maxWidth -
                              AppSpacing.md * (columns - 1)) /
                          columns,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            icons[entry.key] ?? Icons.info_outline,
                            size: 18,
                            color: colors.primaryIcon,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  entry.value,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: colors.primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // The label is what makes the value mean
                                // anything. "Automatic" reads on its own,
                                // but "10" and "Yes" are noise without
                                // "Quantity" and "Vaccinated" beneath them.
                                Text(
                                  entry.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    if (listing.description.trim().isEmpty) return const SizedBox.shrink();
    final colors = context.colors;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Description',
            style: AppTextStyles.h3.copyWith(color: colors.primaryText),
          ),
          AppSpacing.gapSm,
          Text(
            listing.description,
            style: AppTextStyles.body.copyWith(color: colors.primaryText),
          ),
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    if (listing.features.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Extra features',
            style: AppTextStyles.h3.copyWith(color: colors.primaryText),
          ),
          AppSpacing.gapMd,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final feature in listing.features)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondaryBackground,
                    borderRadius: AppRadius.allSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: colors.primaryIcon,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        feature,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Who is selling.
///
/// Shows only what a listing carries. Member-since and total listings need
/// the user repository that arrives with the Seller Profile screen, and
/// inventing them here would mean two sources for the same numbers.
class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: colors.secondaryBackground,
              foregroundImage: listing.sellerAvatarUrl == null
                  ? null
                  : CachedNetworkImageProvider(listing.sellerAvatarUrl!),
              child: Text(
                listing.sellerName.isEmpty
                    ? '?'
                    : listing.sellerName.characters.first.toUpperCase(),
                style: AppTextStyles.h4.copyWith(color: colors.brand),
              ),
            ),
            title: Text(
              'Posted by ${listing.sellerName}',
              style: AppTextStyles.h4.copyWith(color: colors.primaryText),
            ),
            subtitle: Text(
              listing.sellerType.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.secondaryText,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: colors.secondaryIcon),
            onTap: () {},
          ),
          if (listing.sellerVerified)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.verified, size: 18, color: colors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Verified seller',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.info,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReportAbuse extends StatelessWidget {
  const _ReportAbuse({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporting opens when moderation goes live.'),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.error,
            side: BorderSide(color: colors.error),
          ),
          icon: const Icon(Icons.flag_outlined, size: 18),
          label: const Text('Report abuse'),
        ),
      ),
    );
  }
}

/// Where the item is, as a link out to a maps app.
///
/// Not an embedded map. `google_maps_flutter` needs an API key with
/// billing enabled, and a static card that opens the phone's own maps app
/// gives a buyer the same answer without that setup or the per-load cost.
class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Posted from ${listing.locationLabel}',
            style: AppTextStyles.h3.copyWith(color: colors.primaryText),
          ),
          AppSpacing.gapMd,
          Material(
            color: colors.secondaryBackground,
            borderRadius: AppRadius.allSm,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openMap(context),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.map_outlined, color: colors.primaryIcon),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: Text(
                        listing.latitude == null
                            ? 'Search this area in maps'
                            : 'Open this location in maps',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.primaryText,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: colors.secondaryIcon,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(BuildContext context) async {
    final lat = listing.latitude;
    final lng = listing.longitude;
    final uri = lat != null && lng != null
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng')
        : Uri.https('www.google.com', '/maps/search/', <String, String>{
            'api': '1',
            'query': listing.locationLabel,
          });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No maps app available')),
    );
  }
}

class _SimilarAds extends ConsumerWidget {
  const _SimilarAds({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similar = ref.watch(similarListingsProvider(listing.id));
    final items = similar.valueOrNull ?? const <Listing>[];
    if (items.isEmpty) return const SizedBox.shrink();

    final scaler = MediaQuery.textScalerOf(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Text(
            'Similar ads',
            style: AppTextStyles.h3.copyWith(color: colors.primaryText),
          ),
        ),
        SizedBox(
          height: ListingCard.extentFor(
            ListingCard.railWidth,
            scaler: scaler,
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.screenHorizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => AppSpacing.hGapMd,
            itemBuilder: (context, index) => ListingCard(
              listing: items[index],
              variant: ListingCardVariant.rail,
              onTap: () => context.push(Routes.listingPath(items[index].id)),
            ),
          ),
        ),
      ],
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

    return Center(
      child: Padding(
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
      ),
    );
  }
}
