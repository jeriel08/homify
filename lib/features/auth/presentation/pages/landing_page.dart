import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/services/location_service.dart';
import 'package:homify/features/auth/presentation/controllers/google_sign_in_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Request location permission as soon as the app starts (Landing Page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });
  }

  Future<void> _initLocation() async {
    final granted = await LocationService.requestAndSaveLocation();
    if (!mounted) return;

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location access needed for nearby searches. Enable in settings?',
          ),
        ),
      );
    }
  }

  void _handleGoogleSignIn() {
    ref.read(googleSignInControllerProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for Google Sign-In errors
    ref.listen<GoogleSignInState>(googleSignInControllerProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(googleSignInControllerProvider.notifier).clearError();
      }
    });

    final googleSignInState = ref.watch(googleSignInControllerProvider);

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
                // Google Sign-In
                ElevatedButton.icon(
                  onPressed: googleSignInState.isLoading
                      ? null
                      : _handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    backgroundColor: const Color(0xFFFFEDD4),
                    foregroundColor: const Color(0xFF32190D),
                  ),
                  icon: googleSignInState.isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Color(0xFF32190D),
                            strokeWidth: 3,
                          ),
                        )
                      : const FaIcon(FontAwesomeIcons.google),
                  label: const Text(
                    'Sign in with Google',
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
