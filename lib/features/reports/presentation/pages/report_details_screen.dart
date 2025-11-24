import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/admin/presentation/widgets/property_details_sheet.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/properties_providers.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/domain/usecases/update_report_status.dart'
    as usecase;
import 'package:homify/features/reports/presentation/providers/report_provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  PropertyEntity? _targetProperty;
  bool _isLoadingProperty = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.report.status;
    if (widget.report.targetType == 'property' &&
        widget.report.targetId != null) {
      _fetchTargetProperty();
    }
  }

  Future<void> _fetchTargetProperty() async {
    setState(() {
      _isLoadingProperty = true;
    });

    final getProperty = ref.read(getPropertyByIdUseCaseProvider);
    final result = await getProperty(widget.report.targetId!);

    if (mounted) {
      setState(() {
        _isLoadingProperty = false;
        result.fold((l) => null, (r) => _targetProperty = r);
      });
    }
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
              backgroundColor: AppColors.error,
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
            SnackBar(
              content: const Text('Status updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          ref.invalidate(reportsProvider);
        }
      },
    );
  }

  void _showPropertyDetails() {
    if (_targetProperty == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PropertyDetailsSheet(property: _targetProperty!, showActions: false),
    );
  }

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Report Details',
          style: HomifyTypography.heading6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Date Row
            Row(
              children: [
                _StatusBadge(status: _currentStatus),
                const Spacer(),
                Icon(LucideIcons.clock, size: 16, color: Colors.grey.shade500),
                const Gap(6),
                Text(
                  DateFormat.yMMMd().add_jm().format(widget.report.createdAt),
                  style: HomifyTypography.label3.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Title Section
            Text(
              widget.report.title,
              style: HomifyTypography.heading4.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(16),

            // Type Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.report.type == ReportType.bug
                            ? LucideIcons.bug
                            : widget.report.type ==
                                  ReportType.inappropriateContent
                            ? LucideIcons.triangleAlert
                            : LucideIcons.circleQuestionMark,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const Gap(8),
                      Text(
                        _formatReportType(widget.report.type),
                        style: HomifyTypography.label2.copyWith(
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
            const Gap(28),

            // Description Section
            _SectionCard(
              title: 'Description',
              child: Text(
                widget.report.description,
                style: HomifyTypography.body2.copyWith(
                  height: 1.6,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Gap(20),

            // Target Section
            _SectionCard(
              title: 'Target',
              child: Skeletonizer(
                enabled: _isLoadingProperty,
                child: InkWell(
                  onTap:
                      widget.report.targetType == 'property' &&
                          _targetProperty != null
                      ? _showPropertyDetails
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.report.targetType == 'property'
                                ? LucideIcons.house
                                : LucideIcons.user,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.report.targetType == 'property'
                                    ? 'Property'
                                    : 'User',
                                style: HomifyTypography.label2.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                _targetProperty?.name ??
                                    widget.report.targetId ??
                                    'N/A',
                                style: HomifyTypography.label1.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (widget.report.targetType == 'property' &&
                            _targetProperty != null)
                          Icon(
                            LucideIcons.chevronRight,
                            size: 20,
                            color: AppColors.accent,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(32),

            // Actions Section
            Text(
              'Actions',
              style: HomifyTypography.heading6.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isUpdating || _currentStatus == ReportStatus.solved
                        ? null
                        : () => _updateStatus(ReportStatus.solved),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: _currentStatus == ReportStatus.solved
                            ? Colors.grey.shade300
                            : AppColors.success,
                        width: 2,
                      ),
                      foregroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(LucideIcons.check, size: 20),
                    label: const Text(
                      'Solved',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        _isUpdating || _currentStatus == ReportStatus.fixed
                        ? null
                        : () => _updateStatus(ReportStatus.fixed),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(LucideIcons.wrench, size: 20),
                    label: const Text(
                      'Fixed',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: HomifyTypography.heading6.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
          child: child,
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const Gap(6),
          Text(
            label.toUpperCase(),
            style: HomifyTypography.label2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
