import 'package:budget_app/di/app_providers.dart';
import 'package:budget_app/domain/entities/category_entity.dart';
import 'package:budget_app/domain/entities/enums.dart';
import 'package:budget_app/domain/entities/transaction_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportChartBucket {
  const ReportChartBucket({
    required this.date,
    required this.expense,
    required this.income,
  });

  final DateTime date;
  final double expense;
  final double income;
}

class ReportCategorySpend {
  const ReportCategorySpend({
    required this.category,
    required this.amount,
    required this.relativeRatio,
  });

  final CategoryEntity? category;
  final double amount;
  final double relativeRatio;
}

class ReportSummaryState {
  const ReportSummaryState({
    required this.periodType,
    required this.referenceDate,
    required this.periodStart,
    required this.periodEnd,
    required this.canGoForward,
    required this.totalExpense,
    required this.totalIncome,
    required this.net,
    required this.chartBuckets,
    required this.topCategories,
    required this.sortedTransactions,
    required this.categoryById,
    required this.allTransactions,
  });

  final ReportPeriodType periodType;
  final DateTime referenceDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final bool canGoForward;
  final double totalExpense;
  final double totalIncome;
  final double net;
  final List<ReportChartBucket> chartBuckets;
  final List<ReportCategorySpend> topCategories;
  final List<TransactionEntity> sortedTransactions;
  final Map<String, CategoryEntity> categoryById;
  final List<TransactionEntity> allTransactions;
}

final reportsViewModelProvider =
    AsyncNotifierProvider<ReportsViewModel, ReportSummaryState>(
      ReportsViewModel.new,
    );

class ReportsViewModel extends AsyncNotifier<ReportSummaryState> {
  ReportPeriodType _periodType = ReportPeriodType.month;
  DateTime _referenceDate = _dateOnly(DateTime.now());

  @override
  Future<ReportSummaryState> build() => _reload();

  Future<void> changePeriod(ReportPeriodType type) async {
    _periodType = type;
    _referenceDate = _dateOnly(DateTime.now());
    state = AsyncData(await _reload());
  }

  Future<void> shiftPeriod(int direction) async {
    _referenceDate = _shiftDate(_periodType, _referenceDate, direction);
    state = AsyncData(await _reload());
  }

  Future<void> setReferenceDate(DateTime date) async {
    _referenceDate = _dateOnly(date);
    state = AsyncData(await _reload());
  }

  Future<ReportSummaryState> _reload() async {
    final transactions = await ref.read(getTransactionsUseCaseProvider).call();
    final categories = await ref.read(getCategoriesUseCaseProvider).call();
    return _compute(transactions, categories);
  }

  ReportSummaryState _compute(
    List<TransactionEntity> allTransactions,
    List<CategoryEntity> categories,
  ) {
    final start = _periodStart(_periodType, _referenceDate);
    final end = _periodEnd(_periodType, _referenceDate);
    final periodTxns = _filterToRange(allTransactions, start, end);
    final totalExpense = _sumByType(periodTxns, TransactionType.expense);
    final totalIncome = _sumByType(periodTxns, TransactionType.income);
    final categoryById = {for (final c in categories) c.id: c};

    return ReportSummaryState(
      periodType: _periodType,
      referenceDate: _referenceDate,
      periodStart: start,
      periodEnd: end,
      canGoForward: !end.isBefore(_dateOnly(DateTime.now())),
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      net: totalIncome - totalExpense,
      chartBuckets: _buildChartBuckets(_periodType, start, end, periodTxns),
      topCategories: _buildTopCategories(periodTxns, categoryById),
      sortedTransactions: [...periodTxns]
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime)),
      categoryById: categoryById,
      allTransactions: allTransactions,
    );
  }
}

DateTime _periodStart(ReportPeriodType type, DateTime reference) {
  final ref = _dateOnly(reference);
  return switch (type) {
    ReportPeriodType.day => ref,
    ReportPeriodType.week => ref.subtract(Duration(days: ref.weekday - 1)),
    ReportPeriodType.month => DateTime(ref.year, ref.month),
    ReportPeriodType.year => DateTime(ref.year),
  };
}

DateTime _periodEnd(ReportPeriodType type, DateTime reference) {
  final ref = _dateOnly(reference);
  return switch (type) {
    ReportPeriodType.day => ref,
    ReportPeriodType.week =>
      ref.subtract(Duration(days: ref.weekday - 1)).add(
        const Duration(days: 6),
      ),
    ReportPeriodType.month => DateTime(ref.year, ref.month + 1, 0),
    ReportPeriodType.year => DateTime(ref.year, 12, 31),
  };
}

DateTime _shiftDate(ReportPeriodType type, DateTime reference, int direction) {
  final ref = _dateOnly(reference);
  return switch (type) {
    ReportPeriodType.day => ref.add(Duration(days: direction)),
    ReportPeriodType.week =>
      ref.add(Duration(days: 7 * direction)),
    ReportPeriodType.month =>
      DateTime(ref.year, ref.month + direction, ref.day),
    ReportPeriodType.year =>
      DateTime(ref.year + direction, ref.month, ref.day),
  };
}

List<TransactionEntity> _filterToRange(
  List<TransactionEntity> transactions,
  DateTime start,
  DateTime end,
) {
  final startDate = _dateOnly(start);
  final endExclusive = _dateOnly(end).add(const Duration(days: 1));
  return transactions.where((t) {
    return !t.dateTime.isBefore(startDate) &&
        t.dateTime.isBefore(endExclusive);
  }).toList();
}

double _sumByType(List<TransactionEntity> transactions, TransactionType type) {
  return transactions
      .where((t) => t.type == type)
      .fold<double>(0, (sum, t) => sum + t.amount);
}

List<ReportChartBucket> _buildChartBuckets(
  ReportPeriodType type,
  DateTime start,
  DateTime end,
  List<TransactionEntity> periodTxns,
) {
  return switch (type) {
    ReportPeriodType.day => const [],
    ReportPeriodType.week || ReportPeriodType.month => () {
      final buckets = <ReportChartBucket>[];
      var day = _dateOnly(start);
      final endDate = _dateOnly(end);
      while (!day.isAfter(endDate)) {
        final current = day;
        buckets.add(
          ReportChartBucket(
            date: current,
            expense: _sumOnDayByType(periodTxns, current, TransactionType.expense),
            income: _sumOnDayByType(periodTxns, current, TransactionType.income),
          ),
        );
        day = day.add(const Duration(days: 1));
      }
      return buckets;
    }(),
    ReportPeriodType.year => [
      for (var month = 1; month <= 12; month++)
        ReportChartBucket(
          date: DateTime(start.year, month),
          expense: _sumInMonthByType(
            periodTxns,
            DateTime(start.year, month),
            TransactionType.expense,
          ),
          income: _sumInMonthByType(
            periodTxns,
            DateTime(start.year, month),
            TransactionType.income,
          ),
        ),
    ],
  };
}

List<ReportCategorySpend> _buildTopCategories(
  List<TransactionEntity> periodTxns,
  Map<String, CategoryEntity> categoryById,
) {
  final totals = <String, double>{};
  for (final txn in periodTxns.where((t) => t.type == TransactionType.expense)) {
    totals[txn.categoryId] = (totals[txn.categoryId] ?? 0) + txn.amount;
  }
  final ranked = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top = ranked.take(5).toList();
  if (top.isEmpty) return const [];
  final topAmount = top.first.value;
  return [
    for (final entry in top)
      ReportCategorySpend(
        category: categoryById[entry.key],
        amount: entry.value,
        relativeRatio: topAmount == 0 ? 0 : entry.value / topAmount,
      ),
  ];
}

double _sumOnDayByType(
  List<TransactionEntity> transactions,
  DateTime day,
  TransactionType type,
) {
  return transactions
      .where((t) => t.type == type && _isSameDay(t.dateTime, day))
      .fold<double>(0, (sum, t) => sum + t.amount);
}

double _sumInMonthByType(
  List<TransactionEntity> transactions,
  DateTime monthStart,
  TransactionType type,
) {
  final endExclusive = DateTime(monthStart.year, monthStart.month + 1);
  return transactions
      .where(
        (t) =>
            t.type == type &&
            !t.dateTime.isBefore(monthStart) &&
            t.dateTime.isBefore(endExclusive),
      )
      .fold<double>(0, (sum, t) => sum + t.amount);
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
