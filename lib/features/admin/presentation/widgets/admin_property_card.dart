import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/admin/domain/entities/property_with_user.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/properties/presentation/widgets/property_address_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminPropertyCard extends StatelessWidget {
  final PropertyWithUser propertyWithUser;
  final VoidCallback onTap;

  const AdminPropertyCard({
    super.key,
    required this.propertyWithUser,
    required this.onTap,
  });

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context) {
    final property = propertyWithUser.property;
    final user = propertyWithUser.user;
    final isApproved =
        property.isVerified; // Assuming isVerified means approved

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
              // Header - Owner & Status
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
                          'Owner',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: textSecondary),
                        ),
                        const Gap(2),
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  _buildStatusBadge(context, isApproved),
                ],
              ),

              const Gap(12),

              // Submission time (if available, or just created at)
              Row(
                children: [
                  Icon(LucideIcons.calendar, size: 14, color: textSecondary),
                  const Gap(6),
                  Text(
                    'Added ${_timeAgo(property.createdAt)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Gap(16),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: property.imageUrls.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: property.imageUrls.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: surface.withValues(alpha: 0.3),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
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
                    child: PropertyAddressWidget(
                      latitude: property.latitude,
                      longitude: property.longitude,
                      style: HomifyTypography.medium(
                        HomifyTypography.body3.copyWith(color: textSecondary),
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(16),
              Container(height: 1, color: surface.withValues(alpha: 0.5)),
              const Gap(16),

              // Bottom section
              Row(
                children: [
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.philippinePeso,
                                size: 16,
                                color: textPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                property.rentAmount.toInt().toString(),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                              ),
                              Text(
                                ' / ${property.rentChargeMethod == RentChargeMethod.perUnit ? 'unit' : 'bed'}',
                                style: HomifyTypography.body3.copyWith(
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'View Details',
                          style: HomifyTypography.medium(
                            HomifyTypography.label3.copyWith(color: primary),
                          ),
                        ),
                        const Gap(4),
                        Icon(LucideIcons.arrowRight, size: 16, color: primary),
                      ],
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

  Widget _buildStatusBadge(BuildContext context, bool isApproved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isApproved
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApproved
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApproved ? LucideIcons.circleCheck : LucideIcons.clock,
            size: 12,
            color: isApproved ? Colors.green : Colors.orange,
          ),
          const Gap(4),
          Text(
            isApproved ? 'Approved' : 'Pending',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isApproved ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
