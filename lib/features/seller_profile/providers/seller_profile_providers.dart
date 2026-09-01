import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/models/tebiyu_user.dart';
import 'package:tebiyu/core/repositories/user_repository_provider.dart';

/// A seller's profile by id.
final FutureProviderFamily<TebiyuUser?, String> sellerProvider =
    FutureProvider.family<TebiyuUser?, String>((ref, id) {
  return ref.watch(userRepositoryProvider).fetchById(id);
});

/// Whether the signed in account follows this seller.
///
/// Optimistic: the button flips immediately and the write happens behind
/// it. A follow is cheap to undo and nobody should watch a spinner to
/// express interest in a seller.
final AsyncNotifierProviderFamily<FollowNotifier, bool, String>
    followProvider =
    AsyncNotifierProvider.family<FollowNotifier, bool, String>(
  FollowNotifier.new,
);

/// Holds and toggles follow state for one seller.
class FollowNotifier extends FamilyAsyncNotifier<bool, String> {
  @override
  Future<bool> build(String arg) {
    return ref.watch(userRepositoryProvider).isFollowing(arg);
  }

  /// Follows or unfollows the seller.
  Future<void> toggle() async {
    final current = state.valueOrNull ?? false;
    state = AsyncData(!current);
    try {
      await ref
          .read(userRepositoryProvider)
          .setFollowing(arg, following: !current);
    } on Object {
      // Put the button back where it was. Leaving it flipped would tell
      // the user they follow someone they do not.
      state = AsyncData(current);
    }
  }
}
