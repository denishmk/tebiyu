import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:tebiyu/core/constants/south_sudan_locations.dart';
import 'package:tebiyu/core/services/preferences_service.dart';
import 'package:tebiyu/features/location/models/selected_location.dart';

/// The location read from storage at startup.
///
/// Overridden in `main` before the app builds, so the home screen's location
/// chip renders correct on the first frame instead of flashing a default and
/// then correcting itself.
final Provider<SelectedLocation> initialLocationProvider =
    Provider<SelectedLocation>(
      (ref) => throw UnimplementedError(
        'initialLocationProvider must be overridden in main',
      ),
    );

/// The active location filter.
final NotifierProvider<LocationNotifier, SelectedLocation> locationProvider =
    NotifierProvider<LocationNotifier, SelectedLocation>(LocationNotifier.new);

/// Holds and persists the location filter.
class LocationNotifier extends Notifier<SelectedLocation> {
  @override
  SelectedLocation build() => ref.watch(initialLocationProvider);

  /// Clears the filter so listings come from everywhere.
  Future<void> selectEverywhere() =>
      _apply(const SelectedLocation.everywhere());

  /// Filters to a whole city.
  Future<void> selectCity(String city) => _apply(SelectedLocation(city: city));

  /// Filters to a single area within a city.
  Future<void> selectArea({required String city, required String area}) =>
      _apply(SelectedLocation(city: city, area: area));

  Future<void> _apply(SelectedLocation location) async {
    state = location;
    await PreferencesService.setLocation(location);
  }
}

/// Why a location lookup failed.
/// Why a location lookup failed.
enum LocationFailureReason {
  /// Location services are switched off on the device.
  serviceDisabled,

  /// The user declined the permission prompt.
  permissionDenied,

  /// The user declined permanently and must change it in system settings.
  permissionDeniedForever,

  /// The fix could not be obtained, usually a timeout indoors.
  unavailable,
}

/// A location lookup failure with a message fit to show a user.
class LocationFailure implements Exception {
  /// Creates a failure for [reason].
  LocationFailure(this.reason) : message = _messageFor(reason);

  /// What went wrong.
  final LocationFailureReason reason;

  /// Human readable explanation.
  final String message;

  static String _messageFor(LocationFailureReason reason) {
    return switch (reason) {
      LocationFailureReason.serviceDisabled =>
        'Location is turned off. Switch it on and try again.',
      LocationFailureReason.permissionDenied =>
        'Tebiyu needs location access to find listings near you.',
      LocationFailureReason.permissionDeniedForever =>
        'Location access is blocked. Enable it in your device settings.',
      LocationFailureReason.unavailable =>
        'Could not get your location. Pick a city from the list instead.',
    };
  }

  @override
  String toString() => 'LocationFailure(${reason.name}): $message';
}

/// Resolves the device's position to one of Tebiyu's cities.
///
/// Deliberately does not reverse geocode. A geocoder asked about a point in
/// South Sudan frequently returns nothing usable, or a state rather than a
/// town. Matching the fix against the known city list always yields a real
/// answer, needs no network, and costs nothing per call.
class LocationDetector {
  /// Returns the nearest city, or throws [LocationFailure] on failure.
  Future<SsCity> detectCity() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationFailure(LocationFailureReason.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationFailure(LocationFailureReason.permissionDeniedForever);
    }
    if (permission == LocationPermission.denied) {
      throw LocationFailure(LocationFailureReason.permissionDenied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // Medium accuracy is plenty. The result is only used to pick the
          // nearest of ten cities hundreds of kilometres apart, and a coarser
          // fix arrives faster and uses less battery.
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return SouthSudanLocations.nearestTo(
        position.latitude,
        position.longitude,
      );
    } on Exception {
      throw LocationFailure(LocationFailureReason.unavailable);
    }
  }
}

/// The app wide [LocationDetector].
final Provider<LocationDetector> locationDetectorProvider =
    Provider<LocationDetector>((ref) => LocationDetector());
