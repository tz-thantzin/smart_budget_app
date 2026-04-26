import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSelectionOption<T> {
  const AppSelectionOption({required this.value, required this.label});

  final T value;
  final String label;
}

class AppSelectionField<T> extends StatelessWidget {
  const AppSelectionField({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.prefixIcon,
    this.title,
    super.key,
  });

  final String label;
  final List<AppSelectionOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onSelected;
  final Widget? prefixIcon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final selectedOption = options.cast<AppSelectionOption<T>?>().firstWhere(
      (option) => option?.value == selectedValue,
      orElse: () => null,
    );

    return InkWell(
      onTap: () => _showSelectionSheet(context),
      borderRadius: BorderRadius.circular(16.r),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon,
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(selectedOption?.label ?? ''),
      ),
    );
  }

  Future<void> _showSelectionSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title!,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                ),
              ),
            ...options.map(
              (option) => ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                title: Text(option.label),
                trailing: option.value == selectedValue
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(sheetContext).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(option.value),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }
}
