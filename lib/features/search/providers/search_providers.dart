import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';
import 'package:tebiyu/core/repositories/listing_repository_provider.dart';
import 'package:tebiyu/core/services/preferences_service.dart';

/// Search terms the user has run before, most recent first.
final AsyncNotifierProvider<RecentSearchesNotifier, List<String>>
    recentSearchesProvider =
    AsyncNotifierProvider<RecentSearchesNotifier, List<String>>(
  RecentSearchesNotifier.new,
);

/// Holds and persists the search history.
class RecentSearchesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() => PreferencesService.recentSearches();

  /// Records [term] and moves it to the top.
  Future<void> add(String term) async {
    state = AsyncData(await PreferencesService.addRecentSearch(term));
  }

  /// Removes one term.
  Future<void> remove(String term) async {
    state = AsyncData(await PreferencesService.removeRecentSearch(term));
  }

  /// Empties the history.
  Future<void> clear() async {
    await PreferencesService.clearRecentSearches();
    state = const AsyncData(<String>[]);
  }
}

/// Popular searches shown before the user types anything.
///
/// A fixed list, not real data. Genuine trending terms need query logging
/// and aggregation that nobody is collecting yet, and an empty section
/// helps nobody. These are drawn from the taxonomy's busiest corners and
/// should be replaced once there is traffic to measure.
const List<String> trendingSearches = <String>[
  'Toyota',
  'iPhone',
  'House for rent',
  'Land in Juba',
  'Generator',
  'Motorcycle',
  'Laptop',
  'Solar panel',
];

/// The text currently in the search field.
final NotifierProvider<SearchQueryNotifier, String> searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Holds the live search text.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  /// The current text.
  String get text => state;

  /// Replaces the current text.
  set text(String value) => state = value;
}

/// Listings matching the live search text.
///
/// Debounced, because this fires on every keystroke. Without the delay a
/// six letter word is six queries, five of which are thrown away before
/// they return, and on a metered connection the user pays for all of them.
final FutureProvider<List<Listing>> searchSuggestionsProvider =
    FutureProvider<List<Listing>>((ref) async {
  final term = ref.watch(searchQueryProvider).trim();
  if (term.length < 2) return const <Listing>[];

  await Future<void>.delayed(const Duration(milliseconds: 300));

  // Riverpod cancels superseded futures, so a keystroke during the delay
  // discards this one before it reaches the repository.
  final page = await ref.watch(listingRepositoryProvider).fetchListings(
        ListingQuery(searchTerm: term, limit: 6),
      );
  return page.items;
});
