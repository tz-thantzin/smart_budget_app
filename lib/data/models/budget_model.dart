import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/enums.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.title,
    required super.amountLimit,
    required super.periodType,
    required super.startDate,
    required super.endDate,
    required super.spentAmount,
    required super.alertThresholdPercent,
    required super.rolloverEnabled,
    super.categoryId,
  });

  factory BudgetModel.fromEntity(BudgetEntity entity) => BudgetModel(
    id: entity.id,
    title: entity.title,
    amountLimit: entity.amountLimit,
    categoryId: entity.categoryId,
    periodType: entity.periodType,
    startDate: entity.startDate,
    endDate: entity.endDate,
    spentAmount: entity.spentAmount,
    alertThresholdPercent: entity.alertThresholdPercent,
    rolloverEnabled: entity.rolloverEnabled,
  );

  factory BudgetModel.fromMap(Map<String, Object?> map) {
    return BudgetModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amountLimit: (map['amount_limit'] as num).toDouble(),
      categoryId: map['category_id'] as String?,
      periodType: BudgetPeriodType.values.byName(map['period_type'] as String),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      spentAmount: (map['spent_amount'] as num).toDouble(),
      alertThresholdPercent: (map['alert_threshold_percent'] as num).toDouble(),
      rolloverEnabled: (map['rollover_enabled'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount_limit': amountLimit,
      'category_id': categoryId,
      'period_type': periodType.name,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'spent_amount': spentAmount,
      'alert_threshold_percent': alertThresholdPercent,
      'rollover_enabled': rolloverEnabled ? 1 : 0,
    };
  }
}
