import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget_app/core/utils/id_generator.dart';
import 'package:budget_app/di/app_providers.dart';
import 'package:budget_app/domain/entities/budget_entity.dart';
import 'package:budget_app/domain/entities/category_entity.dart';
import 'package:budget_app/domain/entities/enums.dart';
import 'package:budget_app/domain/entities/transaction_entity.dart';
import 'package:budget_app/presentation/viewmodels/dashboard_viewmodel.dart';

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
      id: newId(),
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

BudgetEntity? budgetNeedingAlert(
  List<BudgetEntity> budgets,
  String? categoryId,
) {
  final matching = budgets
      .where(
        (b) =>
            b.amountLimit > 0 &&
            _matchesBudgetCategory(b, categoryId) &&
            b.usagePercent >= b.alertThresholdPercent,
      )
      .toList()
    ..sort((a, b) => b.usagePercent.compareTo(a.usagePercent));
  return matching.isEmpty ? null : matching.first;
}

bool _matchesBudgetCategory(BudgetEntity budget, String? categoryId) {
  final budgetCategoryId = budget.categoryId;
  if (budgetCategoryId == null || budgetCategoryId.isEmpty) return true;
  return budgetCategoryId == categoryId;
}

List<CategoryEntity> expenseCategories(List<CategoryEntity> all) =>
    all.where((c) => c.type == TransactionType.expense).toList();
