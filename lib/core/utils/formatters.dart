import 'package:intl/intl.dart';

import 'package:budget_app/core/constants/app_constants.dart';
import 'package:budget_app/core/constants/app_currency.dart';

class Formatters {
  static String currency(
    double amount, {
    String currencyCode = AppConstants.defaultCurrency,
  }) {
    final currency = AppCurrency.fromCode(currencyCode);
    return NumberFormat.currency(
      name: currency.code,
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    ).format(amount);
  }

  static String date(DateTime date) => DateFormat('dd MMM yyyy').format(date);
}
