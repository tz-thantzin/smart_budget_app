import 'package:budget_app/core/constants/app_currency.dart';
import 'package:budget_app/core/extensions/build_context_extensions.dart';
import 'package:budget_app/core/services/report_pdf_export_service.dart';
import 'package:budget_app/core/shared_widgets/app_scaffold.dart';
import 'package:budget_app/core/utils/formatters.dart';
import 'package:budget_app/domain/entities/category_entity.dart';
import 'package:budget_app/domain/entities/enums.dart';
import 'package:budget_app/domain/entities/transaction_entity.dart';
import 'package:budget_app/presentation/viewmodels/reports_viewmodel.dart';
import 'package:budget_app/presentation/viewmodels/settings_viewmodel.dart';
import 'package:budget_app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ReportsAnalyticsScreen extends HookConsumerWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.localization;
    final currencyCode = ref.watch(currentCurrencyCodeProvider);
    final isExporting = useState(false);
    final summaryAsync = ref.watch(reportsViewModelProvider);
    final vm = ref.read(reportsViewModelProvider.notifier);
    final exportService = useMemoized(() => const ReportPdfExportService());

    return AppScaffold(
      title: l10n.reports,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: isExporting.value
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(strokeWidth: 2.w),
                  ),
                )
              : IconButton.filledTonal(
                  onPressed: summaryAsync.hasValue
                      ? () => _export(
                          context: context,
                          summary: summaryAsync.requireValue,
                          currencyCode: currencyCode,
                          exportService: exportService,
                          isExporting: isExporting,
                        )
                      : null,
                  tooltip: l10n.exportPdf,
                  icon: const Icon(Icons.file_download_rounded),
                ),
        ),
      ],
      child: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (summary) => ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: [
            _PeriodTabs(
              value: summary.periodType,
              onChanged: vm.changePeriod,
            ),
            SizedBox(height: 16.h),
            _PeriodNavigator(
              label: _periodLabel(context, summary),
              onPrevious: () => vm.shiftPeriod(-1),
              onNext: summary.canGoForward ? null : () => vm.shiftPeriod(1),
              onTapDate: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: summary.referenceDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) vm.setReferenceDate(picked);
              },
            ),
            SizedBox(height: 16.h),
            _StatsRow(
              spent: summary.totalExpense,
              income: summary.totalIncome,
              currencyCode: currencyCode,
            ),
            if (summary.periodType != ReportPeriodType.day) ...[
              SizedBox(height: 20.h),
              Text(
                l10n.spendingTrend,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10.h),
              _SpendBarChart(
                buckets: _formatChartBuckets(
                  context,
                  summary.periodType,
                  summary.chartBuckets,
                ),
                currencyCode: currencyCode,
                scrollable: summary.periodType == ReportPeriodType.month,
              ),
            ],
            SizedBox(height: 22.h),
            Text(
              l10n.topCategories,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10.h),
            _TopCategoriesPanel(
              topCategories: summary.topCategories,
              currencyCode: currencyCode,
            ),
            SizedBox(height: 22.h),
            Text(
              l10n.transactionsHeader(
                summary.sortedTransactions.length.toString(),
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10.h),
            _TransactionsList(
              transactions: summary.sortedTransactions,
              categoryById: summary.categoryById,
              currencyCode: currencyCode,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export({
    required BuildContext context,
    required ReportSummaryState summary,
    required String currencyCode,
    required ReportPdfExportService exportService,
    required ValueNotifier<bool> isExporting,
  }) async {
    final l10n = context.localization;
    final messenger = ScaffoldMessenger.of(context);
    final categoryNames = {
      for (final entry in summary.categoryById.entries)
        entry.key: entry.value.name,
    };

    isExporting.value = true;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.exportingPdf)));

    try {
      await exportService.exportReport(
        periodSubtitle: _periodLabel(context, summary),
        startDate: summary.periodStart,
        endDate: summary.periodEnd,
        localeTag: Localizations.localeOf(context).toLanguageTag(),
        currencyCode: currencyCode,
        currencyDecimalDigits: AppCurrency.fromCode(currencyCode).decimalDigits,
        transactions: summary.allTransactions,
        categoryNames: categoryNames,
        totalExpense: summary.totalExpense,
        totalIncome: summary.totalIncome,
        net: summary.net,
        strings: ReportPdfExportStrings(
          reportTitle: l10n.expenseReport,
          summarySection: l10n.reportSummary,
          transactionsSection: l10n.reportTransactions,
          periodLabel: l10n.period,
          generatedAtLabel: l10n.generatedAt,
          totalExpenseLabel: l10n.totalSpent,
          totalIncomeLabel: l10n.income,
          netLabel: l10n.net,
          transactionCountLabel: l10n.transactionCount,
          dateLabel: l10n.date,
          titleLabel: l10n.title,
          categoryLabel: l10n.category,
          noteLabel: l10n.note,
          amountLabel: l10n.amount,
          typeLabel: l10n.type,
          unknownCategoryLabel: l10n.unknownCategory,
          expenseLabel: l10n.expense,
          incomeLabel: l10n.income,
        ),
      );
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.pdfExported)));
    } catch (e, st) {
      debugPrint('PDF export error: $e\n$st');
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.pdfExportFailed)));
    } finally {
      isExporting.value = false;
    }
  }
}

// ---------------------------------------------------------------------------
// Locale-dependent label helpers (presentation only — no business logic)
// ---------------------------------------------------------------------------

String _periodLabel(BuildContext context, ReportSummaryState summary) {
  final tag = Localizations.localeOf(context).toLanguageTag();
  return switch (summary.periodType) {
    ReportPeriodType.day =>
      DateFormat.yMMMEd(tag).format(summary.periodStart),
    ReportPeriodType.week =>
      '${DateFormat.MMMd(tag).format(summary.periodStart)} - '
          '${DateFormat.yMMMd(tag).format(summary.periodEnd)}',
    ReportPeriodType.month =>
      DateFormat.yMMMM(tag).format(summary.periodStart),
    ReportPeriodType.year => DateFormat.y(tag).format(summary.periodStart),
  };
}

List<_ChartBucket> _formatChartBuckets(
  BuildContext context,
  ReportPeriodType type,
  List<ReportChartBucket> buckets,
) {
  final tag = Localizations.localeOf(context).toLanguageTag();
  final fmt = switch (type) {
    ReportPeriodType.week => DateFormat.E(tag),
    ReportPeriodType.month => DateFormat.d(tag),
    _ => DateFormat.MMM(tag),
  };
  return [
    for (final b in buckets)
      _ChartBucket(
        label: fmt.format(b.date),
        expense: b.expense,
        income: b.income,
      ),
  ];
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.value, required this.onChanged});

  final ReportPeriodType value;
  final ValueChanged<ReportPeriodType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    return SegmentedButton<ReportPeriodType>(
      segments: [
        ButtonSegment(value: ReportPeriodType.day, label: Text(l10n.day)),
        ButtonSegment(value: ReportPeriodType.week, label: Text(l10n.week)),
        ButtonSegment(value: ReportPeriodType.month, label: Text(l10n.month)),
        ButtonSegment(value: ReportPeriodType.year, label: Text(l10n.year)),
      ],
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}

class _PeriodNavigator extends StatelessWidget {
  const _PeriodNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onTapDate,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onTapDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localization;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: l10n.previousPeriodLabel,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: InkWell(
              onTap: onTapDate,
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: l10n.nextPeriodLabel,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.spent,
    required this.income,
    required this.currencyCode,
  });

  final double spent;
  final double income;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final theme = Theme.of(context);
    final net = income - spent;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: l10n.totalSpent,
            amount: spent,
            currencyCode: currencyCode,
            color: theme.colorScheme.error,
            background: theme.colorScheme.errorContainer.withValues(alpha: 0.45),
            icon: Icons.south_rounded,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatTile(
            label: l10n.income,
            amount: income,
            currencyCode: currencyCode,
            color: theme.colorScheme.tertiary,
            background: theme.colorScheme.tertiaryContainer.withValues(
              alpha: 0.45,
            ),
            icon: Icons.north_rounded,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatTile(
            label: l10n.net,
            amount: net,
            currencyCode: currencyCode,
            color: net >= 0
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
            background: theme.colorScheme.primaryContainer.withValues(
              alpha: 0.45,
            ),
            icon: net >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final double amount;
  final String currencyCode;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.currency(amount, currencyCode: currencyCode),
              style: theme.textTheme.titleMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBucket {
  const _ChartBucket({
    required this.label,
    required this.expense,
    required this.income,
  });

  final String label;
  final double expense;
  final double income;
}

class _SpendBarChart extends StatelessWidget {
  const _SpendBarChart({
    required this.buckets,
    required this.currencyCode,
    required this.scrollable,
  });

  final List<_ChartBucket> buckets;
  final String currencyCode;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localization;
    final expenseColor = theme.colorScheme.error;
    final incomeColor = theme.colorScheme.tertiary;
    final mutedColor = theme.colorScheme.surfaceContainerHighest;
    final maxValue = buckets.fold<double>(0, (max, b) {
      final localMax = b.expense > b.income ? b.expense : b.income;
      return localMax > max ? localMax : max;
    });
    final isEmpty = maxValue == 0;
    final bucketWidth = scrollable ? 30.0 : 0.0;

    final columns = [
      for (final bucket in buckets)
        _BucketColumn(
          bucket: bucket,
          maxValue: maxValue,
          expenseColor: expenseColor,
          incomeColor: incomeColor,
          mutedColor: mutedColor,
          currencyCode: currencyCode,
          expenseLabel: l10n.expense,
          incomeLabel: l10n.income,
          fixedWidth: scrollable ? bucketWidth : null,
        ),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendDot(color: expenseColor, label: l10n.expense),
              SizedBox(width: 12.w),
              _LegendDot(color: incomeColor, label: l10n.income),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 140.h,
            child: isEmpty
                ? Center(
                    child: Text(
                      l10n.noTransactionsInPeriod,
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                : scrollable
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final column in columns)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: column,
                          ),
                      ],
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final column in columns) Expanded(child: column),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}

class _BucketColumn extends StatelessWidget {
  const _BucketColumn({
    required this.bucket,
    required this.maxValue,
    required this.expenseColor,
    required this.incomeColor,
    required this.mutedColor,
    required this.currencyCode,
    required this.expenseLabel,
    required this.incomeLabel,
    this.fixedWidth,
  });

  final _ChartBucket bucket;
  final double maxValue;
  final Color expenseColor;
  final Color incomeColor;
  final Color mutedColor;
  final String currencyCode;
  final String expenseLabel;
  final String incomeLabel;
  final double? fixedWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxBarHeight = 100.h;
    final width = fixedWidth;

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: maxBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniBar(
                value: bucket.expense,
                maxValue: maxValue,
                maxBarHeight: maxBarHeight,
                color: expenseColor,
                mutedColor: mutedColor,
              ),
              SizedBox(width: 2.w),
              _MiniBar(
                value: bucket.income,
                maxValue: maxValue,
                maxBarHeight: maxBarHeight,
                color: incomeColor,
                mutedColor: mutedColor,
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          bucket.label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    return Tooltip(
      message: _tooltipMessage(),
      child: width != null ? SizedBox(width: width, child: column) : column,
    );
  }

  String _tooltipMessage() {
    final parts = <String>[bucket.label];
    if (bucket.expense > 0) {
      parts.add(
        '$expenseLabel ${Formatters.currency(bucket.expense, currencyCode: currencyCode)}',
      );
    }
    if (bucket.income > 0) {
      parts.add(
        '$incomeLabel ${Formatters.currency(bucket.income, currencyCode: currencyCode)}',
      );
    }
    return parts.join(' · ');
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.value,
    required this.maxValue,
    required this.maxBarHeight,
    required this.color,
    required this.mutedColor,
  });

  final double value;
  final double maxValue;
  final double maxBarHeight;
  final Color color;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue == 0 ? 0.0 : (value / maxValue);
    final barHeight = (ratio * maxBarHeight)
        .clamp(value > 0 ? 4.h : 0, maxBarHeight)
        .toDouble();
    return Expanded(
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: value > 0 ? color : mutedColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
        ),
      ),
    );
  }
}

class _TopCategoriesPanel extends StatelessWidget {
  const _TopCategoriesPanel({
    required this.topCategories,
    required this.currencyCode,
  });

  final List<ReportCategorySpend> topCategories;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localization;
    if (topCategories.isEmpty) {
      return _EmptyPanel(message: l10n.noExpenseForPeriod);
    }
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < topCategories.length; i++) ...[
            if (i > 0) SizedBox(height: 12.h),
            _CategoryRow(
              entry: topCategories[i],
              currencyCode: currencyCode,
              fallbackName: l10n.unknownCategory,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.entry,
    required this.currencyCode,
    required this.fallbackName,
  });

  final ReportCategorySpend entry;
  final String currencyCode;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = entry.category;
    final color = category == null
        ? theme.colorScheme.primary
        : Color(category.colorHex);
    final icon = category == null
        ? Icons.label_off_rounded
        : IconData(category.iconCodePoint, fontFamily: 'MaterialIcons');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 16.sp, color: color),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                category?.name ?? fallbackName,
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              Formatters.currency(entry.amount, currencyCode: currencyCode),
              style: theme.textTheme.titleSmall?.copyWith(color: color),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: entry.relativeRatio.clamp(0, 1).toDouble(),
            minHeight: 6.h,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({
    required this.transactions,
    required this.categoryById,
    required this.currencyCode,
  });

  final List<TransactionEntity> transactions;
  final Map<String, CategoryEntity> categoryById;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localization;
    if (transactions.isEmpty) {
      return _EmptyPanel(message: l10n.noTransactionsInPeriod);
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 4.h),
        itemCount: transactions.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 16.w,
          endIndent: 16.w,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final category = categoryById[transaction.categoryId];
          final isExpense = transaction.type == TransactionType.expense;
          final typeColor = isExpense
              ? theme.colorScheme.error
              : theme.colorScheme.tertiary;
          final categoryColor =
              category == null ? typeColor : Color(category.colorHex);
          final iconData = category == null
              ? (isExpense ? Icons.south_rounded : Icons.north_rounded)
              : IconData(category.iconCodePoint, fontFamily: 'MaterialIcons');
          return ListTile(
            onTap: () =>
                context.push(AppRoutes.transactionDetail, extra: transaction),
            leading: CircleAvatar(
              backgroundColor: categoryColor.withValues(alpha: 0.18),
              child: Icon(iconData, color: categoryColor, size: 18.sp),
            ),
            title: Text(transaction.title),
            subtitle: Text(
              '${category?.name ?? l10n.unknownCategory} · '
              '${Formatters.date(transaction.dateTime)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              '${isExpense ? '-' : '+'}'
              '${Formatters.currency(transaction.amount, currencyCode: currencyCode)}',
              style: theme.textTheme.titleSmall?.copyWith(color: typeColor),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
