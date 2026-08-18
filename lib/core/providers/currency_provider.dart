import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tebiyu/core/models/listing.dart';
import 'package:tebiyu/core/services/exchange_rate_service.dart';
import 'package:tebiyu/core/utils/formatters.dart';

/// Which currency prices are displayed in.
enum CurrencyMode {
  /// Show each listing at the price its seller quoted.
  all('All'),

  /// Convert every price into South Sudanese Pounds.
  ssp('SSP'),

  /// Convert every price into US Dollars.
  usd('USD');

  const CurrencyMode(this.label);

  /// Label shown in the selector.
  final String label;

  /// The currency to render in, or null when showing sellers' own prices.
  ListingCurrency? get target => switch (this) {
        CurrencyMode.all => null,
        CurrencyMode.ssp => ListingCurrency.ssp,
        CurrencyMode.usd => ListingCurrency.usd,
      };
}

/// The active currency mode.
///
/// Defaults to [CurrencyMode.all], which shows what each seller actually
/// asked for. That is the only mode where no price on screen is an estimate.
final NotifierProvider<CurrencyModeNotifier, CurrencyMode>
    currencyModeProvider =
    NotifierProvider<CurrencyModeNotifier, CurrencyMode>(
  CurrencyModeNotifier.new,
);

/// Holds the currency mode.
class CurrencyModeNotifier extends Notifier<CurrencyMode> {
  @override
  CurrencyMode build() => CurrencyMode.all;

  /// The active mode.
  CurrencyMode get mode => state;

  /// Changes the active mode.
  set mode(CurrencyMode value) => state = value;
}

/// A price ready to render.
@immutable
class DisplayPrice {
  /// Creates a display price.
  const DisplayPrice({required this.text, required this.isApproximate});

  /// Formatted text, including any approximation marker.
  final String text;

  /// Whether this was converted rather than quoted by the seller.
  final bool isApproximate;

  @override
  bool operator ==(Object other) =>
      other is DisplayPrice &&
      other.text == text &&
      other.isApproximate == isApproximate;

  @override
  int get hashCode => Object.hash(text, isApproximate);
}

/// Turns a listing's price into text for the active currency mode.
///
/// Converted prices are marked with a leading `≈` and rounded to three
/// significant figures. Both choices are deliberate: the seller quoted one
/// number in one currency, and a clean unmarked figure in another currency
/// reads as the asking price. A buyer who arrives expecting to pay exactly
/// what the card said has been misled by the app, not by the seller.
@immutable
class PriceConverter {
  /// Creates a converter.
  const PriceConverter({required this.mode, required this.rate});

  /// The active currency mode.
  final CurrencyMode mode;

  /// The rate used for conversion.
  final ExchangeRate rate;

  /// Formats [listing]'s price.
  DisplayPrice format(Listing listing) {
    final target = mode.target;

    // No conversion wanted, already in the target currency, or the rate is
    // too old to stand behind. In every case, show what the seller asked.
    if (target == null || target == listing.currency || rate.isStale) {
      return DisplayPrice(
        text: Formatters.price(listing.price, listing.currency),
        isApproximate: false,
      );
    }

    final converted = switch (target) {
      ListingCurrency.usd => rate.sspToUsd(listing.price),
      ListingCurrency.ssp => rate.usdToSsp(listing.price),
    };

    return DisplayPrice(
      text: '≈ ${Formatters.price(
        Formatters.roundToSignificant(converted),
        target,
      )}',
      isApproximate: true,
    );
  }
}

/// The converter for the active mode and rate.
final Provider<PriceConverter> priceConverterProvider =
    Provider<PriceConverter>((ref) {
  return PriceConverter(
    mode: ref.watch(currencyModeProvider),
    rate: ref.watch(exchangeRateProvider),
  );
});
