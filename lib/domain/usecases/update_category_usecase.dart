import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  const UpdateCategoryUseCase(this._repository);
  final CategoryRepository _repository;

  Future<CategoryEntity> call(CategoryEntity category) =>
      _repository.updateCategory(category);
}
