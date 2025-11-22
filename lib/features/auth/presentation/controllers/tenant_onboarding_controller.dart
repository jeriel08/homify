import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/auth/presentation/pages/onboarding_steps/onboarding_step_budget.dart';
import 'package:homify/features/auth/presentation/pages/onboarding_steps/onboarding_step_preferences.dart';
import 'package:homify/features/auth/presentation/pages/onboarding_steps/onboarding_step_profile.dart';
import 'package:homify/features/auth/presentation/pages/onboarding_steps/onboarding_step_school.dart';

// 1. Define the Step Structure (Same pattern as Registration)
class OnboardingStep {
  final String title;
  final Widget Function(BuildContext context) builder;
  final Future<bool> Function(TenantOnboardingState state) validate;

  OnboardingStep({
    required this.title,
    required this.builder,
    required this.validate,
  });
}

// 2. Define the State
class TenantOnboardingState {
  final int currentStep;
  final List<OnboardingStep> steps;
  final bool isSubmitting;
  final String? error;

  // Data Fields
  final String? selectedOccupation;
  final String? selectedSchool;
  final RangeValues budgetRange;
  final List<String> selectedDealbreakers;

  TenantOnboardingState({
    this.currentStep = 0,
    this.steps = const [],
    this.isSubmitting = false,
    this.error,
    this.selectedOccupation,
    this.selectedSchool,
    this.budgetRange = const RangeValues(1500, 5000),
    this.selectedDealbreakers = const [],
  });

  TenantOnboardingState copyWith({
    int? currentStep,
    List<OnboardingStep>? steps,
    bool? isSubmitting,
    String? error,
    String? selectedOccupation,
    String? selectedSchool,
    RangeValues? budgetRange,
    List<String>? selectedDealbreakers,
  }) {
    return TenantOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      steps: steps ?? this.steps,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      selectedOccupation: selectedOccupation ?? this.selectedOccupation,
      selectedSchool: selectedSchool ?? this.selectedSchool,
      budgetRange: budgetRange ?? this.budgetRange,
      selectedDealbreakers: selectedDealbreakers ?? this.selectedDealbreakers,
    );
  }

  bool get isLoading => isSubmitting;

  bool get isCurrentStepValid {
    if (steps.isEmpty) return false;

    if (currentStep == 0) {
      if (selectedOccupation == null) return false;
      if (selectedOccupation == 'Student' &&
          (selectedSchool == null || selectedSchool!.isEmpty)) {
        return false;
      }
    }
    return true;
  }
}

// 3. The Controller
class TenantOnboardingController extends StateNotifier<TenantOnboardingState> {
  TenantOnboardingController() : super(TenantOnboardingState()) {
    _buildSteps();
  }

  void _buildSteps() {
    final steps = <OnboardingStep>[
      stepProfile(),
      stepBudget(),
      stepPreferences(),
    ];
    state = state.copyWith(steps: steps);
  }

  void selectOccupation(String occupation) {
    String? newSchool = state.selectedSchool;
    if (occupation != 'Student') {
      newSchool = null;
    }
    state = state.copyWith(
      selectedOccupation: occupation,
      selectedSchool: newSchool,
      error: null,
    );
  }

  void selectSchool(String school) {
    state = state.copyWith(selectedSchool: school, error: null);
  }

  void updateBudget(RangeValues range) {
    state = state.copyWith(budgetRange: range);
  }

  void toggleDealbreaker(String item) {
    final currentList = List<String>.from(state.selectedDealbreakers);
    if (currentList.contains(item)) {
      currentList.remove(item);
    } else {
      currentList.add(item);
    }
    state = state.copyWith(selectedDealbreakers: currentList);
  }

  // --- NAVIGATION ---
  Future<bool> next() async {
    final step = state.steps[state.currentStep];
    final isValid = await step.validate(state);

    if (!isValid) {
      state = state.copyWith(error: "Please complete this step.");
      return false;
    }

    if (state.currentStep < state.steps.length - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1, error: null);
      return true;
    } else {
      return await submit();
    }
  }

  void back() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, error: null);
    }
  }

  // --- SUBMIT ---
  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      final dataToSave = {
        'occupation': state.selectedOccupation,
        'school': state.selectedSchool,
        'preferences': {
          'min_budget': state.budgetRange.start,
          'max_budget': state.budgetRange.end,
          'dealbreakers': state.selectedDealbreakers,
        },
        'onboarding_complete': true,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(dataToSave);

      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final tenantOnboardingProvider =
    StateNotifierProvider.autoDispose<
      TenantOnboardingController,
      TenantOnboardingState
    >((ref) {
      return TenantOnboardingController();
    });
