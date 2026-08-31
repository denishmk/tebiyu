import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/repositories/listing_repository_provider.dart';

/// A single listing by id.
///
/// Not `autoDispose`: a buyer comparing two items taps back and forth
/// between them, and refetching each time would spend data re-reading a
/// document that has not changed.
final FutureProviderFamily<Listing?, String> listingByIdProvider =
    FutureProvider.family<Listing?, String>((ref, id) {
  return ref.watch(listingRepositoryProvider).fetchById(id);
});

/// Listings similar to the one with this id.
final FutureProviderFamily<List<Listing>, String> similarListingsProvider =
    FutureProvider.family<List<Listing>, String>((ref, id) async {
  final listing = await ref.watch(listingByIdProvider(id).future);
  if (listing == null) return const <Listing>[];
  return ref.watch(listingRepositoryProvider).fetchSimilar(listing);
});

/// Records that a listing's detail screen was opened.
///
/// Fire and forget. A failed view count is not worth telling the user
/// about, and certainly not worth blocking the screen on.
final ProviderFamily<void Function(), String> recordListingViewProvider =
    Provider.family<void Function(), String>((ref, id) {
  return () => ref.read(listingRepositoryProvider).incrementViews(id);
});
