import 'package:dartz/dartz.dart';
import 'package:homify/core/errors/failures.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, void>> submitReport(ReportEntity report);
  Future<Either<Failure, List<ReportEntity>>> getReports();
  Future<Either<Failure, void>> updateReportStatus(
    String reportId,
    ReportStatus status,
  );
}
