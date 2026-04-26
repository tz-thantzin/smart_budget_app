import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/shared_widgets/app_scaffold.dart';
import '../../core/utils/formatters.dart';
import '../../di/app_providers.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/transaction_entity.dart';

class ReportsAnalyticsScreen extends HookConsumerWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.localization;
    final selectedDate = useState(DateTime.now());
    final transactions = ref.watch(getTransactionsUseCaseProvider);

    return AppScaffold(
      title: l10n.reports,
      child: FutureBuilder<List<TransactionEntity>>(
        future: transactions.call(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <TransactionEntity>[];
          final now = DateTime.now();
          final selected = _dateOnly(selectedDate.value);
          final weekStart = selected.subtract(
            Duration(days: selected.weekday - 1),
          );
          final weekEnd = weekStart.add(const Duration(days: 6));
          final monthStart = DateTime(selected.year, selected.month);
          final monthEnd = DateTime(selected.year, selected.month + 1, 0);
          final yearStart = DateTime(selected.year);
          final yearEnd = DateTime(selected.year, 12, 31);

          final cards = [
            _ReportPeriod(
              title: l10n.selectedDateLabel,
              subtitle: _formatDateTitle(context, selected),
              amount: _expenseTotal(items, selected, selected),
              icon: Icons.today_rounded,
              startDate: selected,
              endDate: selected,
              detailType: _ReportDetailType.transactions,
            ),
            _ReportPeriod(
              title: l10n.week,
              subtitle: l10n.selectedWeek(
                _formatDateTitle(context, weekStart),
                _formatDateTitle(context, weekEnd),
              ),
              amount: _expenseTotal(items, weekStart, weekEnd),
              icon: Icons.view_week_rounded,
              startDate: weekStart,
              endDate: weekEnd,
              detailType: _ReportDetailType.dailyTotals,
            ),
            _ReportPeriod(
              title: l10n.month,
              subtitle: l10n.selectedMonth(
                _formatMonthTitle(context, monthStart),
              ),
              amount: _expenseTotal(items, monthStart, monthEnd),
              icon: Icons.calendar_view_month_rounded,
              startDate: monthStart,
              endDate: monthEnd,
              detailType: _ReportDetailType.weeklyTotals,
            ),
            _ReportPeriod(
              title: l10n.year,
              subtitle: l10n.selectedYear(selected.year.toString()),
              amount: _expenseTotal(items, yearStart, yearEnd),
              icon: Icons.calendar_today_rounded,
              startDate: yearStart,
              endDate: yearEnd,
              detailType: _ReportDetailType.monthlyTotals,
            ),
          ];

          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            children: [
              _ReportHero(
                title: l10n.expenseReport,
                selectedDate: _formatDateTitle(context, selected),
                amount: cards.first.amount,
                onChooseDate: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate.value,
                    firstDate: DateTime(2000),
                    lastDate: _dateOnly(now),
                  );
                  if (picked != null) {
                    selectedDate.value = picked;
                  }
                },
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.periodBreakdown,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10.h),
              ...cards.map(
                (period) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _ReportCard(
                    period: period,
                    onTap: () => _showReportDetails(context, period, items),
                  ),
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }
}

enum _ReportDetailType {
  transactions,
  dailyTotals,
  weeklyTotals,
  monthlyTotals,
}

class _ReportPeriod {
  const _ReportPeriod({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.startDate,
    required this.endDate,
    required this.detailType,
  });

  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final DateTime startDate;
  final DateTime endDate;
  final _ReportDetailType detailType;
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({
    required this.title,
    required this.selectedDate,
    required this.amount,
    required this.onChooseDate,
  });

  final String title;
  final String selectedDate;
  final double amount;
  final VoidCallback onChooseDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localization;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.24),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onChooseDate,
                tooltip: l10n.chooseDate,
                icon: const Icon(Icons.calendar_month_rounded),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            l10n.totalSpent,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.76),
            ),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.currency(amount),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_rounded,
                  color: theme.colorScheme.onPrimary,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  selectedDate,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.period, required this.onTap});

  final _ReportPeriod period;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localization;
    final borderRadius = BorderRadius.circular(20.r);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  period.icon,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(period.title, style: theme.textTheme.titleMedium),
                    SizedBox(height: 3.h),
                    Text(
                      period.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      period.amount == 0
                          ? l10n.noExpenseForPeriod
                          : l10n.totalSpent,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              SizedBox(
                width: 118.w,
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          Formatters.currency(period.amount),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportDetailRow {
  const _ReportDetailRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
}

void _showReportDetails(
  BuildContext context,
  _ReportPeriod period,
  List<TransactionEntity> transactions,
) {
  final rows = _reportDetailRows(context, period, transactions);
  final theme = Theme.of(context);
  final l10n = context.localization;

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.68,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(period.title, style: theme.textTheme.titleLarge),
                SizedBox(height: 4.h),
                Text(
                  period.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 12.h),
                _ReportDetailTotal(amount: period.amount),
                SizedBox(height: 10.h),
                Expanded(
                  child: rows.isEmpty
                      ? Center(child: Text(l10n.noExpenseForPeriod))
                      : ListView.separated(
                          itemCount: rows.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final row = rows[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(child: Icon(row.icon)),
                              title: Text(row.title),
                              subtitle: Text(row.subtitle),
                              trailing: Text(
                                Formatters.currency(row.amount),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ReportDetailTotal extends StatelessWidget {
  const _ReportDetailTotal({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localization;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n.totalSpent, style: theme.textTheme.labelLarge),
          ),
          Text(
            Formatters.currency(amount),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _formatDateTitle(BuildContext context, DateTime value) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}

String _formatMonthTitle(BuildContext context, DateTime value) {
  return DateFormat.yMMMM(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}

String _formatShortDateTitle(BuildContext context, DateTime value) {
  return DateFormat.MMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}

String _formatWeekRange(BuildContext context, DateTime start, DateTime end) {
  return '${_formatShortDateTitle(context, start)} - '
      '${_formatShortDateTitle(context, end)}';
}

double _expenseTotal(
  List<TransactionEntity> transactions,
  DateTime start,
  DateTime end,
) {
  final startDate = _dateOnly(start);
  final endExclusive = _dateOnly(end).add(const Duration(days: 1));

  return transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .where((transaction) {
        final date = transaction.dateTime;
        return !date.isBefore(startDate) && date.isBefore(endExclusive);
      })
      .fold<double>(0, (total, transaction) => total + transaction.amount);
}

List<TransactionEntity> _expenseTransactions(
  List<TransactionEntity> transactions,
  DateTime start,
  DateTime end,
) {
  final startDate = _dateOnly(start);
  final endExclusive = _dateOnly(end).add(const Duration(days: 1));

  return transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .where((transaction) {
        final date = transaction.dateTime;
        return !date.isBefore(startDate) && date.isBefore(endExclusive);
      })
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
}

List<_ReportDetailRow> _reportDetailRows(
  BuildContext context,
  _ReportPeriod period,
  List<TransactionEntity> transactions,
) {
  return switch (period.detailType) {
    _ReportDetailType.transactions => _transactionRows(
      context,
      transactions,
      period.startDate,
      period.endDate,
    ),
    _ReportDetailType.dailyTotals => _dailyTotalRows(
      context,
      transactions,
      period.startDate,
      period.endDate,
    ),
    _ReportDetailType.weeklyTotals => _weeklyTotalRows(
      context,
      transactions,
      period.startDate,
      period.endDate,
    ),
    _ReportDetailType.monthlyTotals => _monthlyTotalRows(
      context,
      transactions,
      period.startDate,
      period.endDate,
    ),
  };
}

List<_ReportDetailRow> _transactionRows(
  BuildContext context,
  List<TransactionEntity> transactions,
  DateTime start,
  DateTime end,
) {
  return _expenseTransactions(transactions, start, end)
      .map(
        (transaction) => _ReportDetailRow(
          title: transaction.title,
          subtitle: Formatters.date(transaction.dateTime),
          amount: transaction.amount,
          icon: Icons.receipt_long_rounded,
        ),
      )
      .toList();
}

List<_ReportDetailRow> _dailyTotalRows(
  BuildContext context,
  List<TransactionEntity> transactions,
  DateTime start,
  DateTime end,
) {
  final rows = <_ReportDetailRow>[];
  var day = _dateOnly(start);
  final endDate = _dateOnly(end);

  while (!day.isAfter(endDate)) {
    final dayTransactions = _expenseTransactions(transactions, day, day);
    final total = dayTransactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
    rows.add(
      _ReportDetailRow(
        title: _formatShortDateTitle(context, day),
        subtitle: '${dayTransactions.length} transactions',
        amount: total,
        icon: Icons.today_rounded,
      ),
    );
    day = day.add(const Duration(days: 1));
  }

  return rows;
}

List<_ReportDetailRow> _weeklyTotalRows(
  BuildContext context,
  List<TransactionEntity> transactions,
  DateTime start,
  DateTime end,
) {
  final rows = <_ReportDetailRow>[];
  var weekStart = _dateOnly(start);
  final endDate = _dateOnly(end);

  while (!weekStart.isAfter(endDate)) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final cappedWeekEnd = weekEnd.isAfter(endDate) ? endDate : weekEnd;
    final weekTransactions = _expenseTransactions(
      transactions,
      weekStart,
      cappedWeekEnd,
    );
    final total = weekTransactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
    rows.add(
      _ReportDetailRow(
        title: _formatWeekRange(context, weekStart, cappedWeekEnd),
        subtitle: '${weekTransactions.length} transactions',
        amount: total,
        icon: Icons.view_week_rounded,
      ),
    );
    weekStart = cappedWeekEnd.add(const Duration(days: 1));
  }

  return rows;
}

List<_ReportDetailRow> _monthlyTotalRows(
  BuildContext context,
  List<TransactionEntity> transactions,
  DateTime start,
  DateTime end,
) {
  final rows = <_ReportDetailRow>[];
  var monthStart = DateTime(start.year, start.month);
  final endDate = _dateOnly(end);

  while (!monthStart.isAfter(endDate)) {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
    final cappedMonthEnd = monthEnd.isAfter(endDate) ? endDate : monthEnd;
    final monthTransactions = _expenseTransactions(
      transactions,
      monthStart,
      cappedMonthEnd,
    );
    final total = monthTransactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
    rows.add(
      _ReportDetailRow(
        title: _formatMonthTitle(context, monthStart),
        subtitle: '${monthTransactions.length} transactions',
        amount: total,
        icon: Icons.calendar_view_month_rounded,
      ),
    );
    monthStart = DateTime(monthStart.year, monthStart.month + 1);
  }

  return rows;
}
