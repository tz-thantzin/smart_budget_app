import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/id_generator.dart';
import '../../di/app_providers.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/enums.dart';
import 'dashboard_viewmodel.dart';

final categoryViewModelProvider =
    AsyncNotifierProvider<CategoryViewModel, List<CategoryEntity>>(
      CategoryViewModel.new,
    );

class CategoryViewModel extends AsyncNotifier<List<CategoryEntity>> {
  @override
  Future<List<CategoryEntity>> build() async {
    return ref.read(getCategoriesUseCaseProvider).call();
  }

  Future<void> addCategory(
    String name,
    TransactionType type,
    int icon,
    int color,
  ) async {
    final category = CategoryEntity(
      id: newId(),
      name: name,
      type: type,
      iconCodePoint: icon,
      colorHex: color,
    );
    await ref.read(addCategoryUseCaseProvider).call(category);
    state = AsyncData(await ref.read(getCategoriesUseCaseProvider).call());
    ref.invalidate(dashboardViewModelProvider);
  }

  Future<void> updateCategory(CategoryEntity category) async {
    await ref.read(updateCategoryUseCaseProvider).call(category);
    state = AsyncData(await ref.read(getCategoriesUseCaseProvider).call());
    ref.invalidate(dashboardViewModelProvider);
  }

  Future<void> deleteCategory(String id) async {
    await ref.read(deleteCategoryUseCaseProvider).call(id);
    state = AsyncData(await ref.read(getCategoriesUseCaseProvider).call());
    ref.invalidate(dashboardViewModelProvider);
  }
}

CategoryEntity? findCategoryById(List<CategoryEntity> categories, String? id) {
  if (id == null || id.isEmpty) return null;
  for (final c in categories) {
    if (c.id == id) return c;
  }
  return null;
}
