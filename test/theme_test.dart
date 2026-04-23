import 'package:budget_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('light theme text uses readable surface colors', (tester) async {
    late final ThemeData theme;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, child) {
          theme = AppTheme.lightTheme;
          return MaterialApp(theme: theme, home: const SizedBox());
        },
      ),
    );

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
