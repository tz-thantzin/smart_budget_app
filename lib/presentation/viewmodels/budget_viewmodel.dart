import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/app_providers.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/transaction_entity.dart';
import 'dashboard_viewmodel.dart';

final budgetViewModelProvider =
    AsyncNotifierProvider<BudgetViewModel, List<BudgetEntity>>(
      BudgetViewModel.new,
    );

class BudgetViewModel extends AsyncNotifier<List<BudgetEntity>> {
  @override
  Future<List<BudgetEntity>> build() async {
    return _fetchBudgetsWithSpentAmounts();
  }

  Future<void> addBudget({
    required String title,
    required double amountLimit,
    required BudgetPeriodType periodType,
    String? categoryId,
  }) async {
    final now = DateTime.now();
    final budget = BudgetEntity(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      amountLimit: amountLimit,
      categoryId: categoryId,
      periodType: periodType,
      startDate: now,
      endDate: now.add(const Duration(days: 30)),
      spentAmount: 0,
      alertThresholdPercent: 0.8,
      rolloverEnabled: true,
    );
    await ref.read(addBudgetUseCaseProvider).call(budget);
    state = AsyncData(await _fetchBudgetsWithSpentAmounts());
    ref.invalidate(dashboardViewModelProvider);
  }

  Future<void> updateBudget(BudgetEntity budget) async {
    await ref.read(updateBudgetUseCaseProvider).call(budget);
    state = AsyncData(await _fetchBudgetsWithSpentAmounts());
    ref.invalidate(dashboardViewModelProvider);
  }

  Future<void> deleteBudget(String id) async {
    await ref.read(deleteBudgetUseCaseProvider).call(id);
    state = AsyncData(await _fetchBudgetsWithSpentAmounts());
    ref.invalidate(dashboardViewModelProvider);
  }

  Future<List<BudgetEntity>> _fetchBudgetsWithSpentAmounts() async {
    final budgets = await ref.read(getBudgetsUseCaseProvider).call();
    final transactions = await ref.read(getTransactionsUseCaseProvider).call();

    return budgets.map((budget) {
      final spentAmount = transactions
          .where((transaction) => _appliesToBudget(transaction, budget))
          .fold<double>(0, (total, transaction) => total + transaction.amount);
      return budget.copyWith(spentAmount: spentAmount);
    }).toList();
  }

  bool _appliesToBudget(TransactionEntity transaction, BudgetEntity budget) {
    if (transaction.type != TransactionType.expense) return false;

    final transactionDate = _dateOnly(transaction.dateTime);
    final startDate = _dateOnly(budget.startDate);
    final endDate = _dateOnly(budget.endDate);
    if (transactionDate.isBefore(startDate)) return false;
    if (transactionDate.isAfter(endDate)) return false;

    final budgetCategoryId = budget.categoryId;
    if (budgetCategoryId == null || budgetCategoryId.isEmpty) return true;

    return transaction.categoryId == budgetCategoryId;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
