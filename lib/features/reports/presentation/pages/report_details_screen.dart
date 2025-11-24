import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/admin/presentation/widgets/property_details_sheet.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/properties_providers.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/domain/usecases/update_report_status.dart'
    as usecase;
import 'package:homify/features/reports/presentation/providers/report_provider.dart';
import 'package:homify/features/reports/presentation/widgets/report_section_card.dart';
import 'package:homify/features/reports/presentation/widgets/report_status_badge.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';

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
  String? _reporterName;
  String? _resolverName;
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.report.status;
    _fetchUserNames();
    if (widget.report.targetType == 'property' &&
        widget.report.targetId != null) {
      _fetchTargetProperty();
    }
  }

  Future<void> _fetchUserNames() async {
    setState(() {
      _isLoadingUsers = true;
    });

    final authRepo = ref.read(authRepositoryProvider);

    try {
      // Fetch reporter name
      final reporter = await authRepo.getUser(widget.report.reporterId);
      if (mounted) {
        setState(() {
          _reporterName = '${reporter.firstName} ${reporter.lastName}';
        });
      }

      // Fetch resolver name if report is resolved
      if (widget.report.resolvedBy != null) {
        final resolver = await authRepo.getUser(widget.report.resolvedBy!);
        if (mounted) {
          setState(() {
            _resolverName = '${resolver.firstName} ${resolver.lastName}';
          });
        }
      }
    } catch (e) {
      // Handle errors silently, keep showing UIDs if fetch fails
      if (mounted) {
        setState(() {
          _reporterName = widget.report.reporterId;
          _resolverName = widget.report.resolvedBy;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
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

  bool get _isResolved =>
      _currentStatus == ReportStatus.solved ||
      _currentStatus == ReportStatus.fixed;

  Future<void> _updateStatus(ReportStatus newStatus) async {
    final authState = ref.read(authStateProvider);
    final currentUser = authState.value;

    if (currentUser == null) {
      if (mounted) {
        DelightToastBar(
          autoDismiss: true,
          position: DelightSnackbarPosition.top,
          builder: (context) => ToastCard(
            leading: Icon(
              LucideIcons.triangleAlert,
              size: 28,
              color: AppColors.error,
            ),
            title: Text(
              'User not authenticated',
              style: HomifyTypography.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            color: AppColors.error.withValues(alpha: 0.1),
          ),
        ).show(context);
      }
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    final updateStatus = ref.read(updateReportStatusUseCaseProvider);
    final result = await updateStatus(
      usecase.UpdateReportStatusParams(
        reportId: widget.report.id,
        status: newStatus,
        resolvedBy: currentUser.uid,
      ),
    );

    setState(() {
      _isUpdating = false;
    });

    result.fold(
      (failure) {
        if (mounted) {
          DelightToastBar(
            autoDismiss: true,
            snackbarDuration: const Duration(seconds: 3),
            position: DelightSnackbarPosition.top,
            builder: (context) => ToastCard(
              leading: Icon(
                LucideIcons.triangleAlert,
                size: 28,
                color: AppColors.error,
              ),
              title: Text(
                'Failed to update status: ${failure.message}',
                style: HomifyTypography.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              color: Colors.white,
            ),
          ).show(context);
        }
      },
      (_) {
        if (mounted) {
          setState(() {
            _currentStatus = newStatus;
          });
          DelightToastBar(
            autoDismiss: true,
            snackbarDuration: const Duration(seconds: 3),
            position: DelightSnackbarPosition.top,
            builder: (context) => ToastCard(
              leading: Icon(
                LucideIcons.circleCheck,
                size: 28,
                color: AppColors.success,
              ),
              title: Text(
                'Status updated successfully',
                style: HomifyTypography.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              color: Colors.white,
            ),
          ).show(context);
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
      case ReportType.fakeProperty:
        return 'FAKE PROPERTY';
      case ReportType.inappropriateDescription:
        return 'INAPPROPRIATE DESCRIPTION';
      case ReportType.unresponsiveOwner:
        return 'UNRESPONSIVE OWNER';
      case ReportType.inappropriateImage:
        return 'INAPPROPRIATE IMAGE';
      case ReportType.other:
        return 'OTHER';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEDD4),
        foregroundColor: const Color(0xFF32190D),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.2),
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
                ReportStatusBadge(status: _currentStatus),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        : widget.report.type == ReportType.inappropriateContent
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
            const Gap(28),

            // Description Section
            ReportSectionCard(
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
            ReportSectionCard(
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
            const Gap(20),

            // Reported By Section
            ReportSectionCard(
              title: 'Reported By',
              child: Skeletonizer(
                enabled: _isLoadingUsers,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.userRound,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      _reporterName ?? widget.report.reporterId,
                      style: HomifyTypography.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Resolved By Section (if resolved)
            if (widget.report.resolvedBy != null) ...[
              const Gap(20),
              ReportSectionCard(
                title: 'Resolved By',
                child: Skeletonizer(
                  enabled: _isLoadingUsers,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.userCheck,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              _resolverName ?? widget.report.resolvedBy!,
                              style: HomifyTypography.body2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.report.resolvedAt != null) ...[
                        const Gap(12),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const Gap(6),
                            Text(
                              DateFormat.yMMMd().add_jm().format(
                                widget.report.resolvedAt!,
                              ),
                              style: HomifyTypography.label3.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Actions Section (only show if not resolved)
            if (!_isResolved) ...[
              const Gap(32),
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
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus(ReportStatus.solved),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.success, width: 2),
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
                      onPressed: _isUpdating
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
          ],
        ),
      ),
    );
  }
}
