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
}
