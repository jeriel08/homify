import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/providers/owner_dashboard_provider.dart';
import 'package:homify/features/properties/presentation/widgets/owner/property_info_section.dart';
import 'package:homify/features/properties/presentation/pages/edit_pages/edit_property_information.dart';
import 'package:homify/features/properties/presentation/pages/edit_pages/edit_property_images.dart';
import 'package:homify/features/properties/presentation/pages/edit_pages/edit_property_type.dart';
import 'package:homify/features/properties/presentation/pages/edit_pages/edit_rent_details.dart';
import 'package:homify/features/properties/presentation/pages/edit_pages/edit_amenities.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditPropertyPage extends ConsumerWidget {
  final PropertyEntity property;

  const EditPropertyPage({super.key, required this.property});

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color background = Color(0xFFFFF8F0);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get real-time updates
    final dashboardState = ref.watch(ownerDashboardProvider);

    // Find the updated property in the list, or fallback to the passed property
    PropertyEntity currentProperty;
    try {
      currentProperty = dashboardState.properties.firstWhere(
        (p) => p.id == property.id,
      );
    } catch (_) {
      currentProperty = property;
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Edit Property',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Property Information Section
            PropertyInfoSection(
              title: 'Property Information',
              onEditTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditPropertyInformation(property: currentProperty),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    'Property Name',
                    currentProperty.name,
                    LucideIcons.house,
                  ),
                  const Gap(12),
                  Divider(color: textPrimary.withValues(alpha: 0.1), height: 1),
                  const Gap(12),
                  _buildInfoRow(
                    context,
                    'Description',
                    currentProperty.description.isEmpty
                        ? 'No description'
                        : currentProperty.description,
                    LucideIcons.fileText,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const Gap(20),

            // Images Section
            PropertyInfoSection(
              title: 'Images',
              onEditTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditPropertyImages(property: currentProperty),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.images, size: 20, color: textSecondary),
                      const Gap(12),
                      Text(
                        '${currentProperty.imageUrls.length} image${currentProperty.imageUrls.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (currentProperty.imageUrls.isNotEmpty) ...[
                    const Gap(12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: currentProperty.imageUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: surface.withValues(alpha: 0.3),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: surface.withValues(alpha: 0.3),
                            child: Center(
                              child: Icon(
                                LucideIcons.imageOff,
                                size: 48,
                                color: textSecondary.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Gap(20),

            // Property Type Section
            PropertyInfoSection(
              title: 'Property Type',
              onEditTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditPropertyType(property: currentProperty),
                  ),
                );
              },
              child: _buildInfoRow(
                context,
                'Type',
                _formatType(currentProperty.type),
                LucideIcons.building,
              ),
            ),

            const Gap(20),

            // Rent Details Section
            PropertyInfoSection(
              title: 'Rent Details',
              onEditTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditRentDetails(property: currentProperty),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    'Rent Amount',
                    '₱${currentProperty.rentAmount.toInt().toString()}',
                    LucideIcons.philippinePeso,
                  ),
                  const Gap(12),
                  Divider(color: textPrimary.withValues(alpha: 0.1), height: 1),
                  const Gap(12),
                  _buildInfoRow(
                    context,
                    'Charge Method',
                    currentProperty.rentChargeMethod == RentChargeMethod.perUnit
                        ? 'Per Unit'
                        : 'Per Bed',
                    LucideIcons.calculator,
                  ),
                ],
              ),
            ),

            const Gap(20),

            // Amenities Section
            PropertyInfoSection(
              title: 'Amenities',
              onEditTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditAmenities(property: currentProperty),
                  ),
                );
              },
              child: currentProperty.amenities.isEmpty
                  ? Row(
                      children: [
                        Icon(
                          LucideIcons.sparkles,
                          size: 20,
                          color: textSecondary,
                        ),
                        const Gap(12),
                        Text(
                          'No amenities listed',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: textSecondary),
                        ),
                      ],
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentProperty.amenities
                          .map(
                            (amenity) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: surface.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primary.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.check,
                                    size: 14,
                                    color: primary,
                                  ),
                                  const Gap(6),
                                  Text(
                                    amenity,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),

            const Gap(40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: textSecondary),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(4),
              Text(
                value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatType(PropertyType type) {
    return type.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}
