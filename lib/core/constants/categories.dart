import 'package:flutter/material.dart';

/// A second level entry beneath a [TebiyuCategory].
@immutable
class TebiyuSubcategory {
  /// Creates a subcategory.
  const TebiyuSubcategory({required this.name, required this.slug});

  /// Display name, also the value stored on a listing.
  final String name;

  /// File-safe identifier, used to locate this subcategory's artwork.
  ///
  /// Also the right value to put in a URL when subcategory deep links
  /// arrive, which is why it is stored rather than derived from [name]:
  /// deriving would break every link the moment a name is reworded.
  final String slug;

  /// Bundled image for this subcategory.
  String get imagePath => Categories.assetPathFor(slug);
}

/// A top level category in Tebiyu's taxonomy.
@immutable
class TebiyuCategory {
  /// Creates a category.
  const TebiyuCategory({
    required this.name,
    required this.slug,
    required this.icon,
    required this.subcategories,
  });

  /// Display name, also the value stored on a listing.
  final String name;

  /// Fallback icon, shown when [imagePath] has no bundled file yet.
  final IconData icon;

  /// Second level entries beneath this category.
  final List<TebiyuSubcategory> subcategories;

  /// File-safe identifier, used to locate this category's artwork.
  final String slug;

  /// Bundled image for this category.
  String get imagePath => Categories.assetPathFor(slug);

  /// Short label for tight spaces such as the Home category row.
  ///
  /// Falls back to [name] when no abbreviation is needed.
  String get shortName => Categories.shortNames[name] ?? name;
}

/// Tebiyu's category taxonomy.
///
/// The single source of truth for category and subcategory names. Listings
/// store these strings, so renaming an entry without migrating existing
/// documents orphans every listing that used the old name.
///
/// Held as Dart constants rather than a JSON asset. These names are needed
/// at compile time by the router, the listing form and the admin filters,
/// and a typo in a constant is a build error where a typo in JSON is a
/// silent empty screen. The trade-off is that changing the taxonomy needs a
/// release, which is the right constraint while listings reference these
/// values by name.
abstract final class Categories {
  /// Every top level category, in display order.
  static const List<TebiyuCategory> all = <TebiyuCategory>[
    TebiyuCategory(
      name: 'Electronics & Appliances',
      slug: 'electronics',
      icon: Icons.devices,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Computers & Laptops', slug: 'laptops'),
        TebiyuSubcategory(
          name: 'Computer Accessories',
          slug: 'pcaccessories',
        ),
        TebiyuSubcategory(name: 'TV & Video Equipment', slug: 'tvvideo'),
        TebiyuSubcategory(name: 'Audio Devices', slug: 'audiodevices'),
        TebiyuSubcategory(name: 'Camera & Lenses', slug: 'cameras'),
        TebiyuSubcategory(name: 'Printers & Scanners', slug: 'printers'),
        TebiyuSubcategory(
          name: 'Networking Products',
          slug: 'networking',
        ),
        TebiyuSubcategory(name: 'Washing Machines', slug: 'washing'),
        TebiyuSubcategory(
          name: 'Security & Surveillance',
          slug: 'security',
        ),
        TebiyuSubcategory(
          name: 'Refrigerators & Freezers',
          slug: 'fridges',
        ),
        TebiyuSubcategory(name: 'Gaming Consoles', slug: 'consoles'),
        TebiyuSubcategory(name: 'Kitchen Appliances', slug: 'kitchenapp'),
        TebiyuSubcategory(
          name: 'Content Creation Gear',
          slug: 'contentgear',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Mobile Phones & Accessories',
      slug: 'mobilephones',
      icon: Icons.smartphone,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Mobile Phones', slug: 'phones'),
        TebiyuSubcategory(
          name: 'Cases, Covers & Skins',
          slug: 'phonecases',
        ),
        TebiyuSubcategory(name: 'Screen Protectors', slug: 'protectors'),
        TebiyuSubcategory(name: 'Chargers & Cables', slug: 'chargers'),
        TebiyuSubcategory(name: 'Power Banks', slug: 'powerbanks'),
        TebiyuSubcategory(
          name: 'Headphones & Earbuds',
          slug: 'headphones',
        ),
        TebiyuSubcategory(name: 'Bluetooth Speakers', slug: 'speakers'),
        TebiyuSubcategory(name: 'Car Accessories', slug: 'caraccess'),
        TebiyuSubcategory(name: 'Memory Cards', slug: 'memorycards'),
        TebiyuSubcategory(name: 'Replacement Batteries', slug: 'batts'),
        TebiyuSubcategory(
          name: 'Selfie Sticks & Tripods',
          slug: 'tripods',
        ),
        TebiyuSubcategory(name: 'Wearables', slug: 'wearables'),
      ],
    ),
    TebiyuCategory(
      name: 'Properties',
      slug: 'properties',
      icon: Icons.apartment,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Land & Plots', slug: 'land'),
        TebiyuSubcategory(name: 'Houses', slug: 'houses'),
        TebiyuSubcategory(name: 'Apartments', slug: 'apartments'),
        TebiyuSubcategory(
          name: 'Commercial Properties',
          slug: 'commercialprop',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Home & Garden',
      slug: 'homegarden',
      icon: Icons.chair_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Furniture', slug: 'furniture'),
        TebiyuSubcategory(name: 'Kitchen & Dining', slug: 'kitchendine'),
        TebiyuSubcategory(name: 'Home Décor', slug: 'decor'),
        TebiyuSubcategory(name: 'Lighting', slug: 'lighting'),
        TebiyuSubcategory(
          name: 'Household Essentials',
          slug: 'household',
        ),
        TebiyuSubcategory(name: 'Bedding & Linen', slug: 'bedding'),
        TebiyuSubcategory(
          name: 'Home Security & Safety',
          slug: 'homesafety',
        ),
        TebiyuSubcategory(name: 'Pet Supplies', slug: 'petsupplies'),
        TebiyuSubcategory(name: 'Garden & Outdoor', slug: 'garden'),
      ],
    ),
    TebiyuCategory(
      name: 'Fashion',
      slug: 'fashion',
      icon: Icons.checkroom,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Clothing', slug: 'clothing'),
        TebiyuSubcategory(name: 'Footwear', slug: 'footwear'),
        TebiyuSubcategory(name: 'Bags & Luggage', slug: 'bags'),
        TebiyuSubcategory(name: 'Jewelry & Accessories', slug: 'jewelry'),
        TebiyuSubcategory(name: 'Outerwear', slug: 'outerwear'),
        TebiyuSubcategory(name: 'Designer & Luxury', slug: 'designer'),
        TebiyuSubcategory(name: 'Tailoring & Custom', slug: 'tailoring'),
        TebiyuSubcategory(
          name: 'Second-hand Fashion',
          slug: 'secondhand',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Vehicles',
      slug: 'vehicles',
      icon: Icons.directions_car_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Cars', slug: 'cars'),
        TebiyuSubcategory(name: 'SUV', slug: 'suv'),
        TebiyuSubcategory(name: 'Pickup Trucks', slug: 'pickups'),
        TebiyuSubcategory(name: 'Vans', slug: 'vans'),
        TebiyuSubcategory(name: 'Buses', slug: 'buses'),
        TebiyuSubcategory(name: 'Motorcycles', slug: 'motorcycles'),
        TebiyuSubcategory(name: 'Tuk-tuk', slug: 'tuktuk'),
        TebiyuSubcategory(name: 'Bicycles', slug: 'bicycles'),
        TebiyuSubcategory(name: 'Heavy Machinery', slug: 'heavymach'),
      ],
    ),
    TebiyuCategory(
      name: 'Farm & Agriculture',
      slug: 'farm',
      icon: Icons.agriculture,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Farmland', slug: 'farmland'),
        TebiyuSubcategory(name: 'Livestock', slug: 'livestock'),
        TebiyuSubcategory(name: 'Produce', slug: 'produce'),
        TebiyuSubcategory(name: 'Farm Equipment', slug: 'farmequip'),
        TebiyuSubcategory(name: 'Seeds & Fertilizers', slug: 'seeds'),
      ],
    ),
    TebiyuCategory(
      name: 'Beauty & Personal Care',
      slug: 'beauty',
      icon: Icons.spa_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Personal Care', slug: 'personalcare'),
        TebiyuSubcategory(name: 'Body Care', slug: 'bodycare'),
        TebiyuSubcategory(name: 'Oral Care', slug: 'oralcare'),
        TebiyuSubcategory(name: 'Skin Care', slug: 'skincare'),
        TebiyuSubcategory(name: 'Fragrance', slug: 'fragrance'),
        TebiyuSubcategory(name: 'Nail Care', slug: 'nailcare'),
        TebiyuSubcategory(name: 'Wigs & Hair Care', slug: 'haircare'),
        TebiyuSubcategory(name: 'Eyeglasses', slug: 'eyeglasses'),
      ],
    ),
    TebiyuCategory(
      name: 'Sports & Leisure',
      slug: 'sports',
      icon: Icons.sports_soccer,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Sports Equipment', slug: 'sportsequip'),
        TebiyuSubcategory(name: 'Fitness & Gym', slug: 'gym'),
        TebiyuSubcategory(name: 'Outdoor & Camping', slug: 'camping'),
        TebiyuSubcategory(name: 'Cycling', slug: 'cycling'),
        TebiyuSubcategory(name: 'Water Sports', slug: 'watersports'),
        TebiyuSubcategory(name: 'Gaming & Recreation', slug: 'gaming'),
        TebiyuSubcategory(name: 'Sportswear', slug: 'sportswear'),
        TebiyuSubcategory(
          name: 'Musical Instruments',
          slug: 'instruments',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Services',
      slug: 'services',
      icon: Icons.handyman_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Event Services', slug: 'events'),
        TebiyuSubcategory(name: 'Personal Services', slug: 'personalsvc'),
        TebiyuSubcategory(name: 'Health & Wellness', slug: 'wellness'),
        TebiyuSubcategory(name: 'Photo & Video', slug: 'photovideo'),
        TebiyuSubcategory(name: 'IT & Digital', slug: 'itdigital'),
        TebiyuSubcategory(
          name: 'Transport & Logistics',
          slug: 'logistics',
        ),
        TebiyuSubcategory(name: 'Repair & Maintenance', slug: 'repairs'),
        TebiyuSubcategory(
          name: 'Construction & Building',
          slug: 'buildingsvc',
        ),
        TebiyuSubcategory(name: 'Cleaning Services', slug: 'cleaning'),
      ],
    ),
    TebiyuCategory(
      name: 'Baby & Kids',
      slug: 'babykids',
      icon: Icons.child_friendly_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Baby Gear', slug: 'babygear'),
        TebiyuSubcategory(name: 'Nursery Furniture', slug: 'nursery'),
        TebiyuSubcategory(name: 'Baby & Kid Clothing', slug: 'kidcloth'),
        TebiyuSubcategory(name: 'Toys & Games', slug: 'toys'),
        TebiyuSubcategory(name: 'Books & School', slug: 'schoolbooks'),
        TebiyuSubcategory(name: 'Feeding Essentials', slug: 'feeding'),
        TebiyuSubcategory(name: 'Baby Care & Safety', slug: 'babysafety'),
        TebiyuSubcategory(
          name: 'Maternity & Pregnancy',
          slug: 'maternity',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Commercial Equipment & Tools',
      slug: 'commercial',
      icon: Icons.construction_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(
          name: 'Construction Equipment',
          slug: 'constequip',
        ),
        TebiyuSubcategory(name: 'Hand & Power Tools', slug: 'powertools'),
        TebiyuSubcategory(name: 'Shop & Retail', slug: 'retailequip'),
        TebiyuSubcategory(name: 'Restaurant & Catering', slug: 'catering'),
        TebiyuSubcategory(name: 'Office Equipment', slug: 'officeequip'),
        TebiyuSubcategory(
          name: 'Industrial Equipment',
          slug: 'industrial',
        ),
        TebiyuSubcategory(
          name: 'Electrical & Mechanical',
          slug: 'electrical',
        ),
        TebiyuSubcategory(name: 'Safety Equipment', slug: 'safetyequip'),
      ],
    ),
    TebiyuCategory(
      name: 'Jobs',
      slug: 'jobs',
      icon: Icons.work_outline,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Casual Jobs', slug: 'casualjobs'),
        TebiyuSubcategory(name: 'NGO & INGO Jobs', slug: 'ngojobs'),
        TebiyuSubcategory(name: 'Company Jobs', slug: 'companyjobs'),
      ],
    ),
  ];

  /// Directory holding category and subcategory artwork.
  static const String assetDirectory = 'assets/images/categories';

  /// Extension used by every category image.
  ///
  /// WebP rather than PNG: roughly a third of the size at the same visual
  /// quality, which matters when a hundred-odd images ship in the APK and
  /// the target device is a mid-range Android on a metered connection.
  static const String assetExtension = 'webp';

  /// The bundled image path for [slug].
  static String assetPathFor(String slug) =>
      '$assetDirectory/$slug.$assetExtension';

  /// A short label for the Home category row, where full names do not fit.
  ///
  /// Only long names are shortened. Anything absent falls back to its full
  /// name.
  static const Map<String, String> shortNames = <String, String>{
    'Electronics & Appliances': 'Electronics',
    'Mobile Phones & Accessories': 'Phones',
    'Home & Garden': 'Home',
    'Farm & Agriculture': 'Farm',
    'Beauty & Personal Care': 'Beauty',
    'Sports & Leisure': 'Sports',
    'Baby & Kids': 'Kids',
    'Commercial Equipment & Tools': 'Tools',
  };

  /// The short label for [name].
  static String shortNameOf(String name) => shortNames[name] ?? name;

  /// The category called [name], or null when there is no such category.
  static TebiyuCategory? byName(String name) {
    for (final category in all) {
      if (category.name == name) return category;
    }
    return null;
  }
}
