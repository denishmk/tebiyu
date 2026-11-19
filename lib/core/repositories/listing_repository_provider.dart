import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/repositories/cached_listing_repository.dart';
import 'package:tebiyu/core/repositories/firestore_listing_repository.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';

/// Provides the active [ListingRepository] implementation.
///
/// This is the single seam between the app and its listing backend. The
/// mock lived here through Phase 2; widget tests override this provider
/// with a zero-latency mock so they never touch the network, and a future
/// staging backend would swap in the same way.
final Provider<ListingRepository> listingRepositoryProvider =
    Provider<ListingRepository>((ref) {
  final repository = FirestoreListingRepository();
  return CachedListingRepository(repository);
});
