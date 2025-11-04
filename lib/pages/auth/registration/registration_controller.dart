// lib/auth/registration/registration_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/pages/auth/registration/steps/step_account_type.dart';
import 'package:homify/pages/auth/registration/steps/step_birthday.dart';
import 'package:homify/pages/auth/registration/steps/step_name.dart';

enum AccountType { tenant, owner }

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

  RegistrationState({
    this.currentStep = 0,
    this.accountType,
    this.formData = const {},
    this.steps = const [],
  });

  RegistrationState copyWith({
    int? currentStep,
    AccountType? accountType,
    Map<String, dynamic>? formData,
    List<RegistrationStep>? steps,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      accountType: accountType ?? this.accountType,
      formData: formData ?? this.formData,
      steps: steps ?? this.steps,
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
    ];

    final ownerSteps = state.accountType == AccountType.owner
        ? <RegistrationStep>[] // Add later
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

  Future<void> _submit() async {
    debugPrint('Final Data: ${state.formData}');
    // TODO: Call backend
  }
}

final registrationControllerProvider =
    StateNotifierProvider<RegistrationController, RegistrationState>((ref) {
      return RegistrationController();
    });
