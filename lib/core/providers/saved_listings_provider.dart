import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which listings the user has saved.
///
/// Guest users save into memory only; the merge into their account on
/// signup is a backlog item and will replace this build method with a read
/// from Hive plus a Firestore sync.
class SavedListingsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  /// Adds [id] if absent, removes it if present.
  void toggle(String id) {
    final next = Set<String>.of(state);
    if (!next.remove(id)) next.add(id);
    state = next;
  }

  /// Whether [id] is currently saved.
  bool contains(String id) => state.contains(id);
}

/// Ids of every listing the user has saved.
final savedListingsProvider =
    NotifierProvider<SavedListingsNotifier, Set<String>>(
      SavedListingsNotifier.new,
    );

/// Whether one specific listing is saved.
///
/// Watching this instead of [savedListingsProvider] keeps a heart tap from
/// rebuilding every other card in the feed.
final ProviderFamily<bool, String> isListingSavedProvider =
    Provider.family<bool, String>((ref, id) {
      return ref.watch(savedListingsProvider).contains(id);
    });
