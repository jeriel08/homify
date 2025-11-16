import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/home/data/models/admin_stats_model.dart';
import 'package:homify/features/home/presentation/providers/admin_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  // Define our theme colors
  static const Color textDark = Color(0xFF32190D);
  static const Color cardBg = Color(0xFFF9E5C5);
  static const Color accentColor = Color(0xFFE05725);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminStatsAsync = ref.watch(adminStatsProvider);
    final stats = adminStatsAsync.value ?? AdminStatsModel.dummy();

    return Skeletonizer(
      enabled: adminStatsAsync.isLoading,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- 1. KPI Grid ---
          // We use a GridView for a responsive card layout
          GridView.count(
            crossAxisCount: 2, // 2 cards per row
            shrinkWrap: true, // Let it fit inside the ListView
            physics:
                const NeverScrollableScrollPhysics(), // Let ListView handle scroll
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2, // Make cards slightly taller than wide
            children: [
              // This is our "Actionable" card
              _KpiCard(
                title: 'Total Pending',
                value: stats.pendingApprovals.toString(),
                icon: LucideIcons.circleCheckBig,
                iconColor: accentColor,
              ),
              _KpiCard(
                title: 'Total Properties',
                value: stats.totalProperties.toString(),
                icon: LucideIcons.building,
              ),
              _KpiCard(
                title: 'Total Tenants',
                value: stats.totalTenants.toString(),
                icon: LucideIcons.user,
              ),
              _KpiCard(
                title: 'Total Owners',
                value: stats.totalOwners.toString(),
                icon: LucideIcons.userStar,
              ),
            ],
          ),

          Divider(),

          // --- 2. Quick Actions Section ---
          const _SectionHeader(title: 'Quick Actions'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ActionCard(
                  title: 'Review Properties',
                  icon: Icon(LucideIcons.circleCheckBig),
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  title: 'Manage\nUsers',
                  icon: Icon(LucideIcons.users),
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  title: 'View Full Reports',
                  icon: Icon(LucideIcons.chartColumnBig),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // --- 3. Registration Chart ---
          const _SectionHeader(title: 'New User Registrations'),
          const _UserRegistrationChart(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// 2. The KPI Card Widget
// -------------------------------------------------------------------
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AdminDashboardScreen.cardBg,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              size: 28,
              color:
                  iconColor ??
                  AdminDashboardScreen.textDark.withValues(alpha: 0.8),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AdminDashboardScreen.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AdminDashboardScreen.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 3. The Quick Action Card Widget
// -------------------------------------------------------------------
// -------------------------------------------------------------------
// 3. The Quick Action Card Widget (as ElevatedButton)
// -------------------------------------------------------------------
class _ActionCard extends StatelessWidget {
  final String title;
  final Icon icon; // Changed from IconData to Icon
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // We still use SizedBox to give the button a finite width
    return SizedBox(
      width: 120, // You can adjust this
      height: 90, // We can set a height for consistency
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminDashboardScreen.cardBg,
          foregroundColor: AdminDashboardScreen.textDark,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12.0),
          // We align the child (the Column) to the top-left
          alignment: Alignment.topLeft,
        ),
        // The child is a Column, not a Row
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pass the icon widget directly
            icon,
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 4. The Registration Chart Widget
// (Stateful to handle chip selection)
// -------------------------------------------------------------------
class _UserRegistrationChart extends ConsumerWidget {
  const _UserRegistrationChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- 7. ---
    // Read the filter state from its provider
    final selectedFilter = ref.watch(adminGraphFilterProvider);
    final filters = ['This Week', 'Last Week', 'Last Month'];

    // --- 8. ---
    // Watch the graph data provider
    final chartDataAsync = ref.watch(adminGraphDataProvider);

    return Card(
      color: AdminDashboardScreen.cardBg,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            // --- Filter Chips ---
            Wrap(
              spacing: 8.0,
              children: filters.map((filter) {
                return FilterChip(
                  label: Text(filter),
                  selected: selectedFilter == filter,
                  onSelected: (bool selected) {
                    if (selected) {
                      // --- 9. ---
                      // Update the filter provider on tap
                      ref.read(adminGraphFilterProvider.notifier).state =
                          filter;
                    }
                  },
                  backgroundColor: Colors.black.withValues(alpha: 0.05),
                  selectedColor: AdminDashboardScreen.textDark,
                  labelStyle: TextStyle(
                    color: selectedFilter == filter
                        ? Colors.white
                        : AdminDashboardScreen.textDark.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // --- Syncfusion Chart ---
            SizedBox(
              height: 200,
              // --- 10. ---
              // Use .when() to handle loading/error states for the chart
              child: chartDataAsync.when(
                data: (chartData) {
                  // This is the same chart as before
                  return SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      labelStyle: const TextStyle(
                        color: AdminDashboardScreen.textDark,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      labelStyle: const TextStyle(
                        color: AdminDashboardScreen.textDark,
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<ChartData, String>>[
                      LineSeries<ChartData, String>(
                        // --- 11. ---
                        // Use the real data from the provider
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.day,
                        yValueMapper: (ChartData data, _) => data.users,
                        color: AdminDashboardScreen.accentColor,
                        width: 3,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          color: AdminDashboardScreen.accentColor,
                          borderColor: AdminDashboardScreen.cardBg,
                          borderWidth: 2,
                        ),
                      ),
                    ],
                  );
                },
                // Show a mini-skeleton for the chart area
                loading: () => const Skeletonizer(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    // Use a 'Bone' to represent the chart area
                    child: Bone.square(),
                  ),
                ),
                error: (err, stack) =>
                    Center(child: Text('Error: ${err.toString()}')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 5. Data Models & Helper Widgets
// -------------------------------------------------------------------\

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AdminDashboardScreen.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
