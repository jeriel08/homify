import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RecentReportsList extends StatelessWidget {
  final List<ReportEntity> recentReports;

  const RecentReportsList({super.key, required this.recentReports});

  // Brand colors
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  IconData _getIconForType(ReportType type) {
    switch (type) {
      case ReportType.fakeProperty:
        return LucideIcons.circleAlert;
      case ReportType.inappropriateDescription:
        return LucideIcons.messageSquareOff;
      case ReportType.unresponsiveOwner:
        return LucideIcons.userX;
      case ReportType.inappropriateImage:
        return LucideIcons.imageOff;
      case ReportType.bug:
        return LucideIcons.bug;
      case ReportType.inappropriateContent:
        return LucideIcons.triangleAlert;
      case ReportType.other:
        return LucideIcons.circleQuestionMark;
    }
  }

  Color _getColorForType(ReportType type) {
    switch (type) {
      case ReportType.fakeProperty:
        return Colors.red;
      case ReportType.inappropriateDescription:
      case ReportType.inappropriateContent:
      case ReportType.inappropriateImage:
        return Colors.orange;
      case ReportType.unresponsiveOwner:
        return Colors.blue;
      case ReportType.bug:
        return Colors.purple;
      case ReportType.other:
        return Colors.grey;
    }
  }

  String _formatType(ReportType type) {
    switch (type) {
      case ReportType.fakeProperty:
        return 'Fake Property';
      case ReportType.inappropriateDescription:
        return 'Inappropriate Description';
      case ReportType.unresponsiveOwner:
        return 'Unresponsive Owner';
      case ReportType.inappropriateImage:
        return 'Inappropriate Image';
      case ReportType.bug:
        return 'Bug';
      case ReportType.inappropriateContent:
        return 'Inappropriate Content';
      case ReportType.other:
        return 'Other';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recentReports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: Text('No recent reports')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: recentReports.asMap().entries.map((entry) {
          final index = entry.key;
          final report = entry.value;
          final isLast = index == recentReports.length - 1;

          return Column(
            children: [
              _RecentReportItem(
                icon: _getIconForType(report.type),
                reportType: _formatType(report.type),
                title: report.title,
                timeAgo: _formatTimeAgo(report.createdAt),
                color: _getColorForType(report.type),
              ),
              if (!isLast) const Gap(16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _RecentReportItem extends StatelessWidget {
  final IconData icon;
  final String reportType;
  final String title;
  final String timeAgo;
  final Color color;

  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  const _RecentReportItem({
    required this.icon,
    required this.reportType,
    required this.title,
    required this.timeAgo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reportType,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const Gap(2),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          timeAgo,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}
