import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget_app/di/app_providers.dart';
import 'package:budget_app/domain/entities/dashboard_summary_entity.dart';

final dashboardViewModelProvider =
    AsyncNotifierProvider<DashboardViewModel, DashboardSummaryEntity>(
      DashboardViewModel.new,
    );

class DashboardViewModel extends AsyncNotifier<DashboardSummaryEntity> {
  @override
  Future<DashboardSummaryEntity> build() {
    return ref.read(getDashboardSummaryUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(
      await ref.read(getDashboardSummaryUseCaseProvider).call(),
    );
  }
}
