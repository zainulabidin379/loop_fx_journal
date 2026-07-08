import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy · HH:mm');
  static final DateFormat _date = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDate = DateFormat('MM/dd/yy');

  static String formatDateTime(DateTime date) => _dateTime.format(date);
  static String formatDate(DateTime date) => _date.format(date);
  static String formatShortDate(DateTime date) => _shortDate.format(date);
}
