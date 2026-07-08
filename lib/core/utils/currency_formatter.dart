import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static String format(double value, {String currency = 'USD'}) {
    final symbol = _symbolFor(currency);
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(value);
  }

  static String formatSigned(double value, {String currency = 'USD'}) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${format(value, currency: currency)}';
  }

  static String formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatRatio(double? value) {
    if (value == null) return '—';
    return '${value.toStringAsFixed(2)}R';
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
