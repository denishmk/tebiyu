import 'package:flutter/material.dart';

/// A top level category in Tebiyu's taxonomy.
@immutable
class TebiyuCategory {
  /// Creates a category.
  const TebiyuCategory({required this.name, required this.icon});

  /// Display name, also the value stored on a listing.
  final String name;

  /// Icon shown in the category row and sidebar.
  final IconData icon;
}

/// Tebiyu's thirteen top level categories.
///
/// The single source of truth for category names. Listings store these
/// strings, so renaming one here without migrating existing documents will
/// orphan every listing that used the old name.
abstract final class Categories {
  /// Every top level category, in display order.
  static const List<TebiyuCategory> all = <TebiyuCategory>[
    TebiyuCategory(name: 'Electronics & Appliances', icon: Icons.devices),
    TebiyuCategory(
      name: 'Mobile Phones & Accessories',
      icon: Icons.smartphone,
    ),
    TebiyuCategory(name: 'Properties', icon: Icons.apartment),
    TebiyuCategory(name: 'Home & Garden', icon: Icons.chair_outlined),
    TebiyuCategory(name: 'Fashion', icon: Icons.checkroom),
    TebiyuCategory(name: 'Vehicles', icon: Icons.directions_car_outlined),
    TebiyuCategory(name: 'Farm & Agriculture', icon: Icons.agriculture),
    TebiyuCategory(name: 'Beauty & Personal Care', icon: Icons.spa_outlined),
    TebiyuCategory(name: 'Sports & Leisure', icon: Icons.sports_soccer),
    TebiyuCategory(name: 'Services', icon: Icons.handyman_outlined),
    TebiyuCategory(name: 'Baby & Kids', icon: Icons.child_friendly_outlined),
    TebiyuCategory(
      name: 'Commercial Equipment & Tools',
      icon: Icons.construction_outlined,
    ),
    TebiyuCategory(name: 'Jobs', icon: Icons.work_outline),
  ];

  /// A short label for the category row, where full names do not fit.
  ///
  /// Only the long names are shortened. Anything absent falls back to its
  /// full name.
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
}
