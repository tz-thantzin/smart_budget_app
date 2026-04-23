import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  const GetTransactionsUseCase(this._repository);
  final TransactionRepository _repository;
  Future<List<TransactionEntity>> call() => _repository.fetchTransactions();
}
