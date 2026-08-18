import 'dart:async';

import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/repositories/listing_repository.dart';

/// In-memory [ListingRepository] used until the Firestore schema is fixed.
///
/// Mirrors the latency and paging behaviour of the real backend so the Home
/// screen exercises its loading, empty, and pagination states properly. The
/// seed data is deterministic, which keeps widget tests stable.
class MockListingRepository implements ListingRepository {
  /// Creates a mock repository.
  ///
  /// [latency] simulates a slow connection. Pass [Duration.zero] in tests.
  MockListingRepository({
    List<Listing>? seed,
    this.latency = const Duration(milliseconds: 450),
  }) : _listings = List<Listing>.of(seed ?? _seedListings());

  /// Artificial delay applied to every call.
  final Duration latency;

  final List<Listing> _listings;
  final Map<String, StreamController<Listing?>> _watchers =
      <String, StreamController<Listing?>>{};

  /// Unmodifiable view of the seeded data, useful in tests.
  List<Listing> get all => List<Listing>.unmodifiable(_listings);

  @override
  Future<ListingPage> fetchListings(ListingQuery query) async {
    await _wait();
    final filtered = _applyFilters(_listings, query);
    final sorted = _applySort(filtered, query.sort);
    return _paginate(sorted, query);
  }

  @override
  Future<FeedResult> fetchRecommended({
    String? city,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    await _wait();
    final pool = _listings.where((l) => l.status.isPublic).toList()
      ..sort((a, b) {
        final aLocal = city == null || a.city == city;
        final bLocal = city == null || b.city == city;
        if (aLocal != bLocal) return aLocal ? -1 : 1;
        if (a.isPromotedNow != b.isPromotedNow) {
          return a.isPromotedNow ? -1 : 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
    return FeedResult.network(pool.take(limit).toList());
  }

  @override
  Future<FeedResult> fetchTrending({
    String? city,
    int limit = 12,
    bool forceRefresh = false,
  }) async {
    await _wait();
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final pool =
        _listings
            .where((l) => l.status.isPublic && l.createdAt.isAfter(cutoff))
            .where((l) => city == null || l.city == city)
            .toList()
          ..sort((a, b) => b.views.compareTo(a.views));
    return FeedResult.network(pool.take(limit).toList());
  }

  @override
  Future<Listing?> fetchById(String id) async {
    await _wait();
    for (final listing in _listings) {
      if (listing.id == id) return listing;
    }
    return null;
  }

  @override
  Stream<Listing?> watchById(String id) {
    final controller = _watchers.putIfAbsent(
      id,
      StreamController<Listing?>.broadcast,
    );
    unawaited(fetchById(id).then(controller.add));
    return controller.stream;
  }

  @override
  Future<void> incrementViews(String id) async {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index == -1) return;
    final updated = _listings[index].copyWith(
      views: _listings[index].views + 1,
    );
    _listings[index] = updated;
    _watchers[id]?.add(updated);
  }

  /// Releases the streams opened by [watchById].
  void dispose() {
    for (final controller in _watchers.values) {
      unawaited(controller.close());
    }
    _watchers.clear();
  }

  Future<void> _wait() =>
      latency == Duration.zero ? Future<void>.value() : Future.delayed(latency);

  static List<Listing> _applyFilters(
    List<Listing> source,
    ListingQuery query,
  ) {
    final term = query.searchTerm?.trim().toLowerCase();
    return source.where((listing) {
      if (!listing.status.isPublic) return false;
      if (query.category != null && listing.category != query.category) {
        return false;
      }
      if (query.subcategory != null &&
          listing.subcategory != query.subcategory) {
        return false;
      }
      if (query.city != null && listing.city != query.city) return false;
      if (query.area != null && listing.area != query.area) return false;
      if (query.conditions.isNotEmpty &&
          !query.conditions.contains(listing.condition)) {
        return false;
      }
      if (query.minPrice != null && listing.price < query.minPrice!) {
        return false;
      }
      if (query.maxPrice != null && listing.price > query.maxPrice!) {
        return false;
      }
      if (query.currency != null && listing.currency != query.currency) {
        return false;
      }
      if (query.sellerId != null && listing.sellerId != query.sellerId) {
        return false;
      }
      if (query.negotiableOnly && !listing.negotiable) return false;
      if (query.promotedOnly && !listing.isPromotedNow) return false;
      if (term != null && term.isNotEmpty) {
        final haystack =
            '${listing.title} ${listing.description} ${listing.subcategory}'
                .toLowerCase();
        if (!haystack.contains(term)) return false;
      }
      return true;
    }).toList();
  }

  static List<Listing> _applySort(List<Listing> source, ListingSort sort) {
    final sorted = List<Listing>.of(source);
    switch (sort) {
      case ListingSort.latest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ListingSort.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case ListingSort.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case ListingSort.mostViewed:
        sorted.sort((a, b) => b.views.compareTo(a.views));
    }
    return sorted;
  }

  static ListingPage _paginate(List<Listing> sorted, ListingQuery query) {
    var start = 0;
    final cursor = query.startAfter;
    if (cursor != null) {
      final index = sorted.indexWhere((l) => l.id == cursor.id);
      if (index != -1) start = index + 1;
    }
    if (start >= sorted.length) return ListingPage.empty;

    final end = (start + query.limit).clamp(0, sorted.length);
    final items = sorted.sublist(start, end);
    final hasMore = end < sorted.length;
    return ListingPage(
      items: items,
      nextCursor: hasMore && items.isNotEmpty
          ? ListingCursor.after(items.last, query.sort)
          : null,
    );
  }

  static String _photo(String seed) =>
      'https://picsum.photos/seed/$seed/800/600';

  static String _avatar(int index) => 'https://i.pravatar.cc/150?img=$index';

  static List<Listing> _seedListings() {
    final now = DateTime.now();
    DateTime ago(int hours) => now.subtract(Duration(hours: hours));

    return <Listing>[
      Listing(
        id: 'lst_001',
        title: 'Toyota Land Cruiser V8 2016',
        description:
            'Well maintained V8, full service history, new tyres fitted '
            'last month. Serious buyers only.',
        category: 'Vehicles',
        subcategory: 'SUV',
        price: 48000,
        currency: ListingCurrency.usd,
        condition: ListingCondition.foreignUsed,
        images: <String>[
          _photo('landcruiser-a'),
          _photo('landcruiser-b'),
          _photo('landcruiser-c'),
        ],
        city: 'Juba',
        area: 'Thongpiny',
        sellerId: 'usr_101',
        sellerName: 'Deng Motors',
        sellerAvatarUrl: _avatar(12),
        sellerVerified: true,
        negotiable: true,
        attributes: const <String, String>{
          'Brand': 'Toyota',
          'Model': 'Land Cruiser V8',
          'Year': '2016',
          'Transmission': 'Automatic',
          'Fuel': 'Petrol',
          'Mileage': '96,000 km',
        },
        views: 1840,
        saves: 212,
        inquiries: 47,
        promoted: true,
        promotedUntil: now.add(const Duration(days: 5)),
        createdAt: ago(6),
      ),
      Listing(
        id: 'lst_002',
        title: 'iPhone 13 Pro 256GB',
        description:
            'Battery health 91 percent. Comes with original box, cable '
            'and a protective case.',
        category: 'Mobile Phones & Accessories',
        subcategory: 'Mobile Phones',
        price: 620,
        currency: ListingCurrency.usd,
        condition: ListingCondition.foreignUsed,
        images: <String>[_photo('iphone13-a'), _photo('iphone13-b')],
        city: 'Juba',
        area: 'Hai Malakal',
        sellerId: 'usr_102',
        sellerName: 'Akol Tech',
        sellerAvatarUrl: _avatar(33),
        sellerVerified: true,
        negotiable: true,
        exchangePossible: true,
        attributes: const <String, String>{
          'Brand': 'Apple',
          'Model': 'iPhone 13 Pro',
          'Storage': '256GB',
          'Colour': 'Graphite',
        },
        views: 2310,
        saves: 340,
        inquiries: 88,
        createdAt: ago(14),
      ),
      Listing(
        id: 'lst_003',
        title: 'Plot of land 20x30 in Gudele',
        description:
            'Fenced plot with clear title deed, close to the main road. '
            'Water and power available on the street.',
        category: 'Properties',
        subcategory: 'Land/Plots',
        price: 9500000,
        currency: ListingCurrency.ssp,
        priceUsdAtPost: 7300,
        condition: ListingCondition.brandNew,
        images: <String>[_photo('plot-gudele')],
        city: 'Juba',
        area: 'Gudele',
        sellerId: 'usr_103',
        sellerName: 'Nyandeng Properties',
        sellerAvatarUrl: _avatar(45),
        sellerVerified: true,
        negotiable: true,
        attributes: const <String, String>{
          'Size': '20 x 30 m',
          'Title': 'Freehold',
          'Fenced': 'Yes',
        },
        views: 1120,
        saves: 96,
        inquiries: 31,
        createdAt: ago(30),
      ),
      Listing(
        id: 'lst_004',
        title: 'Samsung 300L double door fridge',
        description:
            'Used for one year, cooling is perfect. Selling because I am '
            'relocating.',
        category: 'Electronics & Appliances',
        subcategory: 'Refrigerators & Freezers',
        price: 480000,
        currency: ListingCurrency.ssp,
        priceUsdAtPost: 370,
        condition: ListingCondition.used,
        images: <String>[_photo('fridge-a'), _photo('fridge-b')],
        city: 'Juba',
        area: 'Munuki',
        sellerId: 'usr_104',
        sellerName: 'Grace M.',
        sellerAvatarUrl: _avatar(28),
        negotiable: true,
        attributes: const <String, String>{
          'Brand': 'Samsung',
          'Capacity': '300L',
          'Type': 'Double door',
        },
        views: 640,
        saves: 54,
        inquiries: 12,
        createdAt: ago(38),
      ),
      Listing(
        id: 'lst_005',
        title: '3 bedroom house for rent, Thongpiny',
        description:
            'Self contained compound, parking for two cars, borehole and '
            'standby generator. Annual payment preferred.',
        category: 'Properties',
        subcategory: 'Houses/Apartments',
        price: 12000,
        currency: ListingCurrency.usd,
        condition: ListingCondition.used,
        images: <String>[
          _photo('house-thongpiny-a'),
          _photo('house-thongpiny-b'),
          _photo('house-thongpiny-c'),
        ],
        city: 'Juba',
        area: 'Thongpiny',
        sellerId: 'usr_103',
        sellerName: 'Nyandeng Properties',
        sellerAvatarUrl: _avatar(45),
        sellerVerified: true,
        attributes: const <String, String>{
          'Bedrooms': '3',
          'Bathrooms': '2',
          'Furnished': 'Semi',
          'Parking': '2 cars',
        },
        views: 1490,
        saves: 178,
        inquiries: 40,
        promoted: true,
        promotedUntil: now.add(const Duration(days: 12)),
        createdAt: ago(52),
      ),
      Listing(
        id: 'lst_006',
        title: 'Tecno Spark 10 Pro, 8GB RAM',
        description: 'Brand new, sealed in box. Shop warranty of 6 months.',
        category: 'Mobile Phones & Accessories',
        subcategory: 'Mobile Phones',
        price: 165000,
        currency: ListingCurrency.ssp,
        priceUsdAtPost: 127,
        condition: ListingCondition.brandNew,
        images: <String>[_photo('tecno-spark')],
        city: 'Juba',
        area: 'Konyo Konyo',
        sellerId: 'usr_102',
        sellerName: 'Akol Tech',
        sellerAvatarUrl: _avatar(33),
        sellerVerified: true,
        attributes: const <String, String>{
          'Brand': 'Tecno',
          'Model': 'Spark 10 Pro',
          'RAM': '8GB',
          'Storage': '256GB',
        },
        views: 980,
        saves: 121,
        inquiries: 26,
        createdAt: ago(66),
      ),
      Listing(
        id: 'lst_007',
        title: '5.5 KVA diesel generator',
        description:
            'Runs quietly, low fuel consumption. Serviced two weeks ago, '
            'ready to work.',
        category: 'Commercial Equipment & Tools',
        subcategory: 'Industrial Equipment',
        price: 1350,
        currency: ListingCurrency.usd,
        condition: ListingCondition.used,
        images: <String>[_photo('generator-a'), _photo('generator-b')],
        city: 'Juba',
        area: 'Jebel',
        sellerId: 'usr_105',
        sellerName: 'Lado Hardware',
        sellerAvatarUrl: _avatar(52),
        negotiable: true,
        attributes: const <String, String>{
          'Output': '5.5 KVA',
          'Fuel': 'Diesel',
          'Starter': 'Electric',
        },
        views: 720,
        saves: 63,
        inquiries: 19,
        createdAt: ago(80),
      ),
      Listing(
        id: 'lst_008',
        title: 'Toyota Hilux double cabin 2014',
        description:
            'Strong pickup, suitable for field work. Body is clean, no '
            'accident history.',
        category: 'Vehicles',
        subcategory: 'Pickup Trucks',
        price: 26500,
        currency: ListingCurrency.usd,
        condition: ListingCondition.foreignUsed,
        images: <String>[_photo('hilux-a'), _photo('hilux-b')],
        city: 'Wau',
        area: 'Hai Jedid',
        sellerId: 'usr_101',
        sellerName: 'Deng Motors',
        sellerAvatarUrl: _avatar(12),
        sellerVerified: true,
        negotiable: true,
        exchangePossible: true,
        attributes: const <String, String>{
          'Brand': 'Toyota',
          'Model': 'Hilux',
          'Year': '2014',
          'Transmission': 'Manual',
          'Fuel': 'Diesel',
        },
        views: 1260,
        saves: 140,
        inquiries: 35,
        createdAt: ago(96),
      ),
      Listing(
        id: 'lst_009',
        title: 'Office desk and executive chair set',
        description:
            'Solid wood desk with matching leather chair. Light scratches '
            'on one side, otherwise good.',
        category: 'Home & Garden',
        subcategory: 'Furniture',
        price: 210000,
        currency: ListingCurrency.ssp,
        priceUsdAtPost: 162,
        condition: ListingCondition.used,
        images: <String>[_photo('office-desk')],
        city: 'Juba',
        area: 'Atlabara',
        sellerId: 'usr_106',
        sellerName: 'Sarah A.',
        sellerAvatarUrl: _avatar(9),
        negotiable: true,
        attributes: const <String, String>{
          'Material': 'Wood',
          'Includes': 'Desk and chair',
        },
        views: 410,
        saves: 29,
        inquiries: 8,
        createdAt: ago(120),
      ),
      Listing(
        id: 'lst_010',
        title: '300W solar panel with inverter',
        description:
            'Complete kit with panel, 100Ah battery and 1000W inverter. '
            'Installation can be arranged.',
        category: 'Electronics & Appliances',
        subcategory: 'Security & Surveillance',
        price: 890,
        currency: ListingCurrency.usd,
        condition: ListingCondition.brandNew,
        images: <String>[_photo('solar-a'), _photo('solar-b')],
        city: 'Juba',
        area: 'Gudele',
        sellerId: 'usr_105',
        sellerName: 'Lado Hardware',
        sellerAvatarUrl: _avatar(52),
        attributes: const <String, String>{
          'Panel': '300W',
          'Battery': '100Ah',
          'Inverter': '1000W',
        },
        views: 830,
        saves: 88,
        inquiries: 21,
        promoted: true,
        promotedUntil: now.add(const Duration(days: 3)),
        createdAt: ago(140),
      ),
      Listing(
        id: 'lst_011',
        title: 'Ten healthy goats for sale',
        description:
            'Mixed ages, all vaccinated. Can sell individually or as a '
            'group. Transport available at a fee.',
        category: 'Farm & Agriculture',
        subcategory: 'Livestock',
        price: 1450000,
        currency: ListingCurrency.ssp,
        priceUsdAtPost: 1115,
        condition: ListingCondition.brandNew,
        images: <String>[_photo('goats-a')],
        city: 'Bor',
        area: 'Marol',
        sellerId: 'usr_107',
        sellerName: 'Majok Farm',
        sellerAvatarUrl: _avatar(61),
        negotiable: true,
        attributes: const <String, String>{
          'Quantity': '10',
          'Vaccinated': 'Yes',
        },
        views: 560,
        saves: 41,
        inquiries: 17,
        createdAt: ago(168),
      ),
      Listing(
        id: 'lst_012',
        title: 'Event photography and videography',
        description:
            'Weddings, graduations and corporate events. Full day package '
            'includes edited photos and a highlight video.',
        category: 'Services',
        subcategory: 'Creative & Media',
        price: 350,
        currency: ListingCurrency.usd,
        condition: ListingCondition.brandNew,
        images: <String>[_photo('photography-a'), _photo('photography-b')],
        city: 'Juba',
        area: 'Hai Cinema',
        sellerId: 'usr_108',
        sellerName: 'Juba Frames Studio',
        sellerAvatarUrl: _avatar(19),
        sellerVerified: true,
        negotiable: true,
        attributes: const <String, String>{
          'Service': 'Photo and video',
          'Duration': 'Full day',
          'Delivery': '7 days',
        },
        views: 690,
        saves: 72,
        inquiries: 24,
        createdAt: ago(200),
      ),
    ];
  }
}
