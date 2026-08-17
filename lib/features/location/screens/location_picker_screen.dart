import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tebiyu/core/constants/south_sudan_locations.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/theme.dart';
import 'package:tebiyu/features/location/data/location_providers.dart';

/// Picks the city listings are filtered to.
///
/// Tapping a city opens its areas rather than selecting it outright, since a
/// buyer in Juba cares which side of town a sofa is on. Choosing the whole
/// city stays available as an explicit option on the next screen.
class LocationPickerScreen extends ConsumerStatefulWidget {
  /// Creates the city picker.
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _searchController = TextEditingController();

  String _query = '';
  bool _isDetecting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SsCity> get _matchingCities {
    if (_query.isEmpty) return SouthSudanLocations.cities;
    final query = _query.toLowerCase();
    return SouthSudanLocations.cities
        .where(
          (city) =>
              city.name.toLowerCase().contains(query) ||
              city.state.toLowerCase().contains(query),
        )
        .toList();
  }

  /// Areas matching the query, across every city.
  ///
  /// People think in neighbourhoods before they think in cities. Someone
  /// typing "Munuki" should not have to know it is in Juba to find it.
  List<({SsCity city, String area})> get _matchingAreas {
    if (_query.isEmpty) return const [];
    final query = _query.toLowerCase();
    final matches = <({SsCity city, String area})>[];

    for (final city in SouthSudanLocations.cities) {
      for (final area in city.areas) {
        if (area.toLowerCase().contains(query)) {
          matches.add((city: city, area: area));
        }
      }
    }
    return matches;
  }

  Future<void> _detect() async {
    setState(() => _isDetecting = true);

    try {
      final city = await ref.read(locationDetectorProvider).detectCity();
      if (!mounted) return;
      setState(() => _isDetecting = false);
      await context.push(Routes.locationAreasPath(city.name));
    } on LocationFailure catch (failure) {
      if (!mounted) return;
      setState(() => _isDetecting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> _selectEverywhere() async {
    await ref.read(locationProvider.notifier).selectEverywhere();
    if (!mounted) return;
    context.pop();
  }

  Future<void> _selectArea(SsCity city, String area) async {
    await ref
        .read(locationProvider.notifier)
        .selectArea(city: city.name, area: area);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = ref.watch(locationProvider);
    final cities = _matchingCities;
    final areas = _matchingAreas;

    return Scaffold(
      backgroundColor: colors.appBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My location',
              style: AppTextStyles.h3.copyWith(color: colors.primaryText),
            ),
            Text(
              'Select your location to see listings in your area',
              style: AppTextStyles.caption.copyWith(
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          Padding(
            padding: AppSpacing.screenHorizontal,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: 'Search city or area',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          AppSpacing.gapLg,

          if (_query.isEmpty) ...[
            Padding(
              padding: AppSpacing.screenHorizontal,
              child: Container(
                decoration: context.cardSurface(),
                padding: AppSpacing.card,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.secondaryBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.my_location,
                        size: 22,
                        color: colors.primaryIcon,
                      ),
                    ),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use my current location',
                            style: AppTextStyles.h4.copyWith(
                              color: colors.primaryText,
                            ),
                          ),
                          Text(
                            'Find the closest city automatically',
                            style: AppTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isDetecting)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.brand,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        color: colors.brand,
                        onPressed: _detect,
                      ),
                  ],
                ),
              ),
            ),
            AppSpacing.gapXl,
            const _SectionLabel('All locations'),
            _LocationTile(
              title: 'All locations',
              subtitle: 'Listings from every city',
              isSelected: selected.isEverywhere,
              onTap: _selectEverywhere,
            ),
            AppSpacing.gapLg,
          ],

          if (areas.isNotEmpty) ...[
            const _SectionLabel('Areas'),
            for (final match in areas)
              _LocationTile(
                title: match.area,
                subtitle: '${match.city.name}, ${match.city.state}',
                isSelected:
                    selected.city == match.city.name &&
                    selected.area == match.area,
                onTap: () => _selectArea(match.city, match.area),
              ),
            AppSpacing.gapLg,
          ],

          if (cities.isNotEmpty) ...[
            _SectionLabel(_query.isEmpty ? 'Cities' : 'Cities and towns'),
            for (final city in cities)
              _LocationTile(
                title: city.name,
                subtitle: '${city.state} · ${city.areas.length} areas',
                isSelected: selected.city == city.name,
                showChevron: true,
                onTap: () => context.push(Routes.locationAreasPath(city.name)),
              ),
          ],

          if (cities.isEmpty && areas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 40,
                    color: colors.secondaryIcon,
                  ),
                  AppSpacing.gapMd,
                  Text(
                    'No match for "$_query"',
                    style: AppTextStyles.body.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

          AppSpacing.gapXl,
          Padding(
            padding: AppSpacing.screenHorizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.public,
                  size: 16,
                  color: colors.secondaryIcon,
                ),
                AppSpacing.hGapSm,
                Expanded(
                  child: Text(
                    'Listings are shown based on your selected location. You '
                    'can change this anytime in settings.',
                    style: AppTextStyles.caption.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A section heading inside the location lists.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: context.colors.secondaryText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// A selectable row in the location lists.
class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.showChevron = false,
  });

  final String title;
  final String? subtitle;
  final bool isSelected;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: isSelected ? colors.secondaryBackground : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h4.copyWith(
                        color: isSelected ? colors.brand : colors.primaryText,
                      ),
                    ),
                    if (subtitle != null) ...[
                      AppSpacing.gapXs,
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, size: 22, color: colors.brand)
              else if (showChevron)
                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: colors.secondaryIcon,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
