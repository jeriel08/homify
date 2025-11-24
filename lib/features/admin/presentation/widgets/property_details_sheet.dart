import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/messages/presentation/widgets/contact_owner_button.dart';
import 'package:homify/features/properties/presentation/widgets/property_address_widget.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class PropertyDetailsSheet extends StatefulWidget {
  final PropertyEntity property;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool showActions;

  const PropertyDetailsSheet({
    super.key,
    required this.property,
    this.onApprove = _defaultApprove,
    this.onReject = _defaultReject,
    this.showActions = true,
  });

  static void _defaultApprove() {}
  static void _defaultReject() {}

  @override
  State<PropertyDetailsSheet> createState() => _PropertyDetailsSheetState();
}

class _PropertyDetailsSheetState extends State<PropertyDetailsSheet> {
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
    final maxHeight = screenHeight - topPadding - 60; // 20px margin from top

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
                  // Image Carousel with indicator
                  SizedBox(
                    height: 280,
                    child: widget.property.imageUrls.isEmpty
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
                                itemCount: widget.property.imageUrls.length,
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
                                    child: Image.network(
                                      widget.property.imageUrls[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        color: surface.withValues(alpha: 0.3),
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
                              if (widget.property.imageUrls.length > 1) ...[
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
                                    widget.property.imageUrls.length - 1)
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
                                      widget.property.imageUrls.length,
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
                                      '${_currentPage + 1}/${widget.property.imageUrls.length}',
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
                            _formatType(widget.property.type),
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
                    widget.property.name,
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
                                  // Philippine Peso Icon
                                  Icon(
                                    LucideIcons.philippinePeso,
                                    size: 16,
                                    color: textPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.property.rentAmount
                                        .toInt()
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                  ),
                                  Text(
                                    ' / ${widget.property.rentChargeMethod == RentChargeMethod.perUnit ? 'unit' : 'bed'}',
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
                                latitude: widget.property.latitude,
                                longitude: widget.property.longitude,
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

                  ContactOwnerButton(ownerUid: widget.property.ownerUid),

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
                      widget.property.description.isEmpty
                          ? 'No description provided.'
                          : widget.property.description,
                      style: HomifyTypography.body2.copyWith(
                        color: textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const Gap(24),

                  // Amenities
                  if (widget.property.amenities.isNotEmpty) ...[
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
                      children: widget.property.amenities
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

                  const Gap(8),

                  // Action Buttons
                  if (widget.showActions) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              widget.onReject();
                              Navigator.pop(context);
                            },
                            icon: const Icon(LucideIcons.x, size: 20),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(
                                color: Colors.red.shade400,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: HomifyTypography.semibold(
                                HomifyTypography.label1,
                              ),
                            ),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.onApprove();
                              Navigator.pop(context);
                            },
                            icon: const Icon(LucideIcons.check, size: 20),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: HomifyTypography.bold(
                                HomifyTypography.label1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                  ],
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
