import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> fetchCategories();
  Future<CategoryEntity> addCategory(CategoryEntity category);
  Future<CategoryEntity> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
}
