import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/controllers/tenant_onboarding_controller.dart'; // Ensure this path is correct
import 'package:homify/features/auth/presentation/pages/onboarding_steps/onboarding_step_preferences.dart';
import 'package:homify/features/auth/presentation/pages/onboarding_steps/onboarding_step_school.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TenantOnboardingPage extends ConsumerStatefulWidget {
  const TenantOnboardingPage({super.key});

  @override
  ConsumerState<TenantOnboardingPage> createState() =>
      _TenantOnboardingPageState();
}

class _TenantOnboardingPageState extends ConsumerState<TenantOnboardingPage> {
  final PageController _pageController = PageController();

  // Brand Colors
  static const Color primary = Color(0xFF32190D);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color surface = Color(0xFFF9E5C5);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() async {
    final controller = ref.read(tenantOnboardingProvider.notifier);
    final state = ref.read(tenantOnboardingProvider);

    if (state.currentStep < 2) {
      // Move to next step
      controller.next();
      _pageController.animateToPage(
        state.currentStep + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit
      final success = await controller.submit();
      if (success && mounted) {
        context.go('/home');
      } else if (mounted && state.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
      }
    }
  }

  void _handleBack() {
    final state = ref.read(tenantOnboardingProvider);
    final controller = ref.read(tenantOnboardingProvider.notifier);

    if (state.currentStep > 0) {
      controller.back();
      _pageController.animateToPage(
        state.currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tenantOnboardingProvider);
    final isLastStep = state.currentStep == 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Progress) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (state.currentStep > 0)
                    IconButton(
                      onPressed: _handleBack,
                      icon: const Icon(
                        LucideIcons.arrowLeft,
                        color: textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (state.currentStep > 0) const Gap(16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (state.currentStep + 1) / 3,
                        backgroundColor: surface,
                        valueColor: const AlwaysStoppedAnimation(primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const Gap(16),
                  Text(
                    '${state.currentStep + 1}/3',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // --- BODY (PageView) ---
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: const [
                  _SchoolStep(),
                  _BudgetStep(),
                  _PreferencesStep(),
                ],
              ),
            ),

            // --- FOOTER (Buttons) ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading || !state.isCurrentStepValid
                      ? null
                      : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isLastStep ? 'Finish Setup' : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// STEP 1: SCHOOL SELECTION
// ==========================================
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
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE05725),
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(LucideIcons.graduationCap),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: kDavaoSchools.map((school) {
              return DropdownMenuItem(
                value: school,
                child: Text(
                  school,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
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

// ==========================================
// STEP 2: BUDGET RANGE
// ==========================================
class _BudgetStep extends ConsumerWidget {
  const _BudgetStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tenantOnboardingProvider);
    final controller = ref.read(tenantOnboardingProvider.notifier);

    // Formatting helper for currency
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

          // Display Current Range
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9E5C5).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatMoney(state.budgetRange.start),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE05725),
                  ),
                ),
                const Text("-", style: TextStyle(color: Colors.grey)),
                Text(
                  formatMoney(state.budgetRange.end),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE05725),
                  ),
                ),
              ],
            ),
          ),

          const Gap(32),

          // Slider
          RangeSlider(
            values: state.budgetRange,
            min: 500,
            max: 20000,
            divisions: 39, // Steps of 500
            activeColor: const Color(0xFFE05725),
            inactiveColor: Colors.grey.shade300,
            labels: RangeLabels(
              formatMoney(state.budgetRange.start),
              formatMoney(state.budgetRange.end),
            ),
            onChanged: (RangeValues values) {
              controller.updateBudget(values);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₱500',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '₱20k+',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// STEP 3: PREFERENCES (DEALBREAKERS)
// ==========================================
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
                // Styling to match your Amenities step
                selectedColor: const Color(0xFFFFEDD4),
                checkmarkColor: const Color(0xFF32190D),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: const Color(0xFF32190D),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF32190D)
                        : Colors.grey.shade300,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
