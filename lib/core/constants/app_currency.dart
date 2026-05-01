enum AppCurrency {
  usd(code: 'USD', symbol: r'$', label: 'USD (\$)', decimalDigits: 2),
  thb(code: 'THB', symbol: '฿', label: 'Baht (฿)', decimalDigits: 2),
  mmk(code: 'MMK', symbol: 'Ks', label: 'MMK (Ks)', decimalDigits: 0),
  eur(code: 'EUR', symbol: '€', label: 'EUR (€)', decimalDigits: 2),
  sgd(code: 'SGD', symbol: 'S\$', label: 'SGD (S\$)', decimalDigits: 2),
  jpy(code: 'JPY', symbol: '¥', label: 'JPY (¥)', decimalDigits: 0),
  cny(code: 'CNY', symbol: '¥', label: 'CNY (Yuan)', decimalDigits: 2),
  krw(code: 'KRW', symbol: '₩', label: 'KRW (Won)', decimalDigits: 0);

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.label,
    required this.decimalDigits,
  });

  final String code;
  final String symbol;
  final String label;
  final int decimalDigits;

  static AppCurrency fromCode(String code) {
    return AppCurrency.values.firstWhere(
      (currency) => currency.code == code,
      orElse: () => AppCurrency.usd,
    );
  }
}
