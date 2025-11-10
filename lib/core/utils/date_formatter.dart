import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime? date, {String format = 'dd MMMM yyyy'}) {
    if (date == null) return '-';
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime? date) {
    return formatDate(date, format: 'dd MMMM yyyy, HH:mm');
  }

  static String formatCurrency(num? amount) {
    if (amount == null) return '-';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}