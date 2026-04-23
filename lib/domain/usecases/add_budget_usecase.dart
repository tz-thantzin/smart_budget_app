import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class AddBudgetUseCase {
  const AddBudgetUseCase(this._repository);
  final BudgetRepository _repository;
  Future<BudgetEntity> call(BudgetEntity budget) => _repository.addBudget(budget);
}
