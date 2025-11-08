// lib/auth/registration/widgets/progress_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/registration_controller.dart';

class ProgressBar extends ConsumerWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationControllerProvider);
    final steps = state.steps;
    final currentStep = state.currentStep;
    final isSubmitting = state.isSubmitting;

    if (steps.isEmpty) return const SizedBox.shrink();

    final double progress = (currentStep + 1) / steps.length;

    final bool showIndeterminate =
        isSubmitting && currentStep == steps.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: showIndeterminate ? null : progress,
            color: const Color(0xFF32190D), // Active fill
            backgroundColor: Color(
              0xFF32190D,
            ).withValues(alpha: 0.2), // Inactive track
            minHeight: 4, // Thicker bar
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
