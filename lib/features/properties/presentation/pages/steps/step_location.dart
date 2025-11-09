// lib/features/properties/presentation/pages/steps/step_location.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/core/services/location_service.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_controller.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_state.dart';

PropertyStep stepLocation() {
  return PropertyStep(
    title: 'Property Location',
    builder: (context) => const _LocationStep(),
    validate: (data) async {
      final lat = data['latitude'] as double?;
      final lng = data['longitude'] as double?;
      return lat != null && lng != null;
    },
  );
}

class _LocationStep extends ConsumerStatefulWidget {
  const _LocationStep();

  @override
  ConsumerState<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<_LocationStep> {
  // --- ALL STATE IS BACK IN THIS WIDGET ---
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  bool _triedNext = false;
  static const LatLng _defaultCenter = LatLng(14.5995, 120.9842); // Manila

  @override
  void initState() {
    super.initState();
    // We load the saved position from the controller's data
    final data = ref.read(addPropertyControllerProvider).formData;
    final lat = data['latitude'] as double?;
    final lng = data['longitude'] as double?;
    if (lat != null && lng != null) {
      _selectedPosition = LatLng(lat, lng);
    }
  }

  Future<void> _moveCameraToInitialPos() async {
    // 1. Check for a pin
    if (_selectedPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedPosition!, 16),
      );
      return;
    }
    // 2. Check for user's saved location
    final saved = await LocationService.getSavedLocation();
    if (saved != null && mounted) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(saved.latitude, saved.longitude), 14),
      );
      return;
    }
    // 3. Fallback to default center
    _mapController!.animateCamera(CameraUpdate.newLatLng(_defaultCenter));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveCameraToInitialPos(); // Move camera once map is ready
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _triedNext = false;
    });
    // Save to formData
    ref
        .read(addPropertyControllerProvider.notifier)
        .updateData('latitude', position.latitude);
    ref
        .read(addPropertyControllerProvider.notifier)
        .updateData('longitude', position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(addPropertyControllerProvider.notifier);
    final state = ref.watch(addPropertyControllerProvider);
    final isLastStep = state.currentStep == state.steps.length - 1;
    final isSubmitting = state.isSubmitting;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            'Where is your property located?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'Tap on the map to place a pin at your boarding house location.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),

          // ---- YOUR NEW MAP CONTAINER ----
          Expanded(
            child: Container(
              // 1. Border Radius
              clipBehavior: Clip.antiAlias, // Clips the GoogleMap to the border
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // 2. Elevation Shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // 3. The Map
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedPosition ?? _defaultCenter,
                  zoom: _selectedPosition != null ? 16 : 12,
                ),
                onMapCreated: _onMapCreated,
                onTap: _onTap,
                markers: _selectedPosition != null
                    ? {
                        Marker(
                          markerId: const MarkerId('property_pin'),
                          position: _selectedPosition!,
                        ),
                      }
                    : {},
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false, // Cleaner look
              ),
            ),
          ),
          // ---- END OF MAP CONTAINER ----

          // Error
          if (_triedNext && _selectedPosition == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please tap the map to select your property location.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          const SizedBox(height: 24),

          // Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => _triedNext = true);
                          if (_selectedPosition == null) return;

                          final ok = await controller.next();
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a location'),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32190D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(isLastStep ? 'Submit' : 'Next'),
                ),
              ),
              if (state.currentStep > 0) const SizedBox(height: 12),
              if (state.currentStep > 0)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : controller.back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF32190D),
                      side: const BorderSide(color: Color(0xFF32190D)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Back'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
