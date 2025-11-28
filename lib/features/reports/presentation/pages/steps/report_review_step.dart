import 'package:flutter/material.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';

class ReportReviewStep extends StatelessWidget {
  final ReportType? selectedType;
  final String title;
  final String description;

  const ReportReviewStep({
    super.key,
    required this.selectedType,
    required this.title,
    required this.description,
  });

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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review your report',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          _buildReviewItem(
            'Type',
            selectedType != null ? _formatReportType(selectedType!) : '',
          ),
          const SizedBox(height: 16),
          _buildReviewItem('Title', title),
          const SizedBox(height: 16),
          _buildReviewItem('Description', description),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
