import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/shared_widgets/app_scaffold.dart';
import '../../di/app_providers.dart';
import '../../router/app_routes.dart';
import '../viewmodels/settings_viewmodel.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.localization;
    return AppScaffold(
      title: l10n.login,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fingerprint_rounded,
                size: 72.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.fingerprintLogin,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20.h),
              FilledButton.icon(
                onPressed: () async {
                  final authenticated = await ref
                      .read(biometricAuthServiceProvider)
                      .authenticate(l10n.fingerprintAuthReason);
                  if (!context.mounted) return;
                  if (authenticated) {
                    context.go(AppRoutes.dashboard);
                    return;
                  }
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(content: Text(l10n.fingerprintFailed)),
                    );
                },
                icon: const Icon(Icons.lock_open_rounded),
                label: Text(l10n.unlockApp),
              ),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(settingsViewModelProvider.notifier)
                      .setFingerprintLoginEnabled(
                        enabled: false,
                        reason: l10n.fingerprintAuthReason,
                      );
                  if (!context.mounted) return;
                  context.go(AppRoutes.dashboard);
                },
                child: Text(l10n.disableFingerprintLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
