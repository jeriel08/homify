// lib/auth/registration/registration_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homify/auth/registration/steps/owner/step_amenities.dart';
import 'package:homify/auth/registration/steps/owner/step_images.dart';
import 'package:homify/auth/registration/steps/owner/step_location.dart';
import 'package:homify/auth/registration/steps/owner/step_property_info.dart';
import 'package:homify/auth/registration/steps/owner/step_property_type.dart';
import 'package:homify/auth/registration/steps/owner/step_rent_amount.dart';
import 'package:homify/auth/registration/steps/owner/step_rent_method.dart';
import 'package:homify/auth/registration/steps/step_account_type.dart';
import 'package:homify/auth/registration/steps/step_birthday.dart';
import 'package:homify/auth/registration/steps/step_email.dart';
import 'package:homify/auth/registration/steps/step_gender.dart';
import 'package:homify/auth/registration/steps/step_mobile.dart';
import 'package:homify/auth/registration/steps/step_name.dart';
import 'package:homify/auth/registration/steps/step_password.dart';
import 'package:homify/models/user_model.dart';

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

  RegistrationController() : super(RegistrationState()) {
    _buildSteps();
  }

  void _buildSteps() {
    // Placeholder – real steps added later
    final baseSteps = <RegistrationStep>[
      stepAccountType(),
      stepName(),
      stepBirthday(),
      stepGender(),
      stepMobile(),
      stepEmail(),
      stepPassword(),
    ];

    final ownerSteps = state.accountType == AccountType.owner
        ? <RegistrationStep>[
            stepPropertyInfo(),
            stepPropertyType(),
            stepRentMethod(),
            stepRentAmount(),
            stepAmenities(),
            stepLocation(),
            stepImages(),
          ] // Add later
        : <RegistrationStep>[];

    state = state.copyWith(steps: [...baseSteps, ...ownerSteps]);
  }

  void selectAccountType(AccountType type) {
    state = state.copyWith(
      accountType: type,
      formData: {'account_type': type.name},
    );
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
    state = RegistrationState(); // Creates a fresh, default state
    _buildSteps(); // Re-populates the initial steps
  }

  Future<void> submit() async {
    // Validate final step
    final isValid = await state.steps.last.validate.call(state.formData);
    if (!isValid) return;

    // Trigger the actual Firebase submission
    await _submit();
  }

  Future<void> _submit() async {
    debugPrint('Submitting registration data...');
    debugPrint(state.formData.toString());

    state = state.copyWith(isSubmitting: true, submitError: null);

    final data = state.formData;
    final password = data['password'] as String?;
    final email = data['email'] as String?;

    if (password == null || email == null) {
      state = state.copyWith(isSubmitting: false);
      return;
    }

    try {
      // 1. Auth (Firebase hashes password automatically)
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Build strongly‑typed user object
      final user = AppUser(
        uid: cred.user!.uid,
        accountType: _accountTypeFromString(data['account_type'] as String),
        firstName: data['first_name'] as String,
        lastName: data['last_name'] as String,
        birthday: data['birthday'] as String,
        gender: data['gender'] as String,
        mobile: data['mobile'] as String,
        email: email,
        createdAt:
            DateTime.now(), // placeholder – server timestamp will overwrite
      );

      // 3. Save to **users** collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set(user.toFirestore());

      state = state.copyWith(submitSuccess: true, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(submitError: e.toString(), isSubmitting: false);
    }
  }

  AccountType _accountTypeFromString(String raw) {
    return AccountType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => AccountType.tenant,
    );
  }
}

final registrationControllerProvider =
    StateNotifierProvider<RegistrationController, RegistrationState>((ref) {
      return RegistrationController();
    });
