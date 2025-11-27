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
  final List<PropertyEntity> allRecommendedProperties;
  final int displayedRecommendedCount;
  final String? error;

  const TenantHomeState({
    this.isLoading = false,
    this.nearbyProperties = const [],
    this.allRecommendedProperties = const [],
    this.displayedRecommendedCount = 10,
    this.error,
  });

  List<PropertyEntity> get displayedRecommendedProperties =>
      allRecommendedProperties.take(displayedRecommendedCount).toList();

  bool get hasMoreRecommendations =>
      displayedRecommendedCount < allRecommendedProperties.length;

  TenantHomeState copyWith({
    bool? isLoading,
    List<PropertyEntity>? nearbyProperties,
    List<PropertyEntity>? allRecommendedProperties,
    int? displayedRecommendedCount,
    String? error,
  }) {
    return TenantHomeState(
      isLoading: isLoading ?? this.isLoading,
      nearbyProperties: nearbyProperties ?? this.nearbyProperties,
      allRecommendedProperties:
          allRecommendedProperties ?? this.allRecommendedProperties,
      displayedRecommendedCount:
          displayedRecommendedCount ?? this.displayedRecommendedCount,
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
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Fetch Nearby Properties
      await _loadNearbyProperties();

      // 2. Fetch Recommended Properties
      await _loadRecommendedProperties();

      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void loadMoreRecommendations() {
    if (!mounted) return;
    if (state.hasMoreRecommendations) {
      state = state.copyWith(
        displayedRecommendedCount: state.displayedRecommendedCount + 10,
      );
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

    if (!mounted) return;

    result.fold(
      (failure) => null, // Handle error silently or log
      (properties) {
        if (mounted) {
          state = state.copyWith(nearbyProperties: properties);
        }
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

    if (!mounted) return;

    await result.fold((failure) async => null, (properties) async {
      if (!mounted) return;

      if (properties.isEmpty) {
        // FALLBACK: If no recommendations, fetch ALL verified properties
        final repo = ref.read(propertyRepositoryProvider);
        final allPropertiesResult = await repo.getVerifiedProperties();

        if (!mounted) return;

        allPropertiesResult.fold((failure) => null, (allProps) {
          if (mounted) {
            state = state.copyWith(
              allRecommendedProperties: allProps,
              displayedRecommendedCount: 10, // Reset count
            );
          }
        });
      } else {
        state = state.copyWith(
          allRecommendedProperties: properties,
          displayedRecommendedCount: 10, // Reset count
        );
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
