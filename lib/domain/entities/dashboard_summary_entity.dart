import 'budget_entity.dart';
import 'category_entity.dart';
import 'savings_goal_entity.dart';
import 'transaction_entity.dart';

class DashboardSummaryEntity {
  const DashboardSummaryEntity({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.budgets,
    required this.recentTransactions,
    required this.topSpendingCategories,
    required this.savingsGoals,
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<BudgetEntity> budgets;
  final List<TransactionEntity> recentTransactions;
  final List<CategoryEntity> topSpendingCategories;
  final List<SavingsGoalEntity> savingsGoals;
}
