import '../entities/dashboard_summary_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._repository);
  final DashboardRepository _repository;
  Future<DashboardSummaryEntity> call() => _repository.getDashboardSummary();
}
