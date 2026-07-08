import 'package:intl/intl.dart';

import 'number_formatter.dart';

abstract final class CurrencyFormatter {
  static String format(double value, {String currency = 'USD'}) {
    final symbol = _symbolFor(currency);
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(value);
  }

  static String formatPercent(double value) {
    return '${NumberFormatter.format(value)}%';
  }

  static String formatRatio(double? value) {
    if (value == null) return '—';
    return '${NumberFormatter.format(value)}R';
  }

  static String _symbolFor(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return '\$';
    }
  }
}
