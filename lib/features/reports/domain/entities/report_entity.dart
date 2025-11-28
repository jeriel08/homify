import 'package:equatable/equatable.dart';

enum ReportType {
  bug,
  inappropriateContent,
  fakeProperty,
  inappropriateDescription,
  unresponsiveOwner,
  inappropriateImage,
  other,
}

enum ReportStatus { pending, solved, fixed }

class ReportEntity extends Equatable {
  final String id;
  final String reporterId;
  final String? targetId; // ID of the property or user being reported
  final String targetType; // 'property', 'user', 'app'
  final ReportType type;
  final String title;
  final String description;
  final ReportStatus status;
  final DateTime createdAt;
  final String? resolvedBy; // ID of admin who resolved the report
  final DateTime? resolvedAt; // When the report was resolved

  const ReportEntity({
    required this.id,
    required this.reporterId,
    this.targetId,
    required this.targetType,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedBy,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
    id,
    reporterId,
    targetId,
    targetType,
    type,
    title,
    description,
    status,
    createdAt,
    resolvedBy,
    resolvedAt,
  ];
}
