import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tebiyu/core/theme/theme.dart';
import 'package:tebiyu/core/widgets/constrained_page.dart';

/// One navigable destination in the shell.
class ShellDestination {
  /// Creates a destination.
  const ShellDestination({
    required this.branch,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isPrimary = false,
  });

  /// Index of the matching branch in the router's shell route.
  final int branch;

  /// Icon shown when the destination is not selected.
  final IconData icon;

  /// Icon shown when the destination is selected.
  final IconData activeIcon;

  /// Text label.
  final String label;

  /// Whether this is the emphasised action, drawn as a filled tile.
  ///
  /// Only Sell sets this. Posting a listing is the action the marketplace
  /// earns from, so it is given visual weight the other tabs do not have.
  final bool isPrimary;
}

/// The navigation chrome wrapped around every tab.
///
/// Below [AppBreakpoints.wide] the destinations render as a five item bottom
/// bar. Above it they render as a rail with the full eight item set, matching
/// the tablet design. Both drive the same branches, so a tab keeps its stack
/// when the window is resized across the threshold.
class AppShell extends StatelessWidget {
  /// Creates the shell.
  const AppShell({required this.navigationShell, super.key});

  /// The branch container supplied by `StatefulShellRoute`.
  final StatefulNavigationShell navigationShell;

  /// Branch index for the home feed.
  static const int branchHome = 0;

  /// Branch index for category browsing.
  static const int branchCategories = 1;

  /// Branch index for saved listings.
  static const int branchSaved = 2;

  /// Branch index for conversations.
  static const int branchMessages = 3;

  /// Branch index for the new listing form.
  static const int branchSell = 4;

  /// Branch index for the user's own profile.
  static const int branchProfile = 5;

  /// Branch index for the notifications centre.
  static const int branchNotifications = 6;

  /// Branch index for the user's own listings.
  static const int branchMyListings = 7;

  /// Branch index for account settings.
  static const int branchSettings = 8;

  /// Destinations shown on a phone.
  ///
  /// Categories is absent because the home feed carries a category row, and
  /// Notifications is absent because it lives in the home app bar. That frees
  /// the centre slot for Sell.
  static const List<ShellDestination> mobileDestinations = [
    ShellDestination(
      branch: branchHome,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    ShellDestination(
      branch: branchMessages,
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Messages',
    ),
    ShellDestination(
      branch: branchSell,
      icon: Icons.add,
      activeIcon: Icons.add,
      label: 'Sell',
      isPrimary: true,
    ),
    ShellDestination(
      branch: branchSaved,
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: 'Saved',
    ),
    ShellDestination(
      branch: branchProfile,
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  /// Destinations shown on a tablet or desktop rail.
  static const List<ShellDestination> wideDestinations = [
    ShellDestination(
      branch: branchHome,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    ShellDestination(
      branch: branchCategories,
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
      label: 'Categories',
    ),
    ShellDestination(
      branch: branchSaved,
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: 'Saved',
    ),
    ShellDestination(
      branch: branchMessages,
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Messages',
    ),
    ShellDestination(
      branch: branchMyListings,
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: 'My Listings',
    ),
    ShellDestination(
      branch: branchNotifications,
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Notifications',
    ),
    ShellDestination(
      branch: branchProfile,
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
    ShellDestination(
      branch: branchSettings,
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  void _go(int branch) {
    navigationShell.goBranch(
      branch,
      // Tapping the already selected tab returns it to its root, which is the
      // behaviour people expect from a tab bar.
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.wide;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                _Rail(
                  destinations: wideDestinations,
                  currentBranch: navigationShell.currentIndex,
                  onSelect: _go,
                  isExtended: constraints.maxWidth >= 1100,
                ),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: _BottomBar(
            destinations: mobileDestinations,
            currentBranch: navigationShell.currentIndex,
            onSelect: _go,
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.destinations,
    required this.currentBranch,
    required this.onSelect,
  });

  final List<ShellDestination> destinations;
  final int currentBranch;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.primaryBackground,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (final destination in destinations)
                Expanded(
                  child: _BottomItem(
                    destination: destination,
                    isActive: destination.branch == currentBranch,
                    onTap: () => onSelect(destination.branch),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = isActive ? colors.brand : colors.secondaryIcon;

    return InkResponse(
      onTap: onTap,
      radius: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (destination.isPrimary)
            Container(
              width: 46,
              height: 28,
              decoration: BoxDecoration(
                color: colors.brand,
                borderRadius: AppRadius.allSm,
              ),
              child: Icon(destination.icon, size: 20, color: colors.onBrand),
            )
          else
            Icon(
              isActive ? destination.activeIcon : destination.icon,
              size: 24,
              color: tint,
            ),
          AppSpacing.gapXs,
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: destination.isPrimary ? colors.brand : tint,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.destinations,
    required this.currentBranch,
    required this.onSelect,
    required this.isExtended,
  });

  final List<ShellDestination> destinations;
  final int currentBranch;
  final ValueChanged<int> onSelect;
  final bool isExtended;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: isExtended ? 232 : 84,
      decoration: BoxDecoration(
        color: colors.primaryBackground,
        border: Border(
          right: BorderSide(color: colors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: isExtended
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Text(
                    isExtended ? 'Tebiyu' : 'T',
                    style: AppTextStyles.h2.copyWith(
                      color: colors.brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isExtended)
                    Text(
                      'Find what you need',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                children: [
                  for (final destination in destinations)
                    _RailItem(
                      destination: destination,
                      isActive: destination.branch == currentBranch,
                      isExtended: isExtended,
                      onTap: () => onSelect(destination.branch),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.isActive,
    required this.isExtended,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool isActive;
  final bool isExtended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = isActive ? colors.brand : colors.secondaryIcon;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: isActive ? colors.secondaryBackground : Colors.transparent,
        borderRadius: AppRadius.allMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.allMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: isExtended
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? destination.activeIcon : destination.icon,
                  size: 22,
                  color: tint,
                ),
                if (isExtended) ...[
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: isActive ? colors.brand : colors.primaryText,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
