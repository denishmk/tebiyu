/// Asset paths for Tebiyu.
///
/// Referencing files through these constants means a renamed asset breaks in
/// one place rather than at runtime wherever the string was duplicated.
abstract final class AppAssets {
  /// The Tebiyu wordmark. White, used only on the splash screen.
  static const String logo = 'assets/images/logo/tebiyu_logo.png';

  /// Google's brand mark, shown on the sign in button.
  static const String googleIcon = 'assets/icons/google_icon.png';
}
