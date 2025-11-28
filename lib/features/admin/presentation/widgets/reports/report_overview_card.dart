import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/reports/domain/entities/report_stats.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportOverviewCard extends StatelessWidget {
  final ReportStats stats;

  const ReportOverviewCard({super.key, required this.stats});

  // Brand colors
  static const Color primary = Color(0xFF32190D);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context) {
    // Calculate "new this week" based on total vs previous period
    // For now, we'll show pending as that's actionable
    final newCount = stats.pendingReports;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.shieldAlert,
                  color: primary,
                  size: 24,
                ),
              ),
              const Gap(12),
              Text(
                'Report Overview',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            '${stats.totalReports}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const Gap(8),
          if (newCount > 0)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.arrowUp,
                        color: Colors.orange,
                        size: 14,
                      ),
                      const Gap(4),
                      Text(
                        '$newCount new',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Text(
                  'pending',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: textSecondary),
                ),
              ],
            ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: LucideIcons.clock,
                  label: 'Pending',
                  value: '${stats.pendingReports}',
                ),
              ),
              Container(width: 1, height: 40, color: surface),
              Expanded(
                child: _StatItem(
                  icon: LucideIcons.circleCheck,
                  label: 'Resolved',
                  value: '${stats.resolvedReports}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stat Item Widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: textSecondary),
        const Gap(6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
