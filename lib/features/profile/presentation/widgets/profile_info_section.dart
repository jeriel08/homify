import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final List<InfoRow> rows;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.rows,
  });

  // Brand colors
  static const Color primary = Color(0xFF32190D);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const Gap(16),
          ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final isLast = index == rows.length - 1;

            return Column(
              children: [
                _InfoRowWidget(row: row),
                if (!isLast) ...[
                  const Gap(12),
                  Divider(color: primary.withValues(alpha: 0.1), height: 1),
                  const Gap(12),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class InfoRow {
  final String label;
  final String value;
  final IconData? icon;

  const InfoRow({required this.label, required this.value, this.icon});
}

class _InfoRowWidget extends StatelessWidget {
  final InfoRow row;

  const _InfoRowWidget({required this.row});

  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (row.icon != null) ...[
          Icon(row.icon, size: 20, color: textSecondary),
          const Gap(12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(4),
              Text(
                row.value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
