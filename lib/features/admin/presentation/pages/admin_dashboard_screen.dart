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

    return Scaffold(
      backgroundColor: background,
      body: Skeletonizer(
        enabled: adminStatsAsync.isLoading,
        containersColor: surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
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
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  children: [
                    _KpiCard(
                      title: "Pending",
                      value: stats.pendingApprovals,
                      icon: LucideIcons.clock,
                      color: Colors.orange.shade700,
                    ),
                    _KpiCard(
                      title: "Properties",
                      value: stats.totalProperties,
                      icon: LucideIcons.house,
                      color: Colors.blue.shade700,
                    ),
                    _KpiCard(
                      title: "Tenants",
                      value: stats.totalTenants,
                      icon: LucideIcons.users,
                      color: Colors.green.shade700,
                    ),
                    _KpiCard(
                      title: "Owners",
                      value: stats.totalOwners,
                      icon: LucideIcons.userCog,
                      color: Colors.purple.shade700,
                    ),
                  ],
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
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

          const Gap(8),

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
class _RegistrationTrendCard extends ConsumerWidget {
  const _RegistrationTrendCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(adminGraphFilterProvider);
    final chartDataAsync = ref.watch(adminGraphDataProvider);
    final filters = ['This Week', 'Last Week', 'Last Month'];

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                  label: Text(f, style: HomifyTypography.label2),
                  selected: isSelected,
                  onSelected: (_) {
                    ref.read(adminGraphFilterProvider.notifier).state = f;
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: AdminDashboardScreen.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AdminDashboardScreen.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),

            const Gap(28),

            // Interactive Column Chart
            SizedBox(
              height: 300,
              child: chartDataAsync.when(
                data: (data) => SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: const EdgeInsets.only(right: 8),

                  // X-Axis: Days (Mon, Tue, etc.)
                  primaryXAxis: CategoryAxis(
                    labelStyle: HomifyTypography.label3.copyWith(
                      color: AdminDashboardScreen.textSecondary,
                    ),
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 1, color: Colors.grey),
                    labelIntersectAction: AxisLabelIntersectAction.rotate45,
                  ),

                  // Y-Axis: Number of Users
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    interval: data.isEmpty ? 10 : null,
                    labelStyle: HomifyTypography.label3.copyWith(
                      color: AdminDashboardScreen.textSecondary,
                    ),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Colors.grey.shade200,
                      dashArray: const [4, 4],
                    ),
                    axisLine: const AxisLine(width: 1, color: Colors.grey),
                    title: AxisTitle(
                      text: 'New Users',
                      textStyle: HomifyTypography.label2.copyWith(
                        color: AdminDashboardScreen.textSecondary,
                      ),
                    ),
                  ),

                  // Enable tooltip on tap/hover
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: AdminDashboardScreen.textPrimary,
                    textStyle: const TextStyle(color: Colors.white),
                    format: 'point.x: point.y users',
                  ),

                  series: <CartesianSeries<ChartData, String>>[
                    ColumnSeries<ChartData, String>(
                      dataSource: data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.users,
                      name: 'New Users',
                      color: AdminDashboardScreen.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),

                      // Show value on top of each bar
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top,
                        textStyle: HomifyTypography.label2.copyWith(
                          color: AdminDashboardScreen.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      // Interactive highlight
                      enableTooltip: true,
                      animationDuration: 800,
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, _) => Center(
                  child: Text(
                    'Failed to load chart data',
                    style: HomifyTypography.body3.copyWith(
                      color: Colors.red.shade600,
                    ),
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
