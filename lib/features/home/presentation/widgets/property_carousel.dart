import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:homify/features/properties/presentation/widgets/property_address_widget.dart';

class PropertyCarousel extends StatefulWidget {
  final List<PropertyEntity> properties;
  final Function(PropertyEntity) onTap;

  const PropertyCarousel({
    super.key,
    required this.properties,
    required this.onTap,
  });

  @override
  State<PropertyCarousel> createState() => _PropertyCarouselState();
}

class _PropertyCarouselState extends State<PropertyCarousel> {
  late PageController _pageController;
  late int _currentPage;
  Timer? _timer;

  // Large number to simulate infinite scrolling
  static const int _infiniteCount = 10000;

  @override
  void initState() {
    super.initState();
    // Start in the middle so user can scroll left immediately
    _currentPage = _infiniteCount ~/ 2;
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.9, // Show a bit of the next/prev cards
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _manualNavigate(bool forward) {
    // Reset timer on manual interaction
    _startAutoScroll();
    if (forward) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.properties.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text("No properties nearby")),
      );
    }

    final int realCount = widget.properties.length;

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                // Enable manual swiping
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final propertyIndex = index % realCount;
                  final property = widget.properties[propertyIndex];
                  final imageUrls = property.imageUrls;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () => widget.onTap(property),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image
                            imageUrls.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrls.first,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                            size: 40,
                                          ),
                                        ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.home,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),

                            // Gradient Overlay
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // Text Content
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    property.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  PropertyAddressWidget(
                                    latitude: property.latitude,
                                    longitude: property.longitude,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 12,
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
                },
              ),
              // Navigation Arrows
              Positioned(
                left: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _manualNavigate(false),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _manualNavigate(true),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(realCount, (index) {
            final isActive = (index == (_currentPage % realCount));
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: isActive ? 24 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE05725)
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
