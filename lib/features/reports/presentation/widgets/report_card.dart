import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/presentation/widgets/report_status_badge.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportCard extends StatelessWidget {
  final ReportEntity report;

  const ReportCard({super.key, required this.report});

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
                  ReportStatusBadge(status: report.status),
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
