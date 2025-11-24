import 'package:dartz/dartz.dart';
import 'package:homify/core/errors/failures.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, void>> submitReport(ReportEntity report);
  Future<Either<Failure, List<ReportEntity>>> getReports();
  Stream<Either<Failure, List<ReportEntity>>> getReportsStream();
  Future<Either<Failure, void>> updateReportStatus(
    String reportId,
    ReportStatus status,
    String resolvedBy,
  );
}
