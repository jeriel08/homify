import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TopCategoriesList extends StatelessWidget {
  final Map<ReportType, int> reportsByType;

  const TopCategoriesList({super.key, required this.reportsByType});

  // Brand colors
  static const Color primary = Color(0xFF32190D);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);

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

  @override
  Widget build(BuildContext context) {
    // Sort by count and take top categories
    final sortedTypes = reportsByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedTypes.isEmpty) {
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
        child: const Center(child: Text('No reports yet')),
      );
    }

    return Container(
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
        children: sortedTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final typeEntry = entry.value;
          final isLast = index == sortedTypes.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _getIconForType(typeEntry.key),
                          size: 20,
                          color: primary,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        _formatType(typeEntry.key),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${typeEntry.value} ${typeEntry.value == 1 ? 'report' : 'reports'}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 1,
                    color: surface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
