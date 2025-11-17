import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/entities/property_entity.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/properties/data/models/property_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PropertyDetailsSheet extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PropertyDetailsSheet({
    super.key,
    required this.property,
    this.onApprove = _defaultApprove,
    this.onReject = _defaultReject,
  });

  static void _defaultApprove() {}
  static void _defaultReject() {}

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.7,
      maxChildSize: 0.98,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Gap(8),

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Image Carousel (simple PageView)
                  SizedBox(
                    height: 260,
                    child: property.imageUrls.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.home,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : PageView.builder(
                            itemCount: property.imageUrls.length,
                            itemBuilder: (_, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                property.imageUrls[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),

                  const Gap(24),

                  // Title + Price
                  Text(
                    property.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '₱${property.rentAmount.toInt()} / ${property.rentChargeMethod == RentChargeMethod.perUnit ? "unit" : "bed"}',
                    style: HomifyTypography.heading5.copyWith(
                      color: const Color(0xFFE05725),
                    ),
                  ),
                  const Gap(20),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const Gap(8),
                      Text(
                        '${property.latitude.toStringAsFixed(4)}, ${property.longitude.toStringAsFixed(4)}',
                        style: HomifyTypography.body2,
                      ),
                    ],
                  ),
                  const Gap(20),

                  const Divider(height: 32),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    property.description.isEmpty
                        ? 'No description provided.'
                        : property.description,
                    style: HomifyTypography.body2,
                  ),
                  const Gap(16),

                  // Amenities
                  if (property.amenities.isNotEmpty) ...[
                    Text(
                      'Amenities',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.amenities
                          .map(
                            (a) => Chip(
                              label: Text(a, style: HomifyTypography.label3),
                              backgroundColor: Colors.grey.shade100,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const Gap(32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            onReject();
                            Navigator.pop(context);
                          },
                          icon: const Icon(LucideIcons.x, size: 20),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            onApprove();
                            Navigator.pop(context);
                          },
                          icon: const Icon(LucideIcons.check, size: 20),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE05725),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
