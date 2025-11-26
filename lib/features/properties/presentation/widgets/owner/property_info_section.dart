import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PropertyInfoSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showEditButton;
  final VoidCallback? onEditTap;

  const PropertyInfoSection({
    super.key,
    required this.title,
    required this.child,
    this.showEditButton = true,
    this.onEditTap,
  });

  // Brand colors
  static const Color primary = Color(0xFFE05725);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              if (showEditButton)
                IconButton(
                  icon: const Icon(LucideIcons.pencil, size: 18),
                  color: primary,
                  onPressed: onEditTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const Gap(16),
          child,
        ],
      ),
    );
  }
}
