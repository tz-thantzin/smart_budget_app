import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local_database_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource);
  final LocalDatabaseDataSource _dataSource;

  @override
  Future<CategoryEntity> addCategory(CategoryEntity category) async {
    return _dataSource.insertCategory(category);
  }

  @override
  Future<List<CategoryEntity>> fetchCategories() async {
    return _dataSource.fetchCategories();
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    return _dataSource.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    return _dataSource.deleteCategory(id);
  }
}
