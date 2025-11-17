// lib/features/admin/presentation/screens/approvals_screen.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  // Mock data — replace with Riverpod later
  final List<PendingProperty> pendingProperties = [
    PendingProperty(
      id: '1',
      ownerName: 'Maria Santos',
      ownerPhoto: null,
      propertyTitle: 'Sunrise Apartment near UST',
      propertyType: 'Apartment',
      price: 8500,
      location: 'España, Manila',
      submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
      images: [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
      ],
      description:
          'Fully furnished 1-bedroom unit with balcony. Walking distance to UST and restaurants.',
    ),
    PendingProperty(
      id: '2',
      ownerName: 'John Reyes',
      ownerPhoto: null,
      propertyTitle: 'Cozy Bedspace in Katipunan',
      propertyType: 'Bedspace',
      price: 4500,
      location: 'Katipunan Ave, Quezon City',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      images: ['https://images.unsplash.com/photo-1522708323590-d24dbb6b03e7'],
      description: 'Female-only bedspace with study area and fast WiFi.',
    ),
    // Add more...
  ];

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  void _showPropertyDetails(PendingProperty property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PropertyDetailsSheet(property: property),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pendingProperties.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100), //…

        itemCount: pendingProperties.length,
        itemBuilder: (context, index) {
          final property = pendingProperties[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PendingPropertyCard(
              property: property,
              onViewDetails: () => _showPropertyDetails(property),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.circleCheck,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const Gap(16),
            Text(
              'All caught up!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'No pending approvals',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// CARD
// ===================================================================
class _PendingPropertyCard extends StatelessWidget {
  final PendingProperty property;
  final VoidCallback onViewDetails;

  const _PendingPropertyCard({
    required this.property,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onViewDetails, // Tap anywhere to open details
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owner + Status
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      property.ownerName[0],
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
                          property.ownerName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Submitted ${_formatTime(property.submittedAt)}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey.shade600),
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
                  child: Image.network(
                    property.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.home, size: 40),
                    ),
                  ),
                ),
              ),

              const Gap(16),

              // Title + Location
              Text(
                property.propertyTitle,
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
                      property.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Gap(12),

              // Price + Type + View Details
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF32190D)),
                      children: [
                        TextSpan(
                          text: '₱${property.price.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' / mo',
                          style: Theme.of(context).textTheme.bodySmall,
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
                      property.propertyType,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Gap(12),
                  TextButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(LucideIcons.eye, size: 16),
                    label: const Text('Details'),
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

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ===================================================================
// FULL SCREEN DETAILS SHEET
// ===================================================================
class PropertyDetailsSheet extends StatelessWidget {
  final PendingProperty property;

  const PropertyDetailsSheet({super.key, required this.property});

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

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Image Carousel (simple version)
                  SizedBox(
                    height: 240,
                    child: PageView.builder(
                      itemCount: property.images.length,
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          property.images[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const Gap(20),

                  // Title + Price
                  Text(
                    property.propertyTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '₱${property.price.toStringAsFixed(0)} / MONTH',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFE05725),
                    ),
                  ),
                  const Gap(16),

                  // Location
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, color: Colors.grey.shade600),
                      const Gap(8),
                      Text(
                        property.location,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),

                  const Gap(20),
                  const Divider(),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    property.description ?? 'No description provided.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const Gap(32),

                  // Action Buttons (Full Width)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Property rejected'),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.x),
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
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Property approved!'),
                                backgroundColor: Colors.green.shade600,
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE05725),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
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

// Model (same as before)
class PendingProperty {
  final String id;
  final String ownerName;
  final String? ownerPhoto;
  final String propertyTitle;
  final String propertyType;
  final double price;
  final String location;
  final DateTime submittedAt;
  final List<String> images;
  final String? description;

  PendingProperty({
    required this.id,
    required this.ownerName,
    this.ownerPhoto,
    required this.propertyTitle,
    required this.propertyType,
    required this.price,
    required this.location,
    required this.submittedAt,
    required this.images,
    this.description,
  });
}
