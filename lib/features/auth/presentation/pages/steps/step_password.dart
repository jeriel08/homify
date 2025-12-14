// lib/auth/registration/steps/step_password.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/auth/presentation/controllers/registration_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:gap/gap.dart';

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
      final hasSpecial = RegExp(
        r'[!@#$%^&*()_+\-=\[\]{};:\x27",.<>?/\\|`~]',
      ).hasMatch(pass);
      return pass.length >= 8 && hasLetter && hasNumber && hasSpecial;
    },
  );
}

enum PasswordStrength { weak, medium, strong }

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
  bool _triedNext = false;

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

    if (_triedNext) {
      setState(() => _triedNext = false);
    } else {
      setState(() {});
    }
  }

  // Password requirement checks
  bool get _hasMinLength => _passCtrl.text.length >= 8;
  bool get _hasLetter => RegExp(r'[A-Za-z]').hasMatch(_passCtrl.text);
  bool get _hasNumber => RegExp(r'\d').hasMatch(_passCtrl.text);
  bool get _hasSpecial => RegExp(
    r'[!@#$%^&*()_+\-=\[\]{};:\x27",.<>?/\\|`~]',
  ).hasMatch(_passCtrl.text);

  PasswordStrength get _passwordStrength {
    final pass = _passCtrl.text;
    if (pass.isEmpty) return PasswordStrength.weak;

    int score = 0;
    if (_hasMinLength) score++;
    if (_hasLetter) score++;
    if (_hasNumber) score++;
    if (_hasSpecial) score++;

    if (score >= 4) return PasswordStrength.strong;
    if (score >= 3) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  String? _getPasswordError() {
    final pass = _passCtrl.text;

    if (!_triedNext && pass.isEmpty) return null;

    if (pass.isEmpty) return "Password is required";
    if (!_hasMinLength) return "Use at least 8 characters";
    if (!_hasLetter) return "Include at least one letter";
    if (!_hasNumber) return "Include at least one number";
    if (!_hasSpecial) return "Include at least one special character";
    return null;
  }

  String? _getConfirmError() {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (_getPasswordError() != null) return null;

    if (!_triedNext && confirm.isEmpty) return null;

    if (confirm.isEmpty) return "Please confirm your password";
    if (pass != confirm) return "Passwords don't match";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final passError = _getPasswordError();
    final confirmError = _getConfirmError();
    final hasPassError = passError != null;
    final hasConfirmError = confirmError != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            Text(
              "Create a password",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              "Use at least 8 characters with letters, numbers, and special characters.",
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
                  color: AppColors.primary,
                ),
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
                    color: hasPassError ? AppColors.error : AppColors.primary,
                    width: hasPassError ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: hasPassError ? AppColors.error : AppColors.primary,
                    width: 2,
                  ),
                ),
                errorText: passError,
                errorStyle: const TextStyle(color: AppColors.error),
              ),
              cursorColor: AppColors.primary,
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
                  icon: Icon(
                    _showConfirm ? LucideIcons.eye : LucideIcons.eyeOff,
                  ),
                  onPressed: () => setState(() => _showConfirm = !_showConfirm),
                  color: AppColors.primary,
                ),
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
                    color: hasConfirmError
                        ? AppColors.error
                        : AppColors.primary,
                    width: hasConfirmError ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: hasConfirmError
                        ? AppColors.error
                        : AppColors.primary,
                    width: 2,
                  ),
                ),
                errorText: confirmError,
                errorStyle: const TextStyle(color: AppColors.error),
              ),
              cursorColor: AppColors.primary,
              onChanged: (v) {
                _update('confirm_password', v);
                setState(() {});
              },
            ),

            const SizedBox(height: 16),

            // Password Strength Indicator
            if (_passCtrl.text.isNotEmpty) ...[
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: 16),
              _buildRequirementsList(),
            ],

            const SizedBox(height: 20),

            // Buttons
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(registrationControllerProvider);
                final controller = ref.read(
                  registrationControllerProvider.notifier,
                );
                final isLastStep = state.currentStep == state.steps.length - 1;
                final isSubmitting = state.isSubmitting;

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null // disables the button while submitting
                            : () async {
                                setState(() => _triedNext = true);

                                final ok = await controller.next();
                                if (!ok && context.mounted) {
                                  final msg =
                                      _getPasswordError() ??
                                      _getConfirmError() ??
                                      "Please fix password issues";
                                  ToastHelper.warning(context, msg);
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
                            : Text(
                                isLastStep ? 'Submit' : 'Next',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),

                    if (state.currentStep > 0) const SizedBox(height: 8),

                    if (state.currentStep > 0)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : controller.back,
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

  Widget _buildPasswordStrengthIndicator() {
    final strength = _passwordStrength;

    Color color;
    String label;
    double progress;

    switch (strength) {
      case PasswordStrength.weak:
        color = Colors.red;
        label = 'Weak';
        progress = 0.33;
        break;
      case PasswordStrength.medium:
        color = Colors.orange;
        label = 'Medium';
        progress = 0.66;
        break;
      case PasswordStrength.strong:
        color = Colors.green;
        label = 'Strong';
        progress = 1.0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Gap(6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequirementItem('At least 8 characters', _hasMinLength),
          const Gap(8),
          _buildRequirementItem('Contains a letter', _hasLetter),
          const Gap(8),
          _buildRequirementItem('Contains a number', _hasNumber),
          const Gap(8),
          _buildRequirementItem(
            'Contains a special character (!@#\$...)',
            _hasSpecial,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? LucideIcons.circleCheck : LucideIcons.circle,
          size: 16,
          color: isMet
              ? Colors.green
              : AppColors.primary.withValues(alpha: 0.5),
        ),
        const Gap(8),
        Text(
          text,
          style: TextStyle(
            color: isMet ? Colors.green.shade700 : AppColors.primary,
            fontSize: 13,
            fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
