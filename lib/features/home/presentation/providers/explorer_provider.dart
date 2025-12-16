import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homify/core/services/location_service.dart';
import 'package:homify/core/services/places_service.dart';
import 'package:homify/features/properties/domain/usecases/get_verified_properties.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/properties_providers.dart';

// 1. Define the State State
class ExploreState {
  final bool isLoading;
  final List<PropertyEntity> properties; // Store properties for screen access
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final LatLng? initialPosition;
  final String? errorMessage;
  final PropertyEntity? selectedProperty;
  final PropertyEntity?
  targetProperty; // Property to navigate to from other screens

  ExploreState({
    this.isLoading = true,
    this.properties = const [],
    this.markers = const {},
    this.polylines = const {},
    this.initialPosition,
    this.errorMessage,
    this.selectedProperty,
    this.targetProperty,
  });

  ExploreState copyWith({
    bool? isLoading,
    List<PropertyEntity>? properties,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    LatLng? initialPosition,
    String? errorMessage,
    PropertyEntity? selectedProperty,
    bool resetSelectedProperty = false,
    PropertyEntity? targetProperty,
    bool resetTargetProperty = false,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      properties: properties ?? this.properties,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      initialPosition: initialPosition ?? this.initialPosition,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedProperty: resetSelectedProperty
          ? null
          : (selectedProperty ?? this.selectedProperty),
      targetProperty: resetTargetProperty
          ? null
          : (targetProperty ?? this.targetProperty),
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
            properties: properties, // Store properties for screen access
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
        onTap: () {
          // Set the selected property to trigger UI (e.g., bottom sheet)
          state = state.copyWith(selectedProperty: property);
        },
      );
    }).toSet();
  }

  void clearSelectedProperty() {
    state = state.copyWith(
      resetSelectedProperty: true,
      resetTargetProperty: true,
      polylines: {}, // Clear polylines when closing details
    );
  }

  // Called when user wants to navigate to a property from another screen
  Future<void> triggerNavigation(PropertyEntity property) async {
    debugPrint(
      'ExploreNotifier: triggerNavigation called for ${property.name}',
    );
    // 1. Set the target property
    state = state.copyWith(targetProperty: property);
    // 2. Calculate route
    await showDirection(property);
  }

  Future<void> showDirection(PropertyEntity property) async {
    final currentPos = await LocationService.getCurrentPosition();
    if (currentPos == null) return;

    try {
      // Use Geoapify routing API
      final routePoints = await PlacesService.getRoute(
        originLat: currentPos.latitude,
        originLon: currentPos.longitude,
        destLat: property.latitude,
        destLon: property.longitude,
        mode: 'drive',
      );

      if (routePoints.isNotEmpty) {
        final polylineCoordinates = routePoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        _setPolyline(polylineCoordinates);
        debugPrint('ExploreNotifier: Route found, polyline set.');
        return;
      }
    } catch (e) {
      debugPrint('Geoapify Routing Error: $e');
    }

    // Show error if routing fails
    if (mounted) {
      state = state.copyWith(
        errorMessage:
            'Error connecting route. Please check your internet connection.',
      );
    }
  }

  void _setPolyline(List<LatLng> points) {
    final polyline = Polyline(
      polylineId: const PolylineId('direction_path'),
      color: const Color(0xFFE05725), // Primary color
      width: 5,
      points: points,
    );

    if (mounted) {
      debugPrint('ExploreNotifier: Setting polylines in state.');
      state = state.copyWith(polylines: {polyline});
    } else {
      debugPrint('ExploreNotifier: Not mounted, cannot set polylines.');
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
