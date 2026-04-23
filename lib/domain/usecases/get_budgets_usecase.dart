import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class GetBudgetsUseCase {
  const GetBudgetsUseCase(this._repository);
  final BudgetRepository _repository;
  Future<List<BudgetEntity>> call() => _repository.fetchBudgets();
}
