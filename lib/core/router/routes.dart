/// Every route path in Tebiyu, in one place.
///
/// Paths are referenced through these constants rather than as string
/// literals so a rename breaks at compile time instead of producing a silent
/// navigation failure at runtime.
abstract final class Routes {
  /// Startup screen. Resolves where to send the user, then redirects.
  static const String splash = '/splash';

  /// Language choice and welcome. Shown once, on first launch.
  static const String onboarding = '/onboarding';

  /// Sign in and sign up.
  ///
  /// Reached only when a gated action is tapped. Carries the location the
  /// user was heading to as the `from` query parameter.
  static const String auth = '/auth';

  /// The listings feed. The default tab.
  static const String home = '/home';

  /// Category browsing.
  static const String categories = '/categories';

  /// Saved listings.
  ///
  /// Open to guests. Saves are held locally in Hive and merged into the
  /// account on sign up, which turns a guest's saved items into their reason
  /// to create one.
  static const String saved = '/saved';

  /// Conversations list. Gated.
  static const String messages = '/messages';

  /// New listing form. Gated.
  static const String sell = '/sell';

  /// The user's own profile. Gated.
  static const String profile = '/profile';

  /// Notifications centre. Gated.
  static const String notifications = '/notifications';

  /// The user's own listings. Gated. Reached from profile on mobile and from
  /// the sidebar on wide screens.
  static const String myListings = '/my-listings';

  /// Account settings. Gated.
  static const String settings = '/settings';

  /// Search results.
  static const String search = '/search';

  /// A single listing. Takes a listing id.
  static const String listing = '/listing/:id';

  /// A public seller profile. Takes a seller id.
  static const String seller = '/seller/:id';

  /// Builds a listing path for [id].
  static String listingPath(String id) => '/listing/$id';

  /// Builds a seller path for [id].
  static String sellerPath(String id) => '/seller/$id';

  /// Routes that require a signed in user.
  ///
  /// Browsing is deliberately open: forcing sign up before a visitor can see
  /// a single listing is the largest drop off point in a marketplace, so the
  /// gate sits at the point of action instead. Saved is absent from this list
  /// on purpose.
  static const Set<String> gated = {
    messages,
    sell,
    profile,
    notifications,
    myListings,
    settings,
  };

  /// Whether [location] needs a signed in user.
  static bool requiresAuth(String location) {
    return gated.any(
      (route) => location == route || location.startsWith('$route/'),
    );
  }

  /// City picker. Open to guests.
  static const String location = '/location';

  /// Area picker for a city. Takes a city name.
  static const String locationAreas = '/location/:city';

  /// Builds an area picker path for [city].
  static String locationAreasPath(String city) =>
      '/location/${Uri.encodeComponent(city)}';

    /// Filtered listing results.
  static const String results = '/results';

  /// Builds a results path for a category and optional subcategory.
  ///
  /// Values go in the query string rather than the path because they are
  /// filters, not identity: `/results?category=Vehicles&subcategory=Cars`
  /// stays a valid URL when either is absent, which a path segment would
  /// not. Both are percent-encoded, since category names contain spaces
  /// and ampersands.
  static String resultsFor({
    String? category,
    String? subcategory,
    String? search,
  }) {
        final params = <String, String>{
      'category': ?category,
      'subcategory': ?subcategory,
      'search': ?search,
    };
    return Uri(path: results, queryParameters: params).toString();
  }    
}
