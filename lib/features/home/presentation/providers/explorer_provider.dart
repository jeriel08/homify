import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/core/services/location_service.dart';
import 'package:homify/features/properties/domain/usecases/get_verified_properties.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
// Import your dependency injection or repository providers
import 'package:homify/features/properties/properties_providers.dart';

// 1. Define the State State
class ExploreState {
  final bool isLoading;
  final Set<Marker> markers;
  final LatLng? initialPosition;
  final String? errorMessage;

  ExploreState({
    this.isLoading = true,
    this.markers = const {},
    this.initialPosition,
    this.errorMessage,
  });

  ExploreState copyWith({
    bool? isLoading,
    Set<Marker>? markers,
    LatLng? initialPosition,
    String? errorMessage,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      markers: markers ?? this.markers,
      initialPosition: initialPosition ?? this.initialPosition,
      errorMessage: errorMessage ?? this.errorMessage,
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
    state = state.copyWith(isLoading: true);

    // Step A: Get User Location
    final locationData = await LocationService.getSavedLocation();
    LatLng userPos;
    if (locationData != null) {
      userPos = LatLng(locationData.latitude, locationData.longitude);
    } else {
      userPos = const LatLng(14.5995, 120.9842); // Default to Manila
    }

    // Step B: Fetch Properties
    final result = await _getVerifiedProperties();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          initialPosition: userPos,
          errorMessage: failure
              .toString(), // Ensure your Failure class has a toString or message field
        );
      },
      (properties) {
        final markers = _generateMarkers(properties);
        state = state.copyWith(
          isLoading: false,
          initialPosition: userPos,
          markers: markers,
        );
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
          // Handle marker tap (e.g., update a selectedProperty provider to show a card)
        },
      );
    }).toSet();
  }
}

// 3. Define the Provider
final exploreProvider = StateNotifierProvider<ExploreNotifier, ExploreState>((
  ref,
) {
  // You need to expose your UseCase via a provider as well.
  // Assuming you have a provider for the repository:
  final repository = ref.watch(propertyRepositoryProvider);
  return ExploreNotifier(
    getVerifiedProperties: GetVerifiedProperties(repository),
  );
});
