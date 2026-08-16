import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tebiyu/core/router/go_router_refresh_stream.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/features/auth/data/auth_providers.dart';
import 'package:tebiyu/features/auth/screens/auth_screen.dart';
import 'package:tebiyu/features/onboarding/screens/onboarding_screen.dart';
import 'package:tebiyu/features/shell/screens/app_shell.dart';
import 'package:tebiyu/features/shell/screens/placeholder_screen.dart';
import 'package:tebiyu/features/splash/screens/splash_screen.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Tebiyu's router.
///
/// Exposed as a provider so the redirect can consult Firebase auth state, but
/// note what is watched and what is not. The repository is watched, since it
/// never changes. The auth *state* is deliberately not watched here: doing so
/// would rebuild the entire [GoRouter] on every sign in and discard the
/// navigation stack. Instead the stream drives `refreshListenable`, which
/// re-runs the redirect while leaving the router intact.
///
/// Whether onboarding has run is an asynchronous read and a redirect must be
/// synchronous, so the splash resolves that question itself.
final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: GoRouterRefreshStream(repository.authStateChanges),
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (!Routes.requiresAuth(location)) return null;
      if (repository.isSignedIn) return null;

      // Carry the intended destination so signing in resumes it. Dropping the
      // user on the home feed after they authenticate loses their place and
      // is the most common way this pattern is got wrong.
      final from = Uri.encodeComponent(state.uri.toString());
      return '${Routes.auth}?from=$from';
    },
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
});

StatefulShellBranch _branch(String path, Widget child) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => child)],
  );
}
