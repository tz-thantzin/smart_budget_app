import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';

class LocalDatabaseDataSource {
  static const _databaseName = 'budget_app.db';
  static const _databaseVersion = 3;
  static const _transactionsTable = 'transactions';
  static const _categoriesTable = 'categories';
  static const _budgetsTable = 'budgets';

  Database? _database;

  Future<Database> get database async {
    final current = _database;
    if (current != null) return current;

    final path = p.join(await getDatabasesPath(), _databaseName);
    final opened = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createTransactionsTable(db);
        await _createCategoriesTable(db);
        await _seedInitialCategories(db);
        await _createBudgetsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createCategoriesTable(db);
          await _seedInitialCategories(db);
        }
        if (oldVersion < 3) {
          await _createBudgetsTable(db);
        }
      },
      onOpen: (db) async {
        await _createBudgetsTable(db);
      },
    );
    _database = opened;
    return opened;
  }

  Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS $_transactionsTable (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category_id TEXT NOT NULL,
            wallet_account_id TEXT NOT NULL,
            note TEXT,
            date_time INTEGER NOT NULL,
            tags TEXT NOT NULL,
            receipt_image_path TEXT,
            is_recurring INTEGER NOT NULL,
            recurrence_type TEXT NOT NULL,
            currency_code TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
  }

  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS $_categoriesTable (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            icon_code_point INTEGER NOT NULL,
            color_hex INTEGER NOT NULL
          )
        ''');
  }

  Future<void> _seedInitialCategories(Database db) async {
    await db.insert(_categoriesTable, {
      'id': 'default_food',
      'name': 'Food',
      'type': TransactionType.expense.name,
      'icon_code_point': Icons.restaurant_rounded.codePoint,
      'color_hex': Colors.orange.toARGB32(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _createBudgetsTable(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS $_budgetsTable (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount_limit REAL NOT NULL,
            category_id TEXT,
            period_type TEXT NOT NULL,
            start_date INTEGER NOT NULL,
            end_date INTEGER NOT NULL,
            spent_amount REAL NOT NULL,
            alert_threshold_percent REAL NOT NULL,
            rollover_enabled INTEGER NOT NULL
          )
        ''');
  }

  Future<TransactionEntity> insertTransaction(
    TransactionEntity transaction,
  ) async {
    final db = await database;
    final model = TransactionModel.fromEntity(transaction);
    await db.insert(
      _transactionsTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return transaction;
  }

  Future<List<TransactionEntity>> fetchTransactions() async {
    final db = await database;
    final rows = await db.query(_transactionsTable, orderBy: 'date_time DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<TransactionEntity> updateTransaction(
    TransactionEntity transaction,
  ) async {
    final db = await database;
    final model = TransactionModel.fromEntity(transaction);
    await db.update(
      _transactionsTable,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    return transaction;
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(_transactionsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<CategoryEntity> insertCategory(CategoryEntity category) async {
    final db = await database;
    await db.insert(
      _categoriesTable,
      _categoryToMap(category),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return category;
  }

  Future<List<CategoryEntity>> fetchCategories() async {
    final db = await database;
    final rows = await db.query(
      _categoriesTable,
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(_categoryFromMap).toList();
  }

  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final db = await database;
    await db.update(
      _categoriesTable,
      _categoryToMap(category),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    return category;
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(_categoriesTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<BudgetEntity> insertBudget(BudgetEntity budget) async {
    final db = await database;
    final model = BudgetModel.fromEntity(budget);
    await db.insert(
      _budgetsTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return budget;
  }

  Future<List<BudgetEntity>> fetchBudgets() async {
    final db = await database;
    final rows = await db.query(_budgetsTable, orderBy: 'start_date DESC');
    return rows.map(BudgetModel.fromMap).toList();
  }

  Future<BudgetEntity> updateBudget(BudgetEntity budget) async {
    final db = await database;
    final model = BudgetModel.fromEntity(budget);
    await db.update(
      _budgetsTable,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
    return budget;
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete(_budgetsTable, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _categoryToMap(CategoryEntity category) {
    return {
      'id': category.id,
      'name': category.name,
      'type': category.type.name,
      'icon_code_point': category.iconCodePoint,
      'color_hex': category.colorHex,
    };
  }

  CategoryEntity _categoryFromMap(Map<String, Object?> map) {
    return CategoryEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      type: TransactionType.values.byName(map['type'] as String),
      iconCodePoint: map['icon_code_point'] as int,
      colorHex: map['color_hex'] as int,
    );
  }
}
