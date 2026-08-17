import 'package:flutter/foundation.dart';

/// The location filter currently applied to listings.
///
/// Three states are possible, and the distinction matters to the feed query:
/// no filter at all, a whole city, or a single area within a city.
@immutable
class SelectedLocation {
  /// Creates a location filter.
  const SelectedLocation({this.city, this.area});

  /// No filter. Listings from everywhere.
  const SelectedLocation.everywhere() : city = null, area = null;

  /// The chosen city, or null when browsing everywhere.
  final String? city;

  /// The chosen area within [city], or null for the whole city.
  ///
  /// Never set without a [city].
  final String? area;

  /// Whether no location filter is applied.
  bool get isEverywhere => city == null;

  /// Whether the filter is narrowed to a single area.
  bool get hasArea => area != null;

  /// Short label for the home screen chip.
  String get label {
    if (city == null) return 'All locations';
    if (area == null) return city!;
    return area!;
  }

  /// Full label, used where there is room for the city as well.
  String get fullLabel {
    if (city == null) return 'All locations';
    if (area == null) return city!;
    return '$area, $city';
  }

  /// Returns a copy with the area cleared, keeping the city.
  SelectedLocation withoutArea() => SelectedLocation(city: city);

  @override
  bool operator ==(Object other) =>
      other is SelectedLocation && other.city == city && other.area == area;

  @override
  int get hashCode => Object.hash(city, area);

  @override
  String toString() => 'SelectedLocation($fullLabel)';
}
