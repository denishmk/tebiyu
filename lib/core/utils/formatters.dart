import 'dart:math';

import 'package:tebiyu/core/models/listing.dart';

/// Display formatting shared across listing surfaces.
///
/// Deliberately dependency free. `intl` would bring correct locale rules,
/// but Tebiyu formats exactly two currencies and one relative time scale,
/// and pulling in a localisation package before Arabic support is decided
/// would be adding weight for nothing.
abstract final class Formatters {
  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Formats [amount] with its currency, for example `SSP 1,150,000`.
  ///
  /// Amounts are rounded to whole units. SSP has no practical subunit in
  /// circulation, and USD prices in this market are quoted in whole
  /// dollars, so trailing decimals are noise on a card.
  static String price(double amount, ListingCurrency currency) {
    final grouped = _group(amount.round().abs());
    return switch (currency) {
      ListingCurrency.ssp => 'SSP $grouped',
      ListingCurrency.usd => r'$' + grouped,
    };
  }

  /// Rounds [value] to [digits] significant figures.
  ///
  /// Converted prices carry false precision otherwise. An SSP price divided
  /// by a hand-maintained rate lands on something like 153.33, and showing
  /// that implies the rate is accurate to the cent when it is a round number
  /// somebody typed into an admin panel last week.
  static double roundToSignificant(double value, {int digits = 3}) {
    if (value == 0) return 0;
    final magnitude = (log(value.abs()) / ln10).floor();
    final factor = pow(10, digits - 1 - magnitude).toDouble();
    return (value * factor).round() / factor;
  }

  /// Formats [time] as a short relative string, for example `3h ago`.
  ///
  /// Falls back to an absolute date beyond a week, because "42d ago" asks
  /// the reader to do arithmetic they did not sign up for.
  static String timeAgo(DateTime time, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final elapsed = reference.difference(time);

    if (elapsed.isNegative) return 'just now';
    if (elapsed.inMinutes < 1) return 'just now';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
    if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
    if (elapsed.inDays < 7) return '${elapsed.inDays}d ago';

    final month = _months[time.month - 1];
    if (time.year == reference.year) return '${time.day} $month';
    return '${time.day} $month ${time.year}';
  }

  /// Formats a duration as a coarse age, for example `2 days`.
  ///
  /// Used by the offline banner, which reads better with a word than with
  /// the compact card notation.
  static String age(Duration elapsed) {
    if (elapsed.inMinutes < 1) return 'moments';
    if (elapsed.inMinutes < 60) {
      final value = elapsed.inMinutes;
      return '$value ${value == 1 ? 'minute' : 'minutes'}';
    }
    if (elapsed.inHours < 24) {
      final value = elapsed.inHours;
      return '$value ${value == 1 ? 'hour' : 'hours'}';
    }
    final value = elapsed.inDays;
    return '$value ${value == 1 ? 'day' : 'days'}';
  }

  static String _group(int value) {
    final digits = value.toString();
    if (digits.length <= 3) return digits;

    final buffer = StringBuffer();
    final firstGroup = digits.length % 3;

    if (firstGroup > 0) buffer.write(digits.substring(0, firstGroup));

    for (var i = firstGroup; i < digits.length; i += 3) {
      if (buffer.isNotEmpty) buffer.write(',');
      buffer.write(digits.substring(i, i + 3));
    }

    return buffer.toString();
  }
}
