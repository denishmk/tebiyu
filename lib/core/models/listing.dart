import 'package:flutter/foundation.dart';

/// Currency a listing price is expressed in.
enum ListingCurrency {
  /// South Sudanese Pound.
  ssp('SSP', 'SSP'),

  /// United States Dollar.
  usd('usd', r'$');

  const ListingCurrency(this.storageKey, this.symbol);

  /// Value persisted to Firestore and Hive.
  final String storageKey;

  /// Short symbol rendered beside the price.
  final String symbol;

  /// Resolves a stored value back to an enum, defaulting to [ssp].
  static ListingCurrency fromStorage(Object? value) {
    return ListingCurrency.values.firstWhere(
      (currency) => currency.storageKey == value,
      orElse: () => ListingCurrency.ssp,
    );
  }
}

/// Physical condition of the item being sold.
enum ListingCondition {
  /// Never used, still sealed or unopened.
  brandNew('new', 'New'),

  /// Previously owned and used locally.
  used('used', 'Used'),

  /// Imported second-hand, a common category in this market.
  foreignUsed('foreign_used', 'Foreign used'),

  /// Repaired or restored to working order.
  refurbished('refurbished', 'Refurbished');

  const ListingCondition(this.storageKey, this.label);

  /// Value persisted to Firestore and Hive.
  final String storageKey;

  /// Human readable label shown on condition chips.
  final String label;

  /// Resolves a stored value back to an enum, defaulting to [used].
  static ListingCondition fromStorage(Object? value) {
    return ListingCondition.values.firstWhere(
      (condition) => condition.storageKey == value,
      orElse: () => ListingCondition.used,
    );
  }
}

/// Lifecycle state of a listing.
enum ListingStatus {
  /// Visible in the marketplace.
  active('active'),

  /// Seller marked the item as sold.
  sold('sold'),

  /// Saved by the seller but never published.
  draft('draft'),

  /// Blocked by moderation.
  rejected('rejected'),

  /// Passed its expiry date without renewal.
  expired('expired'),

  /// Temporarily hidden by the seller.
  paused('paused');

  const ListingStatus(this.storageKey);

  /// Value persisted to Firestore and Hive.
  final String storageKey;

  /// Whether the listing should appear in public feeds.
  bool get isPublic => this == ListingStatus.active;

  /// Resolves a stored value back to an enum, defaulting to [active].
  static ListingStatus fromStorage(Object? value) {
    return ListingStatus.values.firstWhere(
      (status) => status.storageKey == value,
      orElse: () => ListingStatus.active,
    );
  }
}

/// A single item offered for sale in the marketplace.
///
/// Seller fields ([sellerName], [sellerAvatarUrl], [sellerVerified]) are
/// denormalized onto every listing. Firestore has no joins, so without
/// them each card in a feed would cost a second read. The trade-off is a
/// fan-out write when a seller changes their name or avatar, handled by a
/// Cloud Function rather than at read time.
@immutable
class Listing {
  /// Creates a listing.
  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.price,
    required this.currency,
    required this.condition,
    required this.images,
    required this.city,
    required this.area,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    this.negotiable = false,
    this.exchangePossible = false,
    this.priceUsdAtPost,
    this.videoUrl,
    this.latitude,
    this.longitude,
    this.sellerAvatarUrl,
    this.sellerVerified = false,
    this.attributes = const <String, String>{},
    this.status = ListingStatus.active,
    this.views = 0,
    this.saves = 0,
    this.inquiries = 0,
    this.promoted = false,
    this.promotedUntil,
    this.expiresAt,
  });

  /// Rebuilds a listing from its stored map form.
  factory Listing.fromMap(String id, Map<String, dynamic> map) {
    return Listing(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      subcategory: map['subcategory'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      currency: ListingCurrency.fromStorage(map['currency']),
      condition: ListingCondition.fromStorage(map['condition']),
      images: (map['images'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>()
          .toList(),
      city: map['city'] as String? ?? '',
      area: map['area'] as String? ?? '',
      sellerId: map['seller_id'] as String? ?? '',
      sellerName: map['seller_name'] as String? ?? '',
      createdAt: _dateFrom(map['created_at']) ?? DateTime.now(),
      negotiable: map['negotiable'] as bool? ?? false,
      exchangePossible: map['exchange_possible'] as bool? ?? false,
      priceUsdAtPost: (map['price_usd_at_post'] as num?)?.toDouble(),
      videoUrl: map['video_url'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      sellerAvatarUrl: map['seller_avatar_url'] as String?,
      sellerVerified: map['seller_verified'] as bool? ?? false,
      attributes: (map['attributes'] as Map<dynamic, dynamic>? ?? {}).map(
        (key, value) => MapEntry('$key', '$value'),
      ),
      status: ListingStatus.fromStorage(map['status']),
      views: (map['views'] as num?)?.toInt() ?? 0,
      saves: (map['saves'] as num?)?.toInt() ?? 0,
      inquiries: (map['inquiries'] as num?)?.toInt() ?? 0,
      promoted: map['promoted'] as bool? ?? false,
      promotedUntil: _dateFrom(map['promoted_until']),
      expiresAt: _dateFrom(map['expires_at']),
    );
  }

  /// Firestore document id.
  final String id;

  /// Headline shown on cards and the detail screen.
  final String title;

  /// Long form seller-written body text.
  final String description;

  /// Top level taxonomy entry, for example `Vehicles`.
  final String category;

  /// Second level taxonomy entry, for example `Cars`.
  final String subcategory;

  /// Asking price, expressed in [currency].
  final double price;

  /// Currency the [price] is quoted in.
  final ListingCurrency currency;

  /// USD value of [price] captured at posting time.
  ///
  /// The SSP rate moves, so an SSP price recorded months ago no longer
  /// means what it meant then. Storing the USD equivalent at post time
  /// keeps historical listings comparable and gives analytics a stable
  /// basis. Null for listings already priced in USD.
  final double? priceUsdAtPost;

  /// Whether the seller will entertain offers.
  final bool negotiable;

  /// Whether the seller will consider a trade.
  final bool exchangePossible;

  /// Physical condition of the item.
  final ListingCondition condition;

  /// Ordered image URLs, first entry is the cover photo.
  final List<String> images;

  /// Optional single video URL.
  final String? videoUrl;

  /// City the item is located in, matched against the picker from P1.7.
  final String city;

  /// Neighbourhood or area within [city].
  final String area;

  /// Latitude of the pinned location, if the seller dropped a pin.
  final double? latitude;

  /// Longitude of the pinned location, if the seller dropped a pin.
  final double? longitude;

  /// Owning user id.
  final String sellerId;

  /// Denormalized seller display name.
  final String sellerName;

  /// Denormalized seller avatar URL.
  final String? sellerAvatarUrl;

  /// Denormalized seller verification flag.
  final bool sellerVerified;

  /// Category specific fields, for example `{'Brand': 'Toyota'}`.
  final Map<String, String> attributes;

  /// Lifecycle state.
  final ListingStatus status;

  /// Detail screen open count.
  final int views;

  /// Number of users who saved this listing.
  final int saves;

  /// Number of chat threads started from this listing.
  final int inquiries;

  /// Whether the seller paid to boost this listing.
  final bool promoted;

  /// When the paid boost lapses.
  final DateTime? promotedUntil;

  /// Publication timestamp.
  final DateTime createdAt;

  /// When the listing falls out of the feed without renewal.
  final DateTime? expiresAt;

  /// Cover image URL, or null when the seller uploaded none.
  String? get coverImage => images.isEmpty ? null : images.first;

  /// Whether the paid boost is still running.
  bool get isPromotedNow {
    final until = promotedUntil;
    if (!promoted || until == null) return false;
    return until.isAfter(DateTime.now());
  }

  /// `Area, City` string used on card location rows.
  String get locationLabel => area.isEmpty ? city : '$area, $city';

  /// Serializes to the stored map form.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'price': price,
      'currency': currency.storageKey,
      'price_usd_at_post': priceUsdAtPost,
      'negotiable': negotiable,
      'exchange_possible': exchangePossible,
      'condition': condition.storageKey,
      'images': images,
      'video_url': videoUrl,
      'city': city,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_avatar_url': sellerAvatarUrl,
      'seller_verified': sellerVerified,
      'attributes': attributes,
      'status': status.storageKey,
      'views': views,
      'saves': saves,
      'inquiries': inquiries,
      'promoted': promoted,
      'promoted_until': promotedUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Returns a copy with the given fields replaced.
  Listing copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? subcategory,
    double? price,
    ListingCurrency? currency,
    double? priceUsdAtPost,
    bool? negotiable,
    bool? exchangePossible,
    ListingCondition? condition,
    List<String>? images,
    String? videoUrl,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
    String? sellerId,
    String? sellerName,
    String? sellerAvatarUrl,
    bool? sellerVerified,
    Map<String, String>? attributes,
    ListingStatus? status,
    int? views,
    int? saves,
    int? inquiries,
    bool? promoted,
    DateTime? promotedUntil,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      priceUsdAtPost: priceUsdAtPost ?? this.priceUsdAtPost,
      negotiable: negotiable ?? this.negotiable,
      exchangePossible: exchangePossible ?? this.exchangePossible,
      condition: condition ?? this.condition,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      city: city ?? this.city,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatarUrl: sellerAvatarUrl ?? this.sellerAvatarUrl,
      sellerVerified: sellerVerified ?? this.sellerVerified,
      attributes: attributes ?? this.attributes,
      status: status ?? this.status,
      views: views ?? this.views,
      saves: saves ?? this.saves,
      inquiries: inquiries ?? this.inquiries,
      promoted: promoted ?? this.promoted,
      promotedUntil: promotedUntil ?? this.promotedUntil,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
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
    return other is Listing &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.subcategory == subcategory &&
        other.price == price &&
        other.currency == currency &&
        other.priceUsdAtPost == priceUsdAtPost &&
        other.negotiable == negotiable &&
        other.exchangePossible == exchangePossible &&
        other.condition == condition &&
        listEquals(other.images, images) &&
        other.videoUrl == videoUrl &&
        other.city == city &&
        other.area == area &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.sellerId == sellerId &&
        other.sellerName == sellerName &&
        other.sellerAvatarUrl == sellerAvatarUrl &&
        other.sellerVerified == sellerVerified &&
        mapEquals(other.attributes, attributes) &&
        other.status == status &&
        other.views == views &&
        other.saves == saves &&
        other.inquiries == inquiries &&
        other.promoted == promoted &&
        other.promotedUntil == promotedUntil &&
        other.createdAt == createdAt &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      category,
      subcategory,
      price,
      currency,
      condition,
      Object.hashAll(images),
      city,
      area,
      sellerId,
      sellerName,
      sellerVerified,
      status,
      views,
      saves,
      promoted,
      createdAt,
      expiresAt,
    );
  }

  @override
  String toString() => 'Listing($id, $title, $price ${currency.storageKey})';
}
