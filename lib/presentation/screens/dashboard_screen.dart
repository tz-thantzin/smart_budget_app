import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/shared_widgets/app_scaffold.dart';
import '../../core/utils/formatters.dart';
import '../../router/app_routes.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardViewModelProvider);
    final l10n = context.localization;
    return AppScaffold(
      title: l10n.dashboard,
      actions: [
        IconButton(
          tooltip: l10n.settings,
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
      child: dashboard.when(
        data: (data) => ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: [
            _BalanceHeader(balance: data.totalBalance),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: l10n.income,
                    value: Formatters.currency(data.totalIncome),
                    icon: Icons.south_west,
                    color: const Color(0xFF1B9E77),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SummaryCard(
                    title: l10n.expense,
                    value: Formatters.currency(data.totalExpense),
                    icon: Icons.north_east,
                    color: const Color(0xFFE35D4F),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12.h),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.02,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                QuickActionButton(
                  label: l10n.add,
                  icon: Icons.add_rounded,
                  onTap: () async {
                    final changed = await context.push<bool>(
                      AppRoutes.addTransaction,
                    );
                    if (changed == true) {
                      ref.invalidate(dashboardViewModelProvider);
                    }
                  },
                ),
                QuickActionButton(
                  label: l10n.history,
                  icon: Icons.history_rounded,
                  onTap: () async {
                    await context.push(AppRoutes.transactionHistory);
                    ref.invalidate(dashboardViewModelProvider);
                  },
                ),
                QuickActionButton(
                  label: l10n.budgets,
                  icon: Icons.savings_rounded,
                  onTap: () => context.push(AppRoutes.budgets),
                ),
                QuickActionButton(
                  label: l10n.categories,
                  icon: Icons.category_rounded,
                  onTap: () => context.push(AppRoutes.categories),
                ),
                QuickActionButton(
                  label: l10n.reports,
                  icon: Icons.bar_chart_rounded,
                  onTap: () => context.push(AppRoutes.reports),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            _SectionHeader(
              title: l10n.recentTransactions,
              actionLabel: l10n.viewAll,
              onTap: () async {
                await context.push(AppRoutes.transactionHistory);
                ref.invalidate(dashboardViewModelProvider);
              },
            ),
            SizedBox(height: 10.h),
            if (data.recentTransactions.isEmpty)
              _EmptyState(message: l10n.noTransactionsYet)
            else
              ...data.recentTransactions.map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _TransactionTile(
                    title: e.title,
                    date: Formatters.date(e.dateTime),
                    amount: Formatters.currency(e.amount),
                    isIncome: e.type.name == 'income',
                    onTap: () async {
                      await context.push(AppRoutes.transactionDetail, extra: e);
                      ref.invalidate(dashboardViewModelProvider);
                    },
                  ),
                ),
              ),
            SizedBox(height: 10.h),
            Text(
              l10n.topCategories,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10.h),
            if (data.topSpendingCategories.isEmpty)
              _EmptyState(message: l10n.categoriesWillAppearHere)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.topSpendingCategories
                    .map(
                      (e) => Chip(
                        avatar: Icon(
                          Icons.local_offer_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(e.name),
                      ),
                    )
                    .toList(),
              ),
            SizedBox(height: 18.h),
            _InsightCard(
              title: l10n.spendingInsight,
              message: l10n.spendingInsightMessage,
            ),
          ],
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNegative = balance < 0;
    const negativeBalanceColor = Color(0xFFFF1744);
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            color: theme.colorScheme.onPrimary,
          ),
          SizedBox(height: 18.h),
          Text(
            context.localization.totalBalance,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.82),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            Formatters.currency(balance),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: isNegative
                  ? negativeBalanceColor
                  : theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.onTap,
  });

  final String title;
  final String date;
  final String amount;
  final bool isIncome;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isIncome ? const Color(0xFF1B9E77) : const Color(0xFFE35D4F);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(18.r),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.12),
          child: Icon(
            isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: accent,
          ),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: theme.textTheme.labelLarge?.copyWith(color: accent),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tips_and_updates_rounded,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Text(message, style: theme.textTheme.bodyLarge),
    );
  }
}
