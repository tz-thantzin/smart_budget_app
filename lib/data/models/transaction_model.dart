import 'dart:convert';

import '../../domain/entities/enums.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.categoryId,
    required super.walletAccountId,
    required super.dateTime,
    required super.currencyCode,
    required super.createdAt,
    required super.updatedAt,
    super.note,
    super.tags,
    super.receiptImagePath,
    super.isRecurring,
    super.recurrenceType,
  });

  factory TransactionModel.fromEntity(TransactionEntity entity) =>
      TransactionModel(
        id: entity.id,
        title: entity.title,
        amount: entity.amount,
        type: entity.type,
        categoryId: entity.categoryId,
        walletAccountId: entity.walletAccountId,
        note: entity.note,
        dateTime: entity.dateTime,
        tags: entity.tags,
        receiptImagePath: entity.receiptImagePath,
        isRecurring: entity.isRecurring,
        recurrenceType: entity.recurrenceType,
        currencyCode: entity.currencyCode,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  factory TransactionModel.fromMap(Map<String, Object?> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.byName(map['type'] as String),
      categoryId: map['category_id'] as String,
      walletAccountId: map['wallet_account_id'] as String,
      note: map['note'] as String?,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
      tags: List<String>.from(jsonDecode(map['tags'] as String) as List),
      receiptImagePath: map['receipt_image_path'] as String?,
      isRecurring: (map['is_recurring'] as int) == 1,
      recurrenceType: RecurrenceType.values.byName(
        map['recurrence_type'] as String,
      ),
      currencyCode: map['currency_code'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category_id': categoryId,
      'wallet_account_id': walletAccountId,
      'note': note,
      'date_time': dateTime.millisecondsSinceEpoch,
      'tags': jsonEncode(tags),
      'receipt_image_path': receiptImagePath,
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_type': recurrenceType.name,
      'currency_code': currencyCode,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
