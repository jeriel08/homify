import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/features/auth/presentation/controllers/tenant_onboarding_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Hardcoded list for simplicity
const List<String> kDavaoSchools = [
  'Ateneo de Davao University',
  'University of Mindanao (Matina)',
  'University of Mindanao (Bolton)',
  'USEP (Obrero)',
  'Davao Doctors College',
  'San Pedro College',
  'Brokenshire College',
  'Holy Cross of Davao College',
  'Mapúa Malayan Colleges Mindanao',
  'UIC (Main)',
  'UIC (Bajada)',
];

OnboardingStep stepSchool() {
  return OnboardingStep(
    title: 'School',
    validate: (state) async =>
        state.selectedSchool != null && state.selectedSchool!.isNotEmpty,
    builder: (context) => const _SchoolStep(),
  );
}

class _SchoolStep extends ConsumerWidget {
  const _SchoolStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tenantOnboardingProvider);
    final controller = ref.read(tenantOnboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Where do you study?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Gap(8),
          const Text(
            "We'll prioritize boarding houses near your campus.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Gap(32),
          DropdownButtonFormField<String>(
            initialValue: state.selectedSchool,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              labelText: 'Select University/College',
              labelStyle: const TextStyle(fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                LucideIcons.graduationCap,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            items: kDavaoSchools.map((school) {
              return DropdownMenuItem(
                value: school,
                child: Text(
                  school,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.selectSchool(val);
            },
          ),
        ],
      ),
    );
  }
}
