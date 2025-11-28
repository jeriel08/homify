import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/admin/presentation/widgets/admin_search_bar.dart';
import 'package:homify/features/reports/presentation/providers/report_provider.dart';
import 'package:homify/features/reports/presentation/widgets/report_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEDD4),
        foregroundColor: const Color(0xFF32190D),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        title: Text(
          'Reports',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          const Gap(16),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AdminSearchBar(
              controller: _searchController,
              hintText: 'Search reports...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const Gap(16),

          // Reports List
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                final filteredReports = reports.where((report) {
                  return report.title.toLowerCase().contains(_searchQuery) ||
                      report.description.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredReports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? LucideIcons.inbox
                              : LucideIcons.searchX,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const Gap(16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No reports yet'
                              : 'No reports found',
                          style: HomifyTypography.heading6.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const Gap(8),
                          Text(
                            'Try a different search term',
                            style: HomifyTypography.body3.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredReports.length,
                  separatorBuilder: (context, index) => const Gap(12),
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    return ReportCard(report: report);
                  },
                );
              },
              loading: () => Skeletonizer(
                enabled: true,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: 5,
                  separatorBuilder: (context, index) => const Gap(12),
                  itemBuilder: (context, index) =>
                      const Card(child: SizedBox(height: 140)),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.triangleAlert,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const Gap(16),
                    Text(
                      'Error loading reports',
                      style: HomifyTypography.heading6.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      error.toString(),
                      style: HomifyTypography.body3.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
