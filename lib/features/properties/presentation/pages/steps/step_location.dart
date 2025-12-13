// lib/features/properties/presentation/pages/steps/step_location.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/core/services/location_service.dart';
import 'package:homify/core/services/places_service.dart';
import 'package:homify/core/models/place_models.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_controller.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  // Map state
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  bool _triedNext = false;
  static const LatLng _defaultCenter = LatLng(14.5995, 120.9842); // Manila

  // Search state
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<PlacePrediction> _predictions = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  void initState() {
    super.initState();
    final data = ref.read(addPropertyControllerProvider).formData;
    final lat = data['latitude'] as double?;
    final lng = data['longitude'] as double?;
    if (lat != null && lng != null) {
      _selectedPosition = LatLng(lat, lng);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _moveCameraToInitialPos() async {
    if (_selectedPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedPosition!, 16),
      );
      return;
    }
    final saved = await LocationService.getSavedLocation();
    if (saved != null && mounted) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(saved.latitude, saved.longitude), 14),
      );
      return;
    }
    _mapController!.animateCamera(CameraUpdate.newLatLng(_defaultCenter));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveCameraToInitialPos();
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _triedNext = false;
      _predictions = [];
    });
    FocusScope.of(context).unfocus();

    ref
        .read(addPropertyControllerProvider.notifier)
        .updateData('latitude', position.latitude);
    ref
        .read(addPropertyControllerProvider.notifier)
        .updateData('longitude', position.longitude);
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.isEmpty || query.length < 2) {
      setState(() => _predictions = []);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);

      final predictions = await PlacesService.getAutocompletePredictions(query);

      if (mounted) {
        setState(() {
          _predictions = predictions;
          _isSearching = false;
        });
      }
    });
  }

  void _onPredictionSelected(PlacePrediction prediction) {
    // Dismiss keyboard and clear predictions
    FocusScope.of(context).unfocus();

    setState(() {
      _predictions = [];
      _searchController.text = prediction.mainText;
    });

    // Use coordinates directly from Geoapify prediction
    if (prediction.latitude != null && prediction.longitude != null) {
      final position = LatLng(prediction.latitude!, prediction.longitude!);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 17));
      _selectLocation(position);
    }
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
          const SizedBox(height: 16),

          // Header
          Text(
            'Where is your property located?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Search for an address or tap on the map.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),

          // Map with Search Bar overlaying
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Map Container - behind everything
                Positioned.fill(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedPosition ?? _defaultCenter,
                        zoom: _selectedPosition != null ? 16 : 12,
                      ),
                      onMapCreated: _onMapCreated,
                      onTap: _selectLocation,
                      markers: _selectedPosition != null
                          ? {
                              Marker(
                                markerId: const MarkerId('property_pin'),
                                position: _selectedPosition!,
                              ),
                            }
                          : {},
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false, // Move button inside
                      zoomControlsEnabled: false,
                      padding: const EdgeInsets.only(
                        top: 60,
                      ), // Space for search bar
                    ),
                  ),
                ),

                // Search Bar - overlaying the map at top
                Positioned(top: 8, left: 8, right: 8, child: _buildSearchBar()),

                // Predictions Dropdown - overlaying the map below search bar
                if (_predictions.isNotEmpty)
                  Positioned(
                    top: 64,
                    left: 8,
                    right: 8,
                    child: GestureDetector(
                      // Absorb all tap events so map doesn't receive them
                      onTap: () {},
                      onTapDown: (_) {},
                      behavior: HitTestBehavior.opaque,
                      child: _buildPredictionsDropdown(),
                    ),
                  ),

                // My Location Button - bottom right
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'my_location',
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      final pos = await LocationService.getCurrentPosition();
                      if (pos != null && mounted) {
                        final latLng = LatLng(pos.latitude, pos.longitude);
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(latLng, 16),
                        );
                      }
                    },
                    child: Icon(
                      LucideIcons.crosshair,
                      color: textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
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

          const SizedBox(height: 16),

          // Buttons
          _buildButtons(controller, state, isLastStep, isSubmitting),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search address...',
          hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
          prefixIcon: Icon(LucideIcons.search, color: textSecondary, size: 20),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(LucideIcons.x, color: textSecondary, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _predictions = []);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(color: textPrimary, fontSize: 14),
      ),
    );
  }

  Widget _buildPredictionsDropdown() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _predictions.length,
          itemBuilder: (context, index) {
            final prediction = _predictions[index];
            return InkWell(
              onTap: () => _onPredictionSelected(prediction),
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? const Radius.circular(12) : Radius.zero,
                bottom: index == _predictions.length - 1
                    ? const Radius.circular(12)
                    : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(LucideIcons.mapPin, color: primary, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            prediction.mainText,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (prediction.secondaryText.isNotEmpty)
                            Text(
                              prediction.secondaryText,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtons(
    AddPropertyController controller,
    AddPropertyState state,
    bool isLastStep,
    bool isSubmitting,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
              backgroundColor: textPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(isLastStep ? 'Submit' : 'Next'),
          ),
        ),
        if (state.currentStep > 0) const SizedBox(height: 10),
        if (state.currentStep > 0)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isSubmitting ? null : controller.back,
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: textPrimary),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
      ],
    );
  }
}
