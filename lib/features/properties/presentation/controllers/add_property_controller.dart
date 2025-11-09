// lib/features/properties/presentation/controllers/add_property_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/core/entities/property_entity.dart';
import 'package:homify/features/auth/auth_providers.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_state.dart';
import 'package:homify/features/properties/properties_providers.dart';

import 'package:homify/features/properties/presentation/pages/steps/step_property_info.dart';
import 'package:homify/features/properties/presentation/pages/steps/step_property_type.dart';
import 'package:homify/features/properties/presentation/pages/steps/step_rent_method.dart';
import 'package:homify/features/properties/presentation/pages/steps/step_rent_amount.dart';
import 'package:homify/features/properties/presentation/pages/steps/step_amenities.dart';
import 'package:homify/features/properties/presentation/pages/steps/step_location.dart';
import 'package:homify/features/properties/presentation/pages/steps/step_images.dart';

class AddPropertyController extends StateNotifier<AddPropertyState> {
  final Ref _ref;

  AddPropertyController(this._ref) : super(AddPropertyState()) {
    _buildSteps();
  }

  void _buildSteps() {
    // These are all the steps for adding a property
    final propertySteps = <PropertyStep>[
      stepPropertyInfo(),
      stepPropertyType(),
      stepRentMethod(),
      stepRentAmount(),
      stepAmenities(),
      stepLocation(),
      stepImages(),
    ];

    state = state.copyWith(steps: propertySteps);
  }

  Future<bool> next() async {
    // You can add validation logic here later if you want
    // For now, we just move to the next step
    if (state.currentStep < state.steps.length - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
      // This is the last step, so we call submit
      await _submit();
    }
    return true;
  }

  void back() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateData(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(state.formData);
    newData[key] = value;
    state = state.copyWith(formData: newData);
  }

  void clearSubmitError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _submit() async {
    debugPrint("Submitting NEW PROPERTY data...");
    state = state.copyWith(isSubmitting: true, submitError: null);

    final data = state.formData;

    try {
      // 1. Get the currently logged-in user (the owner we just created)
      final currentUser = await _ref.read(getCurrentUserUseCaseProvider).call();

      if (currentUser == null) {
        throw Exception('No user found. Please log in again.');
      }

      final ownerUid = currentUser.uid;

      // 2. Build the PropertyEntity
      final propertyEntity = PropertyEntity(
        id: '', // Will be set by the data layer
        ownerUid: ownerUid,
        name: data['property_name'] as String,
        description: data['property_description'] as String,
        type: PropertyType.values.firstWhere(
          (e) => e.name == (data['property_type'] as String),
        ),
        rentChargeMethod: RentChargeMethod.values.firstWhere(
          (e) => e.name == (data['rent_charge_method'] as String),
        ),
        rentAmount: (data['rent_amount'] as num).toDouble(),
        amenities: List<String>.from(data['amenities'] ?? []),
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        imageUrls: [], // Will be set by the data layer
        createdAt: DateTime.now(),
        // --- THIS IS THE KEY FOR ADMIN VERIFICATION ---
        isVerified: false,
      );

      // 3. Get the image files
      final images = List<File>.from(data['images'] ?? []);

      // 4. Get the use case
      final addPropertyUseCase = _ref.read(addPropertyUseCaseProvider);

      // 5. Call the use case
      await addPropertyUseCase(propertyData: propertyEntity, images: images);

      // 6. Success!
      state = state.copyWith(submitSuccess: true, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(submitError: e.toString(), isSubmitting: false);
    }
  }
}

// Create the provider for our new controller
final addPropertyControllerProvider =
    StateNotifierProvider<AddPropertyController, AddPropertyState>((ref) {
      return AddPropertyController(ref);
    });
