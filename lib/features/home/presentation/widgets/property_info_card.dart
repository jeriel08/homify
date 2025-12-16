import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';

/// A compact info card that displays property details when a marker is tapped
class PropertyInfoCard extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const PropertyInfoCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onClose,
  });

  static const Color primary = Color(0xFFE05725);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.imageUrls.isNotEmpty
        ? property.imageUrls.first
        : null;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Property Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.home,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.home,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Property Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Property Name
                    Text(
                      property.name,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Property Type
                    Text(
                      property.type.name.toUpperCase(),
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Rent Amount
                    Row(
                      children: [
                        Text(
                          '₱${property.rentAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          ' / month',
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close button
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
