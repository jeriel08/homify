import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/controllers/tenant_onboarding_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TenantOnboardingPage extends ConsumerStatefulWidget {
  const TenantOnboardingPage({super.key});

  @override
  ConsumerState<TenantOnboardingPage> createState() =>
      _TenantOnboardingPageState();
}

class _TenantOnboardingPageState extends ConsumerState<TenantOnboardingPage> {
  // We don't need a PageController anymore because we aren't using a PageView
  // We are rebuilding the body based on the current step index.
  // However, if you want animation, we can keep a simple AnimatedSwitcher.

  void _handleNext() async {
    final controller = ref.read(tenantOnboardingProvider.notifier);
    final state = ref.read(tenantOnboardingProvider);

    if (state.currentStep < 2) {
      controller.next();
      // ... animation code
    } else {
      // Submit
      final success = await controller.submit();
      if (success && mounted) {
        context.go('/tenant-success');
      } else if (mounted && state.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
      }
    }
  }

  void _handleBack() {
    ref.read(tenantOnboardingProvider.notifier).back();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tenantOnboardingProvider);
    final steps = state.steps;

    // Safety check if steps aren't loaded yet
    if (steps.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLastStep = state.currentStep == steps.length - 1;
    final currentStepWidget = steps[state.currentStep].builder(context);

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
                        color: Color(0xFF32190D),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (state.currentStep > 0) const Gap(16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (state.currentStep + 1) / steps.length,
                        backgroundColor: const Color(0xFFF9E5C5),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF32190D),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const Gap(16),
                  Text(
                    '${state.currentStep + 1}/${steps.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF32190D),
                    ),
                  ),
                ],
              ),
            ),

            // --- BODY (Dynamic Step) ---
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(state.currentStep),
                  child: currentStepWidget,
                ),
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
                    backgroundColor: const Color(0xFF32190D),
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
