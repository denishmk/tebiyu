import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';

/// Firestore backed [ListingRepository].
///
/// Timestamps are converted at this boundary rather than in
/// [Listing.toMap]. Firestore's native `Timestamp` sorts correctly inside
/// queries where an ISO string would sort lexically, and it pairs with
/// `FieldValue.serverTimestamp()` so a phone with a wrong clock cannot post
/// a listing dated 2019 and bury it at the bottom of every feed forever.
/// The Hive cache keeps ISO strings, which suit JSON. Each storage layer
/// gets the format that fits it and the model stays free of Firestore
/// imports.
class FirestoreListingRepository implements ListingRepository {
  /// Creates the repository.
  FirestoreListingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Collection holding every listing.
  static const String collection = 'listings';

  /// Document holding per-subcategory counts, maintained by a Cloud
  /// Function. One read, rather than a hundred aggregation queries.
  static const String countersPath = 'counters/subcategories';

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _db.collection(collection);

  @override
  Future<ListingPage> fetchListings(ListingQuery query) async {
    try {
      var q = _applyFilters(_listings, query);
      q = _applySort(q, query.sort);

      final cursor = query.startAfter;
      if (cursor != null) {
        q = q.startAfter(<Object?>[
          _cursorValue(cursor, query.sort),
          cursor.id,
        ]);
      }

      final snapshot = await q.limit(query.limit).get();
      final items = snapshot.docs.map(_toListing).toList();

      return ListingPage(
        items: items,
        // No total. A `count()` aggregation is a second round trip and is
        // billed per document scanned, which is a poor trade for a number
        // shown once above the grid. The results screen already handles a
        // null total by staying silent.
        nextCursor: items.length < query.limit
            ? null
            : ListingCursor.after(items.last, query.sort),
      );
    } on FirebaseException catch (error) {
      // TEMPORARY: prints the real Firestore error, including the index
      // creation link, while we are still discovering which composite
      // indexes the app needs. Remove once fetchListings is index-clean.
      // ignore: avoid_print
      print(
        'FIRESTORE fetchListings error: ${error.code} — ${error.message}',
      );
      throw ListingFailure(_messageFor(error), cause: error);
    }
  }

  @override
  Future<FeedResult> fetchRecommended({
    String? city,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final page = await fetchListings(
      ListingQuery(city: city, limit: limit, promotedOnly: false),
    );
    return FeedResult.network(page.items);
  }

  @override
  Future<FeedResult> fetchTrending({
    String? city,
    int limit = 12,
    bool forceRefresh = false,
  }) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    try {
      var q = _listings
          .where('status', isEqualTo: 'active')
          .where('created_at', isGreaterThan: Timestamp.fromDate(cutoff));
      if (city != null) q = q.where('city', isEqualTo: city);

      final snapshot = await q
          .orderBy('created_at', descending: true)
          .orderBy('views', descending: true)
          .limit(limit)
          .get();

      return FeedResult.network(snapshot.docs.map(_toListing).toList());
    } on FirebaseException catch (error) {
      // ignore: avoid_print
      print(
        'FIRESTORE fetchTrending error: ${error.code} — ${error.message}',
      );
      throw ListingFailure(_messageFor(error), cause: error);
    }
  }

  @override
  Future<Map<String, int>> fetchSubcategoryCounts() async {
    try {
      final doc = await _db.doc(countersPath).get();
      final data = doc.data() ?? const <String, dynamic>{};
      return <String, int>{
        for (final entry in data.entries)
          if (entry.value is num) entry.key: (entry.value as num).toInt(),
      };
    } on FirebaseException catch (error) {
      throw ListingFailure(_messageFor(error), cause: error);
    }
  }

  @override
  Future<List<Listing>> fetchSimilar(Listing listing, {int limit = 6}) async {
    final page = await fetchListings(
      ListingQuery(
        category: listing.category,
        subcategory: listing.subcategory,
        limit: limit + 1,
      ),
    );
    return page.items.where((l) => l.id != listing.id).take(limit).toList();
  }

  @override
  Future<List<Listing>> fetchByIds(List<String> ids) async {
    if (ids.isEmpty) return const <Listing>[];

    try {
      // whereIn caps at thirty values per query, so long save lists are
      // fetched in batches and stitched back into the caller's order.
      final found = <String, Listing>{};
      for (var i = 0; i < ids.length; i += 30) {
        final batch = ids.sublist(i, (i + 30).clamp(0, ids.length));
        final snapshot = await _listings
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in snapshot.docs) {
          found[doc.id] = _toListing(doc);
        }
      }
      return <Listing>[for (final id in ids) ?found[id]];
    } on FirebaseException catch (error) {
      throw ListingFailure(_messageFor(error), cause: error);
    }
  }

  @override
  Future<Listing?> fetchById(String id) async {
    try {
      final doc = await _listings.doc(id).get();
      return doc.exists ? _toListing(doc) : null;
    } on FirebaseException catch (error) {
      throw ListingFailure(_messageFor(error), cause: error);
    }
  }

  @override
  Stream<Listing?> watchById(String id) {
    return _listings.doc(id).snapshots().map(
          (doc) => doc.exists ? _toListing(doc) : null,
        );
  }

  @override
  Future<void> incrementViews(String id) async {
    try {
      // An atomic increment, not a read-then-write. Two buyers opening the
      // same listing at once would otherwise each read the same number and
      // write the same result, losing a view.
      await _listings.doc(id).update(<String, Object?>{
        'views': FieldValue.increment(1),
      });
    } on FirebaseException {
      // A lost view count is not worth surfacing. The rules also block
      // this field from clients, so this will fail until the Cloud
      // Function that owns it is deployed.
    }
  }

  // -----------------------------------------------------------------
  // Query building
  // -----------------------------------------------------------------

  Query<Map<String, dynamic>> _applyFilters(
    Query<Map<String, dynamic>> base,
    ListingQuery query,
  ) {
    var q = base.where('status', isEqualTo: 'active');

    if (query.category != null) {
      q = q.where('category', isEqualTo: query.category);
    }
    if (query.subcategory != null) {
      q = q.where('subcategory', isEqualTo: query.subcategory);
    }
    if (query.city != null) q = q.where('city', isEqualTo: query.city);
    if (query.area != null) q = q.where('area', isEqualTo: query.area);
    if (query.type != null) {
      q = q.where('type', isEqualTo: query.type!.storageKey);
    }
    if (query.brand != null) {
      q = q.where('attributes.Brand', isEqualTo: query.brand);
    }
    if (query.sellerId != null) {
      q = q.where('seller_id', isEqualTo: query.sellerId);
    }
    if (query.conditions.isNotEmpty) {
      q = q.where(
        'condition',
        whereIn: query.conditions.map((c) => c.storageKey).toList(),
      );
    }
    if (query.negotiableOnly) q = q.where('negotiable', isEqualTo: true);
    if (query.promotedOnly) q = q.where('promoted', isEqualTo: true);
    if (query.deliveryOnly) {
      q = q.where('delivery_available', isEqualTo: true);
    }
    if (query.verifiedSellersOnly) {
      q = q.where('seller_verified', isEqualTo: true);
    }
    if (query.withPhotosOnly) {
      q = q.where('image_count', isGreaterThan: 0);
    }
    if (query.sellerType != null) {
      q = q.where('seller_type', isEqualTo: query.sellerType!.storageKey);
    }
    if (query.postedAfter != null) {
      q = q.where(
        'created_at',
        isGreaterThanOrEqualTo: Timestamp.fromDate(query.postedAfter!),
      );
    }
    for (final entry in query.attributes.entries) {
      q = q.where('attributes.${entry.key}', isEqualTo: entry.value);
    }
    if (query.minPrice != null) {
      q = q.where('price', isGreaterThanOrEqualTo: query.minPrice);
    }
    if (query.maxPrice != null) {
      q = q.where('price', isLessThanOrEqualTo: query.maxPrice);
    }

    return q;
  }

  Query<Map<String, dynamic>> _applySort(
    Query<Map<String, dynamic>> q,
    ListingSort sort,
  ) {
    // The second orderBy on document id breaks ties, without which
    // startAfter can skip or repeat a listing across pages.
    return switch (sort) {
      ListingSort.latest =>
        q.orderBy('created_at', descending: true).orderBy(FieldPath.documentId),
      ListingSort.priceLowToHigh =>
        q.orderBy('price').orderBy(FieldPath.documentId),
      ListingSort.priceHighToLow =>
        q.orderBy('price', descending: true).orderBy(FieldPath.documentId),
      ListingSort.mostViewed =>
        q.orderBy('views', descending: true).orderBy(FieldPath.documentId),
    };
  }

  Object? _cursorValue(ListingCursor cursor, ListingSort sort) {
    return switch (sort) {
      ListingSort.latest => Timestamp.fromDate(cursor.createdAt),
      ListingSort.priceLowToHigh ||
      ListingSort.priceHighToLow =>
        cursor.price,
      ListingSort.mostViewed => cursor.views,
    };
  }

  // -----------------------------------------------------------------
  // Mapping
  // -----------------------------------------------------------------

  static Listing _toListing(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.of(doc.data() ?? <String, dynamic>{});
    for (final key in <String>[
      'created_at',
      'expires_at',
      'promoted_until',
    ]) {
      final value = data[key];
      if (value is Timestamp) data[key] = value.toDate();
    }
    return Listing.fromMap(doc.id, data);
  }

  static String _messageFor(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => 'You do not have access to these listings.',
      'unavailable' => 'No connection. Check your network and try again.',
      // A missing index is a developer error, not something a buyer can
      // act on, but the console link in the raw error is what fixes it, so
      // it stays attached as the cause.
      'failed-precondition' => 'This filter is not available yet.',
      _ => 'Could not load listings. Please try again.',
    };
  }
}
