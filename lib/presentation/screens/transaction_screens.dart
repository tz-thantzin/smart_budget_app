import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';

import '../../core/shared_widgets/app_scaffold.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../l10n/app_localizations.dart';
import '../../router/app_routes.dart';
import '../viewmodels/budget_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref
        .watch(categoryViewModelProvider)
        .maybeWhen(data: (items) => items, orElse: () => <CategoryEntity>[]);
    final matchingCategories = categories
        .where((category) => category.type == _type)
        .toList();
    if (_categoryId != null &&
        !matchingCategories.any((category) => category.id == _categoryId)) {
      _categoryId = null;
    }

    return AppScaffold(
      title: l10n.addTransaction,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          _FormPanel(
            children: [
              Text(
                l10n.transactionDetails,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  prefixIcon: Icon(Icons.payments_rounded),
                ),
              ),
              SizedBox(height: 12.h),
              _DatePickerField(
                label: l10n.date,
                value: _selectedDate,
                onTap: () async {
                  final picked = await _pickTransactionDate(
                    context,
                    _selectedDate,
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<TransactionType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.type,
                  prefixIcon: Icon(Icons.swap_vert_rounded),
                ),
                items: TransactionType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(_transactionTypeLabel(l10n, e)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() {
                  _type = val ?? _type;
                  _categoryId = null;
                }),
              ),
              SizedBox(height: 12.h),
              _CategoryDropdown(
                label: l10n.categoryOptional,
                categories: matchingCategories,
                value: _categoryId,
                noneLabel: l10n.noCategory,
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _note,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
              ),
              SizedBox(height: 18.h),
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(transactionListViewModelProvider.notifier)
                      .addTransaction(
                        title: _title.text,
                        amount: double.tryParse(_amount.text) ?? 0,
                        type: _type,
                        categoryId: _categoryId,
                        walletAccountId: 'w1',
                        note: _note.text.trim().isEmpty
                            ? null
                            : _note.text.trim(),
                        dateTime: _selectedDate,
                      );
                  if (!context.mounted) return;
                  await _showBudgetAlertIfNeeded(context, ref, _type);
                  if (!context.mounted) return;
                  context.pop(true);
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.saveTransaction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.children});

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

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.label,
    required this.categories,
    required this.value,
    required this.noneLabel,
    required this.onChanged,
  });

  final String label;
  final List<CategoryEntity> categories;
  final String? value;
  final String noneLabel;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category_rounded),
      ),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(noneLabel)),
        ...categories.map(
          (category) => DropdownMenuItem<String?>(
            value: category.id,
            child: Text(category.name),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        child: Text(Formatters.date(value)),
      ),
    );
  }
}

class _TransactionListTile extends StatelessWidget {
  const _TransactionListTile({
    required this.title,
    required this.type,
    required this.amount,
    this.onDelete,
    this.onTap,
  });

  final String title;
  final TransactionType type;
  final String amount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = type == TransactionType.income;
    final accent = isIncome ? const Color(0xFF1B9E77) : const Color(0xFFE35D4F);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      child: Material(
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
          title: Text(title),
          subtitle: Text(type.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: theme.textTheme.labelLarge?.copyWith(color: accent),
              ),
              if (onDelete != null) ...[
                SizedBox(width: 6.w),
                IconButton(
                  tooltip: AppLocalizations.of(context)!.delete,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({required this.transaction, super.key});
  final TransactionEntity transaction;

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late TransactionType _type;
  late String? _categoryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.transaction.title);
    _amount = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    _note = TextEditingController(text: widget.transaction.note ?? '');
    _type = widget.transaction.type;
    _categoryId = widget.transaction.categoryId.isEmpty
        ? null
        : widget.transaction.categoryId;
    _selectedDate = widget.transaction.dateTime;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref
        .watch(categoryViewModelProvider)
        .maybeWhen(data: (items) => items, orElse: () => <CategoryEntity>[]);
    final matchingCategories = categories
        .where((category) => category.type == _type)
        .toList();
    if (_categoryId != null &&
        !matchingCategories.any((category) => category.id == _categoryId)) {
      _categoryId = null;
    }

    return AppScaffold(
      title: l10n.editTransaction,
      actions: [
        IconButton(
          tooltip: l10n.delete,
          onPressed: () => _deleteTransaction(
            context,
            ref,
            widget.transaction.id,
            popCount: 1,
          ),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          _FormPanel(
            children: [
              Text(
                l10n.updateDetails,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  prefixIcon: Icon(Icons.payments_rounded),
                ),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<TransactionType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.type,
                  prefixIcon: Icon(Icons.swap_vert_rounded),
                ),
                items: TransactionType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(_transactionTypeLabel(l10n, e)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() {
                  _type = val ?? _type;
                  _categoryId = null;
                }),
              ),
              SizedBox(height: 12.h),
              _CategoryDropdown(
                label: l10n.categoryOptional,
                categories: matchingCategories,
                value: _categoryId,
                noneLabel: l10n.noCategory,
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              SizedBox(height: 12.h),
              _DatePickerField(
                label: l10n.date,
                value: _selectedDate,
                onTap: () async {
                  final picked = await _pickTransactionDate(
                    context,
                    _selectedDate,
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _note,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              SizedBox(height: 18.h),
              FilledButton.icon(
                onPressed: () async {
                  final updated = widget.transaction.copyWith(
                    title: _title.text.trim(),
                    amount:
                        double.tryParse(_amount.text.trim()) ??
                        widget.transaction.amount,
                    type: _type,
                    categoryId: _categoryId ?? '',
                    dateTime: _selectedDate,
                    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                    updatedAt: DateTime.now(),
                  );
                  await ref
                      .read(transactionListViewModelProvider.notifier)
                      .updateTransaction(updated);
                  if (!context.mounted) return;
                  await _showBudgetAlertIfNeeded(context, ref, _type);
                  if (!context.mounted) return;
                  context.pop(true);
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.saveChanges),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({required this.transaction, super.key});
  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: AppLocalizations.of(context)!.transactionDetail,
      actions: [
        IconButton(
          tooltip: AppLocalizations.of(context)!.edit,
          onPressed: () async {
            final changed = await context.push<bool>(
              AppRoutes.editTransaction,
              extra: transaction,
            );
            if (changed == true) {
              ref.invalidate(transactionListViewModelProvider);
              if (!context.mounted) return;
              context.pop(true);
            }
          },
          icon: const Icon(Icons.edit_rounded),
        ),
        IconButton(
          tooltip: AppLocalizations.of(context)!.delete,
          onPressed: () =>
              _deleteTransaction(context, ref, transaction.id, popCount: 1),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          _FormPanel(
            children: [
              _DetailTile(
                label: AppLocalizations.of(context)!.title,
                value: transaction.title,
                icon: Icons.title_rounded,
              ),
              _DetailTile(
                label: AppLocalizations.of(context)!.amount,
                value: Formatters.currency(transaction.amount),
                icon: Icons.payments_rounded,
              ),
              _DetailTile(
                label: AppLocalizations.of(context)!.type,
                value: _transactionTypeLabel(
                  AppLocalizations.of(context)!,
                  transaction.type,
                ),
                icon: Icons.swap_vert_rounded,
              ),
              _DetailTile(
                label: AppLocalizations.of(context)!.date,
                value: Formatters.date(transaction.dateTime),
                icon: Icons.calendar_today_rounded,
              ),
              _DetailTile(
                label: AppLocalizations.of(context)!.note,
                value: transaction.note ?? '-',
                icon: Icons.notes_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  String query = '';
  bool onlyExpense = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionListViewModelProvider);
    return AppScaffold(
      title: AppLocalizations.of(context)!.transactionHistory,
      child: state.when(
        data: (items) {
          var filtered = items
              .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
          if (onlyExpense) {
            filtered = filtered
                .where((e) => e.type == TransactionType.expense)
                .toList();
          }
          filtered.sort((a, b) => b.amount.compareTo(a.amount));
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.searchTransaction,
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (v) => setState(() => query = v),
                    ),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilterChip(
                        avatar: Icon(Icons.filter_alt_rounded, size: 18.sp),
                        label: Text(AppLocalizations.of(context)!.expenseOnly),
                        selected: onlyExpense,
                        onSelected: (v) => setState(() => onlyExpense = v),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final txn = filtered[index];
                    return _TransactionListTile(
                      title: txn.title,
                      type: txn.type,
                      amount: Formatters.currency(txn.amount),
                      onTap: () async {
                        final changed = await context.push<bool>(
                          AppRoutes.editTransaction,
                          extra: txn,
                        );
                        if (changed == true) {
                          ref.invalidate(transactionListViewModelProvider);
                        }
                      },
                      onDelete: () => _deleteTransaction(context, ref, txn.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

Future<void> _deleteTransaction(
  BuildContext context,
  WidgetRef ref,
  String id, {
  int popCount = 0,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.deleteTransactionQuestion),
      content: Text(AppLocalizations.of(context)!.deleteTransactionMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(dialogContext, true),
          icon: const Icon(Icons.delete_outline_rounded),
          label: Text(AppLocalizations.of(context)!.delete),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  await ref
      .read(transactionListViewModelProvider.notifier)
      .deleteTransaction(id);
  if (!context.mounted) return;

  for (var i = 0; i < popCount; i++) {
    context.pop(true);
  }
}

Future<void> _showBudgetAlertIfNeeded(
  BuildContext context,
  WidgetRef ref,
  TransactionType transactionType,
) async {
  if (transactionType != TransactionType.expense) return;

  final budgets = await ref.refresh(budgetViewModelProvider.future);
  final alertBudget = _budgetNeedingAlert(budgets);
  if (alertBudget == null || !context.mounted) return;

  await _playBudgetAlertFeedback();
  if (!context.mounted) return;

  final usagePercent = (alertBudget.usagePercent * 100).clamp(0, 999).round();
  final isOverBudget = alertBudget.usagePercent >= 1;
  final l10n = AppLocalizations.of(context)!;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isOverBudget ? l10n.budgetExceeded : l10n.budgetAlert),
      content: Text(
        l10n.budgetAlertMessage(
          alertBudget.title,
          usagePercent,
          Formatters.currency(alertBudget.spentAmount),
          Formatters.currency(alertBudget.amountLimit),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.ok),
        ),
      ],
    ),
  );
}

Future<void> _playBudgetAlertFeedback() async {
  await SystemSound.play(SystemSoundType.alert);
  await Future<void>.delayed(const Duration(milliseconds: 120));
  await SystemSound.play(SystemSoundType.alert);

  final hasVibrator = await Vibration.hasVibrator();
  if (hasVibrator) {
    final hasAmplitudeControl = await Vibration.hasAmplitudeControl();
    if (hasAmplitudeControl) {
      await Vibration.vibrate(
        pattern: const [0, 450, 140, 450, 140, 700],
        intensities: const [0, 255, 0, 255, 0, 255],
      );
    } else {
      await Vibration.vibrate(pattern: const [0, 450, 140, 450, 140, 700]);
    }
    return;
  }

  await HapticFeedback.vibrate();
  await HapticFeedback.heavyImpact();
  await Future<void>.delayed(const Duration(milliseconds: 120));
  await HapticFeedback.heavyImpact();
  await Future<void>.delayed(const Duration(milliseconds: 120));
  await HapticFeedback.vibrate();
}

BudgetEntity? _budgetNeedingAlert(List<BudgetEntity> budgets) {
  final matchingBudgets =
      budgets
          .where(
            (budget) =>
                budget.amountLimit > 0 &&
                budget.usagePercent >= budget.alertThresholdPercent,
          )
          .toList()
        ..sort((a, b) => b.usagePercent.compareTo(a.usagePercent));

  return matchingBudgets.isEmpty ? null : matchingBudgets.first;
}

String _transactionTypeLabel(AppLocalizations l10n, TransactionType type) {
  return type == TransactionType.income ? l10n.income : l10n.expense;
}

Future<DateTime?> _pickTransactionDate(
  BuildContext context,
  DateTime initialDate,
) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(now.year + 1, 12, 31),
  );
}
