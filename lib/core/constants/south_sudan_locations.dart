/// A South Sudan city or town Tebiyu operates in.
class SsCity {
  /// Creates a city entry.
  const SsCity({
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.areas,
  });

  /// Display name, for example Juba.
  final String name;

  /// The state the city sits in, shown as a subtitle to disambiguate.
  final String state;

  /// Approximate town centre latitude.
  final double latitude;

  /// Approximate town centre longitude.
  final double longitude;

  /// Residential areas and neighbourhoods within the city.
  final List<String> areas;
}

/// Tebiyu's location data.
///
/// Shipped with the app rather than fetched. Three reasons: the picker has to
/// work on a poor connection, Places API calls cost money on every open, and
/// Google's neighbourhood coverage outside Juba is thin enough that a curated
/// list is simply more accurate.
///
/// The area lists below are a starting point compiled from map data and should
/// be corrected against local knowledge, particularly for the smaller towns.
/// Getting these names right matters more than it looks: an area name is what
/// a buyer scans to judge whether a listing is worth the trip.
abstract final class SouthSudanLocations {
  /// Every city Tebiyu covers, in rough order of expected listing volume.
  static const List<SsCity> cities = [
    SsCity(
      name: 'Juba',
      state: 'Central Equatoria',
      latitude: 4.8594,
      longitude: 31.5713,
      areas: [
        'Atlabara',
        'Buluk',
        'Custom',
        'Gudele',
        'Gumbo',
        'Gurei',
        'Hai Amarat',
        'Hai Cinema',
        'Hai Jalaba',
        'Hai Malakal',
        'Hai Referendum',
        'Jebel',
        'Juba Na Bari',
        'Kator',
        'Khor William',
        'Konyo Konyo',
        'Lologo',
        'Luri',
        'Malakia',
        'Munuki',
        'New Site',
        'Northern Bari',
        'Nyakuron',
        'Rejaf',
        'Rock City',
        'Sherikat',
        'Thongpiny',
        'Tongping',
      ],
    ),
    SsCity(
      name: 'Wau',
      state: 'Western Bahr el Ghazal',
      latitude: 7.7014,
      longitude: 27.9895,
      areas: [
        'Baggari',
        'Eastern Bank',
        'Grinti',
        'Hai Jalaba',
        'Hai Masna',
        'Hai Salam',
        'Hillet Sikka',
        'Jebel Kheir',
        'Lokoloko',
        'Nazareth',
      ],
    ),
    SsCity(
      name: 'Malakal',
      state: 'Upper Nile',
      latitude: 9.5334,
      longitude: 31.6605,
      areas: [
        'Assosa',
        'Hai Dar Salaam',
        'Hai Masna',
        'Hai Salam',
        'Lelo',
        'Malakal Town',
        'Malakia',
        'Ogot',
      ],
    ),
    SsCity(
      name: 'Yei',
      state: 'Central Equatoria',
      latitude: 4.0905,
      longitude: 30.6780,
      areas: [
        'Bazi',
        'Hai Jalaba',
        'Hai Salam',
        'Kondokoro',
        'Logo',
        'Mongo',
        'Rubeke',
        'Yei Town',
      ],
    ),
    SsCity(
      name: 'Bor',
      state: 'Jonglei',
      latitude: 6.2088,
      longitude: 31.5591,
      areas: [
        'Anyidi',
        'Bor Town',
        'Hai Malakal',
        'Langbar',
        'Makuach',
        'Malualchat',
        'Marol',
        'Panpandiar',
      ],
    ),
    SsCity(
      name: 'Torit',
      state: 'Eastern Equatoria',
      latitude: 4.4133,
      longitude: 32.5678,
      areas: [
        'Hai Jalaba',
        'Hai Salam',
        'Ifwotu',
        'Imurok',
        'Nyong',
        'Torit Town',
      ],
    ),
    SsCity(
      name: 'Rumbek',
      state: 'Lakes',
      latitude: 6.8000,
      longitude: 29.6769,
      areas: [
        'Agangrial',
        'Amongpiny',
        'Malou-pec',
        'Matangai',
        'Nyang',
        'Rumbek Town',
      ],
    ),
    SsCity(
      name: 'Aweil',
      state: 'Northern Bahr el Ghazal',
      latitude: 8.7667,
      longitude: 27.4000,
      areas: [
        'Apada',
        'Aweil Town',
        'Gakrol',
        'Hai Salam',
        'Maper',
        'Wanyjok',
      ],
    ),
    SsCity(
      name: 'Nimule',
      state: 'Eastern Equatoria',
      latitude: 3.5951,
      longitude: 32.0553,
      areas: ['Kerepi', 'Loa', 'Moli', 'Mugali', 'Nimule Town', 'Opari'],
    ),
    SsCity(
      name: 'Magwi',
      state: 'Eastern Equatoria',
      latitude: 4.1333,
      longitude: 32.2833,
      areas: [
        'Lobone',
        'Magwi Town',
        'Obbo',
        'Owiny Ki-Bul',
        'Pageri',
        'Palotaka',
      ],
    ),
  ];

  /// Finds a city by [name], or null if it is not in the list.
  static SsCity? byName(String name) {
    for (final city in cities) {
      if (city.name.toLowerCase() == name.toLowerCase()) return city;
    }
    return null;
  }

  /// The city nearest to the given coordinates.
  ///
  /// Used instead of reverse geocoding. A geocoder asked about a point in
  /// South Sudan often returns an empty result or a state name rather than a
  /// town, whereas matching against a known list always yields something
  /// usable, works with no connection, and costs nothing.
  ///
  /// Distance is computed on a flat approximation with a latitude correction.
  /// Over the spans involved here the error is far smaller than the gap
  /// between any two cities on the list.
  static SsCity nearestTo(double latitude, double longitude) {
    var closest = cities.first;
    var smallest = double.infinity;

    for (final city in cities) {
      final dy = city.latitude - latitude;
      final dx = (city.longitude - longitude) * 0.996;
      final distance = (dy * dy) + (dx * dx);
      if (distance < smallest) {
        smallest = distance;
        closest = city;
      }
    }

    return closest;
  }
}
