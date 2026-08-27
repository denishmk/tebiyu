import 'package:flutter/material.dart';

/// What a filter acts on.
enum FilterTarget {
  /// The sale, rent or lease flag on the listing itself.
  offerType,

  /// The price range.
  price,

  /// The condition enum.
  condition,

  /// The negotiable flag.
  negotiable,

  /// Whether the seller offers delivery.
  delivery,

  /// Individual, business or verified seller.
  sellerType,

  /// How recently the listing was posted.
  datePosted,

  /// Whether the listing has photos.
  hasPhotos,

  /// A key inside the listing's `attributes` map.
  attribute,
}

/// How a filter value is entered.
enum FilterInput {
  /// Pick one of a fixed set of values.
  choice,

  /// Pick any number of a fixed set of values.
  multiChoice,

  /// Enter a numeric low and high bound.
  range,

  /// On or off.
  flag,
}

/// One filter offered on a results screen.
///
/// Also the source of truth for the listing form in P3.1: a seller is asked
/// for exactly the fields a buyer can filter on. Keeping one definition
/// means the two cannot drift, which is how marketplaces end up with
/// filters that match nothing because sellers were never asked.
///
/// Generated from the Tebiyu filter taxonomy. Free-text fields in that
/// document are deliberately absent: a filter over free text matches
/// nothing reliably, because one seller writes "toyota" and another
/// "Toyota". Those belong on the listing form, not here.
@immutable
class FilterDefinition {
  /// Creates a filter definition.
  const FilterDefinition({
    required this.label,
    required this.icon,
    required this.target,
    required this.input,
    this.attributeKey,
    this.options = const <String>[],
  });

  /// A single choice over an attribute.
  const FilterDefinition.choice({
    required this.label,
    required this.icon,
    required String this.attributeKey,
    required this.options,
  })  : target = FilterTarget.attribute,
        input = FilterInput.choice;

  /// A multiple choice over an attribute.
  const FilterDefinition.multi({
    required this.label,
    required this.icon,
    required String this.attributeKey,
    required this.options,
  })  : target = FilterTarget.attribute,
        input = FilterInput.multiChoice;

  /// A numeric range over an attribute.
  const FilterDefinition.range({
    required this.label,
    required this.icon,
    required String this.attributeKey,
  })  : target = FilterTarget.attribute,
        input = FilterInput.range,
        options = const <String>[];

  /// A yes or no attribute.
  const FilterDefinition.flag({
    required this.label,
    required this.icon,
    required String this.attributeKey,
  })  : target = FilterTarget.attribute,
        input = FilterInput.flag,
        options = const <String>[];

  /// Label shown on the filter button.
  final String label;

  /// Icon shown on the filter button.
  final IconData icon;

  /// What this filter acts on.
  final FilterTarget target;

  /// How the value is entered.
  final FilterInput input;

  /// Key inside `attributes`, when [target] is [FilterTarget.attribute].
  final String? attributeKey;

  /// Allowed values for a choice filter.
  final List<String> options;
}

/// Filters available per subcategory.
///
/// Generated from the Tebiyu filter taxonomy: 105 subcategories, just under
/// three hundred fields. Subcategories with no entry fall back to
/// [universal], which is a working default rather than a gap.
abstract final class ListingFilters {
  /// Filters that apply to every listing in every category.
  ///
  /// Location is absent on purpose. It is a persistent context set from the
  /// Home chip and carried across screens, not something re-chosen inside
  /// one set of results.
  static const List<FilterDefinition> universal = <FilterDefinition>[
    FilterDefinition(
      label: 'Purpose',
      icon: Icons.sell_outlined,
      target: FilterTarget.offerType,
      input: FilterInput.choice,
    ),
    FilterDefinition(
      label: 'Price range',
      icon: Icons.payments_outlined,
      target: FilterTarget.price,
      input: FilterInput.range,
    ),
    FilterDefinition(
      label: 'Condition',
      icon: Icons.verified_outlined,
      target: FilterTarget.condition,
      input: FilterInput.choice,
    ),
    FilterDefinition(
      label: 'Negotiable',
      icon: Icons.handshake_outlined,
      target: FilterTarget.negotiable,
      input: FilterInput.flag,
    ),
    FilterDefinition(
      label: 'Seller type',
      icon: Icons.storefront_outlined,
      target: FilterTarget.sellerType,
      input: FilterInput.choice,
    ),
    FilterDefinition(
      label: 'Date posted',
      icon: Icons.schedule_outlined,
      target: FilterTarget.datePosted,
      input: FilterInput.choice,
    ),
    FilterDefinition(
      label: 'Delivery available',
      icon: Icons.local_shipping_outlined,
      target: FilterTarget.delivery,
      input: FilterInput.flag,
    ),
    FilterDefinition(
      label: 'Has photos',
      icon: Icons.photo_library_outlined,
      target: FilterTarget.hasPhotos,
      input: FilterInput.flag,
    ),
  ];

  /// Subcategory specific filters, keyed by subcategory name.
  static const Map<String, List<FilterDefinition>> bySubcategory =
      <String, List<FilterDefinition>>{
    'Agricultural Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Tractor',
          'Combine Harvester',
          'Irrigation System',
          'Grain Mill/Processor',
        ],
      ),
    ],
    'Apartments': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Apartment Type',
        icon: Icons.category_outlined,
        attributeKey: 'Apartment Type',
        options: <String>[
          'Studio',
          '1-Bedroom',
          '2-Bedroom',
          '3-Bedroom+',
          'Penthouse',
        ],
      ),
      FilterDefinition.choice(
        label: 'Floor Level',
        icon: Icons.stairs_outlined,
        attributeKey: 'Floor Level',
        options: <String>[
          'Ground',
          '1–3',
          '4–6',
          '7+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Furnishing',
        icon: Icons.chair_outlined,
        attributeKey: 'Furnishing',
        options: <String>[
          'Furnished',
          'Semi-Furnished',
          'Unfurnished',
        ],
      ),
      FilterDefinition.multi(
        label: 'Amenities',
        icon: Icons.checklist_outlined,
        attributeKey: 'Amenities',
        options: <String>[
          'Parking',
          'Generator',
          'Water Tank',
          'Security',
          'WiFi',
        ],
      ),
    ],
    'Audio Devices': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Home Theatre/Sound System',
          'Amplifier',
          'Microphone',
          'Radio',
          'Sound Bar',
          'DJ Mixer/Equipment',
        ],
      ),
    ],
    'Baby & Kid Clothing': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Age Range',
        icon: Icons.child_care_outlined,
        attributeKey: 'Age Range',
        options: <String>[
          '0–3mo',
          '3–6mo',
          '6–12mo',
          '1–2yr',
          '3–5yr',
          '6–12yr',
        ],
      ),
      FilterDefinition.choice(
        label: 'Gender',
        icon: Icons.wc_outlined,
        attributeKey: 'Gender',
        options: <String>[
          'Boy',
          'Girl',
          'Unisex',
        ],
      ),
    ],
    'Baby Care & Safety': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Diapers',
          'Baby Monitor',
          'Safety Gates',
          'Baby Bath Tub',
          'First Aid Kit',
        ],
      ),
    ],
    'Baby Gear': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Stroller/Pram',
          'Car Seat',
          'Baby Carrier',
          'Baby Walker',
          'Playpen',
        ],
      ),
    ],
    'Bags & Luggage': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Handbag',
          'Backpack',
          'Suitcase/Luggage',
          'Wallet',
          'Laptop Bag',
          'Travel Duffel',
        ],
      ),
      FilterDefinition.choice(
        label: 'Material',
        icon: Icons.texture_outlined,
        attributeKey: 'Material',
        options: <String>[
          'Leather',
          'Fabric',
          'Canvas',
          'Synthetic',
        ],
      ),
    ],
    'Bedding & Linen': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Bedsheets',
          'Duvet/Comforter',
          'Pillows',
          'Mattress',
          'Blankets',
          'Mosquito Net',
        ],
      ),
      FilterDefinition.choice(
        label: 'Size',
        icon: Icons.straighten_outlined,
        attributeKey: 'Size',
        options: <String>[
          'Single',
          'Double',
          'Queen',
          'King',
        ],
      ),
      FilterDefinition.choice(
        label: 'Material',
        icon: Icons.texture_outlined,
        attributeKey: 'Material',
        options: <String>[
          'Cotton',
          'Polyester',
          'Foam (mattress)',
          'Other',
        ],
      ),
    ],
    'Bicycle': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Mountain',
          'Road',
          'BMX',
          'Kids',
          'Electric Bike',
        ],
      ),
      FilterDefinition.choice(
        label: 'Frame Size',
        icon: Icons.straighten_outlined,
        attributeKey: 'Frame Size',
        options: <String>[
          'Small',
          'Medium',
          'Large',
          'Kids',
        ],
      ),
      FilterDefinition.choice(
        label: 'Gear Type',
        icon: Icons.category_outlined,
        attributeKey: 'Gear Type',
        options: <String>[
          'Single Speed',
          'Multi-Speed',
        ],
      ),
    ],
    'Bluetooth Speakers': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Portable',
          'Home/Party Speaker',
          'Soundbar',
        ],
      ),
      FilterDefinition.flag(
        label: 'Waterproof',
        icon: Icons.tune,
        attributeKey: 'Waterproof',
      ),
    ],
    'Body Care': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Lotion/Body Cream',
          'Soap',
          'Body Wash',
          'Body Scrub',
          'Deodorant',
        ],
      ),
      FilterDefinition.choice(
        label: 'Skin Type',
        icon: Icons.face_outlined,
        attributeKey: 'Skin Type',
        options: <String>[
          'Oily',
          'Dry',
          'Combination',
          'Sensitive',
          'All',
        ],
      ),
    ],
    'Books & School Supplies': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Textbooks',
          'Storybooks',
          'Stationery',
          'School Bags',
          'Uniforms',
        ],
      ),
      FilterDefinition.choice(
        label: 'Grade Level',
        icon: Icons.tune,
        attributeKey: 'Grade Level',
        options: <String>[
          'Pre-School',
          'Primary',
          'Secondary',
          'Not Applicable',
        ],
      ),
    ],
    'Buses': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Seating Capacity',
        icon: Icons.event_seat_outlined,
        attributeKey: 'Seating Capacity',
        options: <String>[
          '≤20',
          '21–40',
          '41+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Use',
        icon: Icons.tune,
        attributeKey: 'Use',
        options: <String>[
          'Public Transport',
          'School',
          'Private',
          'Charter',
        ],
      ),
      FilterDefinition.range(
        label: 'Year',
        icon: Icons.event_outlined,
        attributeKey: 'Year',
      ),
    ],
    'Camera & Lenses': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'DSLR',
          'Mirrorless',
          'Point & Shoot',
          'Action Camera',
          'Lens',
          'Tripod/Gimbal',
          'Drone',
          'Camera Bag',
        ],
      ),
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'Canon',
          'Nikon',
          'Sony',
          'Fujifilm',
          'GoPro',
          'DJI',
          'Other',
        ],
      ),
    ],
    'Car Accessories': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Car Mount/Holder',
          'FM Transmitter',
          'Car Charger',
          'Bluetooth Car Kit',
        ],
      ),
    ],
    'Cars': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Body Type',
        icon: Icons.category_outlined,
        attributeKey: 'Body Type',
        options: <String>[
          'Sedan',
          'Hatchback',
          'Coupe',
          'Wagon',
          'Convertible',
        ],
      ),
      FilterDefinition.choice(
        label: 'Make',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Make',
        options: <String>[
          'Toyota',
          'Nissan',
          'Honda',
          'Hyundai',
          'Kia',
          'Mercedes-Benz',
          'Other',
        ],
      ),
      FilterDefinition.range(
        label: 'Year',
        icon: Icons.event_outlined,
        attributeKey: 'Year',
      ),
      FilterDefinition.range(
        label: 'Mileage (km)',
        icon: Icons.speed_outlined,
        attributeKey: 'Mileage (km)',
      ),
      FilterDefinition.choice(
        label: 'Transmission',
        icon: Icons.settings_outlined,
        attributeKey: 'Transmission',
        options: <String>[
          'Automatic',
          'Manual',
        ],
      ),
      FilterDefinition.choice(
        label: 'Fuel Type',
        icon: Icons.local_gas_station_outlined,
        attributeKey: 'Fuel Type',
        options: <String>[
          'Petrol',
          'Diesel',
          'Hybrid',
          'Electric',
        ],
      ),
    ],
    'Cases, Covers & Skins': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Material',
        icon: Icons.texture_outlined,
        attributeKey: 'Material',
        options: <String>[
          'Silicone',
          'Leather',
          'Hard Plastic',
          'Rugged/Shockproof',
        ],
      ),
    ],
    'Casual Jobs': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Job Type',
        icon: Icons.category_outlined,
        attributeKey: 'Job Type',
        options: <String>[
          'Manual Labor',
          'Domestic Work',
          'Driver',
          'Security Guard',
          'Cleaner',
        ],
      ),
      FilterDefinition.choice(
        label: 'Pay Rate',
        icon: Icons.tune,
        attributeKey: 'Pay Rate',
        options: <String>[
          'Daily',
          'Weekly',
          'Per Task',
        ],
      ),
    ],
    'Chargers & Cables': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Wall Charger',
          'Car Charger',
          'Wireless Charger',
          'USB Cable',
        ],
      ),
      FilterDefinition.choice(
        label: 'Connector',
        icon: Icons.tune,
        attributeKey: 'Connector',
        options: <String>[
          'USB-C',
          'Lightning',
          'Micro-USB',
        ],
      ),
      FilterDefinition.choice(
        label: 'Original/Generic',
        icon: Icons.tune,
        attributeKey: 'Original/Generic',
        options: <String>[
          'Original',
          'Generic (Compatible)',
        ],
      ),
    ],
    'Clothing': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Category',
        icon: Icons.category_outlined,
        attributeKey: 'Category',
        options: <String>[
          'Men',
          'Women',
          'Unisex',
          'Kids',
        ],
      ),
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Shirts',
          'Trousers',
          'Dresses',
          'Suits',
          'Traditional Wear',
          'Sportswear',
          'Sleepwear',
          'Jackets',
        ],
      ),
      FilterDefinition.choice(
        label: 'Size',
        icon: Icons.straighten_outlined,
        attributeKey: 'Size',
        options: <String>[
          'XS',
          'S',
          'M',
          'L',
          'XL',
          'XXL / numeric',
        ],
      ),
    ],
    'Commercial Properties': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Property Type',
        icon: Icons.category_outlined,
        attributeKey: 'Property Type',
        options: <String>[
          'Office Space',
          'Shop/Retail',
          'Warehouse',
          'Hotel/Guesthouse',
          'Building',
          'Land for Business',
        ],
      ),
      FilterDefinition.range(
        label: 'Size',
        icon: Icons.straighten_outlined,
        attributeKey: 'Size',
      ),
    ],
    'Company Jobs': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Industry',
        icon: Icons.tune,
        attributeKey: 'Industry',
        options: <String>[
          'Banking/Finance',
          'Telecom',
          'Retail',
          'Hospitality',
          'Manufacturing',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Employment Type',
        icon: Icons.work_outline,
        attributeKey: 'Employment Type',
        options: <String>[
          'Full-Time',
          'Part-Time',
          'Internship',
          'Contract',
        ],
      ),
      FilterDefinition.choice(
        label: 'Experience Level',
        icon: Icons.trending_up_outlined,
        attributeKey: 'Experience Level',
        options: <String>[
          'Entry',
          'Mid',
          'Senior',
        ],
      ),
      FilterDefinition.choice(
        label: 'Education Level',
        icon: Icons.school_outlined,
        attributeKey: 'Education Level',
        options: <String>[
          'Certificate',
          'Diploma',
          "Bachelor's",
          "Master's+",
        ],
      ),
    ],
    'Computer Accessories': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Keyboard',
          'Mouse',
          'Monitor',
          'Webcam',
          'Speakers',
          'UPS',
          'Laptop Bag',
          'Cooling Pad',
          'Cables & Adapters',
          'External HDD/SSD',
          'Flash Drive',
          'Other',
        ],
      ),
    ],
    'Computers & Laptops': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Laptop',
          'Desktop',
          'All-in-One',
          'Mini PC',
          'Chromebook',
        ],
      ),
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'HP',
          'Dell',
          'Lenovo',
          'Apple',
          'Asus',
          'Acer',
          'Toshiba',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Processor',
        icon: Icons.developer_board_outlined,
        attributeKey: 'Processor',
        options: <String>[
          'Intel Celeron/Pentium',
          'Intel i3',
          'i5',
          'i7',
          'i9',
          'AMD Ryzen 3/5/7/9',
          'Apple M-series',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'RAM',
        icon: Icons.memory_outlined,
        attributeKey: 'RAM',
        options: <String>[
          '2GB',
          '4GB',
          '8GB',
          '16GB',
          '32GB+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Storage Type',
        icon: Icons.sd_storage_outlined,
        attributeKey: 'Storage Type',
        options: <String>[
          'HDD',
          'SSD',
          'Hybrid',
        ],
      ),
      FilterDefinition.choice(
        label: 'Storage Capacity',
        icon: Icons.sd_storage_outlined,
        attributeKey: 'Storage Capacity',
        options: <String>[
          '128GB',
          '256GB',
          '512GB',
          '1TB',
          '2TB+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Screen Size',
        icon: Icons.desktop_windows_outlined,
        attributeKey: 'Screen Size',
        options: <String>[
          '11–13"',
          '14–15"',
          '16–17"',
          '18"+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Operating System',
        icon: Icons.laptop_outlined,
        attributeKey: 'Operating System',
        options: <String>[
          'Windows',
          'macOS',
          'Chrome OS',
          'Linux',
          'No OS',
        ],
      ),
      FilterDefinition.choice(
        label: 'Warranty',
        icon: Icons.shield_outlined,
        attributeKey: 'Warranty',
        options: <String>[
          'Under Warranty',
          'Expired',
          'No Warranty',
        ],
      ),
    ],
    'Construction & Building': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Service Type',
        icon: Icons.handyman_outlined,
        attributeKey: 'Service Type',
        options: <String>[
          'Masonry',
          'Carpentry',
          'Painting',
          'Roofing',
          'Welding',
          'Architecture/Design',
          'General Contracting',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed',
          'Per Sqm',
          'Per Day',
          'Per Project',
        ],
      ),
    ],
    'Construction Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Concrete Mixer',
          'Scaffolding',
          'Wheelbarrow',
          'Generator',
          'Compactor',
        ],
      ),
    ],
    'Content Creation Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Ring Light/Studio Light',
          'Microphone',
          'Green Screen',
          'Camera Rig/Stabilizer',
          'Tripod',
          'Capture Card',
          'Editing Software License',
        ],
      ),
    ],
    'Cycling': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Bicycle Parts',
          'Helmets',
          'Cycling Gear',
          'Bike Accessories',
        ],
      ),
    ],
    'Designer Fashion': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'Gucci',
          'Louis Vuitton',
          'Nike',
          'Adidas Originals',
          'Chanel',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Category',
        icon: Icons.category_outlined,
        attributeKey: 'Category',
        options: <String>[
          'Clothing',
          'Footwear',
          'Bags',
          'Accessories',
        ],
      ),
      FilterDefinition.choice(
        label: 'Authenticity',
        icon: Icons.tune,
        attributeKey: 'Authenticity',
        options: <String>[
          'Verified Authentic',
          'Seller-Claimed Authentic',
          'Replica-Inspired',
        ],
      ),
    ],
    'Electrical & Mechanical': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Generator',
          'Transformer',
          'Motor/Pump',
          'Solar Panel System',
          'Bulk Wiring/Cabling',
        ],
      ),
    ],
    'Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Tractor',
          'Plow',
          'Irrigation Pump',
          'Harvester',
          'Hand Tools',
          'Sprayer',
          'Silo/Storage',
        ],
      ),
    ],
    'Event Planning & Materials': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Service Type',
        icon: Icons.handyman_outlined,
        attributeKey: 'Service Type',
        options: <String>[
          'Full Event Planning',
          'Decoration',
          'Catering',
          'Tent & Chairs Rental',
          'DJ/MC Services',
          'Wedding Planning',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed',
          'Per Hour',
          'Per Event',
        ],
      ),
    ],
    'Eye Glasses': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Prescription Glasses',
          'Sunglasses',
          'Reading Glasses',
          'Contact Lenses',
        ],
      ),
      FilterDefinition.choice(
        label: 'Frame Type',
        icon: Icons.category_outlined,
        attributeKey: 'Frame Type',
        options: <String>[
          'Full-Rim',
          'Half-Rim',
          'Rimless',
        ],
      ),
      FilterDefinition.choice(
        label: 'Gender',
        icon: Icons.wc_outlined,
        attributeKey: 'Gender',
        options: <String>[
          'Men',
          'Women',
          'Unisex',
        ],
      ),
    ],
    'Farmland': <FilterDefinition>[
      FilterDefinition.range(
        label: 'Size',
        icon: Icons.straighten_outlined,
        attributeKey: 'Size',
      ),
      FilterDefinition.choice(
        label: 'Soil Type',
        icon: Icons.category_outlined,
        attributeKey: 'Soil Type',
        options: <String>[
          'Clay',
          'Sandy',
          'Loamy',
          'Black Cotton',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Water Access',
        icon: Icons.tune,
        attributeKey: 'Water Access',
        options: <String>[
          'River',
          'Borehole',
          'Irrigation',
          'None',
        ],
      ),
      FilterDefinition.choice(
        label: 'Documentation',
        icon: Icons.tune,
        attributeKey: 'Documentation',
        options: <String>[
          'Titled',
          'Customary',
          'In Process',
        ],
      ),
    ],
    'Fashion Accessories': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Scarves',
          'Ties',
          'Gloves',
          'Hair Clips',
          'Belts',
          'Sunglasses',
          'Hats/Caps',
        ],
      ),
      FilterDefinition.choice(
        label: 'Gender',
        icon: Icons.wc_outlined,
        attributeKey: 'Gender',
        options: <String>[
          'Men',
          'Women',
          'Unisex',
        ],
      ),
    ],
    'Feeding Essentials': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Baby Bottles',
          'Breast Pump',
          'High Chair',
          'Baby Food/Formula',
          'Sterilizer',
        ],
      ),
    ],
    'Fitness & Gym Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Treadmill',
          'Dumbbells',
          'Weight Bench',
          'Exercise Bike',
          'Yoga Mat',
          'Resistance Bands',
        ],
      ),
    ],
    'Footwear': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Category',
        icon: Icons.category_outlined,
        attributeKey: 'Category',
        options: <String>[
          'Men',
          'Women',
          'Kids',
        ],
      ),
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Sneakers',
          'Sandals',
          'Official/Formal Shoes',
          'Boots',
          'Slippers',
          'Heels',
        ],
      ),
    ],
    'Fragrance': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Perfume',
          'Body Spray',
          'Deodorant Spray',
          'Oud/Incense',
        ],
      ),
      FilterDefinition.choice(
        label: 'Gender',
        icon: Icons.wc_outlined,
        attributeKey: 'Gender',
        options: <String>[
          'Men',
          'Women',
          'Unisex',
        ],
      ),
      FilterDefinition.choice(
        label: 'Volume',
        icon: Icons.tune,
        attributeKey: 'Volume',
        options: <String>[
          '≤30ml',
          '50ml',
          '100ml',
          '150ml+',
        ],
      ),
    ],
    'Furniture': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Sofa/Couch',
          'Bed',
          'Dining Set',
          'Wardrobe',
          'Office Desk/Chair',
          'Cabinet/Shelf',
          'Coffee Table',
          'Outdoor Furniture',
        ],
      ),
      FilterDefinition.choice(
        label: 'Material',
        icon: Icons.texture_outlined,
        attributeKey: 'Material',
        options: <String>[
          'Wood',
          'Metal',
          'Plastic',
          'Rattan/Wicker',
          'Upholstered',
        ],
      ),
    ],
    'Gaming & Consoles': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Console',
          'Video Game (Disc/Digital)',
          'Controller/Accessory',
          'Gaming Chair',
          'VR Headset',
          'Gaming Laptop/PC',
        ],
      ),
      FilterDefinition.choice(
        label: 'Platform',
        icon: Icons.videogame_asset_outlined,
        attributeKey: 'Platform',
        options: <String>[
          'PlayStation',
          'Xbox',
          'Nintendo Switch',
          'PC',
          'Other',
        ],
      ),
    ],
    'Gaming & Recreation': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Board Games',
          'Playing Cards',
          'Puzzles',
          'Pool/Snooker Table',
          'Dart Board',
        ],
      ),
    ],
    'Hand & Power Tools': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Drill',
          'Saw',
          'Grinder',
          'Welding Machine',
          'Hand Tool Set',
          'Ladder',
        ],
      ),
      FilterDefinition.choice(
        label: 'Power Source',
        icon: Icons.bolt_outlined,
        attributeKey: 'Power Source',
        options: <String>[
          'Manual',
          'Electric',
          'Battery',
        ],
      ),
    ],
    'Headphones & Earbuds': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Wired',
          'Wireless/Bluetooth',
          'Earbuds (TWS)',
          'Over-Ear',
          'Neckband',
        ],
      ),
      FilterDefinition.flag(
        label: 'Noise Cancelling',
        icon: Icons.tune,
        attributeKey: 'Noise Cancelling',
      ),
    ],
    'Health & Wellness Services': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Service Type',
        icon: Icons.handyman_outlined,
        attributeKey: 'Service Type',
        options: <String>[
          'Fitness Training/Personal Trainer',
          'Massage Therapy',
          'Nutrition Consulting',
          'Home Nursing Care',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed',
          'Per Hour',
          'Per Session',
        ],
      ),
    ],
    'Heavy Machinery': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Excavator',
          'Bulldozer',
          'Crane',
          'Tractor',
          'Forklift',
          'Grader',
          'Generator',
          'Water Pump',
        ],
      ),
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'CAT',
          'Komatsu',
          'JCB',
          'Other',
        ],
      ),
      FilterDefinition.range(
        label: 'Year',
        icon: Icons.event_outlined,
        attributeKey: 'Year',
      ),
      FilterDefinition.range(
        label: 'Hours Used',
        icon: Icons.tune,
        attributeKey: 'Hours Used',
      ),
    ],
    'Home Appliances': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Fan',
          'Air Conditioner',
          'Heater',
          'Iron Box',
          'Vacuum Cleaner',
          'Generator',
          'Solar System/Inverter',
        ],
      ),
      FilterDefinition.choice(
        label: 'Power Source',
        icon: Icons.bolt_outlined,
        attributeKey: 'Power Source',
        options: <String>[
          'Electric',
          'Solar',
          'Gas',
        ],
      ),
    ],
    'Home Décor': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Wall Art/Paintings',
          'Rugs & Carpets',
          'Curtains',
          'Mirrors',
          'Vases/Ornaments',
          'Clocks',
        ],
      ),
    ],
    'Home Security & Safety': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Padlocks/Locks',
          'Fire Extinguisher',
          'Safe/Vault',
          'Burglar Proofing',
          'Smoke Detector',
        ],
      ),
    ],
    'Household Essentials': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Cleaning Supplies',
          'Storage/Organizers',
          'Laundry Items',
          'Trash Bins',
        ],
      ),
    ],
    'Houses': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'House Type',
        icon: Icons.category_outlined,
        attributeKey: 'House Type',
        options: <String>[
          'Bungalow',
          'Villa',
          'Duplex',
          'Storey Building',
          'Cottage',
        ],
      ),
      FilterDefinition.choice(
        label: 'Bedrooms',
        icon: Icons.bed_outlined,
        attributeKey: 'Bedrooms',
        options: <String>[
          '1',
          '2',
          '3',
          '4',
          '5+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Bathrooms',
        icon: Icons.bathtub_outlined,
        attributeKey: 'Bathrooms',
        options: <String>[
          '1',
          '2',
          '3',
          '4+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Furnishing',
        icon: Icons.chair_outlined,
        attributeKey: 'Furnishing',
        options: <String>[
          'Furnished',
          'Semi-Furnished',
          'Unfurnished',
        ],
      ),
      FilterDefinition.flag(
        label: 'Compound Fenced',
        icon: Icons.tune,
        attributeKey: 'Compound Fenced',
      ),
      FilterDefinition.multi(
        label: 'Amenities',
        icon: Icons.checklist_outlined,
        attributeKey: 'Amenities',
        options: <String>[
          'Parking',
          'Generator',
          'Water Tank/Borehole',
          'Security',
          'WiFi',
          'Solar Power',
        ],
      ),
    ],
    'IT & Digital Services': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Service Type',
        icon: Icons.handyman_outlined,
        attributeKey: 'Service Type',
        options: <String>[
          'Web Design',
          'Graphic Design',
          'Software Development',
          'Social Media Management',
          'Computer Repair',
          'Data Entry',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed',
          'Hourly',
          'Per Project',
        ],
      ),
    ],
    'Industrial Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Compressor',
          'Industrial Motor',
          'Conveyor',
          'Packaging Machine',
          'Boiler',
        ],
      ),
    ],
    'Jewelry & Accessories': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Necklace',
          'Ring',
          'Earrings',
          'Bracelet',
          'Anklet',
          'Jewelry Set',
        ],
      ),
      FilterDefinition.choice(
        label: 'Material',
        icon: Icons.texture_outlined,
        attributeKey: 'Material',
        options: <String>[
          'Gold',
          'Silver',
          'Beaded',
          'Fashion/Costume',
        ],
      ),
      FilterDefinition.choice(
        label: 'Gender',
        icon: Icons.wc_outlined,
        attributeKey: 'Gender',
        options: <String>[
          'Men',
          'Women',
          'Unisex',
        ],
      ),
    ],
    'Kitchen & Dining': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Cookware/Pots & Pans',
          'Cutlery',
          'Dinnerware/Plates',
          'Storage Containers',
          'Dining Table Set',
        ],
      ),
      FilterDefinition.choice(
        label: 'Material',
        icon: Icons.texture_outlined,
        attributeKey: 'Material',
        options: <String>[
          'Stainless Steel',
          'Non-Stick',
          'Ceramic',
          'Glass',
          'Plastic',
          'Wood',
        ],
      ),
    ],
    'Kitchen Appliances': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Refrigerator/Fridge',
          'Freezer',
          'Microwave',
          'Gas Cooker/Stove',
          'Electric Cooker',
          'Blender/Mixer',
          'Kettle',
          'Toaster',
          'Oven',
          'Water Dispenser',
          'Air Fryer',
        ],
      ),
      FilterDefinition.choice(
        label: 'Power Source',
        icon: Icons.bolt_outlined,
        attributeKey: 'Power Source',
        options: <String>[
          'Electric',
          'Gas',
          'Solar',
          'Hybrid',
        ],
      ),
    ],
    'Land & Plots': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Land Type',
        icon: Icons.category_outlined,
        attributeKey: 'Land Type',
        options: <String>[
          'Residential',
          'Commercial',
          'Agricultural',
          'Industrial',
        ],
      ),
      FilterDefinition.range(
        label: 'Size',
        icon: Icons.straighten_outlined,
        attributeKey: 'Size',
      ),
      FilterDefinition.choice(
        label: 'Title Deed / Documentation',
        icon: Icons.tune,
        attributeKey: 'Title Deed / Documentation',
        options: <String>[
          'Titled',
          'In Process',
          'Customary',
          'None',
        ],
      ),
      FilterDefinition.flag(
        label: 'Fenced',
        icon: Icons.tune,
        attributeKey: 'Fenced',
      ),
    ],
    'Leisure Activities': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Game Center',
          'Movie/Cinema',
          'Recreational Club Membership',
          'Tour/Excursion',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed Price',
          'Per Session',
          'Per Membership Period',
        ],
      ),
    ],
    'Lighting': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Ceiling Light',
          'Chandelier',
          'Table/Floor Lamp',
          'Solar Light',
          'Outdoor Light',
          'LED Strip',
        ],
      ),
      FilterDefinition.choice(
        label: 'Power Source',
        icon: Icons.bolt_outlined,
        attributeKey: 'Power Source',
        options: <String>[
          'Electric',
          'Solar',
          'Rechargeable',
        ],
      ),
    ],
    'Livestock': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Cattle',
          'Goats',
          'Sheep',
          'Poultry/Chicken',
          'Pigs',
          'Donkeys/Camels',
          'Fish',
        ],
      ),
      FilterDefinition.choice(
        label: 'Age',
        icon: Icons.tune,
        attributeKey: 'Age',
        options: <String>[
          'Young/Calf',
          'Adult',
          'Mature/Breeding',
        ],
      ),
      FilterDefinition.range(
        label: 'Quantity',
        icon: Icons.tune,
        attributeKey: 'Quantity',
      ),
      FilterDefinition.flag(
        label: 'Vaccination Status',
        icon: Icons.tune,
        attributeKey: 'Vaccination Status',
      ),
    ],
    'Maternity & Pregnancy': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Maternity Wear',
          'Nursing Bras',
          'Pregnancy Pillow',
          'Postpartum Care Items',
        ],
      ),
      FilterDefinition.choice(
        label: 'Size',
        icon: Icons.straighten_outlined,
        attributeKey: 'Size',
        options: <String>[
          'S',
          'M',
          'L',
          'XL',
          'XXL',
        ],
      ),
    ],
    'Memory Cards': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'MicroSD',
          'SD Card',
        ],
      ),
      FilterDefinition.choice(
        label: 'Capacity',
        icon: Icons.inventory_2_outlined,
        attributeKey: 'Capacity',
        options: <String>[
          '8–16GB',
          '32GB',
          '64GB',
          '128GB',
          '256GB+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Speed Class',
        icon: Icons.tune,
        attributeKey: 'Speed Class',
        options: <String>[
          'Class 10',
          'UHS-I',
          'UHS-III',
          'Other',
        ],
      ),
    ],
    'Mobile Phones': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'Samsung',
          'Apple (iPhone)',
          'Tecno',
          'Infinix',
          'Itel',
          'Huawei',
          'Xiaomi',
          'Nokia',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Storage',
        icon: Icons.sd_storage_outlined,
        attributeKey: 'Storage',
        options: <String>[
          '16GB',
          '32GB',
          '64GB',
          '128GB',
          '256GB',
          '512GB+',
        ],
      ),
      FilterDefinition.choice(
        label: 'RAM',
        icon: Icons.memory_outlined,
        attributeKey: 'RAM',
        options: <String>[
          '1–2GB',
          '3–4GB',
          '6–8GB',
          '12GB+',
        ],
      ),
      FilterDefinition.choice(
        label: 'SIM Type',
        icon: Icons.category_outlined,
        attributeKey: 'SIM Type',
        options: <String>[
          'Single SIM',
          'Dual SIM',
          'eSIM',
        ],
      ),
    ],
    'Motorcycles': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Sport',
          'Cruiser',
          'Scooter',
          'Off-Road/Dirt Bike',
          'Boda-Boda/Commercial',
        ],
      ),
      FilterDefinition.choice(
        label: 'Engine Capacity (cc)',
        icon: Icons.tune,
        attributeKey: 'Engine Capacity (cc)',
        options: <String>[
          '<100cc',
          '100–150cc',
          '150–250cc',
          '250cc+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Make/Model',
        icon: Icons.directions_car_outlined,
        attributeKey: 'Make/Model',
        options: <String>[
          'Bajaj',
          'TVS',
          'Haojue',
          'Honda',
          'Other',
        ],
      ),
      FilterDefinition.range(
        label: 'Year',
        icon: Icons.event_outlined,
        attributeKey: 'Year',
      ),
    ],
    'Musical Instruments': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Guitar',
          'Keyboard/Piano',
          'Drum Set',
          'Traditional Instruments',
          'DJ Equipment',
          'Wind Instruments',
        ],
      ),
    ],
    'NGO & INGO Jobs': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Sector',
        icon: Icons.tune,
        attributeKey: 'Sector',
        options: <String>[
          'Health',
          'Education',
          'WASH',
          'Protection',
          'Logistics',
          'M&E',
          'Admin/Finance',
        ],
      ),
      FilterDefinition.choice(
        label: 'Employment Type',
        icon: Icons.work_outline,
        attributeKey: 'Employment Type',
        options: <String>[
          'Full-Time',
          'Part-Time',
          'Contract',
          'Volunteer',
          'Consultancy',
        ],
      ),
      FilterDefinition.choice(
        label: 'Experience Level',
        icon: Icons.trending_up_outlined,
        attributeKey: 'Experience Level',
        options: <String>[
          'Entry',
          'Mid',
          'Senior',
        ],
      ),
      FilterDefinition.choice(
        label: 'Education Level',
        icon: Icons.school_outlined,
        attributeKey: 'Education Level',
        options: <String>[
          'Certificate',
          'Diploma',
          "Bachelor's",
          "Master's+",
        ],
      ),
    ],
    'Nail Care': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Nail Polish',
          'Manicure/Pedicure Kit',
          'Nail Extensions/Accessories',
        ],
      ),
    ],
    'Networking Products': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Router',
          'Modem',
          'WiFi Extender/Repeater',
          'Network Switch',
          'Cable/Adapter',
          'Antenna',
          'Satellite Internet Kit',
        ],
      ),
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'TP-Link',
          'Huawei',
          'MikroTik',
          'Other',
        ],
      ),
    ],
    'Nursery Furniture': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Crib/Cot',
          'Changing Table',
          'Baby Wardrobe',
          'Rocking Chair',
        ],
      ),
    ],
    'Office Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Office Furniture',
          'Photocopier',
          'Shredder',
          'Projector',
          'Filing Cabinet',
          'Office Chair',
        ],
      ),
    ],
    'Oral Care': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Toothpaste',
          'Toothbrush',
          'Mouthwash',
          'Teeth Whitening',
        ],
      ),
    ],
    'Outdoor & Camping': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Tent',
          'Sleeping Bag',
          'Backpack',
          'Camping Stove',
          'Cooler Box',
          'Flashlight/Headlamp',
        ],
      ),
    ],
    'Outerwear': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Coats',
          'Jackets',
          'Sweaters',
          'Hoodies',
          'Rain Gear',
        ],
      ),
      FilterDefinition.choice(
        label: 'Gender',
        icon: Icons.wc_outlined,
        attributeKey: 'Gender',
        options: <String>[
          'Men',
          'Women',
          'Unisex',
          'Kids',
        ],
      ),
      FilterDefinition.choice(
        label: 'Size',
        icon: Icons.straighten_outlined,
        attributeKey: 'Size',
        options: <String>[
          'XS–XXL',
          'numeric',
        ],
      ),
    ],
    'Personal Care': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Period Underwear',
          'Menstrual Cup',
          'Bidet Attachment',
          'Sanitary Pads',
          'Other Hygiene Products',
        ],
      ),
    ],
    'Personal Care Services': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Service Type',
        icon: Icons.handyman_outlined,
        attributeKey: 'Service Type',
        options: <String>[
          'Tutoring',
          'Personal Assistant',
          'Errand Running',
          'Babysitting',
          'Salon/Barbering at Home',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed',
          'Per Hour',
          'Per Session',
        ],
      ),
    ],
    'Personal Satisfaction': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Spa/Massage Services',
          'Relaxation Packages',
          'Hobby Classes',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed Price',
          'Per Session',
        ],
      ),
    ],
    'Photography & Videography': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Service Type',
        icon: Icons.handyman_outlined,
        attributeKey: 'Service Type',
        options: <String>[
          'Wedding Photography',
          'Portrait/Studio',
          'Event Videography',
          'Drone Filming',
          'Photo Editing',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed',
          'Per Event',
          'Per Hour',
        ],
      ),
    ],
    'Pickup Trucks': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Make/Model',
        icon: Icons.directions_car_outlined,
        attributeKey: 'Make/Model',
        options: <String>[
          'Toyota Hilux',
          'Nissan Navara',
          'Isuzu',
          'Ford Ranger',
          'Other',
        ],
      ),
      FilterDefinition.range(
        label: 'Year',
        icon: Icons.event_outlined,
        attributeKey: 'Year',
      ),
      FilterDefinition.choice(
        label: 'Drive Type',
        icon: Icons.alt_route_outlined,
        attributeKey: 'Drive Type',
        options: <String>[
          '4x4',
          '4x2',
        ],
      ),
      FilterDefinition.choice(
        label: 'Cab Type',
        icon: Icons.category_outlined,
        attributeKey: 'Cab Type',
        options: <String>[
          'Single Cab',
          'Double Cab',
          'Extended Cab',
        ],
      ),
      FilterDefinition.range(
        label: 'Mileage (km)',
        icon: Icons.speed_outlined,
        attributeKey: 'Mileage (km)',
      ),
    ],
    'Power Banks': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Capacity',
        icon: Icons.inventory_2_outlined,
        attributeKey: 'Capacity',
        options: <String>[
          '≤5',
          '000mAh',
          '10',
          '000mAh',
          '20',
          '000mAh',
          '30',
          '000mAh+',
        ],
      ),
      FilterDefinition.flag(
        label: 'Fast Charging',
        icon: Icons.tune,
        attributeKey: 'Fast Charging',
      ),
    ],
    'Printers & Scanners': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Inkjet Printer',
          'Laser Printer',
          'All-in-One',
          'Scanner',
          '3D Printer',
          'Photocopier',
        ],
      ),
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'HP',
          'Canon',
          'Epson',
          'Brother',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Print Mode',
        icon: Icons.tune,
        attributeKey: 'Print Mode',
        options: <String>[
          'Color',
          'Mono (Black & White)',
        ],
      ),
    ],
    'Produce': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Grains (Sorghum',
          'Maize',
          'Millet)',
          'Vegetables',
          'Fruits',
          'Legumes',
          'Cash Crops',
        ],
      ),
      FilterDefinition.choice(
        label: 'Quantity / Unit',
        icon: Icons.numbers_outlined,
        attributeKey: 'Quantity / Unit',
        options: <String>[
          'kg',
          'sack',
          'ton',
        ],
      ),
      FilterDefinition.flag(
        label: 'Organic',
        icon: Icons.tune,
        attributeKey: 'Organic',
      ),
    ],
    'Repair & Maintenance': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Service Type',
        icon: Icons.handyman_outlined,
        attributeKey: 'Service Type',
        options: <String>[
          'Electronics Repair',
          'Appliance Repair',
          'Plumbing',
          'Electrical Work',
          'Furniture Repair',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed',
          'Per Job',
          'Callout Fee',
        ],
      ),
    ],
    'Replacement Batteries': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Original/Generic',
        icon: Icons.tune,
        attributeKey: 'Original/Generic',
        options: <String>[
          'Original',
          'Generic',
        ],
      ),
    ],
    'Restaurant & Catering': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Commercial Fridge/Freezer',
          'Oven',
          'Grill/BBQ',
          'Food Warmer',
          'Bulk Cookware',
          'Bulk Cutlery',
          'Commercial Blender',
        ],
      ),
    ],
    'SUV': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Make/Model',
        icon: Icons.directions_car_outlined,
        attributeKey: 'Make/Model',
        options: <String>[
          'Toyota',
          'Nissan',
          'Land Rover',
          'Mitsubishi',
          'Other',
        ],
      ),
      FilterDefinition.range(
        label: 'Year',
        icon: Icons.event_outlined,
        attributeKey: 'Year',
      ),
      FilterDefinition.range(
        label: 'Mileage (km)',
        icon: Icons.speed_outlined,
        attributeKey: 'Mileage (km)',
      ),
      FilterDefinition.choice(
        label: 'Drive Type',
        icon: Icons.alt_route_outlined,
        attributeKey: 'Drive Type',
        options: <String>[
          '4WD',
          'AWD',
          '2WD',
        ],
      ),
      FilterDefinition.choice(
        label: 'Seats',
        icon: Icons.tune,
        attributeKey: 'Seats',
        options: <String>[
          '5',
          '7',
          '8+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Transmission',
        icon: Icons.settings_outlined,
        attributeKey: 'Transmission',
        options: <String>[
          'Automatic',
          'Manual',
        ],
      ),
      FilterDefinition.choice(
        label: 'Fuel Type',
        icon: Icons.local_gas_station_outlined,
        attributeKey: 'Fuel Type',
        options: <String>[
          'Petrol',
          'Diesel',
          'Hybrid',
        ],
      ),
    ],
    'Safety Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Fire Extinguisher',
          'Safety Vest/PPE',
          'Helmet',
          'Safety Boots',
          'First Aid Kit',
          'Safety Signage',
        ],
      ),
    ],
    'Second-hand Fashion': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Used Clothing (Fripperie)',
          'Vintage Fashion',
        ],
      ),
      FilterDefinition.choice(
        label: 'Category',
        icon: Icons.category_outlined,
        attributeKey: 'Category',
        options: <String>[
          'Men',
          'Women',
          'Kids',
        ],
      ),
      FilterDefinition.choice(
        label: 'Condition Grade',
        icon: Icons.tune,
        attributeKey: 'Condition Grade',
        options: <String>[
          'Like New',
          'Good',
          'Fair',
        ],
      ),
      FilterDefinition.choice(
        label: 'Sold By',
        icon: Icons.tune,
        attributeKey: 'Sold By',
        options: <String>[
          'Piece',
          'Bundle',
          'Bale',
        ],
      ),
    ],
    'Security & Surveillance': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'CCTV Camera',
          'DVR/NVR System',
          'Alarm System',
          'Door Lock/Access Control',
          'Intercom',
          'Metal Detector',
        ],
      ),
      FilterDefinition.flag(
        label: 'Wireless',
        icon: Icons.wifi_outlined,
        attributeKey: 'Wireless',
      ),
    ],
    'Seeds & Fertilizers': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Crop Seeds',
          'Organic Fertilizer',
          'Chemical Fertilizer',
          'Pesticide/Herbicide',
        ],
      ),
      FilterDefinition.choice(
        label: 'Crop Type',
        icon: Icons.category_outlined,
        attributeKey: 'Crop Type',
        options: <String>[
          'Sorghum',
          'Maize',
          'Groundnut',
          'Vegetable',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Quantity / Unit',
        icon: Icons.numbers_outlined,
        attributeKey: 'Quantity / Unit',
        options: <String>[
          'kg',
          'bag',
        ],
      ),
    ],
    'Selfie Sticks & Tripods': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Selfie Stick',
          'Tripod',
          'Phone Holder/Mount',
          'Ring Light Stand',
        ],
      ),
      FilterDefinition.flag(
        label: 'Bluetooth Remote',
        icon: Icons.tune,
        attributeKey: 'Bluetooth Remote',
      ),
    ],
    'Shop & Retail Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'POS System/Cash Register',
          'Display Shelving',
          'Shopping Cart/Basket',
          'Weighing Scale',
          'Refrigerated Display',
        ],
      ),
    ],
    'Skin Care': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Face Cream',
          'Serum',
          'Cleanser',
          'Sunscreen',
          'Acne Treatment',
          'Skin Lightening',
        ],
      ),
      FilterDefinition.choice(
        label: 'Skin Type',
        icon: Icons.face_outlined,
        attributeKey: 'Skin Type',
        options: <String>[
          'Oily',
          'Dry',
          'Combination',
          'Sensitive',
          'All',
        ],
      ),
    ],
    'Sport Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Sport Type',
        icon: Icons.category_outlined,
        attributeKey: 'Sport Type',
        options: <String>[
          'Football',
          'Basketball',
          'Volleyball',
          'Tennis/Racket Sports',
          'Athletics',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Item Type',
        icon: Icons.category_outlined,
        attributeKey: 'Item Type',
        options: <String>[
          'Balls',
          'Rackets',
          'Nets',
          'Protective Gear',
          'Other Equipment',
        ],
      ),
    ],
    'Sportswear & Accessories': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Jerseys',
          'Sportswear',
          'Sports Shoes',
          'Gym Bags',
          'Water Bottles',
        ],
      ),
      FilterDefinition.choice(
        label: 'Gender',
        icon: Icons.wc_outlined,
        attributeKey: 'Gender',
        options: <String>[
          'Men',
          'Women',
          'Unisex',
          'Kids',
        ],
      ),
      FilterDefinition.choice(
        label: 'Size',
        icon: Icons.straighten_outlined,
        attributeKey: 'Size',
        options: <String>[
          'XS–XXL',
          'shoe sizing',
        ],
      ),
    ],
    'TV & Video Equipment': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Smart TV',
          'LED/LCD TV',
          'Projector',
          'DVD/Blu-ray Player',
          'Streaming Device',
          'TV Stand/Mount',
          'Satellite Decoder',
        ],
      ),
      FilterDefinition.choice(
        label: 'Screen Size',
        icon: Icons.desktop_windows_outlined,
        attributeKey: 'Screen Size',
        options: <String>[
          '≤24"',
          '32"',
          '40–43"',
          '50–55"',
          '58–65"',
          '70"+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'Samsung',
          'LG',
          'Sony',
          'Hisense',
          'TCL',
          'Skyworth',
          'Other',
        ],
      ),
      FilterDefinition.flag(
        label: 'Smart TV',
        icon: Icons.smart_display_outlined,
        attributeKey: 'Smart TV',
      ),
      FilterDefinition.choice(
        label: 'Resolution',
        icon: Icons.hd_outlined,
        attributeKey: 'Resolution',
        options: <String>[
          'HD',
          'Full HD',
          '4K UHD',
          '8K',
        ],
      ),
    ],
    'Tailoring & Custom Fashion': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Service Type',
        icon: Icons.handyman_outlined,
        attributeKey: 'Service Type',
        options: <String>[
          'Fabric Sales',
          'Alteration Service',
          'Custom-Made Clothing',
        ],
      ),
      FilterDefinition.choice(
        label: 'Fabric Type',
        icon: Icons.category_outlined,
        attributeKey: 'Fabric Type',
        options: <String>[
          'Ankara/African Print',
          'Cotton',
          'Silk',
          'Lace',
          'Denim',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Turnaround Time',
        icon: Icons.tune,
        attributeKey: 'Turnaround Time',
        options: <String>[
          'Same Day',
          '1–3 Days',
          '4–7 Days',
          '1–2 Weeks+',
        ],
      ),
    ],
    'Toys & Games': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Educational Toys',
          'Action Figures',
          'Dolls',
          'Outdoor Toys',
          'Board Games',
          'Building Blocks/Lego',
        ],
      ),
      FilterDefinition.choice(
        label: 'Age Range',
        icon: Icons.child_care_outlined,
        attributeKey: 'Age Range',
        options: <String>[
          '0–2yr',
          '3–5yr',
          '6–8yr',
          '9–12yr',
          '13yr+',
        ],
      ),
    ],
    'Transport & Logistics': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Service Type',
        icon: Icons.handyman_outlined,
        attributeKey: 'Service Type',
        options: <String>[
          'Car Hire/Rental',
          'Courier/Delivery',
          'Moving/Relocation',
          'Boda-Boda Transport',
          'Cargo Transport',
        ],
      ),
      FilterDefinition.choice(
        label: 'Rate Type',
        icon: Icons.schedule_outlined,
        attributeKey: 'Rate Type',
        options: <String>[
          'Fixed',
          'Per Trip',
          'Per Km',
          'Per Day',
        ],
      ),
    ],
    'Tuk-tuk & Cargo': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Fuel Type',
        icon: Icons.local_gas_station_outlined,
        attributeKey: 'Fuel Type',
        options: <String>[
          'Petrol',
          'Diesel',
          'Electric',
        ],
      ),
      FilterDefinition.choice(
        label: 'Seating Capacity',
        icon: Icons.event_seat_outlined,
        attributeKey: 'Seating Capacity',
        options: <String>[
          '3',
          '4',
          '6+',
        ],
      ),
    ],
    'Vans': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Make/Model',
        icon: Icons.directions_car_outlined,
        attributeKey: 'Make/Model',
        options: <String>[
          'Toyota Hiace',
          'Nissan Urvan',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Use',
        icon: Icons.tune,
        attributeKey: 'Use',
        options: <String>[
          'Passenger',
          'Cargo',
        ],
      ),
      FilterDefinition.choice(
        label: 'Seating Capacity',
        icon: Icons.event_seat_outlined,
        attributeKey: 'Seating Capacity',
        options: <String>[
          '≤7',
          '8–14',
          '15+',
        ],
      ),
      FilterDefinition.range(
        label: 'Year',
        icon: Icons.event_outlined,
        attributeKey: 'Year',
      ),
    ],
    'Washing Machines': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Top Load',
          'Front Load',
          'Twin Tub',
          'Semi-Automatic',
          'Fully-Automatic',
        ],
      ),
      FilterDefinition.choice(
        label: 'Capacity',
        icon: Icons.inventory_2_outlined,
        attributeKey: 'Capacity',
        options: <String>[
          '≤5kg',
          '6–7kg',
          '8–9kg',
          '10kg+',
        ],
      ),
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'Samsung',
          'LG',
          'Hisense',
          'Other',
        ],
      ),
    ],
    'Watches & Wearables': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Analog Watch',
          'Digital Watch',
          'Smartwatch',
        ],
      ),
      FilterDefinition.choice(
        label: 'Gender',
        icon: Icons.wc_outlined,
        attributeKey: 'Gender',
        options: <String>[
          'Men',
          'Women',
          'Unisex',
        ],
      ),
    ],
    'Water Sports': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Swimming Gear',
          'Fishing Equipment',
          'Boat/Canoe',
          'Life Jacket',
          'Snorkeling Gear',
        ],
      ),
    ],
    'Wearables': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Smartwatch',
          'Fitness Tracker',
          'Smart Ring',
        ],
      ),
      FilterDefinition.choice(
        label: 'Brand',
        icon: Icons.branding_watermark_outlined,
        attributeKey: 'Brand',
        options: <String>[
          'Apple Watch',
          'Samsung Galaxy Watch',
          'Huawei',
          'Xiaomi Mi Band',
          'Other',
        ],
      ),
      FilterDefinition.choice(
        label: 'Compatibility',
        icon: Icons.tune,
        attributeKey: 'Compatibility',
        options: <String>[
          'Android',
          'iOS',
          'Both',
        ],
      ),
    ],
    'Wigs & Hair Care': <FilterDefinition>[
      FilterDefinition.choice(
        label: 'Type',
        icon: Icons.category_outlined,
        attributeKey: 'Type',
        options: <String>[
          'Wig',
          'Hair Extension',
          'Braiding Hair',
          'Hair Products/Shampoo',
          'Styling Tools',
        ],
      ),
      FilterDefinition.choice(
        label: 'Hair Type',
        icon: Icons.category_outlined,
        attributeKey: 'Hair Type',
        options: <String>[
          'Human Hair',
          'Synthetic',
        ],
      ),
      FilterDefinition.choice(
        label: 'Length',
        icon: Icons.straighten_outlined,
        attributeKey: 'Length',
        options: <String>[
          'Short (≤10")',
          'Medium (12–18")',
          'Long (20"+)',
        ],
      ),
    ],
  };

  /// Filters for [subcategory], in the order they should be shown.
  ///
  /// Price comes first, then the subcategory's own filters, then the rest
  /// of the universal set. Ordering matters because only the first few are
  /// visible before More: leading with all eight universal filters would
  /// bury Body Type and Transmission, which are the ones that make Cars
  /// different from Sofas. Price stays pinned because it is used in nearly
  /// every search regardless of category, and moving it around would cost
  /// more than the slot is worth.
  static List<FilterDefinition> forSubcategory(String? subcategory) {
    final specific = subcategory == null
        ? const <FilterDefinition>[]
        : bySubcategory[subcategory] ?? const <FilterDefinition>[];

    final price = universal.where(
      (f) => f.target == FilterTarget.price,
    );
    final rest = universal.where((f) => f.target != FilterTarget.price);

    return <FilterDefinition>[...price, ...specific, ...rest];
  }

  /// Whether [subcategory] has filters of its own beyond the universal set.
  static bool hasSpecificFilters(String? subcategory) =>
      subcategory != null && bySubcategory.containsKey(subcategory);
}
