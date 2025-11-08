// lib/auth/registration/registration_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/core/entities/property_entity.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/auth_providers.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_account_type.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_birthday.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_email.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_gender.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_mobile.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_name.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_password.dart';
import 'package:homify/features/properties/presentation/pages/step_amenities.dart';
import 'package:homify/features/properties/presentation/pages/step_images.dart';
import 'package:homify/features/properties/presentation/pages/step_location.dart';
import 'package:homify/features/properties/presentation/pages/step_property_info.dart';
import 'package:homify/features/properties/presentation/pages/step_property_type.dart';
import 'package:homify/features/properties/presentation/pages/step_rent_amount.dart';
import 'package:homify/features/properties/presentation/pages/step_rent_method.dart';
import 'package:homify/features/properties/properties_providers.dart';

class RegistrationStep {
  final String title;
  final Widget Function(BuildContext context) builder;
  final Future<bool> Function(Map<String, dynamic> data) validate;

  RegistrationStep({
    required this.title,
    required this.builder,
    required this.validate,
  });
}

class RegistrationState {
  final int currentStep;
  final AccountType? accountType;
  final Map<String, dynamic> formData;
  final List<RegistrationStep> steps;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitError;

  RegistrationState({
    this.currentStep = 0,
    this.accountType,
    this.formData = const {},
    this.steps = const [],
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitError,
  });

  RegistrationState copyWith({
    int? currentStep,
    AccountType? accountType,
    Map<String, dynamic>? formData,
    List<RegistrationStep>? steps,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      accountType: accountType ?? this.accountType,
      formData: formData ?? this.formData,
      steps: steps ?? this.steps,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: submitError ?? this.submitError,
    );
  }
}

class RegistrationController extends StateNotifier<RegistrationState> {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final Ref _ref;

  RegistrationController(this._ref) : super(RegistrationState()) {
    _buildSteps();
  }

  void _buildSteps() {
    // 1. These steps are always required
    final baseSteps = <RegistrationStep>[
      stepAccountType(),
      stepName(),
      stepBirthday(),
      stepGender(),
      stepMobile(),
      stepEmail(),
      stepPassword(),
    ];

    // 2. Add owner steps ONLY if that type is selected
    final ownerSteps = state.accountType == AccountType.owner
        ? <RegistrationStep>[
            stepPropertyInfo(),
            stepPropertyType(),
            stepRentMethod(),
            stepRentAmount(),
            stepAmenities(),
            stepLocation(),
            stepImages(),
          ]
        : <RegistrationStep>[];

    state = state.copyWith(steps: [...baseSteps, ...ownerSteps]);
  }

  void selectAccountType(AccountType type) {
    state = state.copyWith(
      accountType: type,
      formData: {'account_type': type.name},
      currentStep: 0, // Reset to step 0
    );
    // Rebuild the step list with or without owner steps
    _buildSteps();
  }

  Future<bool> next() async {
    _isLoading = true;
    state = state.copyWith();
    final step = state.steps[state.currentStep];
    final valid = await step.validate(state.formData);
    if (!valid) return false;

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
    state = state.copyWith(submitError: null);
  }

  void reset() {
    state = RegistrationState();
    _buildSteps();
  }

  Future<void> submit() async {
    // Validate final step
    final isValid = await state.steps.last.validate.call(state.formData);
    if (!isValid) return;

    // Trigger the actual Firebase submission
    await _submit();
  }

  Future<void> _submit() async {
    debugPrint("${state.formData}");
    debugPrint('Submitting registration data...');
    state = state.copyWith(isSubmitting: true, submitError: null);

    final data = state.formData;
    final password = data['password'] as String?;
    final email = data['email'] as String?;

    if (password == null || email == null) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: 'Email or password missing.',
      );
      return;
    }

    try {
      // --- PART 1: ALWAYS REGISTER THE USER ---
      final registerUser = _ref.read(registerUserUseCaseProvider);

      final newUser = await registerUser(
        email: email,
        password: password,
        userData: data, // Pass all form data
      );

      // --- PART 2: IF OWNER, REGISTER THE PROPERTY ---
      if (newUser.accountType == AccountType.owner) {
        debugPrint('User is owner, now adding property...');

        // 1. Build the PropertyEntity
        final propertyEntity = PropertyEntity(
          id: '', // Will be set by the data layer
          ownerUid: newUser.uid, // <-- USE THE NEW USER'S ID
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
        );

        // 2. Get the image files (from your *fixed* step_images.dart)
        final images = List<File>.from(data['images'] ?? []);

        // 3. Get the use case
        final addPropertyUseCase = _ref.read(addPropertyUseCaseProvider);

        // 4. Call the use case!
        await addPropertyUseCase(propertyData: propertyEntity, images: images);
      }

      // 5. Success for everyone
      state = state.copyWith(submitSuccess: true, isSubmitting: false);
    } catch (e) {
      // 6. Handle failure
      state = state.copyWith(submitError: e.toString(), isSubmitting: false);
    }
  }
}

final registrationControllerProvider =
    StateNotifierProvider<RegistrationController, RegistrationState>((ref) {
      return RegistrationController(ref);
    });
