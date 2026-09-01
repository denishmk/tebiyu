import 'dart:async';

import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/models/tebiyu_user.dart';
import 'package:tebiyu/core/repositories/user_repository.dart';

/// In-memory [UserRepository] used until Firestore is wired.
///
/// Ids match the seller ids on the seeded listings, so tapping through from
/// a listing to its seller lands on a real profile rather than a blank one.
class MockUserRepository implements UserRepository {
  /// Creates the mock repository.
  MockUserRepository({
    List<TebiyuUser>? seed,
    this.latency = const Duration(milliseconds: 350),
  }) : _users = <String, TebiyuUser>{
          for (final user in seed ?? _seedUsers()) user.id: user,
        };

  /// Artificial delay applied to every call.
  final Duration latency;

  final Map<String, TebiyuUser> _users;

  /// Follows held in memory only, so they vanish on restart.
  ///
  /// Real follows need a Firestore subcollection and a Cloud Function to
  /// keep the counters straight. Until then this drives the button state
  /// without pretending anything was saved.
  final Set<String> _following = <String>{};

  @override
  Future<TebiyuUser?> fetchById(String id) async {
    await _wait();
    return _users[id];
  }

  @override
  Stream<TebiyuUser?> watchById(String id) =>
      Stream<TebiyuUser?>.fromFuture(fetchById(id));

  @override
  Future<bool> isFollowing(String userId) async {
    await _wait();
    return _following.contains(userId);
  }

  @override
  Future<void> setFollowing(String userId, {required bool following}) async {
    if (following) {
      _following.add(userId);
    } else {
      _following.remove(userId);
    }
  }

  Future<void> _wait() =>
      latency == Duration.zero ? Future<void>.value() : Future.delayed(latency);

  static String _avatar(int index) => 'https://i.pravatar.cc/300?img=$index';

  static List<TebiyuUser> _seedUsers() {
    return <TebiyuUser>[
      TebiyuUser(
        id: 'usr_101',
        name: 'Deng Motors',
        email: 'sales@dengmotors.ss',
        phone: '+211924312026',
        avatarUrl: _avatar(12),
        city: 'Juba',
        bio: 'Imported vehicles, inspected before sale.',
        verified: true,
        sellerType: SellerType.business,
        memberSince: DateTime(2023, 4, 22),
        followers: 450,
        following: 30,
        activeListings: 2,
        sellerRating: 4.8,
        reviewCount: 6,
        trustScore: 88,
      ),
      TebiyuUser(
        id: 'usr_102',
        name: 'Akol Tech',
        email: 'akoltech@gmail.com',
        phone: '+211925887410',
        avatarUrl: _avatar(33),
        city: 'Juba',
        bio: 'Phones, laptops and accessories in Konyo Konyo.',
        verified: true,
        sellerType: SellerType.business,
        memberSince: DateTime(2024, 1, 9),
        followers: 210,
        following: 44,
        activeListings: 2,
        sellerRating: 4.6,
        reviewCount: 18,
        trustScore: 79,
      ),
      TebiyuUser(
        id: 'usr_103',
        name: 'Nyandeng Properties',
        email: 'info@nyandeng.ss',
        phone: '+211921004455',
        avatarUrl: _avatar(45),
        city: 'Juba',
        bio: 'Land and houses across Juba, title checked.',
        verified: true,
        sellerType: SellerType.business,
        memberSince: DateTime(2022, 11, 3),
        followers: 690,
        following: 12,
        activeListings: 2,
        sellerRating: 4.9,
        reviewCount: 31,
        trustScore: 93,
      ),
      TebiyuUser(
        id: 'usr_104',
        name: 'Grace M.',
        avatarUrl: _avatar(28),
        city: 'Juba',
        memberSince: DateTime(2025, 6, 14),
        followers: 8,
        following: 21,
        activeListings: 1,
      ),
      TebiyuUser(
        id: 'usr_105',
        name: 'Lado Hardware',
        email: 'ladohardware@gmail.com',
        phone: '+211922556677',
        avatarUrl: _avatar(52),
        city: 'Juba',
        bio: 'Generators, solar and tools.',
        sellerType: SellerType.business,
        memberSince: DateTime(2024, 8, 30),
        followers: 96,
        following: 5,
        activeListings: 2,
        sellerRating: 4.3,
        reviewCount: 9,
        trustScore: 71,
      ),
      TebiyuUser(
        id: 'usr_106',
        name: 'Sarah A.',
        avatarUrl: _avatar(9),
        city: 'Juba',
        memberSince: DateTime(2025, 2, 2),
        followers: 3,
        following: 17,
        activeListings: 1,
      ),
      TebiyuUser(
        id: 'usr_107',
        name: 'Majok Farm',
        phone: '+211923118800',
        avatarUrl: _avatar(61),
        city: 'Bor',
        bio: 'Livestock, sold in groups or singly.',
        sellerType: SellerType.business,
        memberSince: DateTime(2024, 5, 18),
        followers: 41,
        following: 2,
        activeListings: 1,
        sellerRating: 4.1,
        reviewCount: 4,
        trustScore: 64,
      ),
      TebiyuUser(
        id: 'usr_108',
        name: 'Juba Frames Studio',
        email: 'bookings@jubaframes.ss',
        phone: '+211926440012',
        avatarUrl: _avatar(19),
        city: 'Juba',
        bio: 'Weddings, graduations and corporate events.',
        verified: true,
        sellerType: SellerType.business,
        memberSince: DateTime(2023, 9, 7),
        followers: 152,
        following: 63,
        activeListings: 1,
        sellerRating: 4.7,
        reviewCount: 22,
        trustScore: 82,
      ),
    ];
  }
}
