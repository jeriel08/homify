import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/reports/data/models/report_model.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';

abstract class ReportRemoteDataSource {
  Future<void> submitReport(ReportModel report);
  Future<List<ReportModel>> getReports();
  Future<void> updateReportStatus(String reportId, ReportStatus status);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final FirebaseFirestore firestore;

  ReportRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> submitReport(ReportModel report) async {
    await firestore
        .collection('reports')
        .doc(report.id)
        .set(report.toFirestore());
  }

  @override
  Future<List<ReportModel>> getReports() async {
    final snapshot = await firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    await firestore.collection('reports').doc(reportId).update({
      'status': status.name,
    });
  }
}
