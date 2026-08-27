import 'package:flutter/material.dart';

/// A second level entry beneath a [TebiyuCategory].
///
/// Carries only its file name. The full asset path needs the parent
/// category's folder, so it is built by [TebiyuCategory.subImagePath]
/// rather than stored here, which keeps the folder name in one place.
@immutable
class TebiyuSubcategory {
  /// Creates a subcategory.
  const TebiyuSubcategory({required this.name, required this.file});

  /// Display name, also the value stored on a listing.
  final String name;

  /// Artwork file name, including its extension.
  ///
  /// Extensions vary across the set, so they are recorded rather than
  /// assumed. One wrong extension is a silently missing image.
  final String file;
}

/// A top level category in Tebiyu's taxonomy.
@immutable
class TebiyuCategory {
  /// Creates a category.
  const TebiyuCategory({
    required this.name,
    required this.folder,
    required this.icon,
    required this.subcategories,
  });

  /// Display name, also the value stored on a listing.
  final String name;

  /// Asset folder name for this category.
  final String folder;

  /// Fallback icon, shown when the artwork is missing.
  final IconData icon;

  /// Second level entries beneath this category.
  final List<TebiyuSubcategory> subcategories;

  /// This category's own artwork.
  String get imagePath => '${Categories.mainDirectory}/$folder.png';

  /// Artwork for [subcategory], which must belong to this category.
  String subImagePath(TebiyuSubcategory subcategory) =>
      '${Categories.subDirectory}/$folder/${subcategory.file}';

  /// Short label for tight spaces such as the Home category row.
  String get shortName => Categories.shortNames[name] ?? name;
}

/// Tebiyu's category taxonomy.
///
/// The single source of truth for category and subcategory names. Listings
/// store these strings, so renaming an entry without migrating existing
/// documents orphans every listing that used the old name.
///
/// Entries mirror the bundled artwork exactly. A subcategory with no image
/// still renders, falling back to an icon, but the pairing is deliberate:
/// the taxonomy and the asset folder are meant to stay in step.
abstract final class Categories {
  /// Folder holding top level category artwork.
  static const String mainDirectory = 'assets/images/categories/main';

  /// Folder holding per-category subcategory artwork.
  static const String subDirectory = 'assets/images/categories/sub';

  /// Every top level category, in display order.
  static const List<TebiyuCategory> all = <TebiyuCategory>[
    TebiyuCategory(
      name: 'Electronics & Appliances',
      folder: 'electronics_and_appliances',
      icon: Icons.devices,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(
          name: 'Computers & Laptops',
          file: 'computers_and_laptops.jpg',
        ),
        TebiyuSubcategory(
          name: 'Computer Accessories',
          file: 'computer_accessories.jpg',
        ),
        TebiyuSubcategory(
          name: 'TV & Video Equipment',
          file: 'tv_and_video_equipment.jpg',
        ),
        TebiyuSubcategory(name: 'Audio Devices', file: 'audio_devices.jpg'),
        TebiyuSubcategory(
          name: 'Camera & Lenses',
          file: 'camera_and_lenses.jpg',
        ),
        TebiyuSubcategory(
          name: 'Printers & Scanners',
          file: 'printers_and_scanners.jpg',
        ),
        TebiyuSubcategory(
          name: 'Networking Products',
          file: 'networking_products.jpg',
        ),
        TebiyuSubcategory(
          name: 'Washing Machines',
          file: 'washing_machines.jpg',
        ),
        TebiyuSubcategory(
          name: 'Security & Surveillance',
          file: 'security_and_surveillance.jpg',
        ),
        TebiyuSubcategory(
          name: 'Gaming & Consoles',
          file: 'gaming_and_consoles.jpg',
        ),
        TebiyuSubcategory(
          name: 'Kitchen Appliances',
          file: 'kitchen_appliances.jpg',
        ),
        TebiyuSubcategory(
          name: 'Content Creation Equipment',
          file: 'content_creation_equipment.jpg',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Mobile Phones & Accessories',
      folder: 'mobile_phones_and_accessories',
      icon: Icons.smartphone,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Mobile Phones', file: 'mobile_phones.jpg'),
        TebiyuSubcategory(
          name: 'Cases, Covers & Skins',
          file: 'cases_covers_and_skins.jpg',
        ),
        TebiyuSubcategory(
          name: 'Chargers & Cables',
          file: 'chargers_and_cables.jpg',
        ),
        TebiyuSubcategory(name: 'Power Banks', file: 'power_banks.jpg'),
        TebiyuSubcategory(
          name: 'Headphones & Earbuds',
          file: 'headphones_and_earbuds.jpg',
        ),
        TebiyuSubcategory(
          name: 'Bluetooth Speakers',
          file: 'bluetooth_speakers.jpg',
        ),
        TebiyuSubcategory(name: 'Car Accessories', file: 'car_accessories.jpg'),
        TebiyuSubcategory(name: 'Memory Cards', file: 'memory_cards.jpg'),
        TebiyuSubcategory(
          name: 'Replacement Batteries',
          file: 'batteries_replacement.jpg',
        ),
        TebiyuSubcategory(
          name: 'Selfie Sticks & Tripods',
          file: 'selfie_sticks_and_tripods.jpg',
        ),
        TebiyuSubcategory(name: 'Wearables', file: 'wearables.jpg'),
      ],
    ),
    TebiyuCategory(
      name: 'Properties',
      folder: 'properties',
      icon: Icons.apartment,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Land & Plots', file: 'land_and_plots.jpg'),
        TebiyuSubcategory(name: 'Houses', file: 'houses.jpg'),
        TebiyuSubcategory(name: 'Apartments', file: 'apartments.jpg'),
        TebiyuSubcategory(
          name: 'Commercial Properties',
          file: 'commercial_properties.jpg',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Home & Garden',
      folder: 'home_and_garden',
      icon: Icons.chair_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Furniture', file: 'furniture.jpg'),
        TebiyuSubcategory(
          name: 'Kitchen & Dining',
          file: 'kitchen_and_dining.jpg',
        ),
        TebiyuSubcategory(name: 'Home Décor', file: 'home_decor.jpg'),
        TebiyuSubcategory(name: 'Lighting', file: 'lighting.jpg'),
        TebiyuSubcategory(
          name: 'Household Essentials',
          file: 'household_essentials.jpg',
        ),
        TebiyuSubcategory(
          name: 'Bedding & Linen',
          file: 'bedding_and_linen.jpg',
        ),
        TebiyuSubcategory(
          name: 'Home Security & Safety',
          file: 'home_security_and_safety.jpg',
        ),
        TebiyuSubcategory(name: 'Home Appliances', file: 'home_appliances.jpg'),
      ],
    ),
    TebiyuCategory(
      name: 'Fashion',
      folder: 'fashion',
      icon: Icons.checkroom,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Clothing', file: 'clothing.jpg'),
        TebiyuSubcategory(name: 'Footwear', file: 'footwear.jpg'),
        TebiyuSubcategory(name: 'Bags & Luggage', file: 'bags_and_luggage.jpg'),
        TebiyuSubcategory(
          name: 'Jewelry & Accessories',
          file: 'jewelry_and_accessories.jpg',
        ),
        TebiyuSubcategory(
          name: 'Fashion Accessories',
          file: 'fashion_accessories.jpg',
        ),
        TebiyuSubcategory(name: 'Outerwear', file: 'outerwear.jpg'),
        TebiyuSubcategory(
          name: 'Designer Fashion',
          file: 'designer_fashion.jpg',
        ),
        TebiyuSubcategory(
          name: 'Tailoring & Custom Fashion',
          file: 'tailoring_and_custom_fashion.jpg',
        ),
        TebiyuSubcategory(
          name: 'Second-hand Fashion',
          file: 'second_hand_fashion.jpg',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Vehicles',
      folder: 'vehicles',
      icon: Icons.directions_car_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Cars', file: 'cars.jpg'),
        TebiyuSubcategory(name: 'SUV', file: 'suv.jpg'),
        TebiyuSubcategory(name: 'Pickup Trucks', file: 'pickup_trucks.jpg'),
        TebiyuSubcategory(name: 'Vans', file: 'vans.jpg'),
        TebiyuSubcategory(name: 'Buses', file: 'buses.jpg'),
        TebiyuSubcategory(name: 'Motorcycles', file: 'motorcycles.jpg'),
        TebiyuSubcategory(
          name: 'Tuk-tuk & Cargo',
          file: 'tuk_tuk_and_cargo.jpg',
        ),
        TebiyuSubcategory(name: 'Bicycle', file: 'bicycle.jpg'),
        TebiyuSubcategory(name: 'Heavy Machinery', file: 'heavy_machinery.jpg'),
      ],
    ),
    TebiyuCategory(
      name: 'Farm & Agriculture',
      folder: 'farm_and_agriculture',
      icon: Icons.agriculture,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Farmland', file: 'farmland.jpg'),
        TebiyuSubcategory(name: 'Livestock', file: 'livestock.jpg'),
        TebiyuSubcategory(name: 'Produce', file: 'produce.jpg'),
        TebiyuSubcategory(name: 'Equipment', file: 'equipment.jpg'),
        TebiyuSubcategory(
          name: 'Seeds & Fertilizers',
          file: 'seeds_and_fertilizers.jpg',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Beauty & Personal Care',
      folder: 'beauty_and_personal_care',
      icon: Icons.spa_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Personal Care', file: 'personal_care.jpg'),
        TebiyuSubcategory(name: 'Body Care', file: 'body_care.jpg'),
        TebiyuSubcategory(name: 'Oral Care', file: 'oral_care.jpg'),
        TebiyuSubcategory(name: 'Skin Care', file: 'skin_care.jpg'),
        TebiyuSubcategory(name: 'Fragrance', file: 'fragrance.jpg'),
        TebiyuSubcategory(name: 'Nail Care', file: 'nail_care.jpg'),
        TebiyuSubcategory(
          name: 'Wigs & Hair Care',
          file: 'wigs_and_hair_care.jpg',
        ),
        TebiyuSubcategory(
          name: 'Watches & Wearables',
          file: 'watches_and_wearables.jpg',
        ),
        TebiyuSubcategory(name: 'Eye Glasses', file: 'eye_glasses.jpg'),
      ],
    ),
    TebiyuCategory(
      name: 'Sports & Leisure',
      folder: 'sports_and_leisure',
      icon: Icons.sports_soccer,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Sport Equipment', file: 'sport_equipment.jpg'),
        TebiyuSubcategory(
          name: 'Fitness & Gym Equipment',
          file: 'fitness_and_gym_equipment.jpg',
        ),
        TebiyuSubcategory(
          name: 'Outdoor & Camping',
          file: 'outdoor_and_camping.jpg',
        ),
        TebiyuSubcategory(name: 'Cycling', file: 'cycling.jpg'),
        TebiyuSubcategory(name: 'Water Sports', file: 'water_sports.jpg'),
        TebiyuSubcategory(
          name: 'Gaming & Recreation',
          file: 'gaming_and_recreation.jpg',
        ),
        TebiyuSubcategory(
          name: 'Sportswear & Accessories',
          file: 'sportswear_and_accessories.jpg',
        ),
        TebiyuSubcategory(
          name: 'Musical Instruments',
          file: 'musical_instruments.jpg',
        ),
        TebiyuSubcategory(
          name: 'Leisure Activities',
          file: 'leisure_activities.jpg',
        ),
        TebiyuSubcategory(
          name: 'Personal Satisfaction',
          file: 'personal_satisfaction.jpg',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Services',
      folder: 'services',
      icon: Icons.handyman_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(
          name: 'Event Planning & Materials',
          file: 'event_planning_and_materials.jpg',
        ),
        TebiyuSubcategory(
          name: 'Personal Care Services',
          file: 'personal_care_services.jpg',
        ),
        TebiyuSubcategory(
          name: 'Health & Wellness Services',
          file: 'health_and_wellness_services.jpg',
        ),
        TebiyuSubcategory(
          name: 'Photography & Videography',
          file: 'photography_and_videography_services.jpg',
        ),
        TebiyuSubcategory(
          name: 'IT & Digital Services',
          file: 'it_and_digital_services.png',
        ),
        TebiyuSubcategory(
          name: 'Transport & Logistics',
          file: 'transport_and_logistics.jpg',
        ),
        TebiyuSubcategory(
          name: 'Repair & Maintenance',
          file: 'repair_and_maintenance_services.jpg',
        ),
        TebiyuSubcategory(
          name: 'Construction & Building',
          file: 'construction_and_building_services.jpg',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Babies & Kids',
      folder: 'babies_and_kids',
      icon: Icons.child_friendly_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Baby Gear', file: 'baby_gear.jpg'),
        TebiyuSubcategory(
          name: 'Nursery Furniture',
          file: 'nursery_furniture.jpg',
        ),
        TebiyuSubcategory(
          name: 'Baby & Kid Clothing',
          file: 'baby_and_kid_clothing.jpg',
        ),
        TebiyuSubcategory(name: 'Toys & Games', file: 'toys_and_games.jpg'),
        TebiyuSubcategory(
          name: 'Books & School Supplies',
          file: 'books_and_school_supplies.jpg',
        ),
        TebiyuSubcategory(
          name: 'Feeding Essentials',
          file: 'feeding_essentials.jpg',
        ),
        TebiyuSubcategory(
          name: 'Baby Care & Safety',
          file: 'baby_care_and_safety.jpg',
        ),
        TebiyuSubcategory(
          name: 'Maternity & Pregnancy',
          file: 'maternity_and_pregnancy_supplies.jpg',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Commercial Equipment',
      folder: 'commercial_equipment',
      icon: Icons.construction_outlined,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(
          name: 'Construction Equipment',
          file: 'construction_equipment.jpg',
        ),
        TebiyuSubcategory(
          name: 'Hand & Power Tools',
          file: 'hand_and_power_tools.jpg',
        ),
        TebiyuSubcategory(
          name: 'Shop & Retail Equipment',
          file: 'shop_and_retail_equipment.jpg',
        ),
        TebiyuSubcategory(
          name: 'Restaurant & Catering',
          file: 'restaurant_and_catering_equipment.jpg',
        ),
        TebiyuSubcategory(
          name: 'Office Equipment',
          file: 'office_equipment.jpg',
        ),
        TebiyuSubcategory(
          name: 'Industrial Equipment',
          file: 'industrial_equipment.jpg',
        ),
        TebiyuSubcategory(
          name: 'Agricultural Equipment',
          file: 'agricultural_equipment.jpg',
        ),
        TebiyuSubcategory(
          name: 'Electrical & Mechanical',
          file: 'electrical_and_mechanical_equipment.jpg',
        ),
        TebiyuSubcategory(
          name: 'Safety Equipment',
          file: 'safety_equipment.jpg',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Jobs',
      folder: 'jobs',
      icon: Icons.work_outline,
      subcategories: <TebiyuSubcategory>[
        TebiyuSubcategory(name: 'Casual Jobs', file: 'casual_jobs.jpg'),
        TebiyuSubcategory(name: 'NGO & INGO Jobs', file: 'ngo_jobs.jpg'),
        TebiyuSubcategory(name: 'Company Jobs', file: 'company_jobs.jpg'),
      ],
    ),
  ];

  /// Short labels for tight spaces. Absent names use their full form.
  static const Map<String, String> shortNames = <String, String>{
    'Electronics & Appliances': 'Electronics',
    'Mobile Phones & Accessories': 'Phones',
    'Home & Garden': 'Home',
    'Farm & Agriculture': 'Farm',
    'Beauty & Personal Care': 'Beauty',
    'Sports & Leisure': 'Sports',
    'Babies & Kids': 'Kids',
    'Commercial Equipment': 'Tools',
  };

  /// The category called [name], or null when there is no such category.
  static TebiyuCategory? byName(String name) {
    for (final category in all) {
      if (category.name == name) return category;
    }
    return null;
  }
}
