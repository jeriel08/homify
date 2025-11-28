import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/auth/presentation/controllers/tenant_onboarding_controller.dart';

const List<String> kTenantDealbreakers = [
  'Must have Wi-Fi',
  'Aircon',
  'No Curfew',
  'Visitors Allowed',
  'Private CR',
  'Cooking Allowed',
  'Pet Friendly',
];

OnboardingStep stepPreferences() {
  return OnboardingStep(
    title: 'Preferences',
    validate: (state) async => true, // Optional
    builder: (context) => const _PreferencesStep(),
  );
}

class _PreferencesStep extends ConsumerWidget {
  const _PreferencesStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tenantOnboardingProvider);
    final controller = ref.read(tenantOnboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Any must-haves?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF32190D),
            ),
          ),
          const Gap(8),
          const Text(
            "We'll highlight properties that match these.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Gap(32),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: kTenantDealbreakers.map((item) {
              final isSelected = state.selectedDealbreakers.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (_) => controller.toggleDealbreaker(item),
                selectedColor: const Color(0xFFFFEDD4),
                checkmarkColor: const Color(0xFF32190D),
                labelStyle: TextStyle(
                  color: const Color(0xFF32190D),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
