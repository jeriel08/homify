import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportStatusBadge extends StatelessWidget {
  final ReportStatus status;

  const ReportStatusBadge({super.key, required this.status});

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
