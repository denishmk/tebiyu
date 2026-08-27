import 'package:flutter/material.dart';

/// What a filter acts on.
enum FilterTarget {
  /// The sale or hire flag on the listing itself.
  offerType,

  /// The price range.
  price,

  /// The condition enum.
  condition,

  /// The negotiable flag.
  negotiable,

  /// A key inside the listing's `attributes` map.
  attribute,
}

/// How a filter is entered.
enum FilterInput {
  /// Pick one of a fixed set of values.
  choice,

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
    this.unit,
  });

  /// A choice filter over an attribute.
  const FilterDefinition.choice({
    required this.label,
    required this.icon,
    required String this.attributeKey,
    required this.options,
  })  : target = FilterTarget.attribute,
        input = FilterInput.choice,
        unit = null;

  /// A numeric range filter over an attribute.
  const FilterDefinition.range({
    required this.label,
    required this.icon,
    required String this.attributeKey,
    this.unit,
  })  : target = FilterTarget.attribute,
        input = FilterInput.range,
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

  /// Allowed values for a [FilterInput.choice] filter.
  ///
  /// Filters only offer fixed options, never free text. A seller typing
  /// "toyota" and another typing "Toyota" would produce two values that
  /// never match one another, and neither would match a buyer's filter.
  final List<String> options;

  /// Unit suffix shown beside a range, such as `km` or `m²`.
  final String? unit;
}

/// Filters available per subcategory.
///
/// Subcategories with no entry fall back to [generic]. That is a deliberate
/// default rather than a gap: a category nobody has characterised yet still
/// filters by price and condition, which is better than showing nothing.
abstract final class ListingFilters {
  /// Filters that apply to anything for sale.
  static const List<FilterDefinition> generic = <FilterDefinition>[
    FilterDefinition(
      label: 'Sale or hire',
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
  ];

  static const List<FilterDefinition> _vehicle = <FilterDefinition>[
    ...generic,
    FilterDefinition.range(
      label: 'Year',
      icon: Icons.event_outlined,
      attributeKey: 'Year',
    ),
    FilterDefinition.choice(
      label: 'Transmission',
      icon: Icons.settings_outlined,
      attributeKey: 'Transmission',
      options: <String>['Automatic', 'Manual'],
    ),
    FilterDefinition.choice(
      label: 'Fuel',
      icon: Icons.local_gas_station_outlined,
      attributeKey: 'Fuel',
      options: <String>['Petrol', 'Diesel', 'Hybrid', 'Electric'],
    ),
    FilterDefinition.range(
      label: 'Mileage',
      icon: Icons.speed_outlined,
      attributeKey: 'Mileage',
      unit: 'km',
    ),
    FilterDefinition.choice(
      label: 'Registration',
      icon: Icons.confirmation_number_outlined,
      attributeKey: 'Registration',
      options: <String>[
        'South Sudan plate',
        'Foreign plate',
        'Unregistered',
      ],
    ),
  ];

  static const List<FilterDefinition> _dwelling = <FilterDefinition>[
    ...generic,
    FilterDefinition.choice(
      label: 'Bedrooms',
      icon: Icons.bed_outlined,
      attributeKey: 'Bedrooms',
      options: <String>['1', '2', '3', '4', '5+'],
    ),
    FilterDefinition.choice(
      label: 'Bathrooms',
      icon: Icons.bathtub_outlined,
      attributeKey: 'Bathrooms',
      options: <String>['1', '2', '3', '4+'],
    ),
    FilterDefinition.choice(
      label: 'Furnished',
      icon: Icons.chair_outlined,
      attributeKey: 'Furnished',
      options: <String>['Furnished', 'Semi furnished', 'Unfurnished'],
    ),
    FilterDefinition.choice(
      label: 'Parking',
      icon: Icons.local_parking_outlined,
      attributeKey: 'Parking',
      options: <String>['None', '1 car', '2 cars', '3+ cars'],
    ),
  ];

  static const List<FilterDefinition> _land = <FilterDefinition>[
    ...generic,
    FilterDefinition.range(
      label: 'Plot size',
      icon: Icons.crop_square_outlined,
      attributeKey: 'Size',
      unit: 'm²',
    ),
    FilterDefinition.choice(
      label: 'Title',
      icon: Icons.description_outlined,
      attributeKey: 'Title',
      options: <String>['Freehold', 'Leasehold', 'Customary'],
    ),
    FilterDefinition.choice(
      label: 'Fenced',
      icon: Icons.fence_outlined,
      attributeKey: 'Fenced',
      options: <String>['Yes', 'No'],
    ),
  ];

  static const List<FilterDefinition> _phone = <FilterDefinition>[
    ...generic,
    FilterDefinition.choice(
      label: 'Brand',
      icon: Icons.branding_watermark_outlined,
      attributeKey: 'Brand',
      options: <String>[
        'Samsung',
        'Apple',
        'Tecno',
        'Infinix',
        'itel',
        'Xiaomi',
        'Oppo',
        'Huawei',
        'Nokia',
      ],
    ),
    FilterDefinition.choice(
      label: 'Storage',
      icon: Icons.sd_storage_outlined,
      attributeKey: 'Storage',
      options: <String>['32GB', '64GB', '128GB', '256GB', '512GB', '1TB'],
    ),
    FilterDefinition.choice(
      label: 'RAM',
      icon: Icons.memory_outlined,
      attributeKey: 'RAM',
      options: <String>['2GB', '3GB', '4GB', '6GB', '8GB', '12GB'],
    ),
  ];

  static const List<FilterDefinition> _computer = <FilterDefinition>[
    ...generic,
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
      ],
    ),
    FilterDefinition.choice(
      label: 'Processor',
      icon: Icons.developer_board_outlined,
      attributeKey: 'Processor',
      options: <String>[
        'Core i3',
        'Core i5',
        'Core i7',
        'Core i9',
        'Ryzen',
        'Celeron',
        'Apple M series',
      ],
    ),
    FilterDefinition.choice(
      label: 'RAM',
      icon: Icons.memory_outlined,
      attributeKey: 'RAM',
      options: <String>['4GB', '8GB', '16GB', '32GB', '64GB'],
    ),
    FilterDefinition.choice(
      label: 'Storage',
      icon: Icons.sd_storage_outlined,
      attributeKey: 'Storage',
      options: <String>['128GB', '256GB', '512GB', '1TB', '2TB'],
    ),
  ];

  static const List<FilterDefinition> _livestock = <FilterDefinition>[
    ...generic,
    FilterDefinition.choice(
      label: 'Animal',
      icon: Icons.pets_outlined,
      attributeKey: 'Animal',
      options: <String>[
        'Cattle',
        'Goats',
        'Sheep',
        'Poultry',
        'Camels',
        'Donkeys',
      ],
    ),
    FilterDefinition.range(
      label: 'Quantity',
      icon: Icons.numbers_outlined,
      attributeKey: 'Quantity',
    ),
  ];

  static const List<FilterDefinition> _job = <FilterDefinition>[
    FilterDefinition.choice(
      label: 'Employment',
      icon: Icons.work_outline,
      attributeKey: 'Employment',
      options: <String>[
        'Full-time',
        'Part-time',
        'Contract',
        'Freelance',
        'Internship',
      ],
    ),
    FilterDefinition.choice(
      label: 'Experience',
      icon: Icons.trending_up_outlined,
      attributeKey: 'Experience',
      options: <String>[
        'Entry level',
        '1-3 years',
        '3-5 years',
        '5+ years',
      ],
    ),
    FilterDefinition(
      label: 'Salary range',
      icon: Icons.payments_outlined,
      target: FilterTarget.price,
      input: FilterInput.range,
    ),
  ];

  static const List<FilterDefinition> _clothing = <FilterDefinition>[
    ...generic,
    FilterDefinition.choice(
      label: 'Size',
      icon: Icons.straighten_outlined,
      attributeKey: 'Size',
      options: <String>['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'],
    ),
    FilterDefinition.choice(
      label: 'Gender',
      icon: Icons.wc_outlined,
      attributeKey: 'Gender',
      options: <String>['Men', 'Women', 'Unisex', 'Children'],
    ),
  ];

  /// Filters keyed by subcategory name.
  ///
  /// Vehicles share one schema, dwellings another, and so on. Authoring a
  /// separate list per subcategory would be a hundred near-copies, and the
  /// copies would fall out of step the first time one was edited.
  static const Map<String, List<FilterDefinition>> bySubcategory =
      <String, List<FilterDefinition>>{
    'Cars': _vehicle,
    'SUV': _vehicle,
    'Pickup Trucks': _vehicle,
    'Vans': _vehicle,
    'Buses': _vehicle,
    'Motorcycles': _vehicle,
    'Tuk-tuk & Cargo': _vehicle,
    'Heavy Machinery': _vehicle,
    'Houses': _dwelling,
    'Apartments': _dwelling,
    'Commercial Properties': _dwelling,
    'Land & Plots': _land,
    'Farmland': _land,
    'Mobile Phones': _phone,
    'Computers & Laptops': _computer,
    'Livestock': _livestock,
    'Casual Jobs': _job,
    'NGO & INGO Jobs': _job,
    'Company Jobs': _job,
    'Clothing': _clothing,
    'Footwear': _clothing,
  };

  /// Filters for [subcategory], falling back to [generic].
  static List<FilterDefinition> forSubcategory(String? subcategory) {
    if (subcategory == null) return generic;
    return bySubcategory[subcategory] ?? generic;
  }
}
