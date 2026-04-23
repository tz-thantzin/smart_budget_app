import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/biometric_auth_service.dart';
import '../data/datasources/local_database_datasource.dart';
import '../data/datasources/local_memory_datasource.dart';
import '../data/repositories/budget_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/dashboard_repository_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/usecases/add_budget_usecase.dart';
import '../domain/usecases/add_category_usecase.dart';
import '../domain/usecases/add_transaction_usecase.dart';
import '../domain/usecases/delete_budget_usecase.dart';
import '../domain/usecases/delete_transaction_usecase.dart';
import '../domain/usecases/delete_category_usecase.dart';
import '../domain/usecases/get_budgets_usecase.dart';
import '../domain/usecases/get_categories_usecase.dart';
import '../domain/usecases/get_dashboard_summary_usecase.dart';
import '../domain/usecases/get_transactions_usecase.dart';
import '../domain/usecases/update_transaction_usecase.dart';
import '../domain/usecases/update_budget_usecase.dart';
import '../domain/usecases/update_category_usecase.dart';

final localDataSourceProvider = Provider<LocalMemoryDataSource>((ref) {
  return LocalMemoryDataSource();
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

final localDatabaseDataSourceProvider = Provider<LocalDatabaseDataSource>((
  ref,
) {
  return LocalDatabaseDataSource();
});

final transactionRepositoryProvider = Provider<TransactionRepositoryImpl>((
  ref,
) {
  return TransactionRepositoryImpl(ref.watch(localDatabaseDataSourceProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepositoryImpl>((ref) {
  return CategoryRepositoryImpl(ref.watch(localDatabaseDataSourceProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepositoryImpl>((ref) {
  return BudgetRepositoryImpl(ref.watch(localDatabaseDataSourceProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepositoryImpl>((ref) {
  return DashboardRepositoryImpl(
    ref.watch(localDataSourceProvider),
    ref.watch(localDatabaseDataSourceProvider),
  );
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(ref.watch(transactionRepositoryProvider));
});
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(ref.watch(transactionRepositoryProvider));
});
final updateTransactionUseCaseProvider = Provider<UpdateTransactionUseCase>((
  ref,
) {
  return UpdateTransactionUseCase(ref.watch(transactionRepositoryProvider));
});
final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((
  ref,
) {
  return DeleteTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});
final addCategoryUseCaseProvider = Provider<AddCategoryUseCase>((ref) {
  return AddCategoryUseCase(ref.watch(categoryRepositoryProvider));
});
final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});
final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final getBudgetsUseCaseProvider = Provider<GetBudgetsUseCase>((ref) {
  return GetBudgetsUseCase(ref.watch(budgetRepositoryProvider));
});
final addBudgetUseCaseProvider = Provider<AddBudgetUseCase>((ref) {
  return AddBudgetUseCase(ref.watch(budgetRepositoryProvider));
});
final updateBudgetUseCaseProvider = Provider<UpdateBudgetUseCase>((ref) {
  return UpdateBudgetUseCase(ref.watch(budgetRepositoryProvider));
});
final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  return DeleteBudgetUseCase(ref.watch(budgetRepositoryProvider));
});

final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummaryUseCase>(
  (ref) {
    return GetDashboardSummaryUseCase(ref.watch(dashboardRepositoryProvider));
  },
);
