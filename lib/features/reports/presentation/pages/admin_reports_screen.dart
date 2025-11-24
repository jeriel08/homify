import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/admin/presentation/widgets/admin_search_bar.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/presentation/providers/report_provider.dart';
import 'package:intl/intl.dart';
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: AdminSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              hintText: 'Search reports...',
            ),
          ),
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                final filteredReports = reports.where((report) {
                  final title = report.title.toLowerCase();
                  final description = report.description.toLowerCase();
                  final type = report.type.name.toLowerCase();
                  return title.contains(_searchQuery) ||
                      description.contains(_searchQuery) ||
                      type.contains(_searchQuery);
                }).toList();

                if (filteredReports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.file,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const Gap(16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No reports found'
                              : 'No matching reports',
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
                    return _ReportCard(report: report);
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

class _ReportCard extends StatelessWidget {
  final ReportEntity report;

  const _ReportCard({required this.report});

  String _formatReportType(ReportType type) {
    switch (type) {
      case ReportType.bug:
        return 'BUG';
      case ReportType.inappropriateContent:
        return 'INAPPROPRIATE CONTENT';
      case ReportType.other:
        return 'OTHER';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.push('/admin/reports/${report.id}', extra: report);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and date
              Row(
                children: [
                  _StatusBadge(status: report.status),
                  const Spacer(),
                  Icon(
                    LucideIcons.clock,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const Gap(4),
                  Text(
                    DateFormat.yMMMd().format(report.createdAt),
                    style: HomifyTypography.label3.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // Title
              Text(
                report.title,
                style: HomifyTypography.heading6.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Gap(8),

              // Description
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: HomifyTypography.body2.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const Gap(16),

              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      report.type == ReportType.bug
                          ? LucideIcons.bug
                          : report.type == ReportType.inappropriateContent
                          ? LucideIcons.triangleAlert
                          : LucideIcons.circleQuestionMark,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const Gap(6),
                    Text(
                      _formatReportType(report.type),
                      style: HomifyTypography.label3.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReportStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case ReportStatus.pending:
        color = Colors.orange.shade700;
        label = 'Pending';
        icon = LucideIcons.clock;
        break;
      case ReportStatus.solved:
        color = Colors.green.shade700;
        label = 'Solved';
        icon = LucideIcons.circleCheck;
        break;
      case ReportStatus.fixed:
        color = Colors.blue.shade700;
        label = 'Fixed';
        icon = LucideIcons.wrench;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const Gap(6),
          Text(
            label.toUpperCase(),
            style: HomifyTypography.label3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
