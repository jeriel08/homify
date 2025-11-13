// lib/auth/registration/registration_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_account_type.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_birthday.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_email.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_gender.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_mobile.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_name.dart';
import 'package:homify/features/auth/presentation/pages/steps/step_password.dart';

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

  int _findStepIndexByTitle(String title) {
    return state.steps.indexWhere((step) => step.title == title);
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

    state = state.copyWith(steps: [...baseSteps]);
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
    debugPrint('Submitting user registration data...');
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
      // --- STEP 1: Register the user ---
      final registerUser = _ref.read(registerUserUseCaseProvider);
      final userModel = await registerUser(
        email: email,
        password: password,
        userData: data,
      );

      // --- STEP 2: LOG THEM IN AUTOMATICALLY ---
      final loginUser = _ref.read(loginUserUseCaseProvider);
      await loginUser.call(email: email, password: password);

      final getCurrentUser = _ref.read(getCurrentUserUseCaseProvider);
      await getCurrentUser();

      debugPrint(
        'REGISTRATION: Firebase login success. UID: ${FirebaseAuth.instance.currentUser?.uid}',
      );

      debugPrint('REGISTRATION: Firestore user loaded: ${userModel.uid}');
      debugPrint('REGISTRATION: Account Type: ${userModel.accountType}');
      debugPrint('REGISTRATION: Full UserModel: $userModel');

      // --- STEP 3: Success! Let router handle navigation ---
      state = state.copyWith(
        submitSuccess: true,
        isSubmitting: false,
        accountType: userModel.accountType,
      );

      final successPath = userModel.accountType == AccountType.owner
          ? '/owner-success?from=registration'
          : '/tenant-success?from=registration';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use context from RegistrationPage? We'll do it in the page
      });
    } catch (e) {
      final error = e.toString();
      int errorStep = state.currentStep;

      if (error.contains('email')) {
        errorStep = _findStepIndexByTitle('Email Address');
      } else if (error.contains('mobile number')) {
        errorStep = _findStepIndexByTitle('Mobile Number');
      }

      if (errorStep == -1) errorStep = state.currentStep;

      state = state.copyWith(
        submitError: error,
        isSubmitting: false,
        currentStep: errorStep,
      );
    }
  }
}

final registrationControllerProvider =
    StateNotifierProvider<RegistrationController, RegistrationState>((ref) {
      return RegistrationController(ref);
    });
