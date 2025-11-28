import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PropertyMessageBubble extends StatelessWidget {
  final Map<String, dynamic> propertyData;
  final VoidCallback? onTap;

  const PropertyMessageBubble({
    super.key,
    required this.propertyData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = propertyData['name'] ?? 'Property';
    final rentAmount = propertyData['rent_amount'] ?? 0;
    final imageUrl = propertyData['image_url'] != null 
        ? (propertyData['image_url'] as List).first 
        : null;

    const Color brand = Color(0xFFE05725);
    const Color textPrimary = Color(0xFF32190D);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: brand.withValues(alpha: 0.3)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              if (imageUrl != null)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: const Color(0xFFF9E5C5),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 120,
                    color: const Color(0xFFF9E5C5),
                    child: const Center(
                      child: Icon(Icons.broken_image, color: brand, size: 32),
                    ),
                  ),
                )
              else
                Container(
                  height: 120,
                  color: const Color(0xFFF9E5C5),
                  child: const Center(
                    child: Icon(Icons.home, color: brand, size: 32),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₱ ${(rentAmount as num).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: brand,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'View Property',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: brand,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
