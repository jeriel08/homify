import 'package:flutter/material.dart';
import 'package:homify/features/auth/presentation/controllers/tenant_onboarding_controller.dart';

class TenantOnboardingState {
  final int currentStep;
  final List<OnboardingStep> steps;
  final bool isSubmitting;
  final String? error;
  final String? selectedSchool;
  final RangeValues budgetRange;
  final List<String> selectedDealbreakers;

  TenantOnboardingState({
    this.currentStep = 0,
    this.steps = const [],
    this.isSubmitting = false,
    this.error,
    this.selectedSchool,
    this.budgetRange = const RangeValues(1500, 5000),
    this.selectedDealbreakers = const [],
  });

  TenantOnboardingState copyWith({
    int? currentStep,
    List<OnboardingStep>? steps,
    bool? isSubmitting,
    String? error,
    String? selectedSchool,
    RangeValues? budgetRange,
    List<String>? selectedDealbreakers,
  }) {
    return TenantOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      steps: steps ?? this.steps,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      selectedSchool: selectedSchool ?? this.selectedSchool,
      budgetRange: budgetRange ?? this.budgetRange,
      selectedDealbreakers: selectedDealbreakers ?? this.selectedDealbreakers,
    );
  }

  bool get isLoading => isSubmitting;

  // Helper to check if the current step is valid to proceed
  bool get isCurrentStepValid {
    switch (currentStep) {
      case 0: // School Step
        return selectedSchool != null && selectedSchool!.isNotEmpty;
      case 1: // Budget Step
        return true; // Always valid as it has defaults
      case 2: // Dealbreakers Step
        return true; // Optional
      default:
        return true;
    }
  }
}
