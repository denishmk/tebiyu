import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/repositories/firestore_user_repository.dart';
import 'package:tebiyu/core/repositories/user_repository.dart';

/// App-wide access to account data.
///
/// The single seam between the app and its user backend, mirroring
/// `listingRepositoryProvider`. Widget tests override this with a mock.
final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>((ref) => FirestoreUserRepository());
