// lib/auth/registration/steps/step_account_type.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/auth/presentation/controllers/registration_controller.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/core/theme/app_colors.dart';

/// The very first registration step – choose Tenant or Owner.
RegistrationStep stepAccountType() {
  return RegistrationStep(
    title: 'Account Type',
    builder: (context) => const _AccountTypeStep(),
    // No validation needed – user must pick one, UI disables Next until chosen
    validate: (data) async => data['account_type'] != null,
  );
}

class _AccountTypeStep extends ConsumerStatefulWidget {
  const _AccountTypeStep();

  @override
  ConsumerState<_AccountTypeStep> createState() => _AccountTypeStepState();
}

class _AccountTypeStepState extends ConsumerState<_AccountTypeStep> {
  AccountType? _selected;
  bool _triedNext = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() {
    final saved =
        ref.read(registrationControllerProvider).formData['account_type']
            as String?;
    if (saved != null) {
      _selected = AccountType.values.firstWhere((e) => e.name == saved);
    }
  }

  void _select(AccountType? value, RegistrationController controller) {
    if (value == null) return;
    setState(() {
      _selected = value;
      _triedNext = false; // clear error when user picks
    });

    controller.selectAccountType(value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);
    final state = ref.watch(registrationControllerProvider);
    final isLastStep = state.currentStep == state.steps.length - 1;
    final isSubmitting = state.isSubmitting;

    // Keep UI in sync when navigating back
    final saved = state.formData['account_type'] as String?;
    if (saved != null && _selected?.name != saved) {
      _selected = AccountType.values.firstWhere((e) => e.name == saved);
    }

    final bool showError = _triedNext && _selected == null;
    final Color borderColor = showError ? AppColors.error : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Header
          Text(
            'How will you use Homify?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),

          // Sub-header
          Text(
            'Select whether you’re looking for a place or posting one.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 32),

          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: borderColor,
                width: showError ? 2 : (_selected != null ? 2 : 1),
              ),
            ),
            color: AppColors.secondary,
            child: Column(
              children: [
                RadioGroup<AccountType>(
                  groupValue: _selected,
                  onChanged: (v) => _select(v, controller),
                  child: const Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Tenant',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        trailing: Radio<AccountType>(
                          value: AccountType.tenant,
                          activeColor: AppColors.primary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Owner',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        trailing: Radio<AccountType>(
                          value: AccountType.owner,
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

          if (showError)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please select an account type.',
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
                                  'Please select an account type.',
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
                  if (state.currentStep > 0) const SizedBox(height: 12),

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
