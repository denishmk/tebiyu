import 'package:flutter/material.dart';

import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_shadows.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/main.dart';

/// A scratch screen that renders every Tebiyu design token.
///
/// Not part of the shipping app. It exists so the palette, type scale,
/// spacing, radii and surface helpers can be checked side by side in both
/// brightness modes before screens are built on top of them. Delete it once
/// the real home screen lands in P2.1.
class ThemePreviewScreen extends StatelessWidget {
  /// Creates the preview screen.
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design tokens'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to light' : 'Switch to dark',
            onPressed: () {
              themeModeNotifier.value = isDark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          AppSpacing.hGapSm,
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl * 2,
        ),
        children: [
          _section(context, 'Surfaces'),
          _swatchGrid(context, [
            _Swatch('app background', context.colors.appBackground),
            _Swatch('primary background', context.colors.primaryBackground),
            _Swatch('elevated background', context.colors.elevatedBackground),
            _Swatch('secondary background', context.colors.secondaryBackground),
            _Swatch('border', context.colors.border),
            _Swatch('scrim', context.colors.scrim),
          ]),

          _section(context, 'Brand'),
          _swatchGrid(context, [
            _Swatch('brand', context.colors.brand),
            _Swatch('brand pressed', context.colors.brandPressed),
            _Swatch('brand disabled', context.colors.brandDisabled),
            _Swatch('primary icon', context.colors.primaryIcon),
            _Swatch('secondary icon', context.colors.secondaryIcon),
            _Swatch('on brand', context.colors.onBrand),
          ]),

          _section(context, 'Semantic'),
          _swatchGrid(context, [
            _Swatch('error', context.colors.error),
            _Swatch('error bg', context.colors.errorBackground),
            _Swatch('warning', context.colors.warning),
            _Swatch('warning bg', context.colors.warningBackground),
            _Swatch('success', context.colors.success),
            _Swatch('success bg', context.colors.successBackground),
            _Swatch('info', context.colors.info),
            _Swatch('info bg', context.colors.infoBackground),
          ]),

          _section(context, 'Type scale'),
          Container(
            width: double.infinity,
            decoration: context.cardSurface(),
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _type(context, 'h1 28', AppTextStyles.h1),
                _type(context, 'h2 22', AppTextStyles.h2),
                _type(context, 'h3 18', AppTextStyles.h3),
                _type(context, 'h4 16', AppTextStyles.h4),
                _type(context, 'body 15', AppTextStyles.body),
                _type(context, 'bodySmall 13', AppTextStyles.bodySmall),
                _type(
                  context,
                  'caption 11',
                  AppTextStyles.caption,
                  muted: true,
                ),
                _type(context, 'label 11', AppTextStyles.label, muted: true),
                _type(context, 'button 15', AppTextStyles.button),
                const Divider(height: AppSpacing.xl),
                Text(
                  'SSP 1,250,000',
                  style: AppTextStyles.price.copyWith(
                    color: context.colors.brand,
                  ),
                ),
                AppSpacing.gapXs,
                Text(
                  'SSP 89,500',
                  style: AppTextStyles.priceSmall.copyWith(
                    color: context.colors.brand,
                  ),
                ),
              ],
            ),
          ),

          _section(context, 'Surface helpers'),
          Container(
            decoration: context.cardSurface(),
            padding: AppSpacing.card,
            child: Text(
              'cardSurface — shadow in light, border in dark',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.secondaryText,
              ),
            ),
          ),
          AppSpacing.gapMd,
          Container(
            decoration: context.elevatedSurface(),
            padding: AppSpacing.card,
            child: Text(
              'elevatedSurface — modals, menus, dropdowns',
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colors.secondaryText,
              ),
            ),
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: context.imageSurface(),
                child: Icon(
                  Icons.image_outlined,
                  color: context.colors.secondaryIcon,
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Text(
                  'imageSurface — always bordered, so white product photos '
                  'do not punch through a dark card',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.colors.secondaryText,
                  ),
                ),
              ),
            ],
          ),

          _section(context, 'Buttons'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Primary')),
              OutlinedButton(onPressed: () {}, child: const Text('Secondary')),
              TextButton(onPressed: () {}, child: const Text('Ghost')),
              const ElevatedButton(onPressed: null, child: Text('Disabled')),
            ],
          ),

          _section(context, 'Chips'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _tag(context, 'New', context.colors.warning),
              _tag(context, 'Used', context.colors.warning),
              _tag(context, 'Verified seller', context.colors.info),
              _tag(context, 'Sold', context.colors.success),
              _tag(context, 'Reported', context.colors.error),
              const Chip(label: Text('Negotiable')),
            ],
          ),

          _section(context, 'Inputs'),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search for anything...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          AppSpacing.gapMd,
          const TextField(
            decoration: InputDecoration(
              labelText: 'Price',
              prefixText: 'SSP ',
              errorText: 'Enter a price',
            ),
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              Switch(value: true, onChanged: (_) {}),
              AppSpacing.hGapSm,
              Text(
                'Negotiable',
                style: AppTextStyles.body.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
            ],
          ),

          _section(context, 'Spacing'),
          Container(
            decoration: context.cardSurface(),
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(context, 'xxs 2', AppSpacing.xxs),
                _bar(context, 'xs 4', AppSpacing.xs),
                _bar(context, 'sm 8', AppSpacing.sm),
                _bar(context, 'md 12', AppSpacing.md),
                _bar(context, 'lg 16', AppSpacing.lg),
                _bar(context, 'xl 24', AppSpacing.xl),
                _bar(context, 'xxl 32', AppSpacing.xxl),
                _bar(context, 'xxxl 48', AppSpacing.xxxl),
              ],
            ),
          ),

          _section(context, 'Radius'),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _radius(context, 'xs 4', AppRadius.allXs),
              _radius(context, 'sm 8', AppRadius.allSm),
              _radius(context, 'md 12', AppRadius.allMd),
              _radius(context, 'lg 16', AppRadius.allLg),
              _radius(context, 'xl 24', AppRadius.allXl),
              _radius(context, 'pill', AppRadius.allPill),
            ],
          ),

          _section(context, 'Listing card'),
          _listingCard(context),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        bottom: AppSpacing.md,
      ),
      child: Text(
        title,
        style: AppTextStyles.h3.copyWith(color: context.colors.primaryText),
      ),
    );
  }

  Widget _swatchGrid(BuildContext context, List<_Swatch> swatches) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: swatches.map((s) {
        return SizedBox(
          width: 104,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: AppRadius.allSm,
                  border: Border.all(color: context.colors.border, width: 0.5),
                ),
              ),
              AppSpacing.gapXs,
              Text(
                s.label,
                style: AppTextStyles.caption.copyWith(
                  color: context.colors.secondaryText,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _type(
    BuildContext context,
    String label,
    TextStyle style, {
    bool muted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.colors.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Buy. Sell. Everything.',
              style: style.copyWith(
                color: muted
                    ? context.colors.secondaryText
                    : context.colors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String label, Color color) {
    return Container(
      padding: AppSpacing.chip,
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.allXs),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: context.colors.onBrand),
      ),
    );
  }

  Widget _bar(BuildContext context, String label, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.colors.secondaryText,
              ),
            ),
          ),
          Container(
            width: size,
            height: 16,
            decoration: BoxDecoration(
              color: context.colors.brand,
              borderRadius: AppRadius.allXs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _radius(BuildContext context, String label, BorderRadius radius) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: context.colors.secondaryBackground,
            borderRadius: radius,
            border: Border.all(color: context.colors.brand, width: 0.5),
          ),
        ),
        AppSpacing.gapXs,
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: context.colors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _listingCard(BuildContext context) {
    return Container(
      decoration: context.cardSurface(),
      padding: AppSpacing.cardCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: context.imageSurface(radius: AppRadius.allMd),
                child: Icon(
                  Icons.photo_outlined,
                  color: context.colors.secondaryIcon,
                  size: 32,
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _tag(context, 'Used', context.colors.warning),
              ),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: context.colors.primaryBackground,
                  child: Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: context.colors.secondaryIcon,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Text(
            'Toyota Land Cruiser V8 2015',
            style: AppTextStyles.h4.copyWith(color: context.colors.primaryText),
          ),
          AppSpacing.gapXs,
          Text(
            'SSP 42,500,000',
            style: AppTextStyles.price.copyWith(color: context.colors.brand),
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: context.colors.secondaryIcon,
              ),
              AppSpacing.hGapXs,
              Text(
                'Juba, Hai Malakal',
                style: AppTextStyles.caption.copyWith(
                  color: context.colors.secondaryText,
                ),
              ),
              const Spacer(),
              Text(
                '2 hours ago',
                style: AppTextStyles.caption.copyWith(
                  color: context.colors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch {
  const _Swatch(this.label, this.color);

  final String label;
  final Color color;
}
