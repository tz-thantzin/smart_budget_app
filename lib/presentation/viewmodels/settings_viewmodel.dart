import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_app/core/constants/app_currency.dart';
import 'package:budget_app/core/constants/app_constants.dart';
import 'package:budget_app/di/app_providers.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.locale,
    required this.currencyCode,
    required this.fingerprintLoginEnabled,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final String currencyCode;
  final bool fingerprintLoginEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    String? currencyCode,
    bool? fingerprintLoginEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      currencyCode: currencyCode ?? this.currencyCode,
      fingerprintLoginEnabled:
          fingerprintLoginEnabled ?? this.fingerprintLoginEnabled,
    );
  }
}

final settingsViewModelProvider =
    AsyncNotifierProvider<SettingsViewModel, AppSettings>(
      SettingsViewModel.new,
    );

class SettingsViewModel extends AsyncNotifier<AppSettings> {
  static const _themeModeKey = 'theme_mode';
  static const _languageCodeKey = 'language_code';
  static const _currencyCodeKey = 'currency_code';
  static const _fingerprintLoginEnabledKey = 'fingerprint_login_enabled';

  @override
  Future<AppSettings> build() async {
    final preferences = await SharedPreferences.getInstance();
    final storedCurrencyCode = preferences.getString(_currencyCodeKey);
    final normalizedCurrencyCode = AppCurrency.fromCode(
      storedCurrencyCode ?? AppConstants.defaultCurrency,
    ).code;
    if (storedCurrencyCode == null ||
        storedCurrencyCode != normalizedCurrencyCode) {
      await preferences.setString(_currencyCodeKey, normalizedCurrencyCode);
    }

    return AppSettings(
      themeMode: _themeModeFromName(
        preferences.getString(_themeModeKey) ?? ThemeMode.system.name,
      ),
      locale: Locale(preferences.getString(_languageCodeKey) ?? 'en'),
      currencyCode: normalizedCurrencyCode,
      fingerprintLoginEnabled:
          preferences.getBool(_fingerprintLoginEnabledKey) ?? false,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final current = await future;
    final updated = current.copyWith(themeMode: themeMode);
    state = AsyncData(updated);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, themeMode.name);
  }

  Future<void> setLocale(Locale locale) async {
    final current = await future;
    final updated = current.copyWith(locale: locale);
    state = AsyncData(updated);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageCodeKey, locale.languageCode);
  }

  Future<void> setCurrencyCode(String currencyCode) async {
    final current = await future;
    final normalizedCode = AppCurrency.fromCode(currencyCode).code;
    final updated = current.copyWith(currencyCode: normalizedCode);
    state = AsyncData(updated);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_currencyCodeKey, normalizedCode);
  }

  Future<bool> setFingerprintLoginEnabled({
    required bool enabled,
    required String reason,
  }) async {
    if (enabled) {
      final authenticated = await ref
          .read(biometricAuthServiceProvider)
          .authenticate(reason);
      if (!authenticated) return false;
    }

    final current = await future;
    final updated = current.copyWith(fingerprintLoginEnabled: enabled);
    state = AsyncData(updated);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_fingerprintLoginEnabledKey, enabled);
    return true;
  }

  ThemeMode _themeModeFromName(String name) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}

final currentCurrencyCodeProvider = Provider<String>((ref) {
  return ref
      .watch(settingsViewModelProvider)
      .maybeWhen(
        data: (settings) => settings.currencyCode,
        orElse: () => AppConstants.defaultCurrency,
      );
});
