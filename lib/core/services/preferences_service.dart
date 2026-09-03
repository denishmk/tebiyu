import 'package:shared_preferences/shared_preferences.dart';

import 'package:tebiyu/features/location/models/selected_location.dart';

/// Thin wrapper over `shared_preferences` for values read at startup.
///
/// Kept as a plain static API. P5.2 wraps it in a Riverpod provider once
/// account settings need to react to changes; until then the callers are the
/// splash, onboarding and the location picker, none of which need reactivity
/// at this layer.
abstract final class PreferencesService {
  static const String _onboardingComplete = 'onboarding_complete';
  static const String _languageCode = 'language_code';
  static const String _locationCity = 'location_city';
  static const String _locationArea = 'location_area';
  static const String _recentSearches = 'recent_searches';
  static const String _savedListings = 'saved_listings';

  /// How many recent searches are kept.
  ///
  /// Eight fills a phone screen without scrolling. A longer history is not
  /// more useful: anything older than the last handful is faster to retype
  /// than to find.
  static const int recentSearchLimit = 8;

  /// Whether the user has finished onboarding.
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingComplete) ?? false;
  }

  /// Records that onboarding finished, along with the chosen [languageCode].
  static Future<void> completeOnboarding(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingComplete, true);
    await prefs.setString(_languageCode, languageCode);
  }

  /// The stored language code, defaulting to English.
  ///
  /// Currently recorded but not applied. Localisation is on the backlog, and
  /// this value is what it will read when it lands.
  static Future<String> languageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCode) ?? 'en';
  }

  /// The stored location filter.
  ///
  /// Defaults to everywhere, which is the right starting point for a guest
  /// who has not chosen yet: an empty feed because of an unset filter looks
  /// like a broken app.
  static Future<SelectedLocation> location() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString(_locationCity);
    if (city == null) return const SelectedLocation.everywhere();
    return SelectedLocation(city: city, area: prefs.getString(_locationArea));
  }

  /// Stores the location filter.
  static Future<void> setLocation(SelectedLocation location) async {
    final prefs = await SharedPreferences.getInstance();

    if (location.city == null) {
      await prefs.remove(_locationCity);
      await prefs.remove(_locationArea);
      return;
    }

    await prefs.setString(_locationCity, location.city!);
    if (location.area == null) {
      await prefs.remove(_locationArea);
    } else {
      await prefs.setString(_locationArea, location.area!);
    }
  }

  /// Ids of listings the user has saved, most recently saved first.
  ///
  /// Device local, not account bound. Saves should follow the account once
  /// there is a Firestore collection for them, otherwise signing in on a
  /// new phone loses everything. Two people sharing a device would also
  /// see each other's saves, which is worth fixing at the same time.
  static Future<List<String>> savedListings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedListings) ?? const <String>[];
  }

  /// Stores the saved listing ids.
  static Future<void> setSavedListings(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedListings, ids);
  }

  /// Recent search terms, most recent first.
  static Future<List<String>> recentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearches) ?? const <String>[];
  }

  /// Records [term] as the most recent search.
  ///
  /// Case-insensitively de-duplicated: someone who searches "Toyota" then
  /// "toyota" has searched for one thing, and showing both back to them
  /// wastes half the list.
  static Future<List<String>> addRecentSearch(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return recentSearches();

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_recentSearches) ?? <String>[];
    final lower = trimmed.toLowerCase();

    final next = <String>[
      trimmed,
      ...existing.where((value) => value.toLowerCase() != lower),
    ].take(recentSearchLimit).toList();

    await prefs.setStringList(_recentSearches, next);
    return next;
  }

  /// Removes one term from the history.
  static Future<List<String>> removeRecentSearch(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_recentSearches) ?? <String>[];
    final next = existing.where((value) => value != term).toList();
    await prefs.setStringList(_recentSearches, next);
    return next;
  }

  /// Empties the search history.
  static Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearches);
  }
}
