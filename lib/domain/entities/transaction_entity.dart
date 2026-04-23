import 'enums.dart';

class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletAccountId,
    required this.dateTime,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.tags = const [],
    this.receiptImagePath,
    this.isRecurring = false,
    this.recurrenceType = RecurrenceType.none,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String walletAccountId;
  final String? note;
  final DateTime dateTime;
  final List<String> tags;
  final String? receiptImagePath;
  final bool isRecurring;
  final RecurrenceType recurrenceType;
  final String currencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? walletAccountId,
    String? note,
    DateTime? dateTime,
    List<String>? tags,
    String? receiptImagePath,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletAccountId: walletAccountId ?? this.walletAccountId,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
