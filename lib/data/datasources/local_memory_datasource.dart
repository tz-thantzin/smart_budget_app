import 'package:budget_app/domain/entities/savings_goal_entity.dart';

class LocalMemoryDataSource {
  LocalMemoryDataSource() {
    final now = DateTime.now();
    savingsGoals = [
      SavingsGoalEntity(
        id: 's1',
        title: 'Emergency Fund',
        targetAmount: 10000,
        currentAmount: 3800,
        targetDate: DateTime(now.year + 1, now.month),
      ),
    ];
  }

  late List<SavingsGoalEntity> savingsGoals;
}
