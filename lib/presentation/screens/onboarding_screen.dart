import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/shared_widgets/app_scaffold.dart';
import '../../router/app_routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Welcome',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track spending, budgets, and goals', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            const Text('Production-ready foundation with clean architecture.'),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
