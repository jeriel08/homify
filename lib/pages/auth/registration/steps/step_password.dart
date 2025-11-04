// lib/auth/registration/steps/step_password.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../registration_controller.dart';

RegistrationStep stepPassword() {
  return RegistrationStep(
    title: 'Password',
    builder: (context) => const _PasswordStep(),
    validate: (data) async {
      final pass = data['password'] as String?;
      final confirm = data['confirm_password'] as String?;
      if (pass == null || confirm == null) return false;
      if (pass != confirm) return false;
      final hasLetter = RegExp(r'[A-Za-z]').hasMatch(pass);
      final hasNumber = RegExp(r'\d').hasMatch(pass);
      return pass.length >= 8 && hasLetter && hasNumber;
    },
  );
}

class _PasswordStep extends ConsumerStatefulWidget {
  const _PasswordStep();

  @override
  ConsumerState<_PasswordStep> createState() => _PasswordStepState();
}

class _PasswordStepState extends ConsumerState<_PasswordStep> {
  late final TextEditingController _passCtrl;
  late final TextEditingController _confirmCtrl;
  bool _showPass = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _passCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
    final data = ref.read(registrationControllerProvider).formData;
    _passCtrl.text = data['password'] ?? '';
    _confirmCtrl.text = data['confirm_password'] ?? '';
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _update(String key, String value) {
    ref.read(registrationControllerProvider.notifier).updateData(key, value);
  }

  String? _getErrorMessage() {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pass.isEmpty || confirm.isEmpty) return null;
    if (pass != confirm) return "Passwords don’t match";
    if (pass.length < 8) return "Use at least 8 characters";
    if (!RegExp(r'[A-Za-z]').hasMatch(pass))
      return "Include at least one letter";
    if (!RegExp(r'\d').hasMatch(pass)) return "Include at least one number";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final error = _getErrorMessage();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            "Create a password",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 4),

          Text(
            "Use at least 8 characters with a mix of letters and numbers.",
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),

          // Password
          TextField(
            controller: _passCtrl,
            obscureText: !_showPass,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(_showPass ? LucideIcons.eye : LucideIcons.eyeOff),
                onPressed: () => setState(() => _showPass = !_showPass),
                color: const Color(0xFF32190D),
              ),
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
              errorText: error,
              errorStyle: const TextStyle(color: Colors.red),
            ),
            cursorColor: const Color(0xFF32190D),
            onChanged: (v) {
              _update('password', v);
              setState(() {}); // trigger error update
            },
          ),

          const SizedBox(height: 16),

          // Confirm Password
          TextField(
            controller: _confirmCtrl,
            obscureText: !_showConfirm,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(_showConfirm ? LucideIcons.eye : LucideIcons.eyeOff),
                onPressed: () => setState(() => _showConfirm = !_showConfirm),
                color: const Color(0xFF32190D),
              ),
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
            onChanged: (v) {
              _update('confirm_password', v);
              setState(() {});
            },
          ),

          const SizedBox(height: 20),

          // Buttons
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(registrationControllerProvider);
              final controller = ref.read(
                registrationControllerProvider.notifier,
              );

              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await controller.next();
                        if (!ok && context.mounted) {
                          final msg =
                              _getErrorMessage() ??
                              "Please fix password issues";
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
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
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  if (state.currentStep > 0) const SizedBox(height: 12),

                  if (state.currentStep > 0)
                    SizedBox(
                      width: double.infinity,
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
