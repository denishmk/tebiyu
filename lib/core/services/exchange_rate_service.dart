import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A central SSP to USD rate with the time it was set.
///
/// The timestamp is not decoration. SSP moves, the rate is maintained by
/// hand from the admin panel, and a converted price is only as trustworthy
/// as the last time somebody updated this number.
@immutable
class ExchangeRate {
  /// Creates a rate.
  const ExchangeRate({required this.sspPerUsd, required this.updatedAt});

  /// The rate the app falls back to before any remote value is loaded.
  ///
  /// Shipping a default rather than blocking on a fetch means conversion
  /// works on a first cold start with no connection. The cost is that a
  /// stale constant can ship to production unnoticed, which is what
  /// [isStale] guards against.
  factory ExchangeRate.fallback() => ExchangeRate(
    sspPerUsd: 7500,
    updatedAt: DateTime(2026, 8),
  );

  /// How many SSP one USD buys.
  final double sspPerUsd;

  /// When this rate was last set by an administrator.
  final DateTime updatedAt;

  /// Whether the rate is old enough that prices should not be converted.
  ///
  /// Past this point the honest thing is to show the seller's own quoted
  /// price rather than a conversion built on a number nobody has checked
  /// in a fortnight.
  bool get isStale =>
      DateTime.now().difference(updatedAt) > const Duration(days: 14);

  /// Converts [amount] from USD into SSP.
  double usdToSsp(double amount) => amount * sspPerUsd;

  /// Converts [amount] from SSP into USD.
  double sspToUsd(double amount) => amount / sspPerUsd;

  @override
  bool operator ==(Object other) =>
      other is ExchangeRate &&
      other.sspPerUsd == sspPerUsd &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(sspPerUsd, updatedAt);
}

/// Source of the current exchange rate.
///
/// Single method today, but kept as an interface rather than collapsed into
/// a function so the Firestore implementation can be swapped in through a
/// provider override, and so tests can supply a fixed rate.
// ignore: one_member_abstracts
abstract class ExchangeRateService {
  /// Fetches the rate currently set by an administrator.
  Future<ExchangeRate> fetchRate();
}

/// In-memory [ExchangeRateService] used until the admin panel exists.
///
/// Mirrors the listing repository pattern: same interface, a Firestore
/// implementation reading a single settings document slots in later without
/// touching anything above.
class MockExchangeRateService implements ExchangeRateService {
  /// Creates the mock service.
  const MockExchangeRateService();

  @override
  Future<ExchangeRate> fetchRate() async {
    return ExchangeRate(sspPerUsd: 7500, updatedAt: DateTime.now());
  }
}

/// The active [ExchangeRateService].
final Provider<ExchangeRateService> exchangeRateServiceProvider =
    Provider<ExchangeRateService>((ref) => const MockExchangeRateService());

/// The current exchange rate.
///
/// Holds [ExchangeRate.fallback] until a fetch lands, so the first frame can
/// convert prices instead of showing blanks while a future resolves.
final NotifierProvider<ExchangeRateNotifier, ExchangeRate>
exchangeRateProvider = NotifierProvider<ExchangeRateNotifier, ExchangeRate>(
  ExchangeRateNotifier.new,
);

/// Holds the exchange rate and refreshes it on demand.
class ExchangeRateNotifier extends Notifier<ExchangeRate> {
  @override
  ExchangeRate build() {
    // Fire the fetch without awaiting it. The fallback renders immediately
    // and the real rate replaces it a moment later, which beats holding the
    // whole feed back on a settings read.
    unawaited(Future<void>.microtask(refresh));
    return ExchangeRate.fallback();
  }

  /// Reloads the rate, keeping the previous value if the fetch fails.
  Future<void> refresh() async {
    try {
      state = await ref.read(exchangeRateServiceProvider).fetchRate();
    } on Object {
      // Keep whatever rate is already in hand. A failed refresh is not a
      // reason to stop converting prices.
    }
  }
}
