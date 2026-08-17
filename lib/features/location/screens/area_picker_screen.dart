import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tebiyu/core/constants/south_sudan_locations.dart';
import 'package:tebiyu/core/theme/theme.dart';
import 'package:tebiyu/features/location/data/location_providers.dart';

/// Picks an area within a city.
///
/// Reached by tapping a city on the previous screen. Selecting here pops both
/// screens so the user returns to what they were doing rather than being left
/// staring at the city list they have just finished with.
class AreaPickerScreen extends ConsumerStatefulWidget {
  /// Creates the area picker for [cityName].
  const AreaPickerScreen({required this.cityName, super.key});

  /// The city whose areas are listed.
  final String cityName;

  @override
  ConsumerState<AreaPickerScreen> createState() => _AreaPickerScreenState();
}

class _AreaPickerScreenState extends ConsumerState<AreaPickerScreen> {
  final _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectWholeCity(SsCity city) async {
    await ref.read(locationProvider.notifier).selectCity(city.name);
    if (!mounted) return;
    _leave();
  }

  Future<void> _selectArea(SsCity city, String area) async {
    await ref
        .read(locationProvider.notifier)
        .selectArea(city: city.name, area: area);
    if (!mounted) return;
    _leave();
  }

  /// Pops this screen and the city list beneath it.
  void _leave() {
    context.pop();
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final city = SouthSudanLocations.byName(widget.cityName);

    if (city == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            'Unknown city',
            style: AppTextStyles.body.copyWith(color: colors.secondaryText),
          ),
        ),
      );
    }

    final selected = ref.watch(locationProvider);
    final areas = _query.isEmpty
        ? city.areas
        : city.areas
              .where(
                (area) => area.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return Scaffold(
      backgroundColor: colors.appBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              city.name,
              style: AppTextStyles.h3.copyWith(color: colors.primaryText),
            ),
            Text(
              'Choose an area, or the whole city',
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
                hintText: 'Search areas in ${city.name}',
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

          if (_query.isEmpty)
            _AreaTile(
              title: 'All of ${city.name}',
              subtitle: 'Listings from every area',
              isSelected: selected.city == city.name && !selected.hasArea,
              onTap: () => _selectWholeCity(city),
            ),

          if (areas.isEmpty)
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
                    'No area matching "$_query"',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final area in areas)
              _AreaTile(
                title: area,
                isSelected: selected.city == city.name && selected.area == area,
                onTap: () => _selectArea(city, area),
              ),
        ],
      ),
    );
  }
}

class _AreaTile extends StatelessWidget {
  const _AreaTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool isSelected;
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
                Icon(Icons.check_circle, size: 22, color: colors.brand),
            ],
          ),
        ),
      ),
    );
  }
}
