import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

@immutable
class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorHex,
  });

  final String id;
  final String name;
  final TransactionType type;
  final int iconCodePoint;
  final int colorHex;
}
