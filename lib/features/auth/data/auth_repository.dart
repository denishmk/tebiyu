import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A sign in failure with a message fit to show a user.
///
/// Firebase reports failures as codes such as `wrong-password`. Translating
/// those into sentences in one place keeps the wording consistent and stops
/// every screen inventing its own phrasing.
class AuthFailure implements Exception {
  /// Creates a failure.
  const AuthFailure(this.message, {this.code});

  /// Human readable explanation.
  final String message;

  /// The originating Firebase code, useful in logs.
  final String? code;

  @override
  String toString() => 'AuthFailure($code): $message';
}

/// Wraps Firebase Auth.
///
/// Deliberately free of Flutter imports so it can be unit tested without a
/// widget binding. Screens reach it through the Riverpod providers rather
/// than constructing it directly.
class AuthRepository {
  /// Creates a repository, optionally with injected dependencies for tests.
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  bool _googleReady = false;

  /// Emits on sign in, sign out and token refresh.
  ///
  /// The router listens to this, so a redirect re-runs the moment auth state
  /// changes rather than waiting for the next navigation.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The signed in user, or null while browsing as a guest.
  User? get currentUser => _auth.currentUser;

  /// Whether anyone is signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Signs in with Google.
  ///
  /// `google_sign_in` 7.x requires a one time [GoogleSignIn.initialize] call
  /// before any authentication attempt, so that is done lazily here rather
  /// than adding another await to app startup.
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (!_googleReady) {
        await GoogleSignIn.instance.initialize();
        _googleReady = true;
      }

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw const AuthFailure(
          'Google sign in is not available on this platform.',
        );
      }

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        throw const AuthFailure(
          'Google did not return a valid token. Please try again.',
        );
      }

      return await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('Sign in cancelled.', code: 'canceled');
      }
      throw AuthFailure(
        'Could not sign in with Google. Please try again.',
        code: error.code.name,
      );
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  /// Signs in with an email address and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  /// Creates an account with an email address and password.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }
      return credential;
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  /// Sends a password reset email.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  /// Starts phone verification and delivers an SMS code.
  ///
  /// [onCodeSent] receives the verification id needed by [signInWithSmsCode].
  /// [onAutoVerified] fires on Android when the platform reads the SMS itself,
  /// in which case no code entry screen is needed at all.
  ///
  /// The generous [timeout] is deliberate. SMS delivery to +211 numbers can be
  /// slow, and a short window would strand users on the code screen with an
  /// expired session.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(AuthFailure failure) onFailed,
    void Function(UserCredential credential)? onAutoVerified,
    int? resendToken,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      forceResendingToken: resendToken,
      verificationCompleted: (credential) async {
        if (onAutoVerified == null) return;
        try {
          onAutoVerified(await _auth.signInWithCredential(credential));
        } on FirebaseAuthException catch (error) {
          onFailed(_mapFirebaseError(error));
        }
      },
      verificationFailed: (error) => onFailed(_mapFirebaseError(error)),
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Completes phone sign in with the code the user typed.
  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      return await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode.trim(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  /// Signs the user out of Firebase and Google.
  Future<void> signOut() async {
    if (_googleReady) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  AuthFailure _mapFirebaseError(FirebaseAuthException error) {
    final message = switch (error.code) {
      'invalid-email' => 'That email address does not look right.',
      'user-disabled' => 'This account has been disabled. Contact support.',
      'user-not-found' => 'No account found with that email.',
      'wrong-password' ||
      'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' =>
        'An account already exists with that email. Try signing in.',
      'weak-password' => 'Choose a password of at least 6 characters.',
      'operation-not-allowed' =>
        'That sign in method is not enabled yet. Try another option.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'No connection. Check your network and try again.',
      'invalid-phone-number' =>
        'That phone number does not look right. Include the country code.',
      'invalid-verification-code' =>
        'That code is not correct. Check it and try again.',
      'session-expired' => 'The code expired. Request a new one.',
      'quota-exceeded' => 'Too many codes requested. Please try again later.',
      'account-exists-with-different-credential' =>
        'An account with this email already uses a different sign in method.',
      _ => 'Something went wrong. Please try again.',
    };
    return AuthFailure(message, code: error.code);
  }
}
