import 'package:intl/intl.dart';

/// Formatter for Pakistani Rupee currency values with comma separation.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'en_US');

  /// Formats [amount] as 'Rs. 1,500' or '1,500'
  static String format(num amount, {bool includeSymbol = true}) {
    final formatted = _numberFormat.format(amount.abs());
    if (!includeSymbol) return formatted;
    return 'Rs. $formatted';
  }

  /// Formats with explicit +/- sign e.g. '+Rs. 15,000' or '-Rs. 450'
  static String formatSigned(num amount, {required bool isIncome}) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix${format(amount)}';
  }
}
