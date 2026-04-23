import '../repositories/budget_repository.dart';

class DeleteBudgetUseCase {
  const DeleteBudgetUseCase(this._repository);
  final BudgetRepository _repository;

  Future<void> call(String id) => _repository.deleteBudget(id);
}
