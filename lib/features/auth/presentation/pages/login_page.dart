import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:homify/core/services/location_service.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/controllers/login_controller.dart';
import 'package:homify/features/auth/presentation/controllers/google_sign_in_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscure = true;

  @override
  void initState() {
    super.initState();

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

  void _submitLogin() {
    // First, validate the form
    if (_formKey.currentState?.validate() ?? false) {
      // If valid, get the values
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Call the controller's login method
      ref.read(loginControllerProvider.notifier).login(email, password);
    }
  }

  void _submitGoogleLogin() {
    ref.read(googleSignInControllerProvider.notifier).signInWithGoogle();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper to build consistent TextField
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? helperText,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      cursorColor: const Color(0xFF32190D),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        helperText: helperText,
        helperStyle: Theme.of(context).inputDecorationTheme.helperStyle,
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
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
    final loginState = ref.watch(loginControllerProvider);
    final googleSignInState = ref.watch(googleSignInControllerProvider);

    final loginController = ref.read(loginControllerProvider.notifier);

    final isEitherLoading = loginState.isLoading || googleSignInState.isLoading;

    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        // Show an error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        loginController.clearError(); // Clear error after showing
      }
      if (next.loginSuccess) {}
    });

    ref.listen<GoogleSignInState>(googleSignInControllerProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null) {
        // Show the error message (e.g., "account-exists-with-different-credential")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        // Clear the error after showing
        ref.read(googleSignInControllerProvider.notifier).clearError();
      }
      if (next.signInSuccess) {}
    });

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color(0xFF32190D),
        backgroundColor: Color(0xFFFFF8F0),
        toolbarHeight: 28,
      ),
      backgroundColor: const Color(
        0xFFFFF8F0,
      ), // Light creamy background for Homify
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Homify_Logo_Transparent.png',
                    height: 240,
                    width: 240,
                  ),
                  const SizedBox(height: 20),

                  // Email / Phone Field
                  _buildTextField(
                    label: 'Email or Phone Number',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: _isPasswordObscure,
                    helperText: 'Forgot Password? Tap Here.',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscure
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye,
                        color: const Color(0xFF32190D).withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscure = !_isPasswordObscure;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Log in Button
                  ElevatedButton.icon(
                    onPressed: loginState.isLoading ? null : _submitLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      backgroundColor: const Color(0xFF32190D),
                      foregroundColor: Colors.white,
                    ),
                    icon: loginState.isLoading
                        ? Container(
                            // Show loading spinner
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(LucideIcons.logIn),
                    label: const Text(
                      'Log in',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Google Sign-In
                  ElevatedButton.icon(
                    onPressed: isEitherLoading ? null : _submitGoogleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      backgroundColor: const Color(0xFFFFEDD4),
                      foregroundColor: const Color(0xFF32190D),
                    ),
                    icon:
                        googleSignInState
                            .isLoading // <-- Specific to this button
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
                      'Continue with Google',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text('Don\'t have an account yet?'),
                  const SizedBox(height: 4),

                  // Create Account Button
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
