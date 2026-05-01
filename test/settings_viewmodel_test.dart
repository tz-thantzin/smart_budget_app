import 'package:budget_app/core/constants/app_constants.dart';
import 'package:budget_app/presentation/viewmodels/settings_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsViewModel currency preferences', () {
    test('persists USD when no currency has been stored yet', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final settings = await container.read(settingsViewModelProvider.future);
      final preferences = await SharedPreferences.getInstance();

      expect(settings.currencyCode, AppConstants.defaultCurrency);
      expect(
        preferences.getString('currency_code'),
        AppConstants.defaultCurrency,
      );
    });

    test('stores selected currency code in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(settingsViewModelProvider.future);
      await container
          .read(settingsViewModelProvider.notifier)
          .setCurrencyCode('JPY');

      final preferences = await SharedPreferences.getInstance();

      expect(container.read(currentCurrencyCodeProvider), 'JPY');
      expect(preferences.getString('currency_code'), 'JPY');
    });

    test('normalizes unsupported stored currency values back to USD', () async {
      SharedPreferences.setMockInitialValues({'currency_code': 'ABC'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final settings = await container.read(settingsViewModelProvider.future);
      final preferences = await SharedPreferences.getInstance();

      expect(settings.currencyCode, AppConstants.defaultCurrency);
      expect(
        preferences.getString('currency_code'),
        AppConstants.defaultCurrency,
      );
    });
  });
}
