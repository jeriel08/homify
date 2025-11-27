import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/typography.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final maxHeight = screenHeight - topPadding - 60;

    final property = widget.property;
    final ownerAsync = ref.watch(userProfileProvider(property.ownerUid));

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: (maxHeight / screenHeight).clamp(0.5, 0.98),
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  // Image Carousel
                  SizedBox(
                    height: 280,
                    child: property.imageUrls.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: surface.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: surface, width: 2),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.image,
                                    size: 64,
                                    color: textSecondary.withValues(alpha: 0.4),
                                  ),
                                  const Gap(12),
                                  Text(
                                    'No images available',
                                    style: HomifyTypography.medium(
                                      HomifyTypography.body2.copyWith(
                                        color: textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              // Image PageView
                              PageView.builder(
                                controller: _pageController,
                                itemCount: property.imageUrls.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                itemBuilder: (_, i) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: CachedNetworkImage(
                                      imageUrl: property.imageUrls[i],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: surface.withValues(alpha: 0.3),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: surface.withValues(
                                              alpha: 0.3,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                LucideIcons.imageOff,
                                                size: 60,
                                                color: textSecondary.withValues(
                                                  alpha: 0.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ),

                              // Navigation arrows (if multiple images)
                              if (property.imageUrls.length > 1) ...[
                                // Left arrow
                                if (_currentPage > 0)
                                  Positioned(
                                    left: 12,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            _pageController.previousPage(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          icon: const Icon(
                                            LucideIcons.chevronLeft,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Right arrow
                                if (_currentPage <
                                    property.imageUrls.length - 1)
                                  Positioned(
                                    right: 12,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          icon: const Icon(
                                            LucideIcons.chevronRight,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Page indicator
                                Positioned(
                                  bottom: 16,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      property.imageUrls.length,
                                      (index) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: _currentPage == index ? 24 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _currentPage == index
                                              ? primary
                                              : Colors.white.withValues(
                                                  alpha: 0.6,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Image counter
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${_currentPage + 1}/${property.imageUrls.length}',
                                      style: HomifyTypography.semibold(
                                        HomifyTypography.label3.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),

                  const Gap(24),

                  // Property type badge
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.house, size: 16, color: primary),
                          const Gap(6),
                          Text(
                            _formatType(property.type),
                            style: HomifyTypography.semibold(
                              HomifyTypography.label2.copyWith(
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(16),

                  // Title
                  Text(
                    property.name,
                    style: HomifyTypography.bold(
                      HomifyTypography.heading5.copyWith(color: textPrimary),
                    ),
                  ),

                  const Gap(12),

                  // Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.banknote, color: primary, size: 24),
                        const Gap(12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rent Price',
                              style: HomifyTypography.medium(
                                HomifyTypography.label3.copyWith(
                                  color: textSecondary,
                                ),
                              ),
                            ),
                            const Gap(4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.philippinePeso,
                                    size: 16,
                                    color: textPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    property.rentAmount.toInt().toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                  ),
                                  Text(
                                    ' / ${property.rentChargeMethod == RentChargeMethod.perUnit ? 'unit' : 'bed'}',
                                    style: HomifyTypography.body3.copyWith(
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Gap(20),

                  // Location
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            LucideIcons.mapPin,
                            color: primary,
                            size: 20,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Location',
                                style: HomifyTypography.medium(
                                  HomifyTypography.label3.copyWith(
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                              const Gap(4),
                              PropertyAddressWidget(
                                latitude: property.latitude,
                                longitude: property.longitude,
                                style: HomifyTypography.medium(
                                  HomifyTypography.body3.copyWith(
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(24),

                  // Divider
                  Container(height: 1, color: surface.withValues(alpha: 0.5)),

                  const Gap(24),

                  // Description
                  Row(
                    children: [
                      Icon(LucideIcons.fileText, size: 20, color: primary),
                      const Gap(8),
                      Text(
                        'Description',
                        style: HomifyTypography.semibold(
                          HomifyTypography.heading6.copyWith(
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      property.description.isEmpty
                          ? 'No description provided.'
                          : property.description,
                      style: HomifyTypography.body2.copyWith(
                        color: textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const Gap(24),

                  // Amenities
                  if (property.amenities.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(LucideIcons.sparkles, size: 20, color: primary),
                        const Gap(8),
                        Text(
                          'Amenities',
                          style: HomifyTypography.semibold(
                            HomifyTypography.heading6.copyWith(
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.amenities
                          .map(
                            (a) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: surface, width: 2),
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
                                    a,
                                    style: HomifyTypography.medium(
                                      HomifyTypography.label2.copyWith(
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const Gap(24),
                  ],

                  // Owner Info
                  Row(
                    children: [
                      Icon(LucideIcons.user, size: 20, color: primary),
                      const Gap(8),
                      Text(
                        'Property Owner',
                        style: HomifyTypography.semibold(
                          HomifyTypography.heading6.copyWith(
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: surface, width: 2),
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
                                    : AssetImage(placeholder) as ImageProvider,
                              );
                            },
                            loading: () => const CircleAvatar(
                              radius: 24,
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, _) => const CircleAvatar(
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
                                    style: HomifyTypography.semibold(
                                      HomifyTypography.body2.copyWith(
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                  loading: () => Container(
                                    width: 100,
                                    height: 16,
                                    color: Colors.grey[200],
                                  ),
                                  error: (_, _) =>
                                      const Text('Error loading owner'),
                                ),
                                Text(
                                  'View Profile',
                                  style: HomifyTypography.medium(
                                    HomifyTypography.label3.copyWith(
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  ContactOwnerButton(ownerUid: property.ownerUid),

                  const Gap(20),

                  // Report Issue Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        context.push(
                          '/report',
                          extra: {
                            'targetId': property.id,
                            'targetType': 'property',
                          },
                        );
                      },
                      icon: Icon(
                        LucideIcons.flag,
                        size: 16,
                        color: textSecondary.withValues(alpha: 0.6),
                      ),
                      label: Text(
                        'Report Issue',
                        style: HomifyTypography.medium(
                          HomifyTypography.label3.copyWith(
                            color: textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                ],
              ),
            ),

            // Bottom Action Bar
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
                      color: surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // TODO: Implement favorite toggle
                      },
                      icon: const Icon(LucideIcons.heart),
                      color: textPrimary,
                      padding: const EdgeInsets.all(16),
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
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        textStyle: HomifyTypography.semibold(
                          HomifyTypography.label1,
                        ),
                      ),
                      icon: const Icon(LucideIcons.map),
                      label: const Text('Show Direction'),
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

  String _formatType(PropertyType type) {
    return type.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}
