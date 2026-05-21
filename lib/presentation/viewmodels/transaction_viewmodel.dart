import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/id_generator.dart';
import '../../di/app_providers.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/transaction_entity.dart';
import 'budget_viewmodel.dart';
import 'dashboard_viewmodel.dart';
import 'settings_viewmodel.dart';

final transactionListViewModelProvider =
    AsyncNotifierProvider<TransactionListViewModel, List<TransactionEntity>>(
      TransactionListViewModel.new,
    );

class TransactionListViewModel extends AsyncNotifier<List<TransactionEntity>> {
  @override
  Future<List<TransactionEntity>> build() async {
    return ref.read(getTransactionsUseCaseProvider).call();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    String? categoryId,
    required String walletAccountId,
    String? note,
    DateTime? dateTime,
  }) async {
    final now = DateTime.now();
    final transactionDateTime = dateTime ?? now;
    final currencyCode = ref.read(currentCurrencyCodeProvider);
    final txn = TransactionEntity(
      id: newId(),
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId ?? '',
      walletAccountId: walletAccountId,
      note: note,
      dateTime: transactionDateTime,
      currencyCode: currencyCode.isEmpty
          ? AppConstants.defaultCurrency
          : currencyCode,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(addTransactionUseCaseProvider).call(txn);
    state = AsyncData(await ref.read(getTransactionsUseCaseProvider).call());
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(budgetViewModelProvider);
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    await ref.read(updateTransactionUseCaseProvider).call(transaction);
    state = AsyncData(await ref.read(getTransactionsUseCaseProvider).call());
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(budgetViewModelProvider);
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(deleteTransactionUseCaseProvider).call(id);
    state = AsyncData(await ref.read(getTransactionsUseCaseProvider).call());
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(budgetViewModelProvider);
  }
}

List<CategoryEntity> categoriesForType(
  List<CategoryEntity> all,
  TransactionType type,
) =>
    all.where((c) => c.type == type).toList();

String? validatedCategoryId(
  String? categoryId,
  List<CategoryEntity> matching,
) {
  if (categoryId == null) return null;
  return matching.any((c) => c.id == categoryId) ? categoryId : null;
}

List<TransactionEntity> filterAndSortTransactions(
  List<TransactionEntity> items, {
  required String query,
  required bool onlyExpense,
  required DateTime? selectedDate,
}) {
  var result = query.isEmpty
      ? items.toList()
      : items
            .where(
              (e) => e.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
  if (onlyExpense) {
    result = result.where((e) => e.type == TransactionType.expense).toList();
  }
  if (selectedDate != null) {
    result = result
        .where((e) => _sameCalendarDay(e.dateTime, selectedDate))
        .toList();
  }
  result.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  return result;
}

bool _sameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
