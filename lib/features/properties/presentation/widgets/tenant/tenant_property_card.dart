import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:homify/features/properties/presentation/widgets/property_address_widget.dart';

class TenantPropertyCard extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const TenantPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onFavorite,
    this.isFavorite = false,
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
      // Shadow must be in the outer container
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Material widget is needed for InkWell ripple + Background Color
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias, // Clips the ripple to the rounded corners
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Image Section
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: property.imageUrls.isNotEmpty
                            ? CachedNetworkImage(
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
                                  child: const Icon(
                                    LucideIcons.house,
                                    size: 48,
                                    color: textSecondary,
                                  ),
                                ),
                              )
                            : Container(color: surface.withValues(alpha: 0.3)),
                      ),
                    ),
                    // Badge (Verified)
                    if (property.isVerified)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.badgeCheck,
                                size: 12,
                                color: Colors.white,
                              ),
                              const Gap(4),
                              const Text(
                                'VERIFIED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const Gap(16),

                // 2. Title & Location
                Text(
                  property.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 14,
                      color: primary.withValues(alpha: 0.7),
                    ),
                    const Gap(4),
                    Expanded(
                      child: PropertyAddressWidget(
                        latitude: property.latitude,
                        longitude: property.longitude,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),

                const Gap(16),
                Container(height: 1, color: surface.withValues(alpha: 0.5)),
                const Gap(16),

                // 3. Price & Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price Info (Expanded pushes other widgets to the right)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rent per month',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.philippinePeso,
                                size: 16,
                                color: textPrimary,
                              ),
                              // Flexible prevents text from pushing button off-screen
                              Flexible(
                                child: Text(
                                  property.rentAmount.toInt().toString(),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ' / ${property.rentChargeMethod.name == 'perUnit' ? 'unit' : 'bed'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Heart Button
                    Material(
                      color: isFavorite
                          ? Colors.red.withValues(alpha: 0.1)
                          : surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: onFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            LucideIcons.heart,
                            size: 24,
                            color: isFavorite ? Colors.red : textSecondary,
                            fill: isFavorite ? 1.0 : 0.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
