import 'package:tebiyu/core/models/tebiyu_user.dart';

/// Raised when a user operation cannot be completed.
class UserFailure implements Exception {
  /// Creates a failure with a user-facing [message].
  const UserFailure(this.message, {this.cause});

  /// Message safe to surface in the UI.
  final String message;

  /// Underlying error, kept for logging.
  final Object? cause;

  @override
  String toString() => 'UserFailure: $message';
}

/// Read access to Tebiyu accounts.
abstract class UserRepository {
  /// Fetches a user, or null when the account no longer exists.
  Future<TebiyuUser?> fetchById(String id);

  /// Emits a user and every subsequent change to them.
  Stream<TebiyuUser?> watchById(String id);

  /// Whether the signed in account follows [userId].
  Future<bool> isFollowing(String userId);

  /// Follows or unfollows [userId].
  ///
  /// Follows live in a subcollection rather than an array on the user
  /// document: an array would cap out at Firestore's one megabyte document
  /// limit, and every follow would rewrite the whole document.
  Future<void> setFollowing(String userId, {required bool following});
}
