import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.iconCodePoint,
    required super.colorHex,
  });

  factory CategoryModel.fromEntity(CategoryEntity entity) => CategoryModel(
        id: entity.id,
        name: entity.name,
        type: entity.type,
        iconCodePoint: entity.iconCodePoint,
        colorHex: entity.colorHex,
      );
}
