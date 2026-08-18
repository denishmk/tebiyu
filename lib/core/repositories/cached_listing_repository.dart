import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';
import 'package:tebiyu/core/services/listing_cache_service.dart';

/// Wraps a [ListingRepository] with a read-through disk cache.
///
/// The screens above this never learn caching exists. Swapping the mock
/// for Firestore leaves this class untouched, and any future feature that
/// reads Home feeds inherits offline behaviour without asking for it.
///
/// Only the two Home feeds are cached. Filtered results from
/// [fetchListings] pass straight through — caching those means keying on
/// the whole query, which is P2.3 work once the filter chips exist.
class CachedListingRepository implements ListingRepository {
  /// Wraps [inner] with caching.
  const CachedListingRepository(this.inner);

  /// How long a cached feed is reused before going back to the network.
  ///
  /// Ten minutes is short enough that prices stay believable and long
  /// enough that flicking between tabs does not spend the user's data.
  static const Duration refetchAfter = Duration(minutes: 10);

  /// Oldest cache the app will display.
  ///
  /// Past this, availability and pricing are unreliable enough that an
  /// empty state with a retry is more honest than a feed of sold items.
  /// This is a judgement call, not a standard — lower it once real traffic
  /// shows how fast sellers actually mark things sold.
  static const Duration maxCacheAge = Duration(days: 7);

  static const String _recommendedFeed = 'recommended';
  static const String _trendingFeed = 'trending';

  /// The repository doing the real work.
  final ListingRepository inner;

  @override
  Future<FeedResult> fetchRecommended({
    String? city,
    int limit = 10,
    bool forceRefresh = false,
  }) {
    return _cached(
      feed: _recommendedFeed,
      city: city,
      forceRefresh: forceRefresh,
      fetch: () => inner.fetchRecommended(city: city, limit: limit),
    );
  }

  @override
  Future<FeedResult> fetchTrending({
    String? city,
    int limit = 12,
    bool forceRefresh = false,
  }) {
    return _cached(
      feed: _trendingFeed,
      city: city,
      forceRefresh: forceRefresh,
      fetch: () => inner.fetchTrending(city: city, limit: limit),
    );
  }

  @override
  Future<ListingPage> fetchListings(ListingQuery query) =>
      inner.fetchListings(query);

  @override
  Future<Listing?> fetchById(String id) => inner.fetchById(id);

  @override
  Stream<Listing?> watchById(String id) => inner.watchById(id);

  @override
  Future<void> incrementViews(String id) => inner.incrementViews(id);

  Future<FeedResult> _cached({
    required String feed,
    required String? city,
    required bool forceRefresh,
    required Future<FeedResult> Function() fetch,
  }) async {
    final key = ListingCacheService.feedKey(feed, city);
    final cached = ListingCacheService.readFeed(key);

    final canReuse =
        cached != null &&
        !forceRefresh &&
        !cached.isStale(refetchAfter) &&
        cached.listings.isNotEmpty;

    if (canReuse) {
      return FeedResult(
        listings: cached.listings,
        source: FeedSource.cache,
        cachedAt: cached.savedAt,
      );
    }

    try {
      final result = await fetch();
      await ListingCacheService.saveFeed(key, result.listings);
      return result;
    } on Object {
      // Network is unreachable or the backend failed. Anything cached and
      // inside the hard cap beats an empty screen, however old it is.
      if (cached != null &&
          cached.listings.isNotEmpty &&
          !cached.isStale(maxCacheAge)) {
        return FeedResult(
          listings: cached.listings,
          source: FeedSource.cache,
          cachedAt: cached.savedAt,
        );
      }
      rethrow;
    }
  }
}
