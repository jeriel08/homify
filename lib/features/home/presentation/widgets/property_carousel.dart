import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';

class PropertyCarousel extends StatefulWidget {
  final List<PropertyEntity> properties;

  const PropertyCarousel({super.key, required this.properties});

  @override
  State<PropertyCarousel> createState() => _PropertyCarouselState();
}

class _PropertyCarouselState extends State<PropertyCarousel> {
  final CarouselController _carouselController = CarouselController(
    initialItem: 5,
  );
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (_currentPage < widget.properties.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_carouselController.hasClients) {
        _carouselController.animateToItem(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _carouselController.dispose();
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

    return SizedBox(
      height: 250,
      child: CarouselView.weighted(
        controller: _carouselController,
        scrollDirection: Axis.horizontal,
        flexWeights: const [1, 7, 1],
        children: List.generate(widget.properties.length, (int index) {
          final imageUrls = widget.properties[index].imageUrls;
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: imageUrls.isNotEmpty
                ? Image.network(imageUrls.first, fit: BoxFit.cover)
                : const Center(child: Text('No image')),
          );
        }),
      ),
    );
  }
}
