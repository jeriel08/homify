// lib/auth/registration/steps/step_mobile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
    if (digits.startsWith('63') && digits.length == 13) {
      return '+63${digits.substring(2)}';
    } else if (digits.startsWith('0') && digits.length == 11) {
      return '+63${digits.substring(1)}';
    }
    return input; // fallback
  }

  void _onChanged(String value) {
    final clean = value.replaceAll(RegExp(r'\D'), '');
    String display = '';

    if (clean.startsWith('63') && clean.length > 2) {
      final part = clean.substring(2);
      display = '+63 ';
      if (part.isNotEmpty) {
        display += '${part.substring(0, part.length.clamp(0, 3))} ';
      }
      if (part.length > 3) {
        display += '${part.substring(3, part.length.clamp(3, 6))} ';
      }
      if (part.length > 6) {
        display += part.substring(6, part.length.clamp(6, 10));
      }
    } else if (clean.startsWith('0') && clean.length > 1) {
      final part = clean.substring(1);
      display = '0';
      if (part.isNotEmpty) {
        display += '${part.substring(0, part.length.clamp(0, 3))} ';
      }
      if (part.length > 3) {
        display += '${part.substring(3, part.length.clamp(3, 6))} ';
      }
      if (part.length > 6) {
        display += part.substring(6, part.length.clamp(6, 10));
      }
    } else {
      display = clean;
    }

    _controller.value = TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );

    final normalized = _normalize(clean);
    final isValid = _isValid(normalized);
    ref
        .read(registrationControllerProvider.notifier)
        .updateData('mobile', isValid ? normalized : null);
  }

  @override
  Widget build(BuildContext context) {
    // final controller = ref.read(registrationControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            "What's your mobile number?",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
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
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              hintText: '09123456789 or +639123456789',
              helperText:
                  "We’ll use this number to contact you about inquiries or updates.",
              helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              helperMaxLines: 2,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF32190D),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF32190D),
                  width: 2,
                ),
              ),
            ),
            cursorColor: const Color(0xFF32190D),
            onChanged: _onChanged,
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
                        final ok = await controller.next();
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid mobile number.',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF32190D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
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
                  if (state.currentStep > 0) const SizedBox(height: 12),

                  // Back Button (only if not first step)
                  if (state.currentStep > 0)
                    SizedBox(
                      width: double.infinity, // Full width
                      child: OutlinedButton(
                        onPressed: controller.back,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF32190D),
                          side: const BorderSide(color: Color(0xFF32190D)),
                          minimumSize: const Size.fromHeight(48),
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
