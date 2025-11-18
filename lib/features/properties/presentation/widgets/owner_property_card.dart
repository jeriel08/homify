import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OwnerPropertyCard extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const OwnerPropertyCard({
    super.key,
    required this.property,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Image & Status Header
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: property.imageUrls.isNotEmpty
                      ? Image.network(
                          property.imageUrls.first,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(LucideIcons.image),
                        ),
                ),
              ),
              // Status Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: property.isVerified ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    property.isVerified ? 'Live' : 'Pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. Details Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Stats
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.heart,
                          size: 16,
                          color: Colors.red,
                        ),
                        const Gap(4),
                        Text('${property.favoritesCount}'),
                      ],
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  '₱${property.rentAmount} / ${property.rentChargeMethod.name}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // 3. Action Buttons (Edit / Delete)
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(LucideIcons.pencil, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
