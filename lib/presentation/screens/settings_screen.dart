import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/shared_widgets/app_scaffold.dart';
import '../viewmodels/settings_viewmodel.dart';

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
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: [
            _SettingsAccordionPanel(
              title: l10n.appearance,
              children: [
                _ThemeModeTile(
                  title: l10n.systemDefault,
                  value: ThemeMode.system,
                  groupValue: data.themeMode,
                  onChanged: (value) => _saveThemeMode(context, ref, value),
                ),
                _ThemeModeTile(
                  title: l10n.lightMode,
                  value: ThemeMode.light,
                  groupValue: data.themeMode,
                  onChanged: (value) => _saveThemeMode(context, ref, value),
                ),
                _ThemeModeTile(
                  title: l10n.darkMode,
                  value: ThemeMode.dark,
                  groupValue: data.themeMode,
                  onChanged: (value) => _saveThemeMode(context, ref, value),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _SettingsAccordionPanel(
              title: l10n.language,
              children: [
                _LanguageTile(
                  title: l10n.english,
                  locale: const Locale('en'),
                  groupValue: data.locale,
                  onChanged: (value) => _saveLocale(context, ref, value),
                ),
                _LanguageTile(
                  title: l10n.myanmar,
                  locale: const Locale('my'),
                  groupValue: data.locale,
                  onChanged: (value) => _saveLocale(context, ref, value),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _SettingsPanel(
              title: l10n.security,
              children: [
                SwitchListTile(
                  title: Text(l10n.fingerprintLogin),
                  subtitle: Text(l10n.fingerprintLoginDescription),
                  value: data.fingerprintLoginEnabled,
                  contentPadding: EdgeInsets.zero,
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

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.title, required this.children});

  final String title;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          SizedBox(height: 8.h),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsAccordionPanel extends StatelessWidget {
  const _SettingsAccordionPanel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          title: Text(title, style: theme.textTheme.titleMedium),
          children: children,
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return ListTile(
      title: Text(title),
      contentPadding: EdgeInsets.zero,
      trailing: selected ? const Icon(Icons.check_circle_rounded) : null,
      onTap: () => onChanged(value),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.locale,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final Locale locale;
  final Locale groupValue;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = locale.languageCode == groupValue.languageCode;
    return ListTile(
      title: Text(title),
      contentPadding: EdgeInsets.zero,
      trailing: selected ? const Icon(Icons.check_circle_rounded) : null,
      onTap: () => onChanged(locale),
    );
  }
}
