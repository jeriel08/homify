import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/domain/usecases/get_nearby_properties.dart';
import 'package:homify/features/properties/domain/usecases/get_recommended_properties.dart';
import 'package:homify/features/properties/properties_providers.dart';

class TenantHomeState {
  final bool isLoading;
  final List<PropertyEntity> nearbyProperties;
  final List<PropertyEntity> recommendedProperties;
  final String? error;

  const TenantHomeState({
    this.isLoading = false,
    this.nearbyProperties = const [],
    this.recommendedProperties = const [],
    this.error,
  });

  TenantHomeState copyWith({
    bool? isLoading,
    List<PropertyEntity>? nearbyProperties,
    List<PropertyEntity>? recommendedProperties,
    String? error,
  }) {
    return TenantHomeState(
      isLoading: isLoading ?? this.isLoading,
      nearbyProperties: nearbyProperties ?? this.nearbyProperties,
      recommendedProperties:
          recommendedProperties ?? this.recommendedProperties,
      error: error,
    );
  }
}

class TenantHomeNotifier extends StateNotifier<TenantHomeState> {
  final Ref ref;
  final GetNearbyProperties _getNearbyProperties;
  final GetRecommendedProperties _getRecommendedProperties;

  TenantHomeNotifier(
    this.ref,
    this._getNearbyProperties,
    this._getRecommendedProperties,
  ) : super(const TenantHomeState());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Fetch Nearby Properties
      await _loadNearbyProperties();

      // 2. Fetch Recommended Properties
      await _loadRecommendedProperties();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadNearbyProperties() async {
    // Check permissions
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition();

    final result = await _getNearbyProperties(
      GetNearbyPropertiesParams(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );

    result.fold(
      (failure) => null, // Handle error silently or log
      (properties) {
        state = state.copyWith(nearbyProperties: properties);
      },
    );
  }

  Future<void> _loadRecommendedProperties() async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;

    if (user == null || user.preferences == null) {
      return;
    }

    final prefs = user.preferences!;
    final minBudget = (prefs['min_budget'] as num?)?.toDouble() ?? 0;
    final maxBudget = (prefs['max_budget'] as num?)?.toDouble() ?? 100000;
    final dealbreakers = List<String>.from(prefs['dealbreakers'] ?? []);

    final result = await _getRecommendedProperties(
      GetRecommendedPropertiesParams(
        minBudget: minBudget,
        maxBudget: maxBudget,
        dealbreakers: dealbreakers,
      ),
    );

    result.fold((failure) => null, (properties) async {
      if (properties.isEmpty) {
        // FALLBACK: If no recommendations, fetch ALL verified properties
        final repo = ref.read(propertyRepositoryProvider);
        final allPropertiesResult = await repo.getVerifiedProperties();
        allPropertiesResult.fold((failure) => null, (allProps) {
          state = state.copyWith(recommendedProperties: allProps);
        });
      } else {
        state = state.copyWith(recommendedProperties: properties);
      }
    });
  }
}

final tenantHomeProvider =
    StateNotifierProvider.autoDispose<TenantHomeNotifier, TenantHomeState>((
      ref,
    ) {
      final repository = ref.watch(propertyRepositoryProvider);
      return TenantHomeNotifier(
        ref,
        GetNearbyProperties(repository),
        GetRecommendedProperties(repository),
      )..loadData();
    });
