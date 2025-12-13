import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homify/core/presentation/widgets/step_progress_bar.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/auth/presentation/providers/registration_flow_provider.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_controller.dart';
// import 'package:homify/features/auth/presentation/widgets/progress_bar.dart';

class AddPropertyPage extends ConsumerStatefulWidget {
  const AddPropertyPage({super.key});

  @override
  ConsumerState<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends ConsumerState<AddPropertyPage> {
  bool _isReverse = false;

  // This dialog prevents the owner from skipping this step
  Future<void> _showExitConfirmDialog(BuildContext context) async {
    final bool? shouldExit = await showDialog<bool>(
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
              'Property Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            content: const Text(
              'You must add a property to continue using the app as an owner. Do you want to exit setup?',
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );

    // If user tapped "Exit", navigate them back to the landing page
    if (shouldExit == true && context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if we have a redirect intent
      final redirectIntent = ref.read(postLoginRedirectProvider);
      if (redirectIntent != null) {
        // Clear the intent so we don't get stuck in a loop
        ref.read(postLoginRedirectProvider.notifier).state = null;
      }
    });

    // 1. Watch our NEW controller
    final state = ref.watch(addPropertyControllerProvider);
    final controller = ref.read(addPropertyControllerProvider.notifier);

    // Listen for step changes to determine direction
    ref.listen(addPropertyControllerProvider, (previous, next) {
      if (previous != null && next.currentStep != previous.currentStep) {
        _isReverse = next.currentStep < previous.currentStep;
      }
    });

    // 2. Listen for navigation and errors
    ref.listen(addPropertyControllerProvider, (previous, next) {
      if (next.submitError != null && previous?.submitError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.submitError!),
            backgroundColor: Colors.red.shade700,
          ),
        );
        controller.clearSubmitError();
      }

      // 3. On success, go to the Owner Success Page
      if (next.submitSuccess && previous?.submitSuccess == false) {
        // This is where we send them to the final success page
        context.go('/property-success');
      }
    });

    // Check if user is already onboarded
    final currentUserAsync = ref.watch(currentUserProvider);
    final isOnboarding = currentUserAsync.value?.onboardingComplete == false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (state.currentStep == 0) {
          if (isOnboarding) {
            // If onboarding, show the strict exit dialog
            _showExitConfirmDialog(context);
          } else {
            // If just adding a property, confirm discard
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Discard Property?'),
                content: const Text(
                  'Are you sure you want to discard this new property?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      context.pop(); // Go back
                    },
                    child: const Text(
                      'Discard',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          // Otherwise, just go back one step
          controller.back();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Add Your Property', // New title
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            // 1. Progress Bar (You'll need to adapt this)
            // You can pass the current step and total steps
            if (state.steps.isNotEmpty)
              StepProgressBar(
                totalSteps: state.steps.length,
                currentStep: state.currentStep,
                isSubmitting: state.isSubmitting,
              ),

            // 2. Current Step Content
            Expanded(
              child: state.steps.isEmpty
                  ? const Center(child: CircularProgressIndicator())
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
