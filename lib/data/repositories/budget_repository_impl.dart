import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/local_database_datasource.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._dataSource);
  final LocalDatabaseDataSource _dataSource;

  @override
  Future<BudgetEntity> addBudget(BudgetEntity budget) async {
    return _dataSource.insertBudget(budget);
  }

  @override
  Future<BudgetEntity> updateBudget(BudgetEntity budget) async {
    return _dataSource.updateBudget(budget);
  }

  @override
  Future<void> deleteBudget(String id) async {
    return _dataSource.deleteBudget(id);
  }

  @override
  Future<List<BudgetEntity>> fetchBudgets() async => _dataSource.fetchBudgets();
}
