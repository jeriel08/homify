import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/auth/presentation/controllers/tenant_onboarding_controller.dart';

OnboardingStep stepBudget() {
  return OnboardingStep(
    title: 'Budget',
    validate: (state) async => true, // Always valid as it has defaults
    builder: (context) => const _BudgetStep(),
  );
}

class _BudgetStep extends ConsumerWidget {
  const _BudgetStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tenantOnboardingProvider);
    final controller = ref.read(tenantOnboardingProvider.notifier);

    String formatMoney(double val) => '₱${val.toInt()}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your monthly budget?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF32190D),
            ),
          ),
          const Gap(8),
          const Text(
            "Find a place that fits your allowance.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Gap(40),

          // Range Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatMoney(state.budgetRange.start),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE05725),
                ),
              ),
              const Text("-", style: TextStyle(color: Colors.grey)),
              Text(
                formatMoney(state.budgetRange.end),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE05725),
                ),
              ),
            ],
          ),
          const Gap(20),

          RangeSlider(
            values: state.budgetRange,
            min: 500,
            max: 20000,
            divisions: 39,
            activeColor: const Color(0xFFE05725),
            onChanged: (val) => controller.updateBudget(val),
          ),
        ],
      ),
    );
  }
}
