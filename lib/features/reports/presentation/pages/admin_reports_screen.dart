import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(title: const Text('Reports')),
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
                          LucideIcons.circleQuestionMark,
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
                      const Card(child: SizedBox(height: 100)),
                ),
              ),
              error: (error, stack) => Center(child: Text('Error: $error')),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          context.push('/admin/reports/${report.id}', extra: report);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: report.status),
                  const Spacer(),
                  Text(
                    DateFormat.yMMMd().format(report.createdAt),
                    style: HomifyTypography.label3.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Text(
                report.title,
                style: HomifyTypography.heading6.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(4),
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: HomifyTypography.body2.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const Gap(12),
              Row(
                children: [
                  Icon(
                    report.type == ReportType.bug
                        ? LucideIcons.bug
                        : report.type == ReportType.inappropriateContent
                        ? LucideIcons.triangleAlert
                        : LucideIcons.circleQuestionMark,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const Gap(6),
                  Text(
                    report.type.name.toUpperCase(),
                    style: HomifyTypography.label3.copyWith(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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

    switch (status) {
      case ReportStatus.pending:
        color = Colors.orange.shade700;
        label = 'Pending';
        break;
      case ReportStatus.solved:
        color = Colors.green.shade700;
        label = 'Solved';
        break;
      case ReportStatus.fixed:
        color = Colors.blue.shade700;
        label = 'Fixed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: HomifyTypography.label3.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
