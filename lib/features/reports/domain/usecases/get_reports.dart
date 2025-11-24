import 'package:dartz/dartz.dart';
import 'package:homify/core/errors/failures.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/domain/repositories/report_repository.dart';

class GetReports {
  final ReportRepository repository;

  GetReports(this.repository);

  Future<Either<Failure, List<ReportEntity>>> call() {
    return repository.getReports();
  }
}
