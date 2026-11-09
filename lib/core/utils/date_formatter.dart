import 'package:intl/intl.dart';

/// Date formatting utilities for student transaction groupings.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE, MMM d');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  /// Returns 'MMMM yyyy' e.g. 'November 2026'
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Returns 'MMM d, yyyy' e.g. 'Oct 24, 2026'
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Returns friendly relative headers: 'Today', 'Yesterday', or 'Monday, Nov 9'
  static String formatRelativeHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final difference = today.difference(target).inDays;
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return _dayOfWeekFormat.format(date);
    }
  }

  /// ISO 8601 YYYY-MM-DD for SQL/Supabase
  static String toIso(DateTime date) {
    return _isoFormat.format(date);
  }

  /// Parse from ISO string
  static DateTime fromIso(String dateStr) {
    return DateTime.parse(dateStr);
  }
}
