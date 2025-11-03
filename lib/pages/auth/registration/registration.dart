// lib/auth/registration/registration.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'registration_controller.dart';
import 'widgets/progress_bar.dart';

class RegistrationPage extends ConsumerWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationControllerProvider);
    final controller = ref.read(registrationControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Progress Bar (under AppBar)
          const ProgressBar(),

          // 2. Current Step Content
          Expanded(
            child: state.steps.isEmpty
                ? const SizedBox.shrink()
                : state.steps[state.currentStep].builder(context),
          ),

          // 3. Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Back Button
                if (state.currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.back,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF32190D),
                        side: const BorderSide(color: Color(0xFF32190D)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Back'),
                    ),
                  ),

                if (state.currentStep > 0) const SizedBox(width: 12),

                // Next / Submit Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF32190D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      state.currentStep == state.steps.length - 1
                          ? 'Submit'
                          : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
