import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/auth/presentation/providers/registration_flow_provider.dart';
import 'package:lottie/lottie.dart';

class OwnerRegistrationSuccess extends ConsumerWidget {
  const OwnerRegistrationSuccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Your app's bg color
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon to show success
            Lottie.asset(
              'assets/animations/DeliveryAddress.json',
              repeat: false,
              height: 250,
              width: 250,
            ),

            // 1. Your requested Header
            Text(
              'Account Created!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF32190D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 2. Your requested Subheader (refined to be shorter)
            Text(
              'Welcome, Owner! Your account is ready. Let\'s get your first property listed.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 3. Button to go to their dashboard
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(postLoginRedirectProvider.notifier).state =
                      '/create-property';
                  ref.invalidate(authStateProvider);
                  ref.read(justRegisteredProvider.notifier).state = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32190D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('List Your Property'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
