// lib/auth/registration/steps/step_name.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

/// Step 2 – First & Last Name
RegistrationStep stepName() {
  return RegistrationStep(
    title: 'Name',
    builder: (context) => const _NameStep(),
    validate: (data) async {
      final first = (data['first_name'] as String?)?.trim();
      final last = (data['last_name'] as String?)?.trim();
      return first != null &&
          first.isNotEmpty &&
          last != null &&
          last.isNotEmpty;
    },
  );
}

class _NameStep extends ConsumerStatefulWidget {
  const _NameStep();

  @override
  ConsumerState<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends ConsumerState<_NameStep> {
  late TextEditingController _firstCtrl;
  late TextEditingController _lastCtrl;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController();
    _lastCtrl = TextEditingController();

    // Pre-fill if data exists (e.g., coming back)
    final data = ref.read(registrationControllerProvider).formData;
    _firstCtrl.text = data['first_name'] ?? '';
    _lastCtrl.text = data['last_name'] ?? '';
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            'What’s your name?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 24),

          // Inside build() → after the header text
          Row(
            children: [
              Expanded(
                child: _buildField(
                  _firstCtrl,
                  'First Name',
                  'Juan',
                  controller,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  _lastCtrl,
                  'Last Name',
                  'Dela Cruz',
                  controller,
                ),
              ),
            ],
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
                              content: Text(
                                'Please fill out all required fields.',
                              ),
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

Widget _buildField(
  TextEditingController ctrl,
  String label,
  String hint,
  RegistrationController controller,
) {
  return TextField(
    controller: ctrl,
    textCapitalization: TextCapitalization.words,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF32190D), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF32190D), width: 2),
      ),
    ),
    cursorColor: const Color(0xFF32190D),
    onChanged: (v) {
      final key = label == 'First Name' ? 'first_name' : 'last_name';
      controller.updateData(key, v.trim());
    },
  );
}
