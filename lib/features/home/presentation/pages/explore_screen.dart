// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/features/home/presentation/providers/explorer_provider.dart';
import 'package:homify/features/messages/presentation/widgets/contact_owner_button.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/home/presentation/widgets/image_gallery_viewer.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _DraggablePropertySheet extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback onClose;
  const _DraggablePropertySheet({required this.property, required this.onClose});

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF32190D);
    const Color textSecondary = Color(0xFF6B4F3C);
    const Color bg = Color(0xFFFFFAF5);
    const Color brand = Color(0xFFE05725);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Pinned header: name + price + close
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                decoration: const BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱ ${property.rentAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: brand,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: textSecondary),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  children: [
                    const SizedBox(height: 8),
                    // Header image (tap to open fullscreen gallery)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: GestureDetector(
                            onTap: () {
                              if (property.imageUrls.isEmpty) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ImageGalleryViewer(
                                    imageUrls: property.imageUrls,
                                  ),
                                ),
                              );
                            },
                            child: property.imageUrls.isNotEmpty
                                ? Image.network(
                                    property.imageUrls.first,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: const Color(0xFFF9E5C5),
                                    child: const Center(
                                      child: Icon(Icons.home, color: brand, size: 40),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            property.description.isEmpty
                                ? 'No description provided.'
                                : property.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: textSecondary,
                                ),
                          ),
                          if (property.amenities.isNotEmpty) const SizedBox(height: 12),
                          if (property.amenities.isNotEmpty)
                            Text(
                              'Amenities',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          if (property.amenities.isNotEmpty) const SizedBox(height: 6),
                          if (property.amenities.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: property.amenities
                                  .map((a) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9E5C5),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.check_circle, size: 14, color: textPrimary),
                                            const SizedBox(width: 6),
                                            Text(a,
                                                style: const TextStyle(
                                                    color: textPrimary, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),

                          const SizedBox(height: 24),
                          // Owner Profile
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Color(0xFFF9E5C5),
                                  child: Icon(Icons.person, color: brand),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Listed by Owner',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: textPrimary,
                                            ),
                                      ),
                                      Text(
                                        'Verified Host',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          // Buttons Row
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: brand),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    // TODO: add favorite logic
                                  },
                                  icon: const Icon(Icons.favorite_border, color: brand),
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ContactOwnerButton(ownerUid: property.ownerUid),
                              ),
                            ],
                          ),
                        ],
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

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {

    final exploreState = ref.watch(exploreProvider);

    if (exploreState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exploreState.errorMessage != null) {
      return Center(child: Text('Error: ${exploreState.errorMessage}'));
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: exploreState.initialPosition!,
              zoom: 14.0,
            ),
            markers: exploreState.markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (_) {
              ref.read(exploreProvider.notifier).clearSelectedProperty();
            },
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
              onPressed: () {
                if (_mapController != null &&
                    exploreState.initialPosition != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLng(exploreState.initialPosition!),
                  );
                }
              },
            ),
          ),

          if (exploreState.selectedProperty != null) ...[
            // tap outside to collapse
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => ref
                    .read(exploreProvider.notifier)
                    .clearSelectedProperty(),
                child: const SizedBox.shrink(),
              ),
            ),
            _DraggablePropertySheet(
              property: exploreState.selectedProperty!,
              onClose: () => ref
                  .read(exploreProvider.notifier)
                  .clearSelectedProperty(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PropertyOverlayCard extends StatelessWidget {
  final VoidCallback onClose;
  final PropertyEntity property;
  const _PropertyOverlayCard({required this.onClose, required this.property});

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF32190D);
    const Color textSecondary = Color(0xFF6B4F3C);
    const Color bg = Color(0xFFFFFAF5);
    const Color brand = Color(0xFFE05725);

    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return Material(
      elevation: 8,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: property.imageUrls.isNotEmpty
                      ? Image.network(property.imageUrls.first, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFF9E5C5),
                          child: const Center(
                            child: Icon(Icons.home, color: brand, size: 40),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            property.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: textSecondary),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱ ${property.rentAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ContactOwnerButton(ownerUid: property.ownerUid),
                    const SizedBox(height: 12),
                    // Description
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      property.description.isEmpty
                          ? 'No description provided.'
                          : property.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textSecondary,
                          ),
                    ),
                    if (property.amenities.isNotEmpty) const SizedBox(height: 12),
                    if (property.amenities.isNotEmpty)
                      Text(
                        'Amenities',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    if (property.amenities.isNotEmpty) const SizedBox(height: 6),
                    if (property.amenities.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: property.amenities
                            .map((a) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9E5C5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle,
                                          size: 14, color: textPrimary),
                                      const SizedBox(width: 6),
                                      Text(
                                        a,
                                        style: const TextStyle(
                                            color: textPrimary,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
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
