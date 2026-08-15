import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/services/auth_state.dart';
import 'package:tebiyu/features/auth/screens/auth_screen.dart';
import 'package:tebiyu/features/onboarding/screens/onboarding_screen.dart';
import 'package:tebiyu/features/shell/screens/app_shell.dart';
import 'package:tebiyu/features/shell/screens/placeholder_screen.dart';
import 'package:tebiyu/features/splash/screens/splash_screen.dart';

/// Tebiyu's router.
///
/// The redirect handles authentication only. Whether onboarding has run is an
/// asynchronous read, and a `go_router` redirect must be synchronous, so the
/// splash resolves that question itself and navigates when it has an answer.
///
/// Gated routes redirect to auth carrying the location the user was heading
/// to, so signing in resumes the original intent rather than dropping them on
/// the home feed. That detail is cheap here and expensive to retrofit, because
/// otherwise every gated entry point has to remember its own return path.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  /// The configured router instance.
  static final GoRouter instance = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: AuthState.instance,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.auth,
        builder: (context, state) =>
            AuthScreen(returnTo: state.uri.queryParameters['from']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          _branch(
            Routes.home,
            const PlaceholderScreen(
              title: 'Home',
              icon: Icons.home_outlined,
              phase: 'P2.1',
            ),
          ),
          _branch(
            Routes.categories,
            const PlaceholderScreen(
              title: 'Categories',
              icon: Icons.grid_view_outlined,
              phase: 'P2.2',
            ),
          ),
          _branch(
            Routes.saved,
            const PlaceholderScreen(
              title: 'Saved',
              icon: Icons.favorite_border,
              phase: 'P2.7',
            ),
          ),
          _branch(
            Routes.messages,
            const PlaceholderScreen(
              title: 'Messages',
              icon: Icons.chat_bubble_outline,
              phase: 'P4.1',
            ),
          ),
          _branch(
            Routes.sell,
            const PlaceholderScreen(
              title: 'Sell',
              icon: Icons.add_box_outlined,
              phase: 'P3.1',
            ),
          ),
          _branch(
            Routes.profile,
            const PlaceholderScreen(
              title: 'Profile',
              icon: Icons.person_outline,
              phase: 'P5.1',
            ),
          ),
          _branch(
            Routes.notifications,
            const PlaceholderScreen(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              phase: 'P4.5',
            ),
          ),
          _branch(
            Routes.myListings,
            const PlaceholderScreen(
              title: 'My Listings',
              icon: Icons.shopping_bag_outlined,
              phase: 'P3.4',
            ),
          ),
          _branch(
            Routes.settings,
            const PlaceholderScreen(
              title: 'Settings',
              icon: Icons.settings_outlined,
              phase: 'P5.2',
            ),
          ),
        ],
      ),
    ],
  );

  static StatefulShellBranch _branch(String path, Widget child) {
    return StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, state) => child)],
    );
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;

    if (!Routes.requiresAuth(location)) return null;
    if (AuthState.instance.isSignedIn) return null;

    final from = Uri.encodeComponent(state.uri.toString());
    return '${Routes.auth}?from=$from';
  }
}
