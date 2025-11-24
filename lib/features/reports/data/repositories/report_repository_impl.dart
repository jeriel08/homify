import 'package:dartz/dartz.dart';
import 'package:homify/core/errors/failures.dart';
import 'package:homify/features/reports/data/datasources/report_remote_data_source.dart';
import 'package:homify/features/reports/data/models/report_model.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> submitReport(ReportEntity report) async {
    try {
      final reportModel = ReportModel(
        id: report.id,
        reporterId: report.reporterId,
        targetId: report.targetId,
        targetType: report.targetType,
        type: report.type,
        title: report.title,
        description: report.description,
        status: report.status,
        createdAt: report.createdAt,
      );
      await remoteDataSource.submitReport(reportModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getReports() async {
    try {
      final reports = await remoteDataSource.getReports();
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateReportStatus(
    String reportId,
    ReportStatus status,
  ) async {
    try {
      await remoteDataSource.updateReportStatus(reportId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
