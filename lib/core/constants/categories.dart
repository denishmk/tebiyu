import 'package:flutter/material.dart';

/// A subcategory within a [TebiyuCategory].
@immutable
class Subcategory {
  /// Creates a subcategory that has artwork.
  const Subcategory(this.name, this.slug, {this.imageExtension = 'jpg'});

  /// Creates a subcategory with no artwork yet.
  ///
  /// The Category screen falls back to a tinted tile carrying the parent
  /// category's icon rather than rendering a gap.
  const Subcategory.withoutImage(this.name, this.slug) : imageExtension = null;

  /// Display name, for example Mobile Phones.
  final String name;

  /// Stable identifier used in routes, Firestore queries and asset paths.
  final String slug;

  /// File extension of the artwork, or null when there is none.
  final String? imageExtension;

  /// Whether artwork exists for this subcategory.
  bool get hasImage => imageExtension != null;
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

  /// Display name, shown to users.
  ///
  /// Safe to reword: listings store [slug], not this.
  final String name;

  /// Stable identifier stored on every listing.
  ///
  /// Never change one after listings exist. A rename orphans every listing
  /// filed under the old value, and there is no cheap migration.
  final String slug;

  /// Fallback icon, used where artwork is missing or a tile is too small to
  /// carry a photograph.
  final IconData icon;

  /// The subcategories filed under this category.
  final List<Subcategory> subcategories;

  /// Path to the category artwork.
  String get imagePath => 'assets/images/categories/main/$slug.png';

  /// Path to [subcategory]'s artwork, or null when it has none.
  String? imagePathFor(Subcategory subcategory) {
    if (!subcategory.hasImage) return null;
    return 'assets/images/categories/sub/$slug/'
        '${subcategory.slug}.${subcategory.imageExtension}';
  }

  /// A short label for the home category row, where the full name will not
  /// fit under a small tile.
  String get shortName => Categories.shortNames[slug] ?? name;
}

/// Tebiyu's category taxonomy.
///
/// Single source of truth for the home category row, the Category screen, the
/// listing form's picker and the admin panel. Item counts are deliberately
/// absent: those come from Firestore at read time, since a hardcoded count is
/// wrong the moment anyone posts.
abstract final class Categories {
  /// Every category, in display order.
  static const List<TebiyuCategory> all = <TebiyuCategory>[
    TebiyuCategory(
      name: 'Electronics & Appliances',
      slug: 'electronics_and_appliances',
      icon: Icons.devices,
      subcategories: [
        Subcategory('Computers & Laptops', 'computers_and_laptops'),
        Subcategory('Computer Accessories', 'computer_accessories'),
        Subcategory('TV & Video Equipment', 'tv_and_video_equipment'),
        Subcategory('Audio Devices', 'audio_devices'),
        Subcategory('Camera & Lenses', 'camera_and_lenses'),
        Subcategory('Printers & Scanners', 'printers_and_scanners'),
        Subcategory('Networking Products', 'networking_products'),
        Subcategory('Washing Machines', 'washing_machines'),
        Subcategory('Security & Surveillance', 'security_and_surveillance'),
        Subcategory('Gaming & Consoles', 'gaming_and_consoles'),
        Subcategory('Kitchen Appliances', 'kitchen_appliances'),
        Subcategory('Content Creation Gear', 'content_creation_equipment'),
      ],
    ),
    TebiyuCategory(
      name: 'Mobile Phones & Accessories',
      slug: 'mobile_phones_and_accessories',
      icon: Icons.smartphone,
      subcategories: [
        Subcategory('Mobile Phones', 'mobile_phones'),
        Subcategory('Cases, Covers & Skins', 'cases_covers_and_skins'),
        Subcategory('Chargers & Cables', 'chargers_and_cables'),
        Subcategory('Power Banks', 'power_banks'),
        Subcategory('Headphones & Earbuds', 'headphones_and_earbuds'),
        Subcategory('Bluetooth Speakers', 'bluetooth_speakers'),
        Subcategory('Car Accessories', 'car_accessories'),
        Subcategory('Memory Cards', 'memory_cards'),
        Subcategory('Batteries', 'batteries_replacement'),
        Subcategory('Selfie Sticks & Tripods', 'selfie_sticks_and_tripods'),
        Subcategory('Wearables', 'wearables'),
      ],
    ),
    TebiyuCategory(
      name: 'Properties',
      slug: 'properties',
      icon: Icons.apartment,
      subcategories: [
        Subcategory('Land & Plots', 'land_and_plots'),
        Subcategory('Houses', 'houses'),
        Subcategory('Apartments', 'apartments'),
        Subcategory('Commercial Properties', 'commercial_properties'),
      ],
    ),
    TebiyuCategory(
      name: 'Home & Garden',
      slug: 'home_and_garden',
      icon: Icons.chair_outlined,
      subcategories: [
        Subcategory('Furniture', 'furniture'),
        Subcategory('Kitchen & Dining', 'kitchen_and_dining'),
        Subcategory('Home Décor', 'home_decor'),
        Subcategory('Lighting', 'lighting'),
        Subcategory('Household Essentials', 'household_essentials'),
        Subcategory('Bedding & Linen', 'bedding_and_linen'),
        Subcategory('Home Security & Safety', 'home_security_and_safety'),
        Subcategory('Home Appliances', 'home_appliances'),
      ],
    ),
    TebiyuCategory(
      name: 'Fashion',
      slug: 'fashion',
      icon: Icons.checkroom,
      subcategories: [
        Subcategory('Clothing', 'clothing'),
        Subcategory('Footwear', 'footwear'),
        Subcategory('Bags & Luggage', 'bags_and_luggage'),
        Subcategory('Jewelry & Accessories', 'jewelry_and_accessories'),
        Subcategory('Fashion Accessories', 'fashion_accessories'),
        Subcategory('Outerwear', 'outerwear'),
        Subcategory('Designer Fashion', 'designer_fashion'),
        Subcategory('Tailoring & Custom', 'tailoring_and_custom_fashion'),
        Subcategory('Second-hand Fashion', 'second_hand_fashion'),
      ],
    ),
    TebiyuCategory(
      name: 'Vehicles',
      slug: 'vehicles',
      icon: Icons.directions_car_outlined,
      subcategories: [
        Subcategory('Cars', 'cars'),
        Subcategory('SUVs', 'suv'),
        Subcategory('Pickup Trucks', 'pickup_trucks'),
        Subcategory('Vans', 'vans'),
        Subcategory('Buses', 'buses'),
        Subcategory('Motorcycles', 'motorcycles'),
        Subcategory('Tuk-tuk & Cargo', 'tuk_tuk_and_cargo'),
        Subcategory('Bicycles', 'bicycle'),
        Subcategory('Heavy Machinery', 'heavy_machinery'),
      ],
    ),
    TebiyuCategory(
      name: 'Farm & Agriculture',
      slug: 'farm_and_agriculture',
      icon: Icons.agriculture,
      subcategories: [
        Subcategory('Farmland', 'farmland'),
        Subcategory('Livestock', 'livestock'),
        Subcategory('Produce', 'produce'),
        Subcategory('Farm Equipment', 'equipment'),
        Subcategory('Seeds & Fertilizers', 'seeds_and_fertilizers'),
      ],
    ),
    TebiyuCategory(
      name: 'Beauty & Personal Care',
      slug: 'beauty_and_personal_care',
      icon: Icons.spa_outlined,
      subcategories: [
        Subcategory('Personal Care', 'personal_care'),
        Subcategory('Body Care', 'body_care'),
        Subcategory('Oral Care', 'oral_care'),
        Subcategory('Skin Care', 'skin_care'),
        Subcategory('Fragrance', 'fragrance'),
        Subcategory('Nail Care', 'nail_care'),
        Subcategory('Wigs & Hair Care', 'wigs_and_hair_care'),
        Subcategory('Watches & Wearables', 'watches_and_wearables'),
        Subcategory('Eyeglasses', 'eye_glasses'),
      ],
    ),
    TebiyuCategory(
      name: 'Sports & Leisure',
      slug: 'sports_and_leisure',
      icon: Icons.sports_soccer,
      subcategories: [
        Subcategory('Sport Equipment', 'sport_equipment'),
        Subcategory('Fitness & Gym Equipment', 'fitness_and_gym_equipment'),
        Subcategory('Outdoor & Camping', 'outdoor_and_camping'),
        Subcategory('Cycling', 'cycling'),
        Subcategory('Water Sports', 'water_sports'),
        Subcategory('Gaming & Recreation', 'gaming_and_recreation'),
        Subcategory('Sportswear & Accessories', 'sportswear_and_accessories'),
        Subcategory('Musical Instruments', 'musical_instruments'),
        Subcategory('Leisure Activities', 'leisure_activities'),
        Subcategory('Personal Satisfaction', 'personal_satisfaction'),
      ],
    ),
    TebiyuCategory(
      name: 'Services',
      slug: 'services',
      icon: Icons.handyman_outlined,
      subcategories: [
        Subcategory(
          'Event Planning & Materials',
          'event_planning_and_materials',
        ),
        Subcategory('Personal Services', 'personal_care_services'),
        Subcategory('Health & Wellness', 'health_and_wellness_services'),
        Subcategory(
          'Photography & Videography',
          'photography_and_videography_services',
        ),
        Subcategory(
          'IT & Digital Services',
          'it_and_digital_services',
          imageExtension: 'png',
        ),
        Subcategory('Transport & Logistics', 'transport_and_logistics'),
        Subcategory('Repair & Maintenance', 'repair_and_maintenance_services'),
        Subcategory(
          'Construction & Building',
          'construction_and_building_services',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Babies & Kids',
      slug: 'babies_and_kids',
      icon: Icons.child_friendly_outlined,
      subcategories: [
        Subcategory('Baby Gear', 'baby_gear'),
        Subcategory('Nursery Furniture', 'nursery_furniture'),
        Subcategory('Baby & Kid Clothing', 'baby_and_kid_clothing'),
        Subcategory('Toys & Games', 'toys_and_games'),
        Subcategory('Books & School Supplies', 'books_and_school_supplies'),
        Subcategory('Feeding Essentials', 'feeding_essentials'),
        Subcategory('Baby Care & Safety', 'baby_care_and_safety'),
        Subcategory(
          'Maternity & Pregnancy',
          'maternity_and_pregnancy_supplies',
        ),
      ],
    ),
    TebiyuCategory(
      name: 'Commercial Equipment',
      slug: 'commercial_equipment',
      icon: Icons.construction_outlined,
      subcategories: [
        Subcategory('Construction Equipment', 'construction_equipment'),
        Subcategory('Hand & Power Tools', 'hand_and_power_tools'),
        Subcategory('Shop & Retail Equipment', 'shop_and_retail_equipment'),
        Subcategory(
          'Restaurant & Catering',
          'restaurant_and_catering_equipment',
        ),
        Subcategory('Office Equipment', 'office_equipment'),
        Subcategory('Industrial Equipment', 'industrial_equipment'),
        Subcategory('Agricultural Equipment', 'agricultural_equipment'),
        Subcategory(
          'Electrical & Mechanical',
          'electrical_and_mechanical_equipment',
        ),
        Subcategory('Safety Equipment', 'safety_equipment'),
      ],
    ),
    TebiyuCategory(
      name: 'Jobs',
      slug: 'jobs',
      icon: Icons.work_outline,
      // No artwork sourced yet, so these fall back to tinted icon tiles.
      subcategories: [
        Subcategory.withoutImage('Casual Jobs', 'casual_jobs'),
        Subcategory.withoutImage('NGO & INGO Jobs', 'ngo_jobs'),
        Subcategory.withoutImage('Company Jobs', 'company_jobs'),
      ],
    ),
  ];

  /// Short labels for the home category row, keyed by slug.
  ///
  /// Only the long names appear here. Anything absent falls back to its full
  /// name via [TebiyuCategory.shortName].
  static const Map<String, String> shortNames = <String, String>{
    'electronics_and_appliances': 'Electronics',
    'mobile_phones_and_accessories': 'Phones',
    'home_and_garden': 'Home',
    'farm_and_agriculture': 'Farm',
    'beauty_and_personal_care': 'Beauty',
    'sports_and_leisure': 'Sports',
    'babies_and_kids': 'Kids',
    'commercial_equipment': 'Tools',
  };

  /// Finds a category by [slug], or null if there is no match.
  static TebiyuCategory? bySlug(String slug) {
    for (final category in all) {
      if (category.slug == slug) return category;
    }
    return null;
  }

  /// Finds a subcategory anywhere in the taxonomy.
  static ({TebiyuCategory category, Subcategory subcategory})? findSubcategory(
    String slug,
  ) {
    for (final category in all) {
      for (final subcategory in category.subcategories) {
        if (subcategory.slug == slug) {
          return (category: category, subcategory: subcategory);
        }
      }
    }
    return null;
  }
}
