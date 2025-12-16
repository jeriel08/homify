// lib/auth/registration/steps/step_name.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/core/utils/toast_helper.dart';
import '../../controllers/registration_controller.dart';
import 'package:homify/core/theme/app_colors.dart';

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
  bool _triedNext = false;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController();
    _lastCtrl = TextEditingController();

    _loadSaved();
  }

  void _loadSaved() {
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

  void _update(String key, String value) {
    ref
        .read(registrationControllerProvider.notifier)
        .updateData(key, value.trim());
    if (_triedNext) setState(() => _triedNext = false);
  }

  bool get _hasFirstError => _triedNext && (_firstCtrl.text.trim().isEmpty);
  bool get _hasLastError => _triedNext && (_lastCtrl.text.trim().isEmpty);

  @override
  Widget build(BuildContext context) {
    // final controller = ref.read(registrationControllerProvider.notifier);
    final state = ref.watch(registrationControllerProvider);
    final isLastStep = state.currentStep == state.steps.length - 1;
    final isSubmitting = state.isSubmitting;

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
              color: AppColors.primary,
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
                  hasError: _hasFirstError,
                  onChanged: (v) => _update('first_name', v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  _lastCtrl,
                  'Last Name',
                  'Dela Cruz',
                  hasError: _hasLastError,
                  onChanged: (v) => _update('last_name', v),
                ),
              ),
            ],
          ),

          // Inline errors (only after Next)
          if (_triedNext && (_hasFirstError || _hasLastError))
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Both first and last name are required.',
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
                              final ok = await controller.next();
                              if (!ok && context.mounted) {
                                ToastHelper.warning(
                                  context,
                                  'Please fill out all required fields.',
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

Widget _buildField(
  TextEditingController ctrl,
  String label,
  String hint, {
  required bool hasError,
  required ValueChanged<String> onChanged,
}) {
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
        borderSide: BorderSide(
          color: hasError ? AppColors.error : AppColors.primary,
          width: hasError ? 2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: hasError ? AppColors.error : AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),
    cursorColor: AppColors.primary,
    onChanged: onChanged,
  );
}
