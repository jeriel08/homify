import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/auth/presentation/controllers/tenant_onboarding_controller.dart';

OnboardingStep stepProfile() {
  return OnboardingStep(
    title: 'Profile',
    validate: (state) async {
      return state.selectedOccupation != null;
    },
    builder: (context) => const _ProfileStep(),
  );
}

class _ProfileStep extends ConsumerWidget {
  const _ProfileStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tenantOnboardingProvider);
    final controller = ref.read(tenantOnboardingProvider.notifier);

    final occupations = [
      'Student',
      'Working Professional',
      'Tourist / Traveler',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Which best describes you?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF32190D),
            ),
          ),
          const Gap(8),
          const Text(
            "This helps us tailor your search experience.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Gap(32),

          // Occupation Chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: occupations.map((role) {
              final isSelected = state.selectedOccupation == role;
              return ChoiceChip(
                label: Text(role),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) controller.selectOccupation(role);
                },
                selectedColor: const Color(0xFFE05725),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF32190D),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.shade300,
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
