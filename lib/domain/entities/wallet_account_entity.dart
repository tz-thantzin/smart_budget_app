import 'enums.dart';

class WalletAccountEntity {
  const WalletAccountEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyCode,
    required this.balance,
  });

  final String id;
  final String name;
  final WalletType type;
  final String currencyCode;
  final double balance;
}
