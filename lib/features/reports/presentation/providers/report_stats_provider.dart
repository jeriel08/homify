import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/domain/entities/report_stats.dart';
import 'package:homify/features/reports/presentation/providers/report_provider.dart';
import 'package:intl/intl.dart';

/// Provider for calculating report statistics filtered by time period
final reportStatsProvider = Provider.family<ReportStats, String>((
  ref,
  timePeriod,
) {
  final reportsAsync = ref.watch(reportsProvider);

  return reportsAsync.when(
    data: (reports) {
      // Filter reports by time period
      final filteredReports = _filterByTimePeriod(reports, timePeriod);

      // Calculate statistics
      final totalReports = filteredReports.length;
      final pendingReports = filteredReports
          .where((r) => r.status == ReportStatus.pending)
          .length;
      final resolvedReports = filteredReports
          .where(
            (r) =>
                r.status == ReportStatus.solved ||
                r.status == ReportStatus.fixed,
          )
          .length;

      // Count reports by type
      final reportsByType = <ReportType, int>{};
      for (final report in filteredReports) {
        reportsByType[report.type] = (reportsByType[report.type] ?? 0) + 1;
      }

      // Get recent reports (last 3)
      final sortedReports = List<ReportEntity>.from(filteredReports)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentReports = sortedReports.take(3).toList();

      // Calculate daily reports for the last 7 days
      final dailyReports = _calculateDailyReports(filteredReports, timePeriod);

      return ReportStats(
        totalReports: totalReports,
        pendingReports: pendingReports,
        resolvedReports: resolvedReports,
        reportsByType: reportsByType,
        recentReports: recentReports,
        dailyReports: dailyReports,
      );
    },
    loading: () => ReportStats.empty,
    error: (_, _) => ReportStats.empty,
  );
});

/// Filter reports based on selected time period
List<ReportEntity> _filterByTimePeriod(
  List<ReportEntity> reports,
  String timePeriod,
) {
  final now = DateTime.now();
  DateTime startDate;

  switch (timePeriod) {
    case 'This Week':
      startDate = now.subtract(const Duration(days: 7));
      break;
    case 'This Month':
      startDate = DateTime(now.year, now.month, 1);
      break;
    case 'Last 3 Months':
      startDate = DateTime(now.year, now.month - 3, 1);
      break;
    case 'This Year':
      startDate = DateTime(now.year, 1, 1);
      break;
    default:
      startDate = DateTime(now.year, now.month, 1); // Default to this month
  }

  return reports
      .where((report) => report.createdAt.isAfter(startDate))
      .toList();
}

/// Calculate daily report counts
Map<String, int> _calculateDailyReports(
  List<ReportEntity> reports,
  String timePeriod,
) {
  // For "This Week", show last 7 days
  if (timePeriod == 'This Week') {
    final dailyCounts = <String, int>{};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = DateFormat('E').format(date); // Mon, Tue, etc.
      dailyCounts[dayName] = 0;
    }

    for (final report in reports) {
      final dayName = DateFormat('E').format(report.createdAt);
      if (dailyCounts.containsKey(dayName)) {
        dailyCounts[dayName] = (dailyCounts[dayName] ?? 0) + 1;
      }
    }

    return dailyCounts;
  }

  // For other periods, return empty map (can be enhanced later)
  return {};
}
