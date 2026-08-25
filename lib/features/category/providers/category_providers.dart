import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/repositories/listing_repository_provider.dart';

/// Index of the category selected in the sidebar.
///
/// Held in a provider rather than widget state so the selection survives a
/// tab switch. Someone who picks Vehicles, checks a message and comes back
/// expects to still be looking at Vehicles.
final NotifierProvider<SelectedCategoryNotifier, int> selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, int>(
  SelectedCategoryNotifier.new,
);

/// Holds the selected category index.
class SelectedCategoryNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// The selected index.
  int get index => state;

  /// Selects the category at [value].
  set index(int value) => state = value;
}

/// Active listing counts keyed by subcategory name.
///
/// One read for the whole taxonomy. Not `autoDispose`, because these
/// numbers change slowly and refetching them on every visit to the tab
/// spends data for a figure that is a rough guide anyway.
final FutureProvider<Map<String, int>> subcategoryCountsProvider =
    FutureProvider<Map<String, int>>((ref) {
  return ref.watch(listingRepositoryProvider).fetchSubcategoryCounts();
});
