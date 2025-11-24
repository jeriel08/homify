import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/domain/usecases/update_report_status.dart'
    as usecase;
import 'package:homify/features/reports/presentation/providers/report_provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportDetailsScreen extends ConsumerStatefulWidget {
  final ReportEntity report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  ConsumerState<ReportDetailsScreen> createState() =>
      _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends ConsumerState<ReportDetailsScreen> {
  late ReportStatus _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.report.status;
  }

  Future<void> _updateStatus(ReportStatus newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    final updateStatus = ref.read(updateReportStatusUseCaseProvider);
    final result = await updateStatus(
      usecase.UpdateReportStatusParams(
        reportId: widget.report.id,
        status: newStatus,
      ),
    );

    setState(() {
      _isUpdating = false;
    });

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: ${failure.message}'),
            ),
          );
        }
      },
      (_) {
        if (mounted) {
          setState(() {
            _currentStatus = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully')),
          );
          ref.invalidate(reportsProvider);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Date
            Row(
              children: [
                _StatusBadge(status: _currentStatus),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().add_jm().format(widget.report.createdAt),
                  style: HomifyTypography.label3.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const Gap(20),

            // Title
            Text(widget.report.title, style: HomifyTypography.heading4),
            const Gap(12),

            // Type
            Row(
              children: [
                Icon(
                  widget.report.type == ReportType.bug
                      ? LucideIcons.bug
                      : widget.report.type == ReportType.inappropriateContent
                      ? LucideIcons.triangleAlert
                      : LucideIcons.circleQuestionMark,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const Gap(8),
                Text(
                  widget.report.type.name.toUpperCase(),
                  style: HomifyTypography.label2.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Description
            Text('Description', style: HomifyTypography.heading6),
            const Gap(8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.report.description,
                style: HomifyTypography.body2,
              ),
            ),
            const Gap(24),

            // Target Info
            Text('Target', style: HomifyTypography.heading6),
            const Gap(8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Icon(
                  widget.report.targetType == 'property'
                      ? LucideIcons.house
                      : LucideIcons.user,
                  color: Colors.grey.shade600,
                ),
              ),
              title: Text(
                widget.report.targetType == 'property' ? 'Property' : 'User',
                style: HomifyTypography.label2,
              ),
              subtitle: Text(
                widget.report.targetId ?? 'N/A',
                style: HomifyTypography.body3.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
              trailing: const Icon(LucideIcons.chevronRight, size: 16),
              onTap: () {
                // TODO: Navigate to target details
              },
            ),
            const Gap(32),

            // Actions
            Text('Actions', style: HomifyTypography.heading6),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isUpdating || _currentStatus == ReportStatus.solved
                        ? null
                        : () => _updateStatus(ReportStatus.solved),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Mark as Solved'),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: FilledButton(
                    onPressed:
                        _isUpdating || _currentStatus == ReportStatus.fixed
                        ? null
                        : () => _updateStatus(ReportStatus.fixed),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Mark as Fixed'),
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

class _StatusBadge extends StatelessWidget {
  final ReportStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case ReportStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case ReportStatus.solved:
        color = Colors.green;
        label = 'Solved';
        break;
      case ReportStatus.fixed:
        color = Colors.blue;
        label = 'Fixed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: HomifyTypography.label2.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
