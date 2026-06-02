import 'package:budget_app/domain/entities/budget_entity.dart';
import 'package:budget_app/domain/entities/category_entity.dart';
import 'package:budget_app/domain/entities/savings_goal_entity.dart';
import 'package:budget_app/domain/entities/transaction_entity.dart';

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
