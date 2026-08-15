import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tebiyu/features/auth/data/auth_repository.dart';

/// The app wide [AuthRepository].
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

/// The current Firebase user, or null while browsing as a guest.
///
/// Watch this anywhere the UI should react to signing in or out. It is a
/// stream rather than a one off read so a session restored at startup, or a
/// token revoked remotely, propagates without a manual refresh.
final StreamProvider<User?> authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

/// Whether a user is signed in right now.
///
/// Reads as false while the auth state is still loading, which is correct for
/// gating: a route should stay closed until the session is confirmed rather
/// than flashing open and then redirecting.
final Provider<bool> isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});
