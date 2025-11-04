// lib/auth/registration/steps/step_account_type.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);
    final state = ref.watch(registrationControllerProvider);
    // Keep UI in sync if the user comes back
    _selected = state.accountType;

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
              color: const Color(0xFF32190D),
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
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: _selected != null
                    ? const Color(0xFF32190D)
                    : Colors.grey.shade300,
                width: _selected != null ? 2 : 1,
              ),
            ),
            color: _selected != null ? const Color(0xFFFFEDD4) : Colors.white,
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
                            color: Color(0xFF32190D),
                          ),
                        ),
                        trailing: Radio<AccountType>(
                          value: AccountType.tenant,
                          activeColor: Color(0xFF32190D),
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
                            color: Color(0xFF32190D),
                          ),
                        ),
                        trailing: Radio<AccountType>(
                          value: AccountType.owner,
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

              return Row(
                children: [
                  if (state.currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.back,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF32190D),
                          side: const BorderSide(color: Color(0xFF32190D)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (state.currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await controller.next();
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You must be 18 or older'),
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

  void _select(AccountType? value, RegistrationController controller) {
    if (value == null) return;
    setState(() => _selected = value);
    controller.selectAccountType(value);
  }
}
