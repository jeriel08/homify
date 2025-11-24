import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/reports/data/datasources/report_remote_data_source.dart';
import 'package:homify/features/reports/data/repositories/report_repository_impl.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/domain/usecases/get_reports.dart';
import 'package:homify/features/reports/domain/usecases/submit_report.dart';
import 'package:homify/features/reports/domain/usecases/update_report_status.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final reportRepositoryProvider = Provider<ReportRepositoryImpl>((ref) {
  return ReportRepositoryImpl(ref.read(reportRemoteDataSourceProvider));
});

final submitReportUseCaseProvider = Provider<SubmitReport>((ref) {
  return SubmitReport(ref.read(reportRepositoryProvider));
});

final getReportsUseCaseProvider = Provider<GetReports>((ref) {
  return GetReports(ref.read(reportRepositoryProvider));
});

final updateReportStatusUseCaseProvider = Provider<UpdateReportStatus>((ref) {
  return UpdateReportStatus(ref.read(reportRepositoryProvider));
});

final reportsProvider = FutureProvider<List<ReportEntity>>((ref) async {
  final getReports = ref.read(getReportsUseCaseProvider);
  final result = await getReports();
  return result.fold((failure) => throw failure, (reports) => reports);
});
