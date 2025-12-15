import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/auth/presentation/controllers/tenant_onboarding_controller.dart';

import 'package:homify/core/theme/app_colors.dart';

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

    if (state.currentStep < state.steps.length - 1) {
      controller.next();
      // ... animation code
    } else {
      // Submit
      final success = await controller.submit();
      if (!mounted) return;

      if (success) {
        // Force navigation to success page
        context.go('/tenant-success');
        return; // Prevent any further code execution after navigation
      } else if (mounted && state.error != null) {
        ToastHelper.error(context, 'Error: ${state.error}');
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Progress) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (state.currentStep + 1) / steps.length,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ),

            // --- BODY (Dynamic Step) ---
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: KeyedSubtree(
                    key: ValueKey(state.currentStep),
                    child: currentStepWidget,
                  ),
                ),
              ),
            ),

            // --- FOOTER (Buttons) ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading || !state.isCurrentStepValid
                          ? null
                          : _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
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
                  if (state.currentStep > 0) ...[
                    const Gap(12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: state.isLoading ? null : _handleBack,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
