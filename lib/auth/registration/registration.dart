// lib/auth/registration/registration.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'registration_controller.dart';
import 'widgets/progress_bar.dart';
import 'tenant_success.dart';

class RegistrationPage extends ConsumerWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationControllerProvider);
    final controller = ref.read(registrationControllerProvider.notifier);

    if (state.submitSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TenantRegistrationSuccess()),
        );
      });
    }

    if (state.submitError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.submitError!),
            backgroundColor: Colors.red.shade700,
          ),
        );
        controller.clearSubmitError(); // clear so it doesn’t repeat
      });
    }

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
        ],
      ),
    );
  }
}
