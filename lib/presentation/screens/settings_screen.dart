import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:budget_app/core/constants/app_currency.dart';
import 'package:budget_app/core/extensions/build_context_extensions.dart';
import 'package:budget_app/core/shared_widgets/app_scaffold.dart';
import 'package:budget_app/presentation/viewmodels/settings_viewmodel.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();
    final settings = ref.watch(settingsViewModelProvider);
    final l10n = context.localization;

    return AppScaffold(
      title: l10n.settings,
      child: settings.when(
        data: (data) => ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
          children: [
            _AppHeaderCard(),
            SizedBox(height: 24.h),
            _SectionLabel(label: l10n.appearance),
            SizedBox(height: 8.h),
            _SettingsCard(
              children: [
                _ThemeSelectorRow(
                  groupValue: data.themeMode,
                  systemLabel: l10n.systemDefault,
                  lightLabel: l10n.lightMode,
                  darkLabel: l10n.darkMode,
                  onChanged: (value) => _saveThemeMode(context, ref, value),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _SectionLabel(label: l10n.language),
            SizedBox(height: 8.h),
            _SettingsCard(
              children: [
                _LanguageSelectorRow(
                  groupValue: data.locale,
                  englishLabel: l10n.english,
                  myanmarLabel: l10n.myanmar,
                  onChanged: (value) => _saveLocale(context, ref, value),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _SectionLabel(label: l10n.currency),
            SizedBox(height: 8.h),
            _SettingsCard(
              children: [
                _CurrencyRow(
                  currencyCode: data.currencyCode,
                  label: l10n.currency,
                  onTap: () =>
                      _showCurrencyPicker(context, ref, data.currencyCode),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _SectionLabel(label: l10n.security),
            SizedBox(height: 8.h),
            _SettingsCard(
              children: [
                _FingerprintRow(
                  enabled: data.fingerprintLoginEnabled,
                  title: l10n.fingerprintLogin,
                  subtitle: l10n.fingerprintLoginDescription,
                  onChanged: (value) =>
                      _saveFingerprintLogin(context, ref, value),
                ),
              ],
            ),
          ],
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _showCurrencyPicker(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) async {
    final l10n = context.localization;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, scrollController) => Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.currency,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                  children: AppCurrency.values.map((currency) {
                    final selected = currency.code == currentCode;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        child: Text(
                          currency.symbol,
                          style: TextStyle(
                            color: selected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      title: Text(currency.label),
                      subtitle: Text(currency.code),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _saveCurrency(context, ref, currency.code);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveThemeMode(
    BuildContext context,
    WidgetRef ref,
    ThemeMode? themeMode,
  ) async {
    if (themeMode == null) return;
    await ref.read(settingsViewModelProvider.notifier).setThemeMode(themeMode);
    if (!context.mounted) return;
    _showSavedMessage(context);
  }

  Future<void> _saveLocale(
    BuildContext context,
    WidgetRef ref,
    Locale? locale,
  ) async {
    if (locale == null) return;
    await ref.read(settingsViewModelProvider.notifier).setLocale(locale);
    if (!context.mounted) return;
    final l10n = context.localization;
    final language = locale.languageCode == 'my' ? l10n.myanmar : l10n.english;
    _showSnackBarMessage(context, l10n.languageChanged(language));
  }

  Future<void> _saveCurrency(
    BuildContext context,
    WidgetRef ref,
    String? currencyCode,
  ) async {
    if (currencyCode == null) return;
    await ref
        .read(settingsViewModelProvider.notifier)
        .setCurrencyCode(currencyCode);
    if (!context.mounted) return;
    _showSnackBarMessage(
      context,
      '${context.localization.preferencesSaved}: $currencyCode',
    );
  }

  Future<void> _saveFingerprintLogin(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final l10n = context.localization;
    final saved = await ref
        .read(settingsViewModelProvider.notifier)
        .setFingerprintLoginEnabled(
          enabled: enabled,
          reason: l10n.fingerprintAuthReason,
        );
    if (!context.mounted) return;
    if (saved) {
      _showSnackBarMessage(
        context,
        enabled ? l10n.fingerprintActivated : l10n.fingerprintDeactivated,
      );
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.fingerprintFailed)));
  }

  void _showSavedMessage(BuildContext context) {
    _showSnackBarMessage(context, context.localization.preferencesSaved);
  }

  void _showSnackBarMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AppHeaderCard extends StatelessWidget {
  const _AppHeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 30.sp,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Budget',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Personal Finance Manager',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
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

class _ThemeSelectorRow extends StatelessWidget {
  const _ThemeSelectorRow({
    required this.groupValue,
    required this.systemLabel,
    required this.lightLabel,
    required this.darkLabel,
    required this.onChanged,
  });

  final ThemeMode groupValue;
  final String systemLabel;
  final String lightLabel;
  final String darkLabel;
  final ValueChanged<ThemeMode?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeOption(
          icon: Icons.brightness_auto_rounded,
          label: systemLabel,
          value: ThemeMode.system,
          groupValue: groupValue,
          onTap: () => onChanged(ThemeMode.system),
        ),
        SizedBox(width: 8.w),
        _ThemeOption(
          icon: Icons.light_mode_rounded,
          label: lightLabel,
          value: ThemeMode.light,
          groupValue: groupValue,
          onTap: () => onChanged(ThemeMode.light),
        ),
        SizedBox(width: 8.w),
        _ThemeOption(
          icon: Icons.dark_mode_rounded,
          label: darkLabel,
          value: ThemeMode.dark,
          groupValue: groupValue,
          onTap: () => onChanged(ThemeMode.dark),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ThemeMode value;
  final ThemeMode groupValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22.sp,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSelectorRow extends StatelessWidget {
  const _LanguageSelectorRow({
    required this.groupValue,
    required this.englishLabel,
    required this.myanmarLabel,
    required this.onChanged,
  });

  final Locale groupValue;
  final String englishLabel;
  final String myanmarLabel;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LanguageOption(
          label: englishLabel,
          code: 'EN',
          locale: const Locale('en'),
          groupValue: groupValue,
          onTap: () => onChanged(const Locale('en')),
        ),
        SizedBox(width: 10.w),
        _LanguageOption(
          label: myanmarLabel,
          code: 'MY',
          locale: const Locale('my'),
          groupValue: groupValue,
          onTap: () => onChanged(const Locale('my')),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.code,
    required this.locale,
    required this.groupValue,
    required this.onTap,
  });

  final String label;
  final String code;
  final Locale locale;
  final Locale groupValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = locale.languageCode == groupValue.languageCode;
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              Text(
                code,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.85)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.currencyCode,
    required this.label,
    required this.onTap,
  });

  final String currencyCode;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = AppCurrency.fromCode(currencyCode);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                currency.symbol,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${currency.label} (${currency.code})',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _FingerprintRow extends StatelessWidget {
  const _FingerprintRow({
    required this.enabled,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final bool enabled;
  final String title;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: enabled
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.fingerprint_rounded,
            size: 24.sp,
            color: enabled
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(value: enabled, onChanged: onChanged),
      ],
    );
  }
}
