// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/features/home/presentation/providers/explorer_provider.dart';
import 'package:homify/features/home/presentation/providers/bottom_nav_provider.dart';

import 'package:homify/features/home/presentation/widgets/explore_property_details_sheet.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Watch the state
    final exploreState = ref.watch(exploreProvider);

    // If loading but we have an initial position (e.g. from previous fetch or default),
    // we can still show the map to avoid a blank screen.
    // Only show loader if we have absolutely nothing to show.
    if (exploreState.isLoading && exploreState.initialPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exploreState.errorMessage != null &&
        exploreState.initialPosition == null) {
      return Center(child: Text('Error: ${exploreState.errorMessage}'));
    }

    // Listen to explore state changes to toggle bottom nav visibility
    ref.listen(exploreProvider, (previous, next) {
      final wasSelected = previous?.selectedProperty != null;
      final isSelected = next.selectedProperty != null;

      if (wasSelected != isSelected) {
        // If property is selected, hide bottom nav. If cleared, show it.
        // We use a microtask to avoid calling setState during build if that happens
        Future.microtask(() {
          ref.read(bottomNavVisibilityProvider.notifier).state = !isSelected;
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  exploreState.initialPosition ??
                  const LatLng(14.5995, 120.9842), // Default fallback
              zoom: 14.0,
            ),
            markers: exploreState.markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We use a custom one
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            // Add padding to move Google Logo & Copyright up above the bottom nav
            padding: const EdgeInsets.only(bottom: 100),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (_) {
              ref.read(exploreProvider.notifier).clearSelectedProperty();
            },
          ),

          Positioned(
            bottom:
                110, // Positioned above the bottom nav bar (approx 80-100px)
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

          // Property Details Sheet
          if (exploreState.selectedProperty != null)
            ExplorePropertyDetailsSheet(
              property: exploreState.selectedProperty!,
              onClose: () {
                ref.read(exploreProvider.notifier).clearSelectedProperty();
              },
            ),

          // Show a small loading indicator on top if refreshing in background
          if (exploreState.isLoading)
            const Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
