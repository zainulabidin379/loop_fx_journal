abstract final class Validators {
  static String? required(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) return '$field must be a positive number';
    return null;
  }

  static String? nonNegativeNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null || parsed < 0) return '$field must be a valid number';
    return null;
  }
}
