import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:tebiyu/core/models/listing.dart';

/// A feed read back from disk, along with when it was stored.
///
/// The timestamp is the point of caching stale data: the UI can render the
/// listings and still tell the user they are looking at something from an
/// hour ago rather than silently presenting it as current.
class CachedFeed {
  /// Creates a cached feed.
  const CachedFeed({required this.listings, required this.savedAt});

  /// Listings as they were when written.
  final List<Listing> listings;

  /// When this feed was written to disk.
  final DateTime savedAt;

  /// How long ago this feed was written.
  Duration get age => DateTime.now().difference(savedAt);

  /// Whether this feed is older than [maxAge].
  bool isStale(Duration maxAge) => age > maxAge;
}

/// Disk cache for listing feeds, backed by Hive.
///
/// Exists so a cold start without a connection shows the last feed instead
/// of an empty spinner. On intermittent networks that is a large share of
/// app opens, which is why this is day-one work rather than a later polish
/// pass.
///
/// Values are stored as JSON strings rather than through typed Hive
/// adapters. [Listing.toMap] already produces primitives and ISO date
/// strings, and the model is still moving during Phase 2 — typed adapters
/// would mean a `build_runner` step plus a schema migration on every field
/// change, for no benefit until the shape settles.
///
/// The trade-off is no type safety at the storage boundary. A malformed
/// entry surfaces as a parse failure at read time, so [readFeed] treats
/// corruption as a cache miss rather than letting it reach the UI.
abstract final class ListingCacheService {
  static const String _boxName = 'listing_cache';
  static const int _maxItemsPerFeed = 30;

  static Box<String>? _box;

  /// Opens the cache. Call once from `main` before `runApp`.
  ///
  /// Opening the box up front costs a little startup time but makes
  /// [readFeed] synchronous, so the first frame can paint cached listings
  /// without waiting on a future.
  static Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Builds the storage key for a [feed] name scoped to [city].
  ///
  /// A null city means the everywhere filter, which gets its own entry so
  /// switching location does not overwrite the unfiltered feed.
  static String feedKey(String feed, String? city) {
    return '$feed:${city ?? 'everywhere'}';
  }

  /// Writes [listings] under [key], replacing whatever was there.
  ///
  /// Only the first [_maxItemsPerFeed] entries are kept. The feed is a
  /// starting point for an offline session, not a full mirror of the
  /// backend, and an unbounded cache would grow with every scroll.
  static Future<void> saveFeed(String key, List<Listing> listings) async {
    final box = _box;
    if (box == null) return;

    final items = listings.take(_maxItemsPerFeed).map((listing) {
      return <String, dynamic>{'id': listing.id, ...listing.toMap()};
    }).toList();

    final payload = jsonEncode(<String, dynamic>{
      'saved_at': DateTime.now().toIso8601String(),
      'items': items,
    });

    await box.put(key, payload);
  }

  /// Reads the feed stored under [key], or null when there is none.
  ///
  /// Synchronous because [init] already opened the box. Returns null on a
  /// decode failure and clears the bad entry, so a cache written by an
  /// older model shape degrades to a normal fetch instead of a crash.
  static CachedFeed? readFeed(String key) {
    final box = _box;
    final payload = box?.get(key);
    if (box == null || payload == null) return null;

    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final savedAt = DateTime.parse(decoded['saved_at'] as String);
      final rawItems = decoded['items'] as List<dynamic>;

      final listings = rawItems.whereType<Map<String, dynamic>>().map((item) {
        return Listing.fromMap(item['id'] as String, item);
      }).toList();

      return CachedFeed(listings: listings, savedAt: savedAt);
    } on Object {
      unawaited(box.delete(key));
      return null;
    }
  }

  /// Removes the feed stored under [key].
  static Future<void> remove(String key) async {
    await _box?.delete(key);
  }

  /// Empties the cache. Wire this to sign-out and to a settings action.
  static Future<void> clear() async {
    await _box?.clear();
  }
}
