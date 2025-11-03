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
          const SizedBox(height: 8),

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
                // Tenant
                RadioListTile<AccountType>(
                  title: const Text(
                    'Tenant',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF32190D),
                    ),
                  ),
                  value: AccountType.tenant,
                  groupValue: _selected,
                  onChanged: (v) => _select(v, controller),
                  activeColor: const Color(0xFF32190D),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),

                // Owner
                RadioListTile<AccountType>(
                  title: const Text(
                    'Owner',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF32190D),
                    ),
                  ),
                  value: AccountType.owner,
                  groupValue: _selected,
                  onChanged: (v) => _select(v, controller),
                  activeColor: const Color(0xFF32190D),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
              ],
            ),
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
