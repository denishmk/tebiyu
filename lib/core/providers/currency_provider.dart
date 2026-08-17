import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/models/listing.dart';

/// Which prices the user wants to see.
enum CurrencyFilter {
  /// Show every listing at the price its seller quoted.
  all('All', null),

  /// Show only listings priced in South Sudanese Pounds.
  ssp('SSP', ListingCurrency.ssp),

  /// Show only listings priced in US Dollars.
  usd(r'USD ($)', ListingCurrency.usd);

  const CurrencyFilter(this.label, this.currency);

  /// Label shown in the Home screen selector.
  final String label;

  /// Currency this filter maps to, null for [all].
  final ListingCurrency? currency;

  /// Resolves a persisted value, defaulting to [all].
  static CurrencyFilter fromStorage(Object? value) {
    return CurrencyFilter.values.firstWhere(
      (filter) => filter.name == value,
      orElse: () => CurrencyFilter.all,
    );
  }
}

/// Holds the user's currency preference.
///
/// Persistence lands with the cache layer. Until then the choice survives
/// navigation but not an app restart.
class CurrencyFilterNotifier extends Notifier<CurrencyFilter> {
  @override
  CurrencyFilter build() => CurrencyFilter.all;

    /// The active filter.
  CurrencyFilter get filter => state;

  /// Changes the active filter.
  set filter(CurrencyFilter value) => state = value;
}

/// The currency filter applied to every price in the app.
final currencyFilterProvider =
    NotifierProvider<CurrencyFilterNotifier, CurrencyFilter>(
      CurrencyFilterNotifier.new,
    );
