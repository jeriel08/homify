// lib/auth/registration/steps/step_mobile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/auth/presentation/controllers/registration_controller.dart';
import 'package:homify/core/theme/app_colors.dart';

RegistrationStep stepMobile() {
  return RegistrationStep(
    title: 'Mobile Number',
    builder: (context) => const _MobileStep(),
    validate: (data) async {
      final mobile = data['mobile'] as String?;
      if (mobile == null) return false;
      // Accept: +639xxxxxxxxx OR 09xxxxxxxxx
      return RegExp(r'^(\+63|0)9\d{9}$').hasMatch(mobile);
    },
  );
}

class _MobileStep extends ConsumerStatefulWidget {
  const _MobileStep();

  @override
  ConsumerState<_MobileStep> createState() => _MobileStepState();
}

class _MobileStepState extends ConsumerState<_MobileStep> {
  late final TextEditingController _controller;
  bool _triedNext = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadSaved();
  }

  void _loadSaved() {
    final saved =
        ref.read(registrationControllerProvider).formData['mobile'] as String?;
    if (saved != null && _isValid(saved)) {
      _controller.text = _formatDisplay(saved);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValid(String input) {
    return RegExp(r'^(\+63|0)9\d{9}$').hasMatch(input);
  }

  String _formatDisplay(String raw) {
    if (raw.startsWith('+63')) {
      final digits = raw.substring(3);
      return '+63 ${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    } else {
      final digits = raw.substring(1);
      return '0${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
  }

  String _normalize(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('63') && digits.length == 12) {
      return '+63${digits.substring(2)}';
    } else if (digits.startsWith('0') && digits.length == 11) {
      return '+63${digits.substring(1)}';
    }
    return input; // fallback
  }

  bool get _hasError => _triedNext && !_isValid(_normalize(_controller.text));

  @override
  Widget build(BuildContext context) {
    // final controller = ref.read(registrationControllerProvider.notifier);
    final state = ref.watch(registrationControllerProvider);
    final isLastStep = state.currentStep == state.steps.length - 1;
    final isSubmitting = state.isSubmitting;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            Text(
              "What's your mobile number?",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              "Enter the mobile number where you can be contacted.",
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [_MobileInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                hintText: '09123456789 or +639123456789',
                helperText:
                    "We’ll use this number to contact you about inquiries or updates.",
                helperStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                helperMaxLines: 2,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: _hasError ? AppColors.error : AppColors.primary,
                    width: _hasError ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: _hasError ? AppColors.error : AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
              ),
              cursorColor: AppColors.primary,
              onChanged: (v) {
                final normalized = _normalize(v);
                ref
                    .read(registrationControllerProvider.notifier)
                    .updateData('mobile', normalized);
                if (_triedNext) setState(() => _triedNext = false);
              },
            ),

            const SizedBox(height: 20),

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
                          setState(() => _triedNext = true);
                          final ok = await controller.next();
                          if (!ok && context.mounted) {
                            ToastHelper.warning(
                              context,
                              'Please enter a valid mobile number.',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(44),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(isLastStep ? 'Submit' : 'Next'),
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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _MobileInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';

    if (clean.startsWith('63')) {
      formatted = '+63';
      final rest = clean.substring(2);
      if (rest.isNotEmpty) {
        formatted += " ${rest.substring(0, rest.length.clamp(0, 3))}";
      }
      if (rest.length > 3) {
        formatted += " ${rest.substring(3, rest.length.clamp(3, 6))}";
      }
      if (rest.length > 6) {
        formatted += " ${rest.substring(6, rest.length.clamp(6, 10))}";
      }
    } else if (clean.startsWith('0')) {
      formatted = '0';
      final rest = clean.substring(1);
      if (rest.isNotEmpty) {
        formatted += rest.substring(0, rest.length.clamp(0, 3));
      }
      if (rest.length > 3) {
        formatted += " ${rest.substring(3, rest.length.clamp(3, 6))}";
      }
      if (rest.length > 6) {
        formatted += " ${rest.substring(6, rest.length.clamp(6, 10))}";
      }
    } else {
      formatted = clean;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
