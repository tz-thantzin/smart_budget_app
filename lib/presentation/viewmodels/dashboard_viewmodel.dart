import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/app_providers.dart';
import '../../domain/entities/dashboard_summary_entity.dart';

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
    state = AsyncData(await ref.read(getDashboardSummaryUseCaseProvider).call());
  }
}
