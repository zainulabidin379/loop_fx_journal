import 'package:flutter/services.dart';

abstract final class NumberFormatter {
  static const int decimalPlaces = 2;

  static String format(double? value, {String fallback = '—'}) {
    if (value == null) return fallback;
    return value.toStringAsFixed(decimalPlaces);
  }

  static String formatInput(double? value) {
    if (value == null) return '';
    return format(value);
  }

  static double round(double value) {
    return double.parse(value.toStringAsFixed(decimalPlaces));
  }

  static double? roundNullable(double? value) {
    if (value == null) return null;
    return round(value);
  }

  static String formatString(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    return format(parsed);
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter({this.decimalPlaces = NumberFormatter.decimalPlaces});

  final int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final pattern = RegExp('^\\d*\\.?\\d{0,$decimalPlaces}\$');
    if (pattern.hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}
