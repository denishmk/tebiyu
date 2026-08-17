import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/repositories/listing_repository_provider.dart';

/// Listings for the "Recommended for you" rail.
///
/// Keyed by city so switching location in the picker fetches a new list
/// while the previous city's results stay cached behind it.
///
/// Deliberately not `autoDispose`: Home sits in a `StatefulShellRoute`
/// branch, so tab switches would otherwise refetch the whole feed every
/// time the user glances at Messages and comes back. Refresh is explicit,
/// through [refreshHomeFeed].
final FutureProviderFamily<List<Listing>, String?> recommendedListingsProvider =
    FutureProvider.family<List<Listing>, String?>((ref, city) {
      final repository = ref.watch(listingRepositoryProvider);
      return repository.fetchRecommended(city: city);
    });

/// Listings for the "Trending" grid.
///
/// Ranked by views within a recent window rather than by recency, so a
/// quiet day does not empty the grid.
final FutureProviderFamily<List<Listing>, String?> trendingListingsProvider =
    FutureProvider.family<List<Listing>, String?>((ref, city) {
      final repository = ref.watch(listingRepositoryProvider);
      return repository.fetchTrending(city: city);
    });

/// Reloads both Home feeds for [city].
///
/// Wire this to pull-to-refresh. Returns once both requests settle so the
/// refresh indicator does not vanish before the new data lands.
Future<void> refreshHomeFeed(Ref ref, String? city) async {
  ref
    ..invalidate(recommendedListingsProvider(city))
    ..invalidate(trendingListingsProvider(city));
  await Future.wait<void>(<Future<void>>[
    ref.read(recommendedListingsProvider(city).future),
    ref.read(trendingListingsProvider(city).future),
  ]);
}
