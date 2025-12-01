// lib/auth/registration/registration.dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/app_colors.dart';
// import 'package:go_router/go_router.dart';
// import 'package:homify/core/entities/user_entity.dart';
// import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/core/presentation/widgets/step_progress_bar.dart';
import 'package:homify/features/auth/presentation/controllers/registration_controller.dart';
// import 'package:homify/features/auth/presentation/widgets/progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  bool _isReverse = false;

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
  Widget build(BuildContext context) {
    final state = ref.watch(registrationControllerProvider);
    final controller = ref.read(registrationControllerProvider.notifier);

    // Listen for step changes to determine direction
    ref.listen(registrationControllerProvider, (previous, next) {
      if (previous != null && next.currentStep != previous.currentStep) {
        _isReverse = next.currentStep < previous.currentStep;
      }
    });

    ref.listen<RegistrationState>(registrationControllerProvider, (
      previous,
      next,
    ) {
      if (next.submitError != null && previous?.submitError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.submitError!),
            backgroundColor: Colors.red,
          ),
        );
        controller.clearSubmitError();
      }

      if (next.submitSuccess && previous?.submitSuccess != true) {
        context.go('/verify-email');
      }
    });

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
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // 1. Progress Bar
            if (state.steps.isNotEmpty)
              StepProgressBar(
                totalSteps: state.steps.length,
                currentStep: state.currentStep,
                isSubmitting: state.isSubmitting,
              ),

            // 2. Current Step Content
            Expanded(
              child: state.steps.isEmpty
                  ? const SizedBox.shrink()
                  : PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 500),
                      reverse: _isReverse,
                      transitionBuilder:
                          (
                            Widget child,
                            Animation<double> primaryAnimation,
                            Animation<double> secondaryAnimation,
                          ) {
                            return SharedAxisTransition(
                              animation: primaryAnimation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType:
                                  SharedAxisTransitionType.horizontal,
                              fillColor: Colors.transparent,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: child,
                              ),
                            );
                          },
                      child: KeyedSubtree(
                        key: ValueKey(state.currentStep),
                        child: state.steps[state.currentStep].builder(context),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
