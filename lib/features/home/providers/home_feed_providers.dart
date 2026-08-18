import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';
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
final FutureProviderFamily<FeedResult, String?> recommendedListingsProvider =
    FutureProvider.family<FeedResult, String?>((ref, city) {
      final repository = ref.watch(listingRepositoryProvider);
      return repository.fetchRecommended(city: city);
    });

/// Listings for the "Trending" grid.
///
/// Ranked by views within a recent window rather than by recency, so a
/// quiet day does not empty the grid.
final FutureProviderFamily<FeedResult, String?> trendingListingsProvider =
    FutureProvider.family<FeedResult, String?>((ref, city) {
      final repository = ref.watch(listingRepositoryProvider);
      return repository.fetchTrending(city: city);
    });

/// Reloads both Home feeds for [city], bypassing the cache window.
///
/// Wire this to pull-to-refresh. Returns once both requests settle so the
/// refresh indicator does not vanish before the new data lands.
///
/// Takes a [WidgetRef] rather than a [Ref] because it is called from the
/// Home screen, and Riverpod keeps those two types separate.
Future<void> refreshHomeFeed(WidgetRef ref, String? city) async {
  final repository = ref.read(listingRepositoryProvider);

  // Force past the freshness window first, so a deliberate pull always
  // reaches the network. The provider invalidation below then reads the
  // cache this just refilled.
  await Future.wait<void>(<Future<void>>[
    repository.fetchRecommended(city: city, forceRefresh: true),
    repository.fetchTrending(city: city, forceRefresh: true),
  ]);

  ref
    ..invalidate(recommendedListingsProvider(city))
    ..invalidate(trendingListingsProvider(city));

  await Future.wait<void>(<Future<void>>[
    ref.read(recommendedListingsProvider(city).future),
    ref.read(trendingListingsProvider(city).future),
  ]);
}
