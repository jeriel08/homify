import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/properties_providers.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A modal sheet for selecting a property to share in chat.
class PropertyPickerSheet extends ConsumerWidget {
  final Function(PropertyEntity) onPropertySelected;

  const PropertyPickerSheet({super.key, required this.onPropertySelected});

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  /// Show the property picker sheet
  static Future<void> show(
    BuildContext context, {
    required Function(PropertyEntity) onPropertySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          PropertyPickerSheet(onPropertySelected: onPropertySelected),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(verifiedPropertiesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(LucideIcons.house, color: primary, size: 24),
                  const Gap(12),
                  const Expanded(
                    child: Text(
                      'Share Property',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Property List
            Expanded(
              child: propertiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.circleAlert,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const Gap(12),
                      Text(
                        'Failed to load properties',
                        style: TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                ),
                data: (properties) {
                  if (properties.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.house,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const Gap(16),
                          Text(
                            'No properties available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            'There are no verified properties to share',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemCount: properties.length,
                    separatorBuilder: (_, _) => const Gap(12),
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return _PropertyTile(
                        property: property,
                        onTap: () {
                          Navigator.pop(context);
                          onPropertySelected(property);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact property tile for the picker list
class _PropertyTile extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback onTap;

  const _PropertyTile({required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.imageUrls.isNotEmpty
        ? property.imageUrls.first
        : null;
    final formatter = NumberFormat('#,###');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 72,
                          height: 72,
                          color: PropertyPickerSheet.surface,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 72,
                          height: 72,
                          color: PropertyPickerSheet.surface,
                          child: const Icon(
                            LucideIcons.house,
                            color: PropertyPickerSheet.primary,
                          ),
                        ),
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: PropertyPickerSheet.surface,
                        child: const Icon(
                          LucideIcons.house,
                          color: PropertyPickerSheet.primary,
                        ),
                      ),
              ),
              const Gap(12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: PropertyPickerSheet.textPrimary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '₱${formatter.format(property.rentAmount.toInt())} / month',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: PropertyPickerSheet.primary,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.tag,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const Gap(4),
                        Text(
                          property.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Share indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PropertyPickerSheet.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.send,
                  size: 18,
                  color: PropertyPickerSheet.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
