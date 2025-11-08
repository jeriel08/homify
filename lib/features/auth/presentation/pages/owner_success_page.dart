import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerRegistrationSuccess extends StatelessWidget {
  const OwnerRegistrationSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Your app's bg color
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon to show success
            const Icon(Icons.check_circle, size: 100, color: Color(0xFF32190D)),
            const SizedBox(height: 24),

            // 1. Your requested Header
            Text(
              'Registration Successful!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF32190D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 2. Your requested Subheader (refined to be shorter)
            Text(
              'Your property is now pending verification by our admin team before it can be seen by tenants.',
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
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32190D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('Go to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
