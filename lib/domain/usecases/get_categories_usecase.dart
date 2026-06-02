import 'package:budget_app/domain/entities/category_entity.dart';
import 'package:budget_app/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);
  final CategoryRepository _repository;
  Future<List<CategoryEntity>> call() => _repository.fetchCategories();
}
