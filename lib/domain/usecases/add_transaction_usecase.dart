import 'package:budget_app/domain/entities/transaction_entity.dart';
import 'package:budget_app/domain/repositories/transaction_repository.dart';

class AddTransactionUseCase {
  const AddTransactionUseCase(this._repository);
  final TransactionRepository _repository;
  Future<TransactionEntity> call(TransactionEntity transaction) =>
      _repository.addTransaction(transaction);
}
