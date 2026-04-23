import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  const UpdateBudgetUseCase(this._repository);
  final BudgetRepository _repository;

  Future<BudgetEntity> call(BudgetEntity budget) =>
      _repository.updateBudget(budget);
}
