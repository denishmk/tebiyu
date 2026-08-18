import 'package:flutter/foundation.dart';
import 'package:tebiyu/core/models/listing.dart';

/// Ordering applied to a listing query.
enum ListingSort {
  /// Newest first.
  latest,

  /// Cheapest first.
  priceLowToHigh,

  /// Most expensive first.
  priceHighToLow,

  /// Highest view count first.
  mostViewed,
}

/// Opaque pagination marker.
///
/// Carries the sort key plus the document id so ties break deterministically.
/// Firestore consumes both values through `startAfter`, and the mock
/// implementation compares against them directly, so the same cursor works
/// for either repository.
@immutable
class ListingCursor {
  /// Creates a cursor pointing just past a given listing.
  const ListingCursor({
    required this.id,
    required this.createdAt,
    this.price,
    this.views,
  });

  /// Builds the cursor that follows [listing] under [sort].
  factory ListingCursor.after(Listing listing, ListingSort sort) {
    return ListingCursor(
      id: listing.id,
      createdAt: listing.createdAt,
      price:
          sort == ListingSort.priceLowToHigh ||
              sort == ListingSort.priceHighToLow
          ? listing.price
          : null,
      views: sort == ListingSort.mostViewed ? listing.views : null,
    );
  }

  /// Id of the last listing on the previous page.
  final String id;

  /// Creation timestamp of the last listing on the previous page.
  final DateTime createdAt;

  /// Price of the last listing, set only for price sorts.
  final double? price;

  /// View count of the last listing, set only for view sorts.
  final int? views;

  @override
  bool operator ==(Object other) {
    return other is ListingCursor &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.price == price &&
        other.views == views;
  }

  @override
  int get hashCode => Object.hash(id, createdAt, price, views);
}

/// Filters and paging options for a listing feed.
@immutable
class ListingQuery {
  /// Creates a query.
  const ListingQuery({
    this.category,
    this.subcategory,
    this.city,
    this.area,
    this.conditions = const <ListingCondition>{},
    this.minPrice,
    this.maxPrice,
    this.currency,
    this.searchTerm,
    this.sellerId,
    this.negotiableOnly = false,
    this.promotedOnly = false,
    this.sort = ListingSort.latest,
    this.limit = 20,
    this.startAfter,
  });

  /// Restricts to one top level category.
  final String? category;

  /// Restricts to one subcategory.
  final String? subcategory;

  /// Restricts to one city.
  final String? city;

  /// Restricts to one area within [city].
  final String? area;

  /// Restricts to the given conditions. Empty means no restriction.
  final Set<ListingCondition> conditions;

  /// Lower price bound, inclusive.
  final double? minPrice;

  /// Upper price bound, inclusive.
  final double? maxPrice;

  /// Restricts to listings quoted in one currency.
  final ListingCurrency? currency;

  /// Free text matched against title and description.
  final String? searchTerm;

  /// Restricts to one seller, used by My Store and Seller Profile.
  final String? sellerId;

  /// Restricts to listings the seller marked negotiable.
  final bool negotiableOnly;

  /// Restricts to boosted listings.
  final bool promotedOnly;

  /// Ordering applied to the result set.
  final ListingSort sort;

  /// Page size.
  final int limit;

  /// Cursor returned by the previous page, null for the first page.
  final ListingCursor? startAfter;

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `resetCursor: true` when changing filters, otherwise a stale
  /// cursor from the previous filter set will be carried into the new query.
  ListingQuery copyWith({
    String? category,
    String? subcategory,
    String? city,
    String? area,
    Set<ListingCondition>? conditions,
    double? minPrice,
    double? maxPrice,
    ListingCurrency? currency,
    String? searchTerm,
    String? sellerId,
    bool? negotiableOnly,
    bool? promotedOnly,
    ListingSort? sort,
    int? limit,
    ListingCursor? startAfter,
    bool resetCursor = false,
  }) {
    return ListingQuery(
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      city: city ?? this.city,
      area: area ?? this.area,
      conditions: conditions ?? this.conditions,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      currency: currency ?? this.currency,
      searchTerm: searchTerm ?? this.searchTerm,
      sellerId: sellerId ?? this.sellerId,
      negotiableOnly: negotiableOnly ?? this.negotiableOnly,
      promotedOnly: promotedOnly ?? this.promotedOnly,
      sort: sort ?? this.sort,
      limit: limit ?? this.limit,
      startAfter: resetCursor ? null : startAfter ?? this.startAfter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ListingQuery &&
        other.category == category &&
        other.subcategory == subcategory &&
        other.city == city &&
        other.area == area &&
        setEquals(other.conditions, conditions) &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.currency == currency &&
        other.searchTerm == searchTerm &&
        other.sellerId == sellerId &&
        other.negotiableOnly == negotiableOnly &&
        other.promotedOnly == promotedOnly &&
        other.sort == sort &&
        other.limit == limit &&
        other.startAfter == startAfter;
  }

  @override
  int get hashCode {
    return Object.hash(
      category,
      subcategory,
      city,
      area,
      Object.hashAll(conditions),
      minPrice,
      maxPrice,
      currency,
      searchTerm,
      sellerId,
      negotiableOnly,
      promotedOnly,
      sort,
      limit,
      startAfter,
    );
  }
}

/// One page of listings plus the cursor needed to fetch the next.
@immutable
class ListingPage {
  /// Creates a page.
  const ListingPage({required this.items, this.nextCursor});

  /// An empty page with no further results.
  static const ListingPage empty = ListingPage(items: <Listing>[]);

  /// Listings in this page, already sorted.
  final List<Listing> items;

  /// Cursor for the following page, null when the feed is exhausted.
  final ListingCursor? nextCursor;

  /// Whether another page is available.
  bool get hasMore => nextCursor != null;

  @override
  bool operator ==(Object other) {
    return other is ListingPage &&
        listEquals(other.items, items) &&
        other.nextCursor == nextCursor;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(items), nextCursor);
}

/// Where a feed's contents came from.
enum FeedSource {
  /// Fetched from the backend during this call.
  network,

  /// Read from the disk cache, either because it was fresh enough to
  /// reuse or because the network was unreachable.
  cache,
}

/// A feed plus where it came from.
///
/// The Home screen needs the provenance, not just the listings: cached
/// prices and availability go out of date, so serving them silently as
/// current is how a buyer ends up calling a seller about an item that sold
/// two days ago.
@immutable
class FeedResult {
  /// Creates a feed result.
  const FeedResult({
    required this.listings,
    required this.source,
    this.cachedAt,
  });

  /// A result carrying freshly fetched listings.
  const FeedResult.network(this.listings)
    : source = FeedSource.network,
      cachedAt = null;

  /// The listings themselves.
  final List<Listing> listings;

  /// Whether these came from the network or from disk.
  final FeedSource source;

  /// When the cache entry was written, null for network results.
  final DateTime? cachedAt;

  /// Whether the UI should show an offline notice.
  bool get isStale => source == FeedSource.cache;

  @override
  bool operator ==(Object other) {
    return other is FeedResult &&
        listEquals(other.listings, listings) &&
        other.source == source &&
        other.cachedAt == cachedAt;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(listings), source, cachedAt);
}

/// Raised when a listing operation cannot be completed.
class ListingFailure implements Exception {
  /// Creates a failure with a user-facing [message].
  const ListingFailure(this.message, {this.cause});

  /// Message safe to surface in the UI.
  final String message;

  /// Underlying error, kept for logging.
  final Object? cause;

  @override
  String toString() => 'ListingFailure: $message';
}

/// Read and write access to marketplace listings.
///
/// Implemented twice: once in memory for development, once against
/// Firestore. The Home screen depends on this interface only, so swapping
/// backends is a provider override rather than a UI change.
abstract class ListingRepository {
  /// Fetches one page matching [query].
  Future<ListingPage> fetchListings(ListingQuery query);

  /// Fetches the personalised rail shown on Home.
  ///
  /// Ranked by promotion, then recency, biased toward [city] when given.
  /// Set [forceRefresh] to bypass any cache freshness window, which is what
  /// pull-to-refresh should do.
  Future<FeedResult> fetchRecommended({
    String? city,
    int limit = 10,
    bool forceRefresh = false,
  });

  /// Fetches the trending grid shown on Home.
  ///
  /// Ranked by view count within a recent window.
  Future<FeedResult> fetchTrending({
    String? city,
    int limit = 12,
    bool forceRefresh = false,
  });

  /// Fetches a single listing, or null when it no longer exists.
  Future<Listing?> fetchById(String id);

  /// Emits a listing and every subsequent change to it.
  Stream<Listing?> watchById(String id);

  /// Records a detail screen open.
  Future<void> incrementViews(String id);
}
