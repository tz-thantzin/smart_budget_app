import 'package:budget_app/domain/entities/dashboard_summary_entity.dart';
import 'package:budget_app/domain/repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._repository);
  final DashboardRepository _repository;
  Future<DashboardSummaryEntity> call() => _repository.getDashboardSummary();
}
