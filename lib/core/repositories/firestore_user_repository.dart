import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tebiyu/core/models/tebiyu_user.dart';
import 'package:tebiyu/core/repositories/user_repository.dart';

/// Firestore backed [UserRepository].
class FirestoreUserRepository implements UserRepository {
  /// Creates the repository.
  FirestoreUserRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Collection holding every account.
  static const String collection = 'users';

  /// Subcollection under a user holding who follows them.
  static const String followers = 'followers';

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(collection);

  @override
  Future<TebiyuUser?> fetchById(String id) async {
    try {
      final doc = await _users.doc(id).get();
      return doc.exists ? _toUser(doc) : null;
    } on FirebaseException catch (error) {
      throw UserFailure(_messageFor(error), cause: error);
    }
  }

  @override
  Stream<TebiyuUser?> watchById(String id) {
    return _users.doc(id).snapshots().map(
          (doc) => doc.exists ? _toUser(doc) : null,
        );
  }

  @override
  Future<bool> isFollowing(String userId) async {
    final uid = _auth.currentUser?.uid;
    // A guest follows nobody. Answering false rather than throwing keeps
    // the profile usable while browsing signed out, which is the point of
    // deferred auth.
    if (uid == null) return false;

    try {
      final doc =
          await _users.doc(userId).collection(followers).doc(uid).get();
      return doc.exists;
    } on FirebaseException catch (error) {
      throw UserFailure(_messageFor(error), cause: error);
    }
  }

  @override
  Future<void> setFollowing(String userId, {required bool following}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const UserFailure('Sign in to follow sellers.');
    }
    if (uid == userId) {
      throw const UserFailure('You cannot follow your own account.');
    }

    // Writes only the membership document. The follower count on the user
    // is maintained by a Cloud Function watching this subcollection: the
    // rules block clients from touching it, and a client that could write
    // its own count could write any number.
    final doc = _users.doc(userId).collection(followers).doc(uid);

    try {
      if (following) {
        await doc.set(<String, Object?>{
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        await doc.delete();
      }
    } on FirebaseException catch (error) {
      throw UserFailure(_messageFor(error), cause: error);
    }
  }

  static TebiyuUser _toUser(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.of(doc.data() ?? <String, dynamic>{});
    final memberSince = data['member_since'];
    if (memberSince is Timestamp) {
      data['member_since'] = memberSince.toDate();
    }
    return TebiyuUser.fromMap(doc.id, data);
  }

  static String _messageFor(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => 'You do not have access to this profile.',
      'unavailable' => 'No connection. Check your network and try again.',
      _ => 'Could not load this profile. Please try again.',
    };
  }
}
