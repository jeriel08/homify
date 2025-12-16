import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PropertyMessageBubble extends StatelessWidget {
  final Map<String, dynamic> propertyData;
  final VoidCallback? onTap;

  const PropertyMessageBubble({
    super.key,
    required this.propertyData,
    this.onTap,
  });

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);

  @override
  Widget build(BuildContext context) {
    final name = propertyData['name'] ?? 'Property';
    final rentAmount = propertyData['rent_amount'] ?? 0;
    final imageUrl = propertyData['image_url'] != null
        ? (propertyData['image_url'] as List).isNotEmpty
              ? (propertyData['image_url'] as List).first
              : null
        : null;

    final formatter = NumberFormat('#,###');

    // Responsive width: 70% of screen, min 260, max 320
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.70).clamp(260.0, 320.0);

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 130,
                  color: surface,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 130,
                  color: surface,
                  child: const Center(
                    child: Icon(LucideIcons.imageOff, color: primary, size: 32),
                  ),
                ),
              )
            else
              Container(
                height: 130,
                color: surface,
                child: const Center(
                  child: Icon(LucideIcons.house, color: primary, size: 40),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property name
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Price
                  Row(
                    children: [
                      const Icon(LucideIcons.tag, size: 14, color: primary),
                      const SizedBox(width: 4),
                      Text(
                        '₱${formatter.format((rentAmount as num).toInt())} / month',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Show Details Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(LucideIcons.eye, size: 16),
                      label: const Text('Show Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
