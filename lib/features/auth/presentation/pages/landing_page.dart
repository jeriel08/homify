import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Light creamy background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo
                Image.asset(
                  'assets/images/Homify_Icon_Transparent.png',
                  height: 240,
                  width: 240,
                ),

                // 2. Title
                Text(
                  'Welcome to Homify!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF32190D),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Subtitle (Here's a great alternative!)
                Text(
                  'Find your next home, or list your property with ease.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 48),

                // 4. Log in Button (Primary Action)
                ElevatedButton.icon(
                  onPressed: () {
                    // GoRouter navigation
                    context.push('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    backgroundColor: const Color(0xFF32190D),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(LucideIcons.logIn),
                  label: const Text(
                    'Log in',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 12),

                // 5. Create Account Button (Secondary Action)
                OutlinedButton(
                  onPressed: () {
                    context.push('/register');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    side: const BorderSide(color: Color(0xFF32190D)),
                    foregroundColor: const Color(0xFF32190D),
                  ),
                  child: const Text(
                    'Create New Account',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Divider(),
                    Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Divider(),
                  ],
                ),

                // 6. Continue as Guest Button (Tertiary Action)
                TextButton(
                  onPressed: () {
                    // GoRouter navigation to the app's home
                    context.go('/home');
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    foregroundColor: const Color(0xFF32190D),
                  ),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
