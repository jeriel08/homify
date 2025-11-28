import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'package:homify/features/admin/domain/entities/chart_data.dart';
import 'package:homify/features/admin/presentation/providers/admin_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Registration Trend Chart Card
class RegistrationTrendCard extends ConsumerWidget {
  const RegistrationTrendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(adminGraphFilterProvider);
    final chartDataAsync = ref.watch(adminGraphDataProvider);
    final filters = ['This Week', 'Last Week', 'Last Month'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: filters.map((f) {
                final isSelected = selectedFilter == f;
                return FilterChip(
                  label: Text(
                    f,
                    style: HomifyTypography.label2.copyWith(
                      color: isSelected
                          ? const Color(0xFFF9E5C5)
                          : const Color(0xFF32190D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    ref.read(adminGraphFilterProvider.notifier).state = f;
                  },
                  backgroundColor: const Color(
                    0xFFF9E5C5,
                  ).withValues(alpha: 0.3),
                  selectedColor: const Color(0xFF32190D),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF32190D)
                          : const Color(0xFFF9E5C5),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),

            const Gap(32),

            // Interactive Line Chart
            SizedBox(
              height: 320,
              child: chartDataAsync.when(
                data: (data) => SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: const EdgeInsets.only(right: 12, top: 16),

                  // X-Axis: Days
                  primaryXAxis: CategoryAxis(
                    labelStyle: HomifyTypography.label3.copyWith(
                      color: AdminDashboardScreen.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: AxisLine(width: 2, color: Colors.grey.shade300),
                    majorTickLines: const MajorTickLines(width: 0),
                  ),

                  // Y-Axis: Number of Users
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    interval: data.isEmpty ? 10 : null,
                    labelStyle: HomifyTypography.label3.copyWith(
                      color: AdminDashboardScreen.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Colors.grey.shade200,
                      dashArray: const [5, 5],
                    ),
                    axisLine: AxisLine(width: 2, color: Colors.grey.shade300),
                    majorTickLines: const MajorTickLines(width: 0),
                    title: AxisTitle(
                      text: 'New Users',
                      textStyle: HomifyTypography.label2.copyWith(
                        color: AdminDashboardScreen.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Enable tooltip on tap/hover
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: const Color(0xFF32190D),
                    textStyle: const TextStyle(
                      color: Color(0xFFF9E5C5),
                      fontWeight: FontWeight.w600,
                    ),
                    format: 'point.x: point.y users',
                    borderWidth: 2,
                    borderColor: AdminDashboardScreen.primary,
                    elevation: 4,
                  ),

                  series: <CartesianSeries<ChartData, String>>[
                    // Area under the line for visual appeal
                    SplineAreaSeries<ChartData, String>(
                      dataSource: data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.users,
                      color: AdminDashboardScreen.primary.withValues(
                        alpha: 0.15,
                      ),
                      borderColor: AdminDashboardScreen.primary,
                      borderWidth: 0,
                      gradient: LinearGradient(
                        colors: [
                          AdminDashboardScreen.primary.withValues(alpha: 0.3),
                          AdminDashboardScreen.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    // Main line with markers
                    SplineSeries<ChartData, String>(
                      dataSource: data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.users,
                      name: 'New Users',
                      color: AdminDashboardScreen.primary,
                      width: 3,

                      // Smooth spline curve
                      splineType: SplineType.cardinal,
                      cardinalSplineTension: 0.5,

                      // Marker settings for data points
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        height: 8,
                        width: 8,
                        borderWidth: 3,
                        borderColor: AdminDashboardScreen.primary,
                        color: Colors.white,
                      ),

                      // Data labels on points
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top,
                        textStyle: HomifyTypography.label3.copyWith(
                          color: const Color(0xFF32190D),
                          fontWeight: FontWeight.w700,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                      ),

                      // Interactive features
                      enableTooltip: true,
                      animationDuration: 1200,
                    ),
                  ],
                ),
                loading: () => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AdminDashboardScreen.primary,
                  ),
                ),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.chartLine,
                        size: 48,
                        color: Colors.red.shade300,
                      ),
                      const Gap(12),
                      Text(
                        'Failed to load chart data',
                        style: HomifyTypography.body3.copyWith(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
