import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/app_providers.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/transaction_entity.dart';
import 'budget_viewmodel.dart';
import 'dashboard_viewmodel.dart';

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
    final txn = TransactionEntity(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId ?? '',
      walletAccountId: walletAccountId,
      note: note,
      dateTime: transactionDateTime,
      currencyCode: 'USD',
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
