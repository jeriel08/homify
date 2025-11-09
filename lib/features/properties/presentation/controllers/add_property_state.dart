import 'package:flutter/material.dart';

// We can re-use your RegistrationStep logic, or create a new one.
// Let's create a new, slightly simpler one for clarity.
class PropertyStep {
  final String title;
  final Widget Function(BuildContext context) builder;
  final Future<bool> Function(Map<String, dynamic> data) validate;

  PropertyStep({
    required this.title,
    required this.builder,
    required this.validate,
  });
}

class AddPropertyState {
  final int currentStep;
  final Map<String, dynamic> formData;
  final List<PropertyStep> steps;

  // State for submission
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitError;

  AddPropertyState({
    this.currentStep = 0,
    this.formData = const {},
    this.steps = const [],
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitError,
  });

  // copyWith method to create new states
  AddPropertyState copyWith({
    int? currentStep,
    Map<String, dynamic>? formData,
    List<PropertyStep>? steps,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
    // Helper to clear the error
    bool clearError = false,
  }) {
    return AddPropertyState(
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
      steps: steps ?? this.steps,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: clearError ? null : submitError ?? this.submitError,
    );
  }
}
