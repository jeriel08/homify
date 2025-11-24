import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/admin/data/models/admin_stats_model.dart';
import 'package:homify/features/admin/presentation/providers/admin_provider.dart';
import 'package:homify/features/admin/presentation/widgets/admin_kpi_card.dart';
import 'package:homify/features/home/presentation/providers/navigation_provider.dart';
import 'package:homify/features/admin/presentation/widgets/quick_action_card.dart';
import 'package:homify/features/admin/presentation/widgets/registration_trend_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
          padding: EdgeInsets.only(top: topPadding),
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
                          child: AdminKpiCard(
                            title: "Pending",
                            value: stats.pendingApprovals,
                            icon: LucideIcons.clock,
                            color: Colors.orange.shade700,
                            onTap: () {
                              // Switch to the "Approvals" tab (index 1)
                              ref.read(bottomNavIndexProvider.notifier).state =
                                  1;
                            },
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: AdminKpiCard(
                            title: "Properties",
                            value: stats.totalProperties,
                            icon: LucideIcons.house,
                            color: Colors.blue.shade700,
                            onTap: () => context.push('/admin/all-properties'),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: AdminKpiCard(
                            title: "Tenants",
                            value: stats.totalTenants,
                            icon: LucideIcons.users,
                            color: Colors.green.shade700,
                            onTap: () => context.push(
                              '/admin/all-users',
                              extra: 0, // 0 for Tenants tab
                            ),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: AdminKpiCard(
                            title: "Owners",
                            value: stats.totalOwners,
                            icon: LucideIcons.userCog,
                            color: Colors.purple.shade700,
                            onTap: () => context.push(
                              '/admin/all-users',
                              extra: 1, // 1 for Owners tab
                            ),
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
                    QuickActionCard(
                      label: "Review Properties",
                      icon: LucideIcons.circleCheckBig,
                      onTap: () {
                        ref.read(bottomNavIndexProvider.notifier).state = 1;
                      },
                    ),
                    QuickActionCard(
                      label: "Manage Users",
                      icon: LucideIcons.usersRound,
                      onTap: () => context.push('/admin/all-users'),
                    ),
                    QuickActionCard(
                      label: "Review Reports",
                      icon: LucideIcons.flag,
                      onTap: () => context.push('/admin/reports'),
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
                const RegistrationTrendCard(),

                const Gap(40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
