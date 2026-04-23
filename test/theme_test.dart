import 'package:budget_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('light theme text uses readable surface colors', () {
    final theme = AppTheme.lightTheme;
    final textColor = theme.colorScheme.onSurface;

    expect(textColor, isNot(Colors.white));
    expect(theme.textTheme.headlineLarge?.color, textColor);
    expect(theme.textTheme.titleLarge?.color, textColor);
    expect(theme.textTheme.titleMedium?.color, textColor);
    expect(theme.textTheme.bodyLarge?.color, textColor);
    expect(theme.textTheme.bodyMedium?.color, textColor);
    expect(theme.textTheme.bodySmall?.color, textColor);
    expect(theme.textTheme.labelLarge?.color, textColor);
  });
}
