import '../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  const DeleteTransactionUseCase(this._repository);
  final TransactionRepository _repository;

  Future<void> call(String id) => _repository.deleteTransaction(id);
}
