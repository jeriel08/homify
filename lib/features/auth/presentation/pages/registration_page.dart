// lib/auth/registration/registration.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/presentation/controllers/registration_controller.dart';
import 'package:homify/features/auth/presentation/widgets/progress_bar.dart';
import 'package:homify/features/properties/presentation/pages/step_location.dart';
import 'tenant_success_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RegistrationPage extends ConsumerWidget {
  const RegistrationPage({super.key});

  Future<void> _showExitConfirmDialog(
    BuildContext context,
    RegistrationController controller,
  ) async {
    final bool? shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(dialogContext).textTheme,
            ),
          ),
          child: AlertDialog(
            title: const Text(
              'Discard Registration?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            content: const Text(
              'If you go back, all your progress will be lost.',
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              // "Cancel" button
              TextButton(
                onPressed: () {
                  // Pop the dialog, return 'false' (don't discard)
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancel'),
              ),
              // "Discard" button
              TextButton(
                onPressed: () {
                  // Pop the dialog, return 'true' (do discard)
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text(
                  'Discard',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );

    // If user tapped "Discard" (shouldDiscard is true)
    if (shouldDiscard == true && context.mounted) {
      controller.reset(); // Reset the state
      Navigator.of(context).pop(); // Manually pop the page
    }
    // Otherwise, user tapped "Cancel", so we do nothing.
  }

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

    final String locationStepTitle = stepLocation().title;

    final bool isLocationStep = state.steps.isEmpty
        ? false
        : state.steps[state.currentStep].title == locationStepTitle;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _showExitConfirmDialog(context, controller);
      },
      child: Scaffold(
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
        body: Stack(
          children: [
            Offstage(
              offstage: !isLocationStep,
              child: const GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(14.5995, 120.9842),
                  zoom: 12,
                ),
              ),
            ),
            Column(
              children: [
                // 1. Progress Bar
                const ProgressBar(),

                // 2. Current Step Content
                Expanded(
                  child: state.steps.isEmpty
                      ? const SizedBox.shrink()
                      : state.steps[state.currentStep].builder(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
