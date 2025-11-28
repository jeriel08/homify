import 'package:homify/features/reports/domain/entities/report_entity.dart';

/// Statistics model for report analytics
class ReportStats {
  final int totalReports;
  final int pendingReports;
  final int resolvedReports; // solved + fixed
  final Map<ReportType, int> reportsByType;
  final List<ReportEntity> recentReports;
  final Map<String, int> dailyReports; // e.g., {'Mon': 3, 'Tue': 5}

  const ReportStats({
    required this.totalReports,
    required this.pendingReports,
    required this.resolvedReports,
    required this.reportsByType,
    required this.recentReports,
    required this.dailyReports,
  });

  double get resolutionRate =>
      totalReports > 0 ? resolvedReports / totalReports : 0.0;

  /// Empty stats for initial state
  static const empty = ReportStats(
    totalReports: 0,
    pendingReports: 0,
    resolvedReports: 0,
    reportsByType: {},
    recentReports: [],
    dailyReports: {},
  );
}
