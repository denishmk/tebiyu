import 'package:flutter/foundation.dart';

/// Whether a user is currently signed in.
///
/// A deliberate stand in. P1.6 replaces the body of this class with Firebase
/// Auth while keeping the same surface, so the router's redirect logic does
/// not change when real authentication lands.
///
/// It extends [ChangeNotifier] because `go_router` takes a `refreshListenable`
/// and re-evaluates redirects whenever it fires. Without that, a user who
/// signs in would stay stuck on the auth screen until they navigated manually.
class AuthState extends ChangeNotifier {
  AuthState._();

  /// The single instance the router and screens read from.
  static final AuthState instance = AuthState._();

  bool _isSignedIn = false;

  /// Whether a user is signed in.
  bool get isSignedIn => _isSignedIn;

  /// Marks the user as signed in and notifies the router.
  void signIn() {
    if (_isSignedIn) return;
    _isSignedIn = true;
    notifyListeners();
  }

  /// Marks the user as signed out and notifies the router.
  void signOut() {
    if (!_isSignedIn) return;
    _isSignedIn = false;
    notifyListeners();
  }
}
