// lib/auth/registration/steps/step_gender.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/presentation/controllers/registration_controller.dart';
import 'package:homify/core/theme/app_colors.dart';

enum Gender { male, female }

RegistrationStep stepGender() {
  return RegistrationStep(
    title: 'Gender',
    builder: (context) => const _GenderStep(),
    validate: (data) async => data['gender'] != null,
  );
}

class _GenderStep extends ConsumerStatefulWidget {
  const _GenderStep();

  @override
  ConsumerState<_GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends ConsumerState<_GenderStep> {
  Gender? _selected;
  bool _triedNext = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() {
    final saved =
        ref.read(registrationControllerProvider).formData['gender'] as String?;
    if (saved != null) {
      _selected = Gender.values.firstWhere((g) => g.name == saved);
    }
  }

  void _select(Gender? value, RegistrationController controller) {
    if (value == null) return;
    setState(() {
      _selected = value;
      _triedNext = false;
    });
    controller.updateData('gender', value.name); // 'male' | 'female'
  }

  bool get _hasError => _triedNext && _selected == null;

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);
    final state = ref.watch(registrationControllerProvider);
    final isLastStep = state.currentStep == state.steps.length - 1;
    final isSubmitting = state.isSubmitting;

    // Sync if user navigates back
    final saved = state.formData['gender'] as String?;
    if (saved != null && _selected?.name != saved) {
      _selected = Gender.values.firstWhere((g) => g.name == saved);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Header
          Text(
            'What\'s your gender?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // ONE CARD – ALL OPTIONS
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: _hasError ? AppColors.error : AppColors.primary,
                width: _hasError ? 2 : (_selected != null ? 2 : 1),
              ),
            ),
            color: AppColors.secondary,
            child: Column(
              children: [
                RadioGroup(
                  onChanged: (v) => _select(v, controller),
                  groupValue: _selected,
                  child: const Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Male',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        trailing: Radio<Gender>(
                          value: Gender.male,
                          activeColor: AppColors.primary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Female',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        trailing: Radio<Gender>(
                          value: Gender.female,
                          activeColor: AppColors.primary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Inline error
          if (_hasError)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 12),
              child: Text(
                'Please select a gender.',
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),

          const SizedBox(height: 24),

          // Buttons moved here (from registration.dart)
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(registrationControllerProvider);
              final controller = ref.read(
                registrationControllerProvider.notifier,
              );

              return Column(
                children: [
                  // Next / Submit Button
                  SizedBox(
                    width: double.infinity, // Full width
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setState(() => _triedNext = true);
                              if (_hasError) return;

                              final ok = await controller.next();
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a gender.'),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text(
                        isLastStep ? 'Submit' : 'Next',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  // Space between buttons
                  if (state.currentStep > 0) const SizedBox(height: 8),

                  // Back Button (only if not first step)
                  if (state.currentStep > 0)
                    SizedBox(
                      width: double.infinity, // Full width
                      child: OutlinedButton(
                        onPressed: controller.back,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
