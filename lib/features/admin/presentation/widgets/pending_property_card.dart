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

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - Responsive
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.user, size: 20, color: primary),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Owner ID',
                          style: HomifyTypography.medium(
                            HomifyTypography.label3.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ),
                        const Gap(2),
                        Text(
                          property.ownerUid,
                          style: HomifyTypography.semibold(
                            HomifyTypography.label2.copyWith(
                              color: textPrimary,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.clock, size: 12, color: primary),
                        const Gap(4),
                        Text(
                          'Pending',
                          style: HomifyTypography.bold(
                            HomifyTypography.label3.copyWith(color: primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Gap(12),

              // Submission time
              Row(
                children: [
                  Icon(LucideIcons.calendar, size: 14, color: textSecondary),
                  const Gap(6),
                  Text(
                    'Submitted ${_timeAgo(property.createdAt)}',
                    style: HomifyTypography.medium(
                      HomifyTypography.label3.copyWith(color: textSecondary),
                    ),
                  ),
                ],
              ),

              const Gap(16),

              // Image - Fixed aspect ratio
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: property.imageUrls.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              property.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: surface.withValues(alpha: 0.3),
                                child: Center(
                                  child: Icon(
                                    LucideIcons.house,
                                    size: 48,
                                    color: textSecondary.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ),
                            // Image count badge
                            if (property.imageUrls.length > 1)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        LucideIcons.images,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const Gap(4),
                                      Text(
                                        '${property.imageUrls.length}',
                                        style: HomifyTypography.semibold(
                                          HomifyTypography.label3.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          color: surface.withValues(alpha: 0.3),
                          child: Center(
                            child: Icon(
                              LucideIcons.house,
                              size: 60,
                              color: textSecondary.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                ),
              ),

              const Gap(16),

              // Property name
              Text(
                property.name,
                style: HomifyTypography.bold(
                  HomifyTypography.title3.copyWith(color: textPrimary),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Gap(8),

              // Location
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.mapPin, size: 14, color: primary),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      '${property.latitude.toStringAsFixed(4)}, ${property.longitude.toStringAsFixed(4)}',
                      style: HomifyTypography.medium(
                        HomifyTypography.body3.copyWith(color: textSecondary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Gap(16),

              // Divider
              Container(height: 1, color: surface.withValues(alpha: 0.5)),

              const Gap(16),

              // Bottom section - Price & Actions
              Row(
                children: [
                  // Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rent Price',
                          style: HomifyTypography.medium(
                            HomifyTypography.label3.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ),
                        const Gap(4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: textPrimary),
                              children: [
                                TextSpan(
                                  text: '₱${property.rentAmount.toInt()}',
                                  style: HomifyTypography.bold(
                                    HomifyTypography.title3.copyWith(
                                      color: primary,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' / ${property.rentChargeMethod == RentChargeMethod.perUnit ? 'unit' : 'bed'}',
                                  style: HomifyTypography.medium(
                                    HomifyTypography.body3.copyWith(
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(12),

                  // Property type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _formatType(property.type),
                      style: HomifyTypography.semibold(
                        HomifyTypography.label2.copyWith(color: textPrimary),
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(16),

              // View details button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(LucideIcons.eye, size: 18),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: HomifyTypography.bold(HomifyTypography.label1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  String _formatType(PropertyType type) {
    return type.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}
