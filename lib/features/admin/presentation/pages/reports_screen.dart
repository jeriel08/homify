import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/admin/presentation/widgets/reports/recent_reports_list.dart';
import 'package:homify/features/admin/presentation/widgets/reports/report_overview_card.dart';
import 'package:homify/features/admin/presentation/widgets/reports/report_status_card.dart';
import 'package:homify/features/admin/presentation/widgets/reports/report_trend_chart.dart';
import 'package:homify/features/admin/presentation/widgets/reports/top_categories_list.dart';
import 'package:homify/features/reports/presentation/providers/report_stats_provider.dart';

// Provider for selected time period
final selectedTimePeriodProvider = StateProvider<String>((ref) => 'This Month');

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  // Brand colors
  static const Color primary = Color(0xFF32190D);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color background = Color(0xFFFFFAF5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedTimePeriodProvider);
    final stats = ref.watch(reportStatsProvider(selectedPeriod));
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: background,
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'User Issue Reports',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Text(
                'Review and manage user-submitted issues.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              const Gap(24),

              // Time period filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      [
                        'This Week',
                        'This Month',
                        'Last 3 Months',
                        'This Year',
                      ].map((period) {
                        final isSelected = selectedPeriod == period;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(period),
                            selected: isSelected,
                            onSelected: (_) {
                              ref
                                      .read(selectedTimePeriodProvider.notifier)
                                      .state =
                                  period;
                            },
                            backgroundColor: surface.withValues(alpha: 0.3),
                            selectedColor: primary,
                            labelStyle: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: isSelected ? surface : primary,
                                  fontWeight: FontWeight.w600,
                                ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected ? primary : surface,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                ),
              ),

              const Gap(28),

              // Report Overview Card
              ReportOverviewCard(stats: stats),

              const Gap(32),

              // Report Trend (only show for "This Week")
              if (selectedPeriod == 'This Week' &&
                  stats.dailyReports.isNotEmpty) ...[
                Text(
                  'New Reports Trend',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const Gap(12),
                ReportTrendChart(dailyData: stats.dailyReports),
                const Gap(32),
              ],

              // Report Status
              Text(
                'Report Status Breakdown',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(12),
              ReportStatusCard(stats: stats),

              const Gap(32),

              // Top Report Categories
              Text(
                'Top Report Categories',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(12),
              TopCategoriesList(reportsByType: stats.reportsByType),

              const Gap(32),

              // Recent Reports
              Text(
                'Recent Reports',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(12),
              RecentReportsList(recentReports: stats.recentReports),

              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}
