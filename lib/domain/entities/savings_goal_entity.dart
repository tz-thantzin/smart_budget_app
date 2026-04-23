class SavingsGoalEntity {
  const SavingsGoalEntity({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;

  double get progress => targetAmount == 0 ? 0 : currentAmount / targetAmount;
}
