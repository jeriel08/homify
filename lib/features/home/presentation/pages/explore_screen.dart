import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/features/home/presentation/providers/explorer_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    // Watch the state
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
            myLocationButtonEnabled: false, // We can build a custom one
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // Example: Custom "My Location" button
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
        ],
      ),
    );
  }
}
