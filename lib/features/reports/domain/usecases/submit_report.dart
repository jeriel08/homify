import 'package:dartz/dartz.dart';
import 'package:homify/core/errors/failures.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/domain/repositories/report_repository.dart';

class SubmitReport {
  final ReportRepository repository;

  SubmitReport(this.repository);

  Future<Either<Failure, void>> call(ReportEntity report) {
    return repository.submitReport(report);
  }
}
