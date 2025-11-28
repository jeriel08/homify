import 'package:dartz/dartz.dart';
import 'package:homify/core/errors/failures.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/domain/repositories/report_repository.dart';

class UpdateReportStatus {
  final ReportRepository repository;

  UpdateReportStatus(this.repository);

  Future<Either<Failure, void>> call(UpdateReportStatusParams params) {
    return repository.updateReportStatus(
      params.reportId,
      params.status,
      params.resolvedBy,
    );
  }
}

class UpdateReportStatusParams {
  final String reportId;
  final ReportStatus status;
  final String resolvedBy;

  const UpdateReportStatusParams({
    required this.reportId,
    required this.status,
    required this.resolvedBy,
  });
}
