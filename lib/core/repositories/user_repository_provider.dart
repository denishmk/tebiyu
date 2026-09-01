import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/repositories/mock_user_repository.dart';
import 'package:tebiyu/core/repositories/user_repository.dart';

/// App-wide access to account data.
///
/// The single seam between the app and its user backend, mirroring
/// `listingRepositoryProvider`. Swapping in Firestore is one line here.
final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>((ref) => MockUserRepository());
