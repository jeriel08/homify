import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/home/presentation/providers/navigation_provider.dart';
import 'package:homify/features/messages/presentation/widgets/contact_owner_button.dart';
import 'package:homify/features/profile/presentation/providers/profile_provider.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/widgets/property_address_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TenantPropertyDetailsSheet extends ConsumerStatefulWidget {
  final PropertyEntity property;

  const TenantPropertyDetailsSheet({super.key, required this.property});

  @override
  ConsumerState<TenantPropertyDetailsSheet> createState() =>
      _TenantPropertyDetailsSheetState();
}

class _TenantPropertyDetailsSheetState
    extends ConsumerState<TenantPropertyDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final ownerAsync = ref.watch(userProfileProvider(property.ownerUid));

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  children: [
                    // 1. Images
                    SizedBox(
                      height: 250,
                      child: property.imageUrls.isNotEmpty
                          ? PageView.builder(
                              itemCount: property.imageUrls.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: property.imageUrls[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.home,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                    const Gap(24),

                    // 2. Title & Address
                    Text(
                      property.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF32190D),
                          ),
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 16,
                          color: Color(0xFFE05725),
                        ),
                        const Gap(4),
                        Expanded(
                          child: PropertyAddressWidget(
                            latitude: property.latitude,
                            longitude: property.longitude,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),

                    // 3. Price
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9E5C5).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE05725).withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rent per month',
                            style: TextStyle(
                              color: const Color(
                                0xFF32190D,
                              ).withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.philippinePeso,
                                size: 20,
                                color: Color(0xFFE05725),
                              ),
                              Text(
                                '${property.rentAmount.toInt()}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE05725),
                                ),
                              ),
                              Text(
                                ' / ${property.rentChargeMethod.name == 'perUnit' ? 'unit' : 'bed'}',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF32190D,
                                  ).withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),

                    // 4. Owner Info
                    Text(
                      'Property Owner',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF32190D),
                      ),
                    ),
                    const Gap(12),
                    InkWell(
                      onTap: () {
                        context.push('/profile/${property.ownerUid}');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ownerAsync.when(
                              data: (owner) {
                                final isMale =
                                    owner.gender?.toLowerCase() == 'male';
                                final placeholder = isMale
                                    ? 'assets/images/placeholder_male.png'
                                    : 'assets/images/placeholder_female.png';

                                return CircleAvatar(
                                  radius: 24,
                                  backgroundImage: owner.photoUrl != null
                                      ? NetworkImage(owner.photoUrl!)
                                      : AssetImage(placeholder)
                                            as ImageProvider,
                                );
                              },
                              loading: () => const CircleAvatar(
                                radius: 24,
                                child: CircularProgressIndicator(),
                              ),
                              error: (_, __) => const CircleAvatar(
                                radius: 24,
                                child: Icon(Icons.error),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ownerAsync.when(
                                    data: (owner) => Text(
                                      '${owner.firstName} ${owner.lastName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    loading: () => Container(
                                      width: 100,
                                      height: 16,
                                      color: Colors.grey[200],
                                    ),
                                    error: (_, __) =>
                                        const Text('Error loading owner'),
                                  ),
                                  const Text(
                                    'View Profile',
                                    style: TextStyle(
                                      color: Color(0xFFE05725),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const Gap(16),
                    ContactOwnerButton(ownerUid: property.ownerUid),
                    const Gap(24),

                    // 5. Description
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF32190D),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      property.description,
                      style: TextStyle(color: Colors.grey[600], height: 1.5),
                    ),
                    const Gap(24),

                    // 6. Amenities
                    if (property.amenities.isNotEmpty) ...[
                      Text(
                        'Amenities',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF32190D),
                            ),
                      ),
                      const Gap(12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: property.amenities.map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              amenity,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Gap(24),
                    ],
                  ],
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Favorite Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // TODO: Implement favorite toggle
                        },
                        icon: const Icon(LucideIcons.heart),
                        color: const Color(0xFF32190D),
                      ),
                    ),
                    const Gap(12),
                    // Show Direction Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close sheet
                          // Switch to Explore tab (Index 1)
                          ref.read(bottomNavIndexProvider.notifier).state = 1;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE05725),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(LucideIcons.map),
                        label: const Text(
                          'Show Direction',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
