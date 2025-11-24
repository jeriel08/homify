import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/reports/data/models/report_model.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';

abstract class ReportRemoteDataSource {
  Future<void> submitReport(ReportModel report);
  Future<List<ReportModel>> getReports();
  Stream<List<ReportModel>> getReportsStream();
  Future<void> updateReportStatus(
    String reportId,
    ReportStatus status,
    String resolvedBy,
  );
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
  Stream<List<ReportModel>> getReportsStream() {
    return firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReportModel.fromSnapshot(doc))
              .toList();
        });
  }

  @override
  Future<void> updateReportStatus(
    String reportId,
    ReportStatus status,
    String resolvedBy,
  ) async {
    await firestore.collection('reports').doc(reportId).update({
      'status': status.name,
      'resolvedBy': resolvedBy,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}
