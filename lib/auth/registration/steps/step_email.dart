// lib/auth/registration/steps/step_email.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/auth/registration/registration_controller.dart';

RegistrationStep stepEmail() {
  return RegistrationStep(
    title: 'Email Address',
    builder: (context) => const _EmailStep(),
    validate: (data) async {
      final email = data['email'] as String?;
      if (email == null || email.isEmpty) return false;
      final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-]+(\.[\w\-]+)*$');
      return regex.hasMatch(email);
    },
  );
}

class _EmailStep extends ConsumerStatefulWidget {
  const _EmailStep();

  @override
  ConsumerState<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends ConsumerState<_EmailStep> {
  late final TextEditingController _controller;
  bool _triedNext = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    final saved =
        ref.read(registrationControllerProvider).formData['email'] as String?;
    if (saved != null) {
      _controller.text = saved;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValid(String email) {
    if (email.isEmpty) return false;
    // Use the same regex as your main validate function
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-]+(\.[\w\-]+)*$');
    return regex.hasMatch(email);
  }

  bool get _hasError => _triedNext && !_isValid(_controller.text.trim());

  void _onChanged(String value) {
    final trimmed = value.trim();
    _controller.value = TextEditingValue(
      text: trimmed,
      selection: TextSelection.collapsed(offset: trimmed.length),
    );

    if (_triedNext) {
      setState(() => _triedNext = false);
    }

    final isValid = _isValid(trimmed);
    ref
        .read(registrationControllerProvider.notifier)
        .updateData('email', isValid ? trimmed : null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            Text(
              "What's your email address?",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF32190D),
              ),
            ),
            const SizedBox(height: 4),

            Text(
              "We’ll send important updates to this email.",
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'you@example.com',
                helperText:
                    "Stay connected — we’ll notify you through email when someone reaches out.",
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
                    color: _hasError ? Colors.red : const Color(0xFF32190D),
                    width: _hasError ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: _hasError ? Colors.red : const Color(0xFF32190D),
                    width: 2,
                  ),
                ),
                // Also good to define the error borders explicitly
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              cursorColor: const Color(0xFF32190D),
              onChanged: _onChanged,
            ),

            const SizedBox(height: 20),

            // Buttons – Full width, Back below Next
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(registrationControllerProvider);
                final controller = ref.read(
                  registrationControllerProvider.notifier,
                );

                return Column(
                  children: [
                    // Next / Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _triedNext = true;
                          });

                          final ok = await controller.next();
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid email address',
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
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    if (state.currentStep > 0) const SizedBox(height: 8),

                    // Back
                    if (state.currentStep > 0)
                      SizedBox(
                        width: double.infinity,
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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
