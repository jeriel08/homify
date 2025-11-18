import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/domain/usecases/get_owner_properties.dart';
import 'package:homify/features/properties/properties_providers.dart'; // Assuming you put the usecase provider here

// The State class
class OwnerDashboardState {
  final bool isLoading;
  final List<PropertyEntity> properties;
  final int totalFavorites;
  final int totalViews; // Optional placeholder
  final String? error;

  OwnerDashboardState({
    this.isLoading = true,
    this.properties = const [],
    this.totalFavorites = 0,
    this.totalViews = 0,
    this.error,
  });

  OwnerDashboardState copyWith({
    bool? isLoading,
    List<PropertyEntity>? properties,
    int? totalFavorites,
    String? error,
  }) {
    return OwnerDashboardState(
      isLoading: isLoading ?? this.isLoading,
      properties: properties ?? this.properties,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      error: error ?? this.error,
    );
  }
}

// The Notifier
class OwnerDashboardNotifier extends StateNotifier<OwnerDashboardState> {
  final GetOwnerProperties _getOwnerProperties;
  final String? _userId;

  OwnerDashboardNotifier({
    required GetOwnerProperties getOwnerProperties,
    required String? userId,
  }) : _getOwnerProperties = getOwnerProperties,
       _userId = userId,
       super(OwnerDashboardState()) {
    if (_userId != null) {
      loadDashboard();
    }
  }

  Future<void> loadDashboard() async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true);

    final result = await _getOwnerProperties(_userId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(), // Adjust based on your Failure class
      ),
      (properties) {
        // Calculate Stats
        final totalLikes = properties.fold(
          0,
          (sum, item) => sum + item.favoritesCount,
        );

        state = state.copyWith(
          isLoading: false,
          properties: properties,
          totalFavorites: totalLikes,
        );
      },
    );
  }
}

// The Provider
final ownerDashboardProvider =
    StateNotifierProvider.autoDispose<
      OwnerDashboardNotifier,
      OwnerDashboardState
    >((ref) {
      final authState = ref.watch(authStateProvider);
      final user = authState.value; // Get the current user model

      // Access the repository through your existing providers
      final repository = ref.watch(propertyRepositoryProvider);

      return OwnerDashboardNotifier(
        getOwnerProperties: GetOwnerProperties(repository),
        userId: user?.uid,
      );
    });
