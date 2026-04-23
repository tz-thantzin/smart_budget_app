import 'enums.dart';

class BudgetEntity {
  const BudgetEntity({
    required this.id,
    required this.title,
    required this.amountLimit,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.spentAmount,
    required this.alertThresholdPercent,
    required this.rolloverEnabled,
    this.categoryId,
  });

  final String id;
  final String title;
  final double amountLimit;
  final String? categoryId;
  final BudgetPeriodType periodType;
  final DateTime startDate;
  final DateTime endDate;
  final double spentAmount;
  final double alertThresholdPercent;
  final bool rolloverEnabled;

  double get usagePercent => amountLimit == 0 ? 0 : spentAmount / amountLimit;

  BudgetEntity copyWith({
    String? id,
    String? title,
    double? amountLimit,
    String? categoryId,
    BudgetPeriodType? periodType,
    DateTime? startDate,
    DateTime? endDate,
    double? spentAmount,
    double? alertThresholdPercent,
    bool? rolloverEnabled,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amountLimit: amountLimit ?? this.amountLimit,
      categoryId: categoryId ?? this.categoryId,
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      spentAmount: spentAmount ?? this.spentAmount,
      alertThresholdPercent:
          alertThresholdPercent ?? this.alertThresholdPercent,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
    );
  }
}
