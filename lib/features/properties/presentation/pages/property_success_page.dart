// lib/features/properties/presentation/pages/property_success_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class PropertySuccessPage extends StatelessWidget {
  const PropertySuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This UI is copied from your original owner_success_page.dart
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Success.json',
              repeat: false,
              height: 250,
              width: 250,
            ),

            // 1. Header
            Text(
              'Property Listed!', // <-- NEW HEADER
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF32190D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 2. Subheader (This is from your original file)
            Text(
              'Your boarding house has been submitted for verification. You can now track its status on your dashboard.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 3. Button (This is from your original file)
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
