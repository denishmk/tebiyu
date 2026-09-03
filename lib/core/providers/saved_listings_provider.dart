import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/services/preferences_service.dart';

/// Ids of listings the user has saved, most recently saved first.
///
/// Order is meaningful: the Saved screen shows newest first, and a set
/// would lose that. Membership checks go through
/// [isListingSavedProvider], which is what the cards watch.
final AsyncNotifierProvider<SavedListingsNotifier, List<String>>
    savedListingsProvider =
    AsyncNotifierProvider<SavedListingsNotifier, List<String>>(
  SavedListingsNotifier.new,
);

/// Holds and persists saved listing ids.
class SavedListingsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() => PreferencesService.savedListings();

  /// Adds or removes [id].
  ///
  /// Optimistic: the heart fills before the write completes. A save is
  /// trivial to undo and nobody should watch a card wait on a disk write.
  Future<void> toggle(String id) async {
    final current = state.valueOrNull ?? const <String>[];
    final next = current.contains(id)
        ? current.where((value) => value != id).toList()
        : <String>[id, ...current];

    state = AsyncData(next);

    try {
      await PreferencesService.setSavedListings(next);
    } on Object {
      // Put it back. A heart that stays filled after a failed write tells
      // the user something is saved when it is not.
      state = AsyncData(current);
    }
  }

  /// Removes every saved listing.
  Future<void> clear() async {
    final current = state.valueOrNull ?? const <String>[];
    state = const AsyncData(<String>[]);
    try {
      await PreferencesService.setSavedListings(const <String>[]);
    } on Object {
      state = AsyncData(current);
    }
  }
}

/// Whether one listing is saved.
///
/// Watched per card, so toggling a heart rebuilds that card rather than
/// every card in the grid.
final ProviderFamily<bool, String> isListingSavedProvider =
    Provider.family<bool, String>((ref, id) {
  final saved = ref.watch(savedListingsProvider).valueOrNull;
  return saved?.contains(id) ?? false;
});
