import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/core/services/location_service.dart';
import 'package:homify/features/properties/domain/usecases/get_verified_properties.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/properties_providers.dart';

// 1. Define the State State
class ExploreState {
  final bool isLoading;
  final Set<Marker> markers;
  final LatLng? initialPosition;
  final String? errorMessage;
  final PropertyEntity? selectedProperty;

  ExploreState({
    this.isLoading = true,
    this.markers = const {},
    this.initialPosition,
    this.errorMessage,
    this.selectedProperty,
  });

  ExploreState copyWith({
    bool? isLoading,
    Set<Marker>? markers,
    LatLng? initialPosition,
    String? errorMessage,
    PropertyEntity? selectedProperty,
    bool resetSelectedProperty = false,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      markers: markers ?? this.markers,
      initialPosition: initialPosition ?? this.initialPosition,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedProperty:
          resetSelectedProperty ? null : (selectedProperty ?? this.selectedProperty),
    );
  }
}

// 2. Define the Notifier
class ExploreNotifier extends StateNotifier<ExploreState> {
  final GetVerifiedProperties _getVerifiedProperties;

  ExploreNotifier({required GetVerifiedProperties getVerifiedProperties})
    : _getVerifiedProperties = getVerifiedProperties,
      super(ExploreState()) {
    loadMapData(); // Load data immediately upon creation
  }

  Future<void> loadMapData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);

    // Step A: Get User Location
    LatLng userPos;
    try {
      final locationData = await LocationService.getSavedLocation();
      if (locationData != null) {
        userPos = LatLng(locationData.latitude, locationData.longitude);
      } else {
        userPos = const LatLng(14.5995, 120.9842); // Default to Manila
      }
    } catch (e) {
      // Fallback if location service fails (e.g. permission denied)
      userPos = const LatLng(14.5995, 120.9842); // Default to Manila
    }

    // Step B: Fetch Properties
    final result = await _getVerifiedProperties();

    if (!mounted) return;

    result.fold(
      (failure) {
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            initialPosition: userPos,
            errorMessage: failure.toString(),
          );
        }
      },
      (properties) {
        final markers = _generateMarkers(properties);
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            initialPosition: userPos,
            markers: markers,
          );
        }
      },
    );
  }

  Set<Marker> _generateMarkers(List<PropertyEntity> properties) {
    return properties.map((property) {
      return Marker(
        markerId: MarkerId(property.id),
        position: LatLng(property.latitude, property.longitude),
        infoWindow: InfoWindow(
          title: property.name,
          snippet: "₱${property.rentAmount}",
        ),
        onTap: () {
          // Set the selected property to trigger UI (e.g., bottom sheet)
          state = state.copyWith(selectedProperty: property);
        },
      );
    }).toSet();
  }

  void clearSelectedProperty() {
    if (state.selectedProperty != null) {
      state = state.copyWith(resetSelectedProperty: true);
    }
  }
}

// 3. Define the Provider
final exploreProvider = StateNotifierProvider<ExploreNotifier, ExploreState>((
  ref,
) {
  final repository = ref.watch(propertyRepositoryProvider);
  return ExploreNotifier(
    getVerifiedProperties: GetVerifiedProperties(repository),
  );
});
