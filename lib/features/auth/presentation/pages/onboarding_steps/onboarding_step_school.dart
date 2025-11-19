import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
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
              color: Color(0xFF32190D),
            ),
          ),
          const Gap(8),
          const Text(
            "We'll prioritize boarding houses near your campus.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Gap(32),
          DropdownButtonFormField<String>(
            value: state.selectedSchool,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Select University/College',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(LucideIcons.graduationCap),
            ),
            items: kDavaoSchools.map((school) {
              return DropdownMenuItem(
                value: school,
                child: Text(school, overflow: TextOverflow.ellipsis),
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
