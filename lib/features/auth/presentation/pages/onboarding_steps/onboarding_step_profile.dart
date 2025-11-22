import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/auth/presentation/controllers/tenant_onboarding_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Reusing your list
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

OnboardingStep stepProfile() {
  return OnboardingStep(
    title: 'Profile',
    validate: (state) async {
      if (state.selectedOccupation == null) return false;
      if (state.selectedOccupation == 'Student') {
        return state.selectedSchool != null && state.selectedSchool!.isNotEmpty;
      }
      return true;
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

          const Gap(32),

          // Conditional School Dropdown
          // Only show if "Student" is selected
          AnimatedOpacity(
            opacity: state.selectedOccupation == 'Student' ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: state.selectedOccupation == 'Student'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Where do you study?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF32190D),
                        ),
                      ),
                      const Gap(16),
                      DropdownButtonFormField<String>(
                        initialValue: state.selectedSchool,
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
                            child: Text(
                              school,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.selectSchool(val);
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(), // Hide if not student
          ),
        ],
      ),
    );
  }
}
