import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  const UpdateTransactionUseCase(this._repository);
  final TransactionRepository _repository;
  Future<TransactionEntity> call(TransactionEntity transaction) =>
      _repository.updateTransaction(transaction);
}
