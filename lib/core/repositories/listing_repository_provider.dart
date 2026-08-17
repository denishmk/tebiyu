import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';
import 'package:tebiyu/core/repositories/mock_listing_repository.dart';

/// Provides the active [ListingRepository] implementation.
///
/// This is the single seam between the app and its listing backend. Moving
/// to Firestore means returning `FirestoreListingRepository()` here and
/// changing nothing else; widget tests override this provider with a
/// zero-latency mock.
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  final repository = MockListingRepository();
  ref.onDispose(repository.dispose);
  return repository;
});
