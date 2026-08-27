import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/constants/listing_filters.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_shadows.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/features/results/providers/results_providers.dart';

/// Opens a sheet for [definitions].
///
/// Pass one definition for a single filter, or the whole list for More.
/// Editing happens on a draft and only lands on Apply: live-applying every
/// tap refetches the list underneath someone who has not finished choosing.
Future<void> showResultsFilterSheet(
  BuildContext context, {
  required ResultsScope scope,
  required List<FilterDefinition> definitions,
  String title = 'Filters',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => ResultsFilterSheet(
      scope: scope,
      definitions: definitions,
      title: title,
    ),
  );
}

/// Editable filter controls.
class ResultsFilterSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const ResultsFilterSheet({
    required this.scope,
    required this.definitions,
    this.title = 'Filters',
    super.key,
  });

  /// Which results screen these filters belong to.
  final ResultsScope scope;

  /// Filters to show.
  final List<FilterDefinition> definitions;

  /// Sheet heading.
  final String title;

  @override
  ConsumerState<ResultsFilterSheet> createState() => _ResultsFilterSheetState();
}

class _ResultsFilterSheetState extends ConsumerState<ResultsFilterSheet> {
  late ResultsFilters _draft = ref.read(
    resultsFiltersProvider(widget.scope),
  );

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  TextEditingController _controllerFor(String key, String initial) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _apply() {
    var next = _draft;

    // Price bounds live outside the attribute maps, so they are read back
    // from their controllers separately.
    final min = double.tryParse(_text('price.min'));
    final max = double.tryParse(_text('price.max'));
    if (_controllers.containsKey('price.min') ||
        _controllers.containsKey('price.max')) {
      final swap = min != null && max != null && min > max;
      next = next.copyWith(clearPrices: true).copyWith(
            minPrice: swap ? max : min,
            maxPrice: swap ? min : max,
          );
    }

    final ranges = Map<String, ({num? min, num? max})>.of(
      next.attributeRanges,
    );
    for (final definition in widget.definitions) {
      final key = definition.attributeKey;
      if (definition.input != FilterInput.range || key == null) continue;
      if (!_controllers.containsKey('$key.min') &&
          !_controllers.containsKey('$key.max')) {
        continue;
      }
      final low = num.tryParse(_text('$key.min'));
      final high = num.tryParse(_text('$key.max'));
      if (low == null && high == null) {
        ranges.remove(key);
      } else {
        final swap = low != null && high != null && low > high;
        ranges[key] = (
          min: swap ? high : low,
          max: swap ? low : high,
        );
      }
    }

    ref.read(resultsFiltersProvider(widget.scope).notifier).filters =
        next.copyWith(attributeRanges: ranges);
    Navigator.of(context).pop();
  }

  String _text(String key) => _controllers[key]?.text.trim() ?? '';

  void _reset() {
    setState(() {
      _draft = ResultsFilters(sort: _draft.sort);
      for (final controller in _controllers.values) {
        controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: context.bottomSheetSurface(),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.title,
                          style: AppTextStyles.h3.copyWith(
                            color: colors.primaryText,
                          ),
                        ),
                      ),
                      TextButton(onPressed: _reset, child: const Text('Reset')),
                    ],
                  ),
                  for (final definition in widget.definitions) ...<Widget>[
                    AppSpacing.gapMd,
                    Text(
                      definition.label,
                      style: AppTextStyles.h4.copyWith(
                        color: colors.primaryText,
                      ),
                    ),
                    AppSpacing.gapSm,
                    _editorFor(definition),
                  ],
                  AppSpacing.gapXl,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _apply,
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editorFor(FilterDefinition definition) {
    switch (definition.target) {
      case FilterTarget.offerType:
        return _Choices(
          labels: <String>[
            'All',
            for (final type in ListingType.values) type.label,
          ],
          selected: _draft.type == null ? 'All' : _draft.type!.label,
          onSelected: (label) => setState(() {
            _draft = label == 'All'
                ? _draft.copyWith(clearType: true)
                : _draft.copyWith(
                    type: ListingType.values.firstWhere(
                      (type) => type.label == label,
                    ),
                  );
          }),
        );

      case FilterTarget.condition:
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final condition in ListingCondition.values)
              _Chip(
                label: condition.label,
                selected: _draft.conditions.contains(condition),
                onTap: () => setState(() {
                  final next = Set<ListingCondition>.of(_draft.conditions);
                  if (!next.remove(condition)) next.add(condition);
                  _draft = _draft.copyWith(conditions: next);
                }),
              ),
          ],
        );

      case FilterTarget.negotiable:
        return SwitchListTile.adaptive(
          value: _draft.negotiableOnly,
          contentPadding: EdgeInsets.zero,
          onChanged: (value) => setState(
            () => _draft = _draft.copyWith(negotiableOnly: value),
          ),
          title: Text(
            'Negotiable only',
            style: AppTextStyles.body.copyWith(
              color: context.colors.primaryText,
            ),
          ),
        );

      case FilterTarget.price:
        return _RangeFields(
          minController: _controllerFor(
            'price.min',
            _draft.minPrice?.round().toString() ?? '',
          ),
          maxController: _controllerFor(
            'price.max',
            _draft.maxPrice?.round().toString() ?? '',
          ),
          // Prices are held in each seller's own currency, so a range
          // cannot span both without converting through a rate that may be
          // stale. Saying so beats quietly dropping SSP listings from a
          // range a buyer typed in dollars.
          hint: 'Matched in each listing\u2019s own currency.',
        );

      case FilterTarget.attribute:
        final key = definition.attributeKey!;
        if (definition.input == FilterInput.range) {
          final range = _draft.attributeRanges[key];
          return _RangeFields(
            minController: _controllerFor(
              '$key.min',
              range?.min?.toString() ?? '',
            ),
            maxController: _controllerFor(
              '$key.max',
              range?.max?.toString() ?? '',
            ),
            hint: definition.unit == null
                ? null
                : 'Values in ${definition.unit}.',
          );
        }
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final option in definition.options)
              _Chip(
                label: option,
                selected: _draft.attributes[key] == option,
                onTap: () => setState(() {
                  final next = Map<String, String>.of(_draft.attributes);
                  // Tapping the selected option clears it, so a filter can
                  // be undone without hunting for a Reset.
                  if (next[key] == option) {
                    next.remove(key);
                  } else {
                    next[key] = option;
                  }
                  _draft = _draft.copyWith(attributes: next);
                }),
              ),
          ],
        );
    }
  }
}

class _Choices extends StatelessWidget {
  const _Choices({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final label in labels)
          _Chip(
            label: label,
            selected: label == selected,
            onTap: () => onSelected(label),
          ),
      ],
    );
  }
}

class _RangeFields extends StatelessWidget {
  const _RangeFields({
    required this.minController,
    required this.maxController,
    this.hint,
  });

  final TextEditingController minController;
  final TextEditingController maxController;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _field(minController, 'Min')),
            AppSpacing.hGapMd,
            Expanded(child: _field(maxController, 'Max')),
          ],
        ),
        if (hint != null) ...<Widget>[
          AppSpacing.gapXs,
          Text(
            hint!,
            style: AppTextStyles.caption.copyWith(
              color: context.colors.secondaryText,
            ),
          ),
        ],
      ],
    );
  }

  Widget _field(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(hintText: hintText),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: selected ? colors.brand : colors.secondaryBackground,
      borderRadius: AppRadius.allPill,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: selected ? colors.onBrand : colors.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}
