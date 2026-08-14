import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over `shared_preferences` for values read at startup.
///
/// Kept as a plain static API for now. P5.2 wraps it in a Riverpod provider
/// once account settings need to react to changes; until then the splash and
/// onboarding are the only callers and neither needs reactivity.
abstract final class PreferencesService {
  static const String _onboardingComplete = 'onboarding_complete';
  static const String _languageCode = 'language_code';

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
}
