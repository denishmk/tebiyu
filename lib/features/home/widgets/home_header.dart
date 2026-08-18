import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tebiyu/core/providers/currency_provider.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/features/location/data/location_providers.dart';

/// The Home screen's top chrome.
///
/// Brand row with the notification bell, the search entry point, and the
/// location and currency selectors.
class HomeHeader extends StatelessWidget {
  /// Creates the header.
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        end: AppSpacing.lg,
        top: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _BrandRow(),
          AppSpacing.gapMd,
          _SearchField(),
          AppSpacing.gapMd,
          _SelectorRow(),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Tebiyu',
                style: AppTextStyles.h1.copyWith(color: colors.brand),
              ),
              Text(
                'Find what you need',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        // Zero until P4.5 wires real notifications. Passed explicitly
        // rather than defaulted so the badge path stays live code.
        const _NotificationBell(unreadCount: 0),
      ],
    );
  }
}

/// The notification bell.
///
/// The badge count is not wired to anything yet: notifications arrive in
/// P4.5, and a hardcoded number here would be a lie the user could see.
/// The bell still navigates, so the route is exercised from day one.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IconButton(
      onPressed: () => context.push(Routes.notifications),
      tooltip: 'Notifications',
      icon: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Icon(Icons.notifications_outlined, color: colors.primaryText),
          if (unreadCount > 0)
            PositionedDirectional(
              top: -2,
              end: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: colors.error,
                  borderRadius: AppRadius.allPill,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: AppTextStyles.label.copyWith(
                    color: colors.primaryBackground,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The search entry point.
///
/// A tappable surface rather than a real [TextField]. The Search screen is
/// P2.6, and a live field here would raise the keyboard on a control that
/// cannot search yet, which reads as a broken app rather than an unbuilt
/// feature.
class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.primaryBackground,
      borderRadius: AppRadius.allXl,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.search, color: colors.secondaryIcon, size: 20),
              AppSpacing.hGapMd,
              Expanded(
                child: Text(
                  'Search for anything...',
                  style: AppTextStyles.body.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
              ),
              // Opens the filter sheet in P2.3. Shown now because its
              // absence would change the header's proportions later.
              Icon(Icons.tune, color: colors.secondaryIcon, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectorRow extends StatelessWidget {
  const _SelectorRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        _LocationChip(),
        AppSpacing.hGapSm,
        Flexible(child: _CurrencySelector()),
      ],
    );
  }
}

class _LocationChip extends ConsumerWidget {
  const _LocationChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final location = ref.watch(locationProvider);
    final label = location.area ?? location.city ?? 'All locations';

    return Material(
      color: colors.brand,
      borderRadius: AppRadius.allPill,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.location),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.location_on, size: 16, color: colors.onBrand),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.label.copyWith(color: colors.onBrand),
              ),
              Icon(Icons.arrow_drop_down, size: 18, color: colors.onBrand),
            ],
          ),
        ),
      ),
    );
  }
}

/// Switches the currency every price is shown in.
///
/// [CurrencyMode.all] is the default and shows each seller's own quoted
/// price. The other two convert, and converted prices are marked
/// approximate, so the selector changes what the numbers mean and not just
/// how they look.
class _CurrencySelector extends ConsumerWidget {
  const _CurrencySelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final mode = ref.watch(currencyModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.primaryBackground,
        borderRadius: AppRadius.allPill,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton<CurrencyMode>(
        initialValue: mode,
        onSelected: (value) =>
            ref.read(currencyModeProvider.notifier).mode = value,
        tooltip: 'Currency',
        position: PopupMenuPosition.under,
        itemBuilder: (context) => <PopupMenuEntry<CurrencyMode>>[
          for (final value in CurrencyMode.values)
            PopupMenuItem<CurrencyMode>(
              value: value,
              child: Text(value.label),
            ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Currency',
                style: AppTextStyles.label.copyWith(
                  color: colors.secondaryText,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                mode.label,
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
    );
  }
}
