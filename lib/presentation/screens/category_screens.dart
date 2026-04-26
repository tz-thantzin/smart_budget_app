import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/shared_widgets/app_selection_field.dart';
import '../../core/shared_widgets/app_scaffold.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../router/app_routes.dart';
import '../viewmodels/category_viewmodel.dart';

class CategoriesManagementScreen extends ConsumerWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryViewModelProvider);
    final l10n = context.localization;
    return AppScaffold(
      title: l10n.categories,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addEditCategory),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addCategory),
      ),
      child: categories.when(
        data: (items) => items.isEmpty
            ? Center(child: Text(l10n.categoriesWillAppearHere))
            : ListView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                children: items
                    .map(
                      (category) => _CategoryCard(
                        category: category,
                        onEdit: () => context.push(
                          AppRoutes.addEditCategory,
                          extra: category,
                        ),
                        onDelete: () => _confirmDeleteCategory(
                          context,
                          ref,
                          category.id,
                          popAfterDelete: false,
                        ),
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

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  const AddEditCategoryScreen({super.key, this.category});

  final CategoryEntity? category;

  @override
  ConsumerState<AddEditCategoryScreen> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  late final TextEditingController controller;
  late TransactionType type;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.category?.name ?? '');
    type = widget.category?.type ?? TransactionType.expense;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    return AppScaffold(
      title: isEditing ? l10n.editCategory : l10n.addCategory,
      actions: [
        if (isEditing)
          IconButton(
            tooltip: l10n.delete,
            onPressed: () => _confirmDeleteCategory(
              context,
              ref,
              widget.category!.id,
              popAfterDelete: true,
            ),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
      ],
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          _CategoryPanel(
            children: [
              Text(
                l10n.categoryDetails,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.categoryName,
                  prefixIcon: const Icon(Icons.category_rounded),
                ),
              ),
              SizedBox(height: 12.h),
              AppSelectionField<TransactionType>(
                label: l10n.type,
                title: l10n.type,
                selectedValue: type,
                prefixIcon: const Icon(Icons.swap_vert_rounded),
                options: TransactionType.values
                    .map(
                      (value) => AppSelectionOption(
                        value: value,
                        label: _transactionTypeLabel(l10n, value),
                      ),
                    )
                    .toList(),
                onSelected: (value) => setState(() => type = value),
              ),
              SizedBox(height: 18.h),
              FilledButton.icon(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;

                  if (isEditing) {
                    final current = widget.category!;
                    await ref
                        .read(categoryViewModelProvider.notifier)
                        .updateCategory(
                          CategoryEntity(
                            id: current.id,
                            name: name,
                            type: type,
                            iconCodePoint: current.iconCodePoint,
                            colorHex: current.colorHex,
                          ),
                        );
                  } else {
                    await ref
                        .read(categoryViewModelProvider.notifier)
                        .addCategory(
                          name,
                          type,
                          Icons.category.codePoint,
                          Colors.teal.toARGB32(),
                        );
                  }

                  if (!context.mounted) return;
                  context.pop(true);
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.saveCategory),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.localization;
    final color = Color(category.colorHex);
    final icon = IconData(category.iconCodePoint, fontFamily: 'MaterialIcons');
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: ListTile(
        onTap: onEdit,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
        ),
        title: Text(category.name),
        subtitle: Text(_transactionTypeLabel(l10n, category.type)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.edit,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              tooltip: l10n.delete,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  const _CategoryPanel({required this.children});

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

String _transactionTypeLabel(AppLocalizations l10n, TransactionType type) {
  return type == TransactionType.income ? l10n.income : l10n.expense;
}

Future<void> _confirmDeleteCategory(
  BuildContext context,
  WidgetRef ref,
  String id, {
  required bool popAfterDelete,
}) async {
  final l10n = context.localization;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteCategoryQuestion),
      content: Text(l10n.deleteCategoryMessage),
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

  if (confirmed != true) return;
  await ref.read(categoryViewModelProvider.notifier).deleteCategory(id);
  if (!context.mounted) return;
  if (popAfterDelete && Navigator.canPop(context)) {
    context.pop(true);
  }
}
