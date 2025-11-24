import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.reporterId,
    super.targetId,
    required super.targetType,
    required super.type,
    required super.title,
    required super.description,
    required super.status,
    required super.createdAt,
    super.resolvedBy,
    super.resolvedAt,
  });

  factory ReportModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      targetId: data['targetId'],
      targetType: data['targetType'] ?? 'app',
      type: ReportType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ReportType.other,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: ReportStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      resolvedBy: data['resolvedBy'],
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reporterId': reporterId,
      'targetId': targetId,
      'targetType': targetType,
      'type': type.name,
      'title': title,
      'description': description,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }
}
