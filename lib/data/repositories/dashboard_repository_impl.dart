import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/local_database_datasource.dart';
import '../datasources/local_memory_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dataSource, this._databaseDataSource);
  final LocalMemoryDataSource _dataSource;
  final LocalDatabaseDataSource _databaseDataSource;

  @override
  Future<DashboardSummaryEntity> getDashboardSummary() async {
    final transactions = await _databaseDataSource.fetchTransactions();
    final categories = await _databaseDataSource.fetchCategories();

    final totalIncome = transactions
        .where((e) => e.type == TransactionType.income)
        .fold<double>(0, (prev, e) => prev + e.amount);
    final totalExpense = transactions
        .where((e) => e.type == TransactionType.expense)
        .fold<double>(0, (prev, e) => prev + e.amount);

    final expenseByCategory = <String, double>{};
    for (final txn in transactions.where(
      (e) => e.type == TransactionType.expense,
    )) {
      expenseByCategory[txn.categoryId] =
          (expenseByCategory[txn.categoryId] ?? 0) + txn.amount;
    }

    final topCategoryIds = expenseByCategory.keys.toList()
      ..sort((a, b) => expenseByCategory[b]!.compareTo(expenseByCategory[a]!));

    final topSpendingCategories = categories
        .where((cat) => topCategoryIds.take(3).contains(cat.id))
        .toList();

    return DashboardSummaryEntity(
      totalBalance: totalIncome - totalExpense,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      budgets: await _databaseDataSource.fetchBudgets(),
      recentTransactions: transactions.take(5).toList(),
      topSpendingCategories: topSpendingCategories,
      savingsGoals: _dataSource.savingsGoals,
    );
  }
}
