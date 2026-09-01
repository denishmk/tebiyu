import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/providers/currency_provider.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';
import 'package:tebiyu/features/search/providers/search_providers.dart';

/// The search entry screen.
///
/// Suggestions are matching listings rather than guessed query strings. A
/// buyer typing "toyo" wants the Toyota that is for sale, not the word
/// "Toyota", and showing the item saves them a hop through a results page.
class SearchScreen extends ConsumerStatefulWidget {
  /// Creates the search screen.
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Clear any text left from a previous visit, so opening search always
    // starts from a blank field rather than someone else's query.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).text = '';
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;

    // Recording the term is a side effect the navigation should not wait
    // on: a slow disk write must not delay showing the results.
    unawaited(ref.read(recentSearchesProvider.notifier).add(trimmed));
    unawaited(context.push(Routes.resultsFor(search: trimmed)));
  }

  void _fill(String term) {
    _controller
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    ref.read(searchQueryProvider.notifier).text = term;
    _submit(term);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider).trim();
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            textInputAction: TextInputAction.search,
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).text = value,
            onSubmitted: _submit,
            decoration: InputDecoration(
              hintText: 'Search for anything...',
              prefixIcon: Icon(Icons.search, color: colors.secondaryIcon),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchQueryProvider.notifier).text = '';
                      },
                      icon: Icon(Icons.close, color: colors.secondaryIcon),
                    ),
            ),
          ),
        ),
      ),
      body: query.length < 2
          ? _Discovery(onSelect: _fill)
          : _Suggestions(query: query, onSeeAll: () => _submit(query)),
    );
  }
}

class _Discovery extends ConsumerWidget {
  const _Discovery({required this.onSelect});

  /// Runs a term the user tapped rather than typed.
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentSearchesProvider).valueOrNull ??
        const <String>[];
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        if (recent.isNotEmpty) ...<Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Recent searches',
                  style: AppTextStyles.h4.copyWith(color: colors.primaryText),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
          AppSpacing.gapSm,
          for (final term in recent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Icons.history, color: colors.secondaryIcon),
              title: Text(
                term,
                style: AppTextStyles.body.copyWith(color: colors.primaryText),
              ),
              trailing: IconButton(
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).remove(term),
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: colors.secondaryIcon,
                ),
                tooltip: 'Remove',
              ),
              onTap: () => onSelect(term),
            ),
          AppSpacing.gapLg,
        ],
        Text(
          'Trending searches',
          style: AppTextStyles.h4.copyWith(color: colors.primaryText),
        ),
        AppSpacing.gapMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final term in trendingSearches)
              ActionChip(
                label: Text(term),
                avatar: Icon(
                  Icons.trending_up,
                  size: 16,
                  color: colors.primaryIcon,
                ),
                onPressed: () => onSelect(term),
              ),
          ],
        ),
      ],
    );
  }
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.query, required this.onSeeAll});

  final String query;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(searchSuggestionsProvider);
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.search, color: colors.brand),
          title: Text(
            'Search for "$query"',
            style: AppTextStyles.body.copyWith(color: colors.primaryText),
          ),
          onTap: onSeeAll,
        ),
        const Divider(height: 1),
        ...switch (suggestions) {
          AsyncLoading<List<Listing>>() => <Widget>[
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          AsyncError<List<Listing>>() => <Widget>[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Could not reach search right now.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
              ),
            ],
          AsyncValue<List<Listing>>(:final value?) => value.isEmpty
              ? <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'Nothing matches "$query" yet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                ]
              : <Widget>[
                  for (final listing in value)
                    _SuggestionTile(listing: listing),
                ],
          _ => const <Widget>[],
        },
      ],
    );
  }
}

class _SuggestionTile extends ConsumerWidget {
  const _SuggestionTile({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final cover = listing.coverImage;
    final price = ref.watch(priceConverterProvider).format(listing);

    return ListTile(
      leading: ClipRRect(
        borderRadius: AppRadius.allXs,
        child: SizedBox(
          width: 48,
          height: 48,
          child: cover == null
              ? ColoredBox(
                  color: colors.secondaryBackground,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 18,
                    color: colors.secondaryIcon,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: cover,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      ColoredBox(color: colors.secondaryBackground),
                  errorWidget: (context, url, error) => ColoredBox(
                    color: colors.secondaryBackground,
                  ),
                ),
        ),
      ),
      title: Text(
        listing.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.body.copyWith(color: colors.primaryText),
      ),
      subtitle: Text(
        '${price.text}  ·  ${listing.locationLabel}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(color: colors.secondaryText),
      ),
      onTap: () => context.push(Routes.listingPath(listing.id)),
    );
  }
}
