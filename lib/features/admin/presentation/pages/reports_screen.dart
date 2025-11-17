import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
              _ReportOverviewCard(),

              const Gap(24),

              // Report Trend
              Text(
                'New Reports Trend',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(12),
              _ReportTrendChart(),

              const Gap(24),

              // Report Status
              Text(
                'Report Status Breakdown',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(12),
              _ReportStatusCard(),

              const Gap(24),

              // Top Report Categories
              Text(
                'Top Report Categories',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(12),
              _TopCategoriesList(),

              const Gap(24),

              // Recent Reports
              Text(
                'Recent Reports',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(12),
              _RecentReportsList(),

              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}

// Report Overview Card
class _ReportOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ReportsScreen.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.shieldAlert,
                  color: ReportsScreen.primary,
                  size: 24,
                ),
              ),
              const Gap(12),
              Text(
                'Report Overview',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ReportsScreen.textPrimary,
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            '128',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: ReportsScreen.primary,
            ),
          ),
          const Gap(8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.arrowUp,
                      color: Colors.orange,
                      size: 14,
                    ),
                    const Gap(4),
                    Text(
                      '15 new',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                'this week',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ReportsScreen.textSecondary,
                ),
              ),
            ],
          ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: LucideIcons.clock,
                  label: 'Pending',
                  value: '22',
                ),
              ),
              Container(width: 1, height: 40, color: ReportsScreen.surface),
              Expanded(
                child: _StatItem(
                  icon: LucideIcons.circleCheck,
                  label: 'Resolved',
                  value: '106',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stat Item Widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: ReportsScreen.textSecondary),
        const Gap(6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: ReportsScreen.textPrimary,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: ReportsScreen.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Report Trend Chart
class _ReportTrendChart extends StatelessWidget {
  final List<_ChartData> data = [
    _ChartData('Mon', 3),
    _ChartData('Tue', 5),
    _ChartData('Wed', 2),
    _ChartData('Thu', 4),
    _ChartData('Fri', 7),
    _ChartData('Sat', 5),
    _ChartData('Sun', 6),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Reports (This Week)',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: ReportsScreen.textPrimary,
            ),
          ),
          const Gap(20),
          SizedBox(
            height: 250,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ReportsScreen.textSecondary,
                ),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ReportsScreen.textSecondary,
                ),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Colors.grey.shade200,
                  dashArray: const [5, 5],
                ),
                axisLine: const AxisLine(width: 0),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                color: ReportsScreen.primary,
                textStyle: const TextStyle(color: Colors.white),
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.value,
                  gradient: LinearGradient(
                    colors: [
                      ReportsScreen.primary.withValues(alpha: 0.3),
                      ReportsScreen.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                SplineSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.value,
                  color: ReportsScreen.primary,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 8,
                    width: 8,
                    borderWidth: 3,
                    borderColor: ReportsScreen.primary,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Report Status Card
class _ReportStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 106 Resolved / 128 Total = ~0.828
    const double resolvedRate = 106 / 128;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: resolvedRate,
                    strokeWidth: 12,
                    backgroundColor: ReportsScreen.surface.withValues(
                      alpha: 0.3,
                    ),
                    color: ReportsScreen.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(resolvedRate * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ReportsScreen.primary,
                          ),
                    ),
                    Text(
                      'Resolved',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ReportsScreen.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusItem(
                  label: 'Total Reports',
                  value: '128',
                  color: ReportsScreen.primary,
                ),
                const Gap(12),
                _StatusItem(
                  label: 'Resolved',
                  value: '106',
                  color: Colors.green,
                ),
                const Gap(12),
                _StatusItem(
                  label: 'Pending',
                  value: '22',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: ReportsScreen.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: ReportsScreen.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Top Categories List
class _TopCategoriesList extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Fake Property', 'count': 42, 'icon': LucideIcons.circleAlert},
    {
      'name': 'Inappropriate Description',
      'count': 35,
      'icon': LucideIcons.messageSquareOff,
    },
    {'name': 'Unresponsive Owner', 'count': 21, 'icon': LucideIcons.userX},
    {'name': 'Other', 'count': 10, 'icon': LucideIcons.flipHorizontal},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final cat = entry.value;
          final isLast = index == categories.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ReportsScreen.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          cat['icon'],
                          size: 20,
                          color: ReportsScreen.primary,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        cat['name'],
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ReportsScreen.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ReportsScreen.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cat['count']} reports',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ReportsScreen.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 1,
                    color: ReportsScreen.surface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Recent Reports List
class _RecentReportsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _RecentReportItem(
            icon: LucideIcons.circleAlert,
            reportType: 'Fake Property',
            propertyName: 'Ocean View Condos',
            timeAgo: '1h ago',
            color: Colors.red,
          ),
          const Gap(16),
          _RecentReportItem(
            icon: LucideIcons.messageSquareOff,
            reportType: 'Inappropriate Description',
            propertyName: 'Downtown Lofts',
            timeAgo: '3h ago',
            color: Colors.orange,
          ),
          const Gap(16),
          _RecentReportItem(
            icon: LucideIcons.userX,
            reportType: 'Unresponsive Owner',
            propertyName: 'Sunset Apartments',
            timeAgo: '8h ago',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _RecentReportItem extends StatelessWidget {
  final IconData icon;
  final String reportType;
  final String propertyName;
  final String timeAgo;
  final Color color;

  const _RecentReportItem({
    required this.icon,
    required this.reportType,
    required this.propertyName,
    required this.timeAgo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reportType,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ReportsScreen.textPrimary,
                ),
              ),
              const Gap(2),
              Text(
                propertyName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ReportsScreen.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          timeAgo,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: ReportsScreen.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Chart Data Model
class _ChartData {
  final String month;
  final double value;

  _ChartData(this.month, this.value);
}
