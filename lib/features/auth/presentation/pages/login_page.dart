import 'package:flutter/material.dart';
import 'package:homify/features/auth/presentation/pages/registration_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:homify/core/services/location_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Focus nodes for text fields
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Track focus state to update label color
  Color _emailLabelColor = const Color(0xFF32190D);
  Color _passwordLabelColor = const Color(0xFF32190D);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });

    // Listen to focus changes
    _emailFocus.addListener(() {
      setState(() {
        _emailLabelColor = _emailFocus.hasFocus
            ? const Color(0xFF32190D) // Active color (darker)
            : const Color(
                0xFF32190D,
              ).withValues(alpha: 0.6); // Inactive (faded)
      });
    });

    _passwordFocus.addListener(() {
      setState(() {
        _passwordLabelColor = _passwordFocus.hasFocus
            ? const Color(0xFF32190D)
            : const Color(0xFF32190D).withValues(alpha: 0.6);
      });
    });
  }

  Future<void> _initLocation() async {
    final granted = await LocationService.requestAndSaveLocation();

    // The "mounted" check is still important!
    if (!mounted) return;

    // This "context" now belongs to LoginPage, which is *inside* the MaterialApp
    // so this will work!
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location access granted! Ready to find homes near you.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location access needed for nearby searches. Enable in settings?',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // Helper to build consistent TextField
  Widget _buildTextField({
    required String label,
    required FocusNode focusNode,
    required Color labelColor,
    bool obscureText = false,
    String? helperText,
  }) {
    return TextField(
      focusNode: focusNode,
      obscureText: obscureText,
      cursorColor: const Color(0xFF32190D),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: Theme.of(context).inputDecorationTheme.helperStyle,
        labelStyle: Theme.of(
          context,
        ).inputDecorationTheme.labelStyle?.copyWith(color: labelColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF32190D), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF32190D), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF8F0,
      ), // Light creamy background for Homify
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Homify_Logo_Transparent.png',
                  height: 240,
                  width: 240,
                ),
                const SizedBox(height: 4),

                // Email / Phone Field
                _buildTextField(
                  label: 'Email or Phone Number',
                  focusNode: _emailFocus,
                  labelColor: _emailLabelColor,
                ),
                const SizedBox(height: 20),

                // Password Field
                _buildTextField(
                  label: 'Password',
                  focusNode: _passwordFocus,
                  labelColor: _passwordLabelColor,
                  obscureText: true,
                  helperText: 'Forgot Password? Tap Here.',
                ),

                const SizedBox(height: 48),

                // Log in Button
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle login
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

                // Google Sign-In
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle Google sign-in
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    backgroundColor: const Color(0xFFFFEDD4),
                    foregroundColor: const Color(0xFF32190D),
                  ),
                  icon: const Icon(LucideIcons.chromium),
                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 48),

                const Text('Don\'t have an account yet?'),
                const SizedBox(height: 4),

                // Create Account Button
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const RegistrationPage(), // ← open registration
                      ),
                    );
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
