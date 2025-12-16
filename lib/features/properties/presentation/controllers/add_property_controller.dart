// lib/features/properties/presentation/controllers/add_property_controller.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_state.dart';
import 'package:homify/features/properties/properties_providers.dart';

// Import Steps
import 'package:homify/features/properties/presentation/pages/steps/step_property_info.dart';
import 'package:homify/features/properties/presentation/pages/steps/step_property_type.dart';

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
    final propertySteps = <PropertyStep>[
      stepPropertyInfo(),
      stepPropertyType(),
      stepRentAmount(),
      stepAmenities(),
      stepLocation(),
      stepImages(),
    ];
    state = state.copyWith(steps: propertySteps);
  }

  Future<bool> next() async {
    if (state.currentStep < state.steps.length - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
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
      final currentUser = await _ref.read(getCurrentUserUseCaseProvider).call();
      if (currentUser == null) throw Exception('No user found.');
      final ownerUid = currentUser.uid;

      final propertyEntity = PropertyEntity(
        id: '',
        ownerUid: ownerUid,
        name: data['property_name'] as String,
        description: data['property_description'] as String,
        type: PropertyType.values.firstWhere(
          (e) => e.name == (data['property_type'] as String),
        ),
        rentChargeMethod: RentChargeMethod.perMonth,
        rentAmount: (data['rent_amount'] as num).toDouble(),
        amenities: List<String>.from(data['amenities'] ?? []),
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        imageUrls: [],
        createdAt: DateTime.now(),
        isVerified: false,
      );

      final images = List<File>.from(data['images'] ?? []);
      final addPropertyUseCase = _ref.read(addPropertyUseCaseProvider);

      // 1. Add Property
      await addPropertyUseCase(propertyData: propertyEntity, images: images);

      // 2. MARK ONBOARDING AS COMPLETE
      // This is the critical link that unlocks the Router
      await FirebaseFirestore.instance.collection('users').doc(ownerUid).update(
        {'onboarding_complete': true},
      );

      debugPrint("Onboarding marked as complete for owner: $ownerUid");

      // 4. Force refresh of the user provider so Router sees the new status
      _ref.invalidate(currentUserProvider);
      // Wait a bit for the provider to update
      await Future.delayed(const Duration(milliseconds: 500));

      // 5. Success
      state = state.copyWith(submitSuccess: true, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(submitError: e.toString(), isSubmitting: false);
    }
  }
}

// Changed to autoDispose so form clears on exit
final addPropertyControllerProvider =
    StateNotifierProvider.autoDispose<AddPropertyController, AddPropertyState>((
      ref,
    ) {
      return AddPropertyController(ref);
    });
