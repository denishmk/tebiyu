import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';
import 'package:tebiyu/core/models/listing.dart';

/// Where a user sits in the permission hierarchy.
enum UserRole {
  /// A normal account, buying and selling.
  user('user'),

  /// Staff with moderation access.
  admin('admin'),

  /// Staff with full access.
  superAdmin('super_admin');

  const UserRole(this.storageKey);

  /// Value persisted to Firestore.
  final String storageKey;

  /// Whether this role can reach the admin dashboard.
  bool get isStaff => this != UserRole.user;

  /// Resolves a stored value back to an enum, defaulting to [user].
  static UserRole fromStorage(Object? value) {
    return UserRole.values.firstWhere(
      (role) => role.storageKey == value,
      orElse: () => UserRole.user,
    );
  }
}

/// A Tebiyu account, as shown on a seller profile.
///
/// Counts here are denormalized and maintained by Cloud Functions rather
/// than computed at read time. Firestore cannot count a subcollection in a
/// query, so a profile that counted its own followers would read every
/// follower document to draw one number.
///
/// The exception is [activeListings]: the profile already runs a filtered
/// listing query to fill its grid, and that query returns a total, so the
/// live figure is free. It is kept here as a fallback for surfaces that do
/// not run that query.
@immutable
class TebiyuUser {
  /// Creates a user.
  const TebiyuUser({
    required this.id,
    required this.name,
    required this.memberSince,
    this.email,
    this.phone,
    this.avatarUrl,
    this.city,
    this.bio,
    this.verified = false,
    this.sellerType = SellerType.individual,
    this.role = UserRole.user,
    this.followers = 0,
    this.following = 0,
    this.activeListings = 0,
    this.sellerRating = 0,
    this.reviewCount = 0,
    this.trustScore = 0,
  });

  /// Rebuilds a user from its stored map form.
  factory TebiyuUser.fromMap(String id, Map<String, dynamic> map) {
    return TebiyuUser(
      id: id,
      name: map['name'] as String? ?? '',
      memberSince: _dateFrom(map['member_since']) ?? DateTime.now(),
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      city: map['city'] as String?,
      bio: map['bio'] as String?,
      verified: map['verified'] as bool? ?? false,
      sellerType: SellerType.fromStorage(map['seller_type']),
      role: UserRole.fromStorage(map['role']),
      followers: (map['followers'] as num?)?.toInt() ?? 0,
      following: (map['following'] as num?)?.toInt() ?? 0,
      activeListings: (map['active_listings'] as num?)?.toInt() ?? 0,
      sellerRating: (map['seller_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      trustScore: (map['trust_score'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Firebase Auth uid, also the Firestore document id.
  final String id;

  /// Display name.
  final String name;

  /// When the account was created.
  final DateTime memberSince;

  /// Contact email, if the user chose to show one.
  final String? email;

  /// Contact phone, if the user chose to show one.
  final String? phone;

  /// Profile photo URL.
  final String? avatarUrl;

  /// Home city, from the same list as the location picker.
  final String? city;

  /// Short self description shown on the profile.
  final String? bio;

  /// Whether identity documents have been checked.
  final bool verified;

  /// Whether this account trades as an individual or a business.
  final SellerType sellerType;

  /// Permission level.
  final UserRole role;

  /// Accounts following this one.
  final int followers;

  /// Accounts this one follows.
  final int following;

  /// Listings currently visible in the marketplace.
  final int activeListings;

  /// Mean review score, from zero to five.
  final double sellerRating;

  /// How many reviews the mean is drawn from.
  ///
  /// Shown beside the rating because 5.0 from one review and 4.6 from
  /// ninety are not the same claim, and a bare average hides which is
  /// which.
  final int reviewCount;

  /// Composite trust score from zero to one hundred.
  final double trustScore;

  /// Whether this account has been reviewed at all.
  bool get hasRating => reviewCount > 0;

  /// First letter of [name], for an avatar with no photo.
  String get initial =>
      name.isEmpty ? '?' : name.characters.first.toUpperCase();

  /// Serializes to the stored map form.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'member_since': memberSince.toIso8601String(),
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'city': city,
      'bio': bio,
      'verified': verified,
      'seller_type': sellerType.storageKey,
      'role': role.storageKey,
      'followers': followers,
      'following': following,
      'active_listings': activeListings,
      'seller_rating': sellerRating,
      'review_count': reviewCount,
      'trust_score': trustScore,
    };
  }

  /// Returns a copy with the given fields replaced.
  TebiyuUser copyWith({
    String? id,
    String? name,
    DateTime? memberSince,
    String? email,
    String? phone,
    String? avatarUrl,
    String? city,
    String? bio,
    bool? verified,
    SellerType? sellerType,
    UserRole? role,
    int? followers,
    int? following,
    int? activeListings,
    double? sellerRating,
    int? reviewCount,
    double? trustScore,
  }) {
    return TebiyuUser(
      id: id ?? this.id,
      name: name ?? this.name,
      memberSince: memberSince ?? this.memberSince,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      verified: verified ?? this.verified,
      sellerType: sellerType ?? this.sellerType,
      role: role ?? this.role,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      activeListings: activeListings ?? this.activeListings,
      sellerRating: sellerRating ?? this.sellerRating,
      reviewCount: reviewCount ?? this.reviewCount,
      trustScore: trustScore ?? this.trustScore,
    );
  }

  static DateTime? _dateFrom(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TebiyuUser &&
        other.id == id &&
        other.name == name &&
        other.memberSince == memberSince &&
        other.email == email &&
        other.phone == phone &&
        other.avatarUrl == avatarUrl &&
        other.city == city &&
        other.bio == bio &&
        other.verified == verified &&
        other.sellerType == sellerType &&
        other.role == role &&
        other.followers == followers &&
        other.following == following &&
        other.activeListings == activeListings &&
        other.sellerRating == sellerRating &&
        other.reviewCount == reviewCount &&
        other.trustScore == trustScore;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        memberSince,
        email,
        phone,
        avatarUrl,
        city,
        bio,
        verified,
        sellerType,
        role,
        followers,
        following,
        activeListings,
        sellerRating,
        reviewCount,
        trustScore,
      );

  @override
  String toString() => 'TebiyuUser($id, $name)';
}
