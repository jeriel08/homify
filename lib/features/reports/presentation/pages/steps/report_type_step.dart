import 'package:flutter/material.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportTypeStep extends StatelessWidget {
  final ReportType? selectedType;
  final ValueChanged<ReportType> onTypeSelected;

  const ReportTypeStep({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  String _formatType(ReportType type) {
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

  IconData _getIcon(ReportType type) {
    switch (type) {
      case ReportType.bug:
        return LucideIcons.bug;
      case ReportType.fakeProperty:
        return LucideIcons.circleAlert;
      case ReportType.inappropriateDescription:
        return LucideIcons.messageSquareOff;
      case ReportType.unresponsiveOwner:
        return LucideIcons.userX;
      case ReportType.inappropriateImage:
        return LucideIcons.imageOff;
      case ReportType.inappropriateContent:
        return LucideIcons.triangleAlert;
      case ReportType.other:
        return LucideIcons.circleQuestionMark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What type of issue are you reporting?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ...ReportType.values.map((type) {
            final isSelected = selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onTypeSelected(type),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.05)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIcon(type),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _formatType(type),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          LucideIcons.check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
