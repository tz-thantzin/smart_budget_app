import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:budget_app/core/extensions/build_context_extensions.dart';
import 'package:budget_app/di/app_providers.dart';
import 'package:budget_app/router/app_routes.dart';
import 'package:budget_app/presentation/viewmodels/settings_viewmodel.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 600), () {
      _openApp();
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Future<void> _openApp() async {
    final settings = await ref.read(settingsViewModelProvider.future);
    if (!mounted) return;

    if (!settings.fingerprintLoginEnabled) {
      context.go(AppRoutes.dashboard);
      return;
    }

    final l10n = context.localization;
    final authenticated = await ref
        .read(biometricAuthServiceProvider)
        .authenticate(l10n.fingerprintAuthReason);

    if (!mounted) return;
    context.go(authenticated ? AppRoutes.dashboard : AppRoutes.login);
  }
}
