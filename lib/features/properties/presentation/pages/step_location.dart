// lib/auth/registration/steps/step_location.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/features/auth/presentation/controllers/registration_controller.dart';
import 'package:homify/core/services/location_service.dart';

RegistrationStep stepLocation() {
  return RegistrationStep(
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
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  bool _triedNext = false;
  static const LatLng _defaultCenter = LatLng(14.5995, 120.9842); // Manila

  @override
  void initState() {
    super.initState();
    _loadSavedOrDefault();
  }

  Future<void> _loadSavedOrDefault() async {
    final saved = await LocationService.getSavedLocation();

    LatLng initialPos = _defaultCenter;

    if (saved != null) {
      initialPos = LatLng(saved.latitude, saved.longitude);
    }

    if (mounted && _mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(initialPos));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _loadSavedOrDefault();
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _triedNext = false;
    });
    // Save to formData
    ref
        .read(registrationControllerProvider.notifier)
        .updateData('latitude', position.latitude);
    ref
        .read(registrationControllerProvider.notifier)
        .updateData('longitude', position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);
    final state = ref.watch(registrationControllerProvider);
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

          // Map (full height minus buttons)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _defaultCenter,
                      zoom: 12,
                    ),
                    onMapCreated: _onMapCreated,
                    onTap: _onTap,
                    markers: _selectedPosition != null
                        ? {
                            Marker(
                              markerId: const MarkerId('property_pin'),
                              position: _selectedPosition!,
                              infoWindow: const InfoWindow(
                                title: 'Your Property',
                              ),
                            ),
                          }
                        : {},
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                  // Instructions overlay
                  if (_selectedPosition == null)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tap anywhere to place your property pin',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

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
          Consumer(
            builder: (context, ref, child) {
              return Column(
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
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
