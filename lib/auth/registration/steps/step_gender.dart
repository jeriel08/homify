// lib/auth/registration/steps/step_gender.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

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

  @override
  void initState() {
    super.initState();
    // Restore saved value when the user comes back
    final saved =
        ref.read(registrationControllerProvider).formData['gender'] as String?;
    if (saved != null) {
      _selected = Gender.values.firstWhere((g) => g.name == saved);
    }
  }

  void _select(Gender? value, RegistrationController controller) {
    if (value == null) return;
    setState(() => _selected = value);
    controller.updateData('gender', value.name); // 'male' | 'female'
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);
    // final state = ref.watch(registrationControllerProvider);

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
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 24),

          // ONE CARD – ALL OPTIONS
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: const Color(0xFF32190D),
                width: _selected != null ? 2 : 1,
              ),
            ),
            color: const Color(0xFFFFEDD4),
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
                            color: Color(0xFF32190D),
                          ),
                        ),
                        trailing: Radio<Gender>(
                          value: Gender.male,
                          activeColor: Color(0xFF32190D),
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
                            color: Color(0xFF32190D),
                          ),
                        ),
                        trailing: Radio<Gender>(
                          value: Gender.female,
                          activeColor: Color(0xFF32190D),
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
                      onPressed: () async {
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
                        backgroundColor: const Color(0xFF32190D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text(
                        state.currentStep == state.steps.length - 1
                            ? 'Submit'
                            : 'Next',
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
                          foregroundColor: const Color(0xFF32190D),
                          side: const BorderSide(color: Color(0xFF32190D)),
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
