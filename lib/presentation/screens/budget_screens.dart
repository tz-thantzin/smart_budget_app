import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/shared_widgets/app_scaffold.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../router/app_routes.dart';
import '../viewmodels/budget_viewmodel.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetViewModelProvider);
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.budgets,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final changed = await context.push<bool>(AppRoutes.addEditBudget);
          if (changed == true) {
            ref.invalidate(budgetViewModelProvider);
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.setBudget),
      ),
      child: budgets.when(
        data: (items) => ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: items
              .map(
                (e) => _BudgetCard(
                  title: e.title,
                  period: e.periodType.name,
                  limit: Formatters.currency(e.amountLimit),
                  spent: Formatters.currency(e.spentAmount),
                  percent: e.usagePercent.clamp(0, 1).toDouble(),
                  spentLabel: l10n.spent,
                  limitLabel: l10n.limit,
                  onTap: () async {
                    final changed = await context.push<bool>(
                      AppRoutes.budgetDetail,
                      extra: e,
                    );
                    if (changed == true) {
                      ref.invalidate(budgetViewModelProvider);
                    }
                  },
                  onDelete: () => _confirmDeleteBudget(context, ref, e.id),
                ),
              )
              .toList(),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class CreateEditBudgetScreen extends ConsumerStatefulWidget {
  const CreateEditBudgetScreen({super.key, this.budget});

  final BudgetEntity? budget;

  @override
  ConsumerState<CreateEditBudgetScreen> createState() =>
      _CreateEditBudgetScreenState();
}

class _CreateEditBudgetScreenState
    extends ConsumerState<CreateEditBudgetScreen> {
  late final TextEditingController titleCtrl;
  late final TextEditingController amountCtrl;
  late BudgetPeriodType period;

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.budget?.title ?? '');
    amountCtrl = TextEditingController(
      text: widget.budget?.amountLimit.toStringAsFixed(2) ?? '',
    );
    period = widget.budget?.periodType ?? BudgetPeriodType.monthly;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.saveBudget,
      actions: [
        if (isEditing)
          IconButton(
            tooltip: l10n.delete,
            onPressed: () => _confirmDeleteBudget(
              context,
              ref,
              widget.budget!.id,
              popAfterDelete: true,
            ),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
      ],
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          _BudgetPanel(
            children: [
              Text(
                l10n.budgetSetup,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: l10n.budgetTitle,
                  prefixIcon: Icon(Icons.savings_rounded),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.limitAmount,
                  prefixIcon: Icon(Icons.payments_rounded),
                ),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<BudgetPeriodType>(
                initialValue: period,
                decoration: InputDecoration(
                  labelText: l10n.period,
                  prefixIcon: Icon(Icons.date_range_rounded),
                ),
                items: BudgetPeriodType.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setState(() => period = v ?? period),
              ),
              SizedBox(height: 18.h),
              FilledButton.icon(
                onPressed: () async {
                  final amount =
                      double.tryParse(amountCtrl.text.trim()) ??
                      widget.budget?.amountLimit ??
                      0;
                  final title = titleCtrl.text.trim();

                  if (isEditing) {
                    final budget = widget.budget!;
                    await ref
                        .read(budgetViewModelProvider.notifier)
                        .updateBudget(
                          budget.copyWith(
                            title: title,
                            amountLimit: amount,
                            periodType: period,
                          ),
                        );
                  } else {
                    await ref
                        .read(budgetViewModelProvider.notifier)
                        .addBudget(
                          title: title,
                          amountLimit: amount,
                          periodType: period,
                        );
                  }
                  if (!context.mounted) return;
                  context.pop(true);
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(isEditing ? l10n.saveChanges : l10n.saveBudget),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.title,
    required this.period,
    required this.limit,
    required this.spent,
    required this.percent,
    required this.spentLabel,
    required this.limitLabel,
    required this.onTap,
    required this.onDelete,
  });

  final String title;
  final String period;
  final String limit;
  final String spent;
  final double percent;
  final String spentLabel;
  final String limitLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.savings_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(title, style: theme.textTheme.titleMedium),
                    ),
                    Text(period, style: theme.textTheme.bodySmall),
                    SizedBox(width: 4.w),
                    IconButton(
                      tooltip: AppLocalizations.of(context)!.delete,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                LinearProgressIndicator(
                  value: percent,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(child: Text('$spentLabel $spent')),
                    Text(
                      '$limitLabel $limit',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetPanel extends StatelessWidget {
  const _BudgetPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class BudgetDetailScreen extends ConsumerWidget {
  const BudgetDetailScreen({required this.budget, super.key});
  final BudgetEntity budget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.budgetDetail,
      actions: [
        IconButton(
          tooltip: l10n.edit,
          onPressed: () async {
            final changed = await context.push<bool>(
              AppRoutes.addEditBudget,
              extra: budget,
            );
            if (changed == true) {
              ref.invalidate(budgetViewModelProvider);
              if (!context.mounted) return;
              context.pop(true);
            }
          },
          icon: const Icon(Icons.edit_rounded),
        ),
        IconButton(
          tooltip: l10n.delete,
          onPressed: () => _confirmDeleteBudget(
            context,
            ref,
            budget.id,
            popAfterDelete: true,
          ),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          _BudgetPanel(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.savings_rounded)),
                title: Text(l10n.title),
                subtitle: Text(budget.title),
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.date_range_rounded),
                ),
                title: Text(l10n.period),
                subtitle: Text(budget.periodType.name),
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.flag_rounded)),
                title: Text(l10n.limit),
                subtitle: Text(Formatters.currency(budget.amountLimit)),
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.trending_up_rounded),
                ),
                title: Text(l10n.spent),
                subtitle: Text(Formatters.currency(budget.spentAmount)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeleteBudget(
  BuildContext context,
  WidgetRef ref,
  String id, {
  bool popAfterDelete = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteBudgetQuestion),
      content: Text(l10n.deleteBudgetMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(dialogContext, true),
          icon: const Icon(Icons.delete_outline_rounded),
          label: Text(l10n.delete),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;
  await ref.read(budgetViewModelProvider.notifier).deleteBudget(id);
  if (!context.mounted) return;
  if (popAfterDelete && Navigator.canPop(context)) {
    context.pop(true);
  }
}
