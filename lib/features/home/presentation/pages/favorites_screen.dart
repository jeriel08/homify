import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/home/presentation/providers/favorites_provider.dart';
import 'package:homify/features/admin/presentation/widgets/property_details_sheet.dart';
import 'package:homify/features/properties/data/models/property_model.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);
  static const Color background = Color(0xFFFFFAF5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);
    final favorites = favoritesState.values;

    if (favorites.isEmpty) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          title: const Text(
            'Favorites',
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.heart,
                size: 64,
                color: textSecondary.withValues(alpha: 0.3),
              ),
              const Gap(16),
              Text(
                'No Favorites Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(8),
              Text(
                'Start adding properties to your favorites',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: Text(
          'Favorites (${favorites.length})',
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final property = favorites[index];
          return _FavoritePropertyCard(
            property: property,
            onViewDetails: () {
              // Convert PropertyEntity back to PropertyModel for the details sheet
              final propertyModel = PropertyModel(
                id: property.id,
                ownerUid: property.ownerUid,
                name: property.name,
                description: property.description,
                type: property.type,
                rentChargeMethod: property.rentChargeMethod,
                rentAmount: property.rentAmount,
                amenities: property.amenities,
                latitude: property.latitude,
                longitude: property.longitude,
                imageUrls: property.imageUrls,
                createdAt: property.createdAt,
                isVerified: property.isVerified,
                favoritesCount: property.favoritesCount,
              );

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => PropertyDetailsSheet(
                  property: propertyModel,
                  showApprovalButtons: false,
                ),
              );
            },
            onRemove: () {
              ref.read(favoritesProvider.notifier).remove(property.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${property.name} removed from favorites'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoritePropertyCard extends StatelessWidget {
  final dynamic property; // PropertyEntity
  final VoidCallback onViewDetails;
  final VoidCallback onRemove;

  const _FavoritePropertyCard({
    required this.property,
    required this.onViewDetails,
    required this.onRemove,
  });

  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.imageUrls.isNotEmpty ? property.imageUrls.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with remove button overlay
            Stack(
              children: [
                // Property Image
                if (imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: surface.withValues(alpha: 0.3),
                      child: const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: surface.withValues(alpha: 0.3),
                      child: const Center(
                        child: Icon(
                          LucideIcons.imageOff,
                          size: 40,
                          color: primary,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: surface.withValues(alpha: 0.3),
                    child: const Center(
                      child: Icon(
                        LucideIcons.building,
                        size: 40,
                        color: primary,
                      ),
                    ),
                  ),

                // Remove button overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.heart,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Property Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    property.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Gap(8),

                  // Price
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.philippinePeso,
                        size: 16,
                        color: primary,
                      ),
                      const Gap(4),
                      Text(
                        property.rentAmount.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const Gap(4),
                      Text(
                        '/ ${property.rentChargeMethod == RentChargeMethod.perUnit ? 'unit' : 'bed'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textSecondary,
                            ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  // Location
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 14,
                        color: textSecondary,
                      ),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          '${property.latitude.toStringAsFixed(2)}, ${property.longitude.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: textSecondary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  // Description preview
                  if (property.description.isNotEmpty)
                    Text(
                      property.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  if (property.description.isNotEmpty) const Gap(12),

                  // Amenities preview
                  if (property.amenities.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: property.amenities.take(3).map<Widget>((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            amenity,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        );
                      }).toList(),
                    ),

                  if (property.amenities.length > 3) ...[
                    const Gap(6),
                    Text(
                      '+${property.amenities.length - 3} more',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],

                  const Gap(16),

                  // View Details Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(LucideIcons.eye, size: 18),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
