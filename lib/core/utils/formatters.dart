import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, {String currency = 'USD'}) {
    return NumberFormat.currency(name: currency, symbol: '\$').format(amount);
  }

  static String date(DateTime date) => DateFormat('dd MMM yyyy').format(date);
}
