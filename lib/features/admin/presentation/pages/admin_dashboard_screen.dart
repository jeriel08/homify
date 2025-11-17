import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/admin/data/models/admin_stats_model.dart';
import 'package:homify/features/admin/presentation/providers/admin_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  // Your brand colors (keep consistent with design system)
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color background = Color(0xFFFFFAF5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminStatsAsync = ref.watch(adminStatsProvider);
    final stats = adminStatsAsync.value ?? AdminStatsModel.dummy();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: background,
      body: Skeletonizer(
        enabled: adminStatsAsync.isLoading,
        containersColor: surface,
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: topPadding),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Header
                Text(
                  'Admin Dashboard',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                Text(
                  'Welcome back! Here’s what’s happening today.',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
                const Gap(20),

                // KPI Grid - Overflow Safe
                // KPI Grid - Responsive Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _KpiCard(
                            title: "Pending",
                            value: stats.pendingApprovals,
                            icon: LucideIcons.clock,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _KpiCard(
                            title: "Properties",
                            value: stats.totalProperties,
                            icon: LucideIcons.house,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _KpiCard(
                            title: "Tenants",
                            value: stats.totalTenants,
                            icon: LucideIcons.users,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _KpiCard(
                            title: "Owners",
                            value: stats.totalOwners,
                            icon: LucideIcons.userCog,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const Gap(48),
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const Gap(16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickActionCard(
                      label: "Review Properties",
                      icon: LucideIcons.circleCheckBig,
                      onTap: () {},
                    ),
                    _QuickActionCard(
                      label: "Manage Users",
                      icon: LucideIcons.usersRound,
                      onTap: () {},
                    ),
                    _QuickActionCard(
                      label: "View Reports",
                      icon: LucideIcons.chartColumnIncreasing,
                      onTap: () {},
                    ),
                  ],
                ),

                const Gap(48),

                // Chart Section
                Text(
                  'New User Registrations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const Gap(16),
                const _RegistrationTrendCard(),

                const Gap(40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// KPI Card - Fully Overflow-Safe
class _KpiCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: color),
          ),

          const Gap(12),

          // Title - Always visible
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const Gap(4),

          // Value - Large, bold, no overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value.toString(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Action Card - Responsive & Clean
class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 125,
      child: Card(
        elevation: 0,
        color: AdminDashboardScreen.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: AdminDashboardScreen.primary),
                const Gap(10),
                Text(
                  label,
                  style: HomifyTypography.label2.copyWith(
                    color: AdminDashboardScreen.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Registration Trend Chart Card
// Registration Trend Chart Card
class _RegistrationTrendCard extends ConsumerWidget {
  const _RegistrationTrendCard();

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
                error: (_, __) => Center(
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
