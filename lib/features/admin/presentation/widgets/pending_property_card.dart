import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/entities/property_entity.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/properties/data/models/property_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PendingPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;

  const PendingPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      property.ownerUid[0].toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Owner ID: ${property.ownerUid}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Submitted ${_timeAgo(property.createdAt)}',
                          style: HomifyTypography.label3.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE05725).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Pending',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE05725),
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(16),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: property.imageUrls.isNotEmpty
                      ? Image.network(
                          property.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.home,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.home,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),

              const Gap(16),

              Text(
                property.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(6),
              Row(
                children: [
                  Icon(
                    LucideIcons.mapPin,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const Gap(4),
                  Expanded(
                    child: Text(
                      '${property.latitude.toStringAsFixed(4)}, ${property.longitude.toStringAsFixed(4)}',
                      style: HomifyTypography.body3.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(12),

              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF32190D)),
                      children: [
                        TextSpan(
                          text: '₱${property.rentAmount.toInt()}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text:
                              ' / ${property.rentChargeMethod == RentChargeMethod.perUnit ? 'unit' : 'bed'}',
                          style: HomifyTypography.body3,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatType(property.type),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Gap(12),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(LucideIcons.eye, size: 16),
                    label: const Text('View'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE05725),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _formatType(PropertyType type) {
    return type.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}
