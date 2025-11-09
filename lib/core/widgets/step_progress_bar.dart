import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final bool isSubmitting; // For the indeterminate (loading) state

  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.isSubmitting = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    if (totalSteps == 0) return const SizedBox.shrink();

    // Calculate progress, ensuring it's between 0.0 and 1.0
    final double progress = (currentStep + 1) / totalSteps;

    // Show indeterminate (loading) bar if submitting on the last step
    final bool showIndeterminate =
        isSubmitting && currentStep == totalSteps - 1;

    // Copied directly from your progress_bar.dart
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: showIndeterminate ? null : progress,
            color: const Color(0xFF32190D), // Active fill
            backgroundColor: const Color(
              0xFF32190D,
            ).withValues(alpha: 0.2), // Inactive track (fixed opacity)
            minHeight: 4, // Thicker bar
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
