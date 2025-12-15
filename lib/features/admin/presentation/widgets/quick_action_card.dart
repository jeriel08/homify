import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/admin/presentation/pages/admin_dashboard_screen.dart';

// Quick Action Card - Responsive & Clean
class QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AdminDashboardScreen.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: AdminDashboardScreen.primary),
              const Gap(10),
              Text(
                label,
                style: HomifyTypography.label2.copyWith(
                  color: AdminDashboardScreen.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
