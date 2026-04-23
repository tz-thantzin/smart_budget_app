import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local_database_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._dataSource);
  final LocalDatabaseDataSource _dataSource;

  @override
  Future<TransactionEntity> addTransaction(
    TransactionEntity transaction,
  ) async {
    return _dataSource.insertTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    return _dataSource.deleteTransaction(id);
  }

  @override
  Future<List<TransactionEntity>> fetchTransactions() async {
    return _dataSource.fetchTransactions();
  }

  @override
  Future<TransactionEntity> updateTransaction(
    TransactionEntity transaction,
  ) async {
    return _dataSource.updateTransaction(transaction);
  }
}
