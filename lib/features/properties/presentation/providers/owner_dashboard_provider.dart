import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/domain/usecases/get_owner_properties.dart';
import 'package:homify/features/properties/domain/usecases/update_property.dart';
import 'package:homify/features/properties/domain/usecases/delete_property.dart';
import 'package:homify/features/properties/domain/usecases/delete_property_provider.dart';
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
  final UpdateProperty _updateProperty;
  final DeleteProperty _deleteProperty;
  final String? _userId;

  OwnerDashboardNotifier({
    required GetOwnerProperties getOwnerProperties,
    required UpdateProperty updateProperty,
    required DeleteProperty deleteProperty,
    required String? userId,
  }) : _getOwnerProperties = getOwnerProperties,
       _updateProperty = updateProperty,
       _deleteProperty = deleteProperty,
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

  Future<void> updateProperty(
    String propertyId,
    Map<String, dynamic> updates,
  ) async {
    final params = UpdatePropertyParams(
      propertyId: propertyId,
      name: updates['name'] as String?,
      description: updates['description'] as String?,
      type: updates['type'] != null
          ? PropertyType.values.firstWhere((e) => e.name == updates['type'])
          : null,
      rentAmount: updates['rentAmount'] as double?,
      rentChargeMethod: updates['rentChargeMethod'] != null
          ? RentChargeMethod.values.firstWhere(
              (e) => e.name == updates['rentChargeMethod'],
            )
          : null,
      amenities: updates['amenities'] != null
          ? List<String>.from(updates['amenities'])
          : null,
      imageUrls: updates['imageUrls'] != null
          ? List<String>.from(updates['imageUrls'])
          : null,
    );

    final result = await _updateProperty(params);

    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (updatedProperty) {
        // Update the property in the list
        final updatedList = state.properties.map((p) {
          return p.id == propertyId ? updatedProperty : p;
        }).toList();

        // Recalculate total favorites
        final totalLikes = updatedList.fold(
          0,
          (sum, item) => sum + item.favoritesCount,
        );

        state = state.copyWith(
          properties: updatedList,
          totalFavorites: totalLikes,
        );
      },
    );
  }

  Future<void> deleteProperty(String propertyId, String reason) async {
    final params = DeletePropertyParams(propertyId: propertyId, reason: reason);
    final result = await _deleteProperty(params);

    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (_) {
        // Remove the property from the list
        final updatedList = state.properties
            .where((p) => p.id != propertyId)
            .toList();

        // Recalculate total favorites
        final totalLikes = updatedList.fold(
          0,
          (sum, item) => sum + item.favoritesCount,
        );

        state = state.copyWith(
          properties: updatedList,
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
      final updateProperty = ref.watch(updatePropertyUseCaseProvider);
      final deleteProperty = ref.watch(deletePropertyUseCaseProvider);

      return OwnerDashboardNotifier(
        getOwnerProperties: GetOwnerProperties(repository),
        updateProperty: updateProperty,
        deleteProperty: deleteProperty,
        userId: user?.uid,
      );
    });
