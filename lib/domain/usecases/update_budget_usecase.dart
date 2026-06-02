import 'package:budget_app/domain/entities/budget_entity.dart';
import 'package:budget_app/domain/repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  const UpdateBudgetUseCase(this._repository);
  final BudgetRepository _repository;

  Future<BudgetEntity> call(BudgetEntity budget) =>
      _repository.updateBudget(budget);
}
