import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/constants/listing_filters.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';
import 'package:tebiyu/core/repositories/listing_repository_provider.dart';

/// What a results screen is showing, before user filters are applied.
///
/// Comes from the route, so it is the one part of the query the user cannot
/// clear from within the screen.
@immutable
class ResultsScope {
  /// Creates a scope.
  const ResultsScope({this.category, this.subcategory, this.searchTerm});

  /// Top level category, if the screen was opened from one.
  final String? category;

  /// Subcategory, if the screen was opened from one.
  final String? subcategory;

  /// Free text, if the screen was opened from search.
  final String? searchTerm;

  /// Heading for the screen.
  String get title => subcategory ?? category ?? searchTerm ?? 'All listings';

  @override
  bool operator ==(Object other) =>
      other is ResultsScope &&
      other.category == category &&
      other.subcategory == subcategory &&
      other.searchTerm == searchTerm;

  @override
  int get hashCode => Object.hash(category, subcategory, searchTerm);
}

/// User-chosen filters on a results screen.
///
/// Separate from [ResultsScope] so "clear filters" has an obvious meaning:
/// it resets this and leaves the category alone.
@immutable
class ResultsFilters {
  /// Creates a filter set.
  const ResultsFilters({
    this.type,
    this.conditions = const <ListingCondition>{},
    this.minPrice,
    this.maxPrice,
    this.negotiableOnly = false,
    this.attributes = const <String, String>{},
    this.attributeRanges = const <String, ({num? min, num? max})>{},
    this.sort = ListingSort.latest,
  });

  /// Sale, hire, or null for both.
  final ListingType? type;

  /// Conditions to include. Empty means all.
  final Set<ListingCondition> conditions;

  /// Lower price bound in the listing's own currency.
  final double? minPrice;

  /// Upper price bound in the listing's own currency.
  final double? maxPrice;

  /// Restrict to listings the seller marked negotiable.
  final bool negotiableOnly;

  /// Exact attribute selections, keyed by attribute name.
  final Map<String, String> attributes;

  /// Numeric attribute bounds, keyed by attribute name.
  final Map<String, ({num? min, num? max})> attributeRanges;

  /// Result ordering.
  final ListingSort sort;

  /// How many filters are active, for the badge on the filter button.
  ///
  /// Sort is excluded: it is always set to something, so counting it would
  /// mean the badge never reads zero.
  int get activeCount {
    var count = 0;
    if (type != null) count++;
    if (conditions.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (negotiableOnly) count++;
    return count + attributes.length + attributeRanges.length;
  }

  /// Whether [definition] currently has a value.
  bool isActive(FilterDefinition definition) {
    return switch (definition.target) {
      FilterTarget.offerType => type != null,
      FilterTarget.price => minPrice != null || maxPrice != null,
      FilterTarget.condition => conditions.isNotEmpty,
      FilterTarget.negotiable => negotiableOnly,
      FilterTarget.attribute => attributes.containsKey(
            definition.attributeKey,
          ) ||
          attributeRanges.containsKey(definition.attributeKey),
    };
  }

  /// Returns a copy with the given fields replaced.
  ///
  /// Nullable fields take explicit clear flags, because passing null to
  /// `copyWith` cannot distinguish "leave alone" from "unset".
  ResultsFilters copyWith({
    ListingType? type,
    Set<ListingCondition>? conditions,
    double? minPrice,
    double? maxPrice,
    bool? negotiableOnly,
    Map<String, String>? attributes,
    Map<String, ({num? min, num? max})>? attributeRanges,
    ListingSort? sort,
    bool clearType = false,
    bool clearPrices = false,
  }) {
    return ResultsFilters(
      type: clearType ? null : type ?? this.type,
      conditions: conditions ?? this.conditions,
      minPrice: clearPrices ? null : minPrice ?? this.minPrice,
      maxPrice: clearPrices ? null : maxPrice ?? this.maxPrice,
      negotiableOnly: negotiableOnly ?? this.negotiableOnly,
      attributes: attributes ?? this.attributes,
      attributeRanges: attributeRanges ?? this.attributeRanges,
      sort: sort ?? this.sort,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ResultsFilters &&
      other.type == type &&
      setEquals(other.conditions, conditions) &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.negotiableOnly == negotiableOnly &&
      mapEquals(other.attributes, attributes) &&
      mapEquals(other.attributeRanges, attributeRanges) &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
        type,
        Object.hashAll(conditions),
        minPrice,
        maxPrice,
        negotiableOnly,
        Object.hashAll(attributes.entries.map((e) => '${e.key}=${e.value}')),
        Object.hashAll(attributeRanges.keys),
        sort,
      );
}

/// Filters for the results screen showing [ResultsScope].
///
/// `autoDispose`, so filters reset when the screen closes. Persisting them
/// would mean someone who capped price at $5,000 while browsing cars later
/// opens Motorcycles and silently sees a fraction of what exists, with no
/// visible cause. Invisible state is the wrong kind of convenience.
final AutoDisposeNotifierProviderFamily<ResultsFiltersNotifier, ResultsFilters,
    ResultsScope> resultsFiltersProvider = NotifierProvider.autoDispose
    .family<ResultsFiltersNotifier, ResultsFilters, ResultsScope>(
  ResultsFiltersNotifier.new,
);

/// Holds the filters for one results screen.
class ResultsFiltersNotifier
    extends AutoDisposeFamilyNotifier<ResultsFilters, ResultsScope> {
  @override
  ResultsFilters build(ResultsScope arg) => const ResultsFilters();

  /// The active filter set.
  ResultsFilters get filters => state;

  /// Replaces the whole filter set, as the filter sheet does on apply.
  set filters(ResultsFilters value) => state = value;

  /// Changes only the sort order.
  void sortBy(ListingSort sort) => state = state.copyWith(sort: sort);

  /// Sets the sale or hire filter, or clears it when [type] is null.
  void setType(ListingType? type) => state = type == null
      ? state.copyWith(clearType: true)
      : state.copyWith(type: type);

  /// Clears every filter, leaving the scope untouched.
  void clear() => state = ResultsFilters(sort: state.sort);
}

/// A page of results plus enough state to drive the load-more button.
@immutable
class ResultsFeed {
  /// Creates a results feed.
  const ResultsFeed({
    this.listings = const <Listing>[],
    this.cursor,
    this.totalCount,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  /// Listings loaded so far, across every page fetched.
  final List<Listing> listings;

  /// Cursor for the next page, null when exhausted.
  final ListingCursor? cursor;

  /// Total matching listings, null when unknown.
  final int? totalCount;

  /// Whether another page is in flight.
  final bool isLoadingMore;

  /// Whether the last load-more attempt failed.
  ///
  /// Kept separate from the provider's error state so a failed second page
  /// does not blank the results already on screen.
  final bool loadMoreFailed;

  /// Whether there is another page to fetch.
  bool get hasMore => cursor != null;

  /// Returns a copy with the given fields replaced.
  ResultsFeed copyWith({
    List<Listing>? listings,
    ListingCursor? cursor,
    int? totalCount,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    bool clearCursor = false,
  }) {
    return ResultsFeed(
      listings: listings ?? this.listings,
      cursor: clearCursor ? null : cursor ?? this.cursor,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

/// Paginated results for [ResultsScope], filtered and sorted.
///
/// Rebuilds from scratch whenever the filters change, which is why the
/// notifier watches them rather than reading them.
final AutoDisposeAsyncNotifierProviderFamily<ResultsNotifier, ResultsFeed,
    ResultsScope> resultsProvider = AsyncNotifierProvider.autoDispose
    .family<ResultsNotifier, ResultsFeed, ResultsScope>(ResultsNotifier.new);

/// Loads and paginates results.
class ResultsNotifier
    extends AutoDisposeFamilyAsyncNotifier<ResultsFeed, ResultsScope> {
  @override
  Future<ResultsFeed> build(ResultsScope arg) async {
    final page = await _fetch(ref.watch(resultsFiltersProvider(arg)));
    return ResultsFeed(
      listings: page.items,
      cursor: page.nextCursor,
      totalCount: page.totalCount,
    );
  }

  /// Fetches the next page and appends it.
  ///
  /// Explicit rather than triggered by scroll position. Infinite scroll
  /// spends the user's data without being asked, and on a metered
  /// connection that is a cost they should get to decline.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreFailed: false),
    );

    try {
      final filters = ref.read(resultsFiltersProvider(arg));
      final page = await _fetch(filters, startAfter: current.cursor);
      state = AsyncData(
        ResultsFeed(
          listings: <Listing>[...current.listings, ...page.items],
          cursor: page.nextCursor,
          totalCount: page.totalCount ?? current.totalCount,
        ),
      );
    } on Object {
      // Keep what is already on screen. Losing twenty loaded listings
      // because the twenty-first page failed would be a poor trade.
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }

  Future<ListingPage> _fetch(
    ResultsFilters filters, {
    ListingCursor? startAfter,
  }) {
    return ref.read(listingRepositoryProvider).fetchListings(
          ListingQuery(
            category: arg.category,
            subcategory: arg.subcategory,
            searchTerm: arg.searchTerm,
            type: filters.type,
            conditions: filters.conditions,
            minPrice: filters.minPrice,
            maxPrice: filters.maxPrice,
            negotiableOnly: filters.negotiableOnly,
            attributes: filters.attributes,
            attributeRanges: filters.attributeRanges,
            sort: filters.sort,
            startAfter: startAfter,
          ),
        );
  }
}
