import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/controllers/login_controller.dart';
import 'package:homify/features/auth/presentation/controllers/google_sign_in_controller.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/utils/toast_helper.dart';

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
    // Location logic moved to LandingPage
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
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        helperText: helperText,
        // Normal border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        // Focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        // Error border (red when validation fails)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        // Focused error border (red when focused with error)
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        // Content padding for better appearance
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final googleSignInState = ref.watch(googleSignInControllerProvider);

    final isEitherLoading = loginState.isLoading || googleSignInState.isLoading;

    // Listen for login errors and show toast
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ToastHelper.error(context, next.errorMessage!);
        ref.read(loginControllerProvider.notifier).clearError();
      }
    });

    ref.listen<GoogleSignInState>(googleSignInControllerProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null) {
        ToastHelper.error(context, next.errorMessage!);
        ref.read(googleSignInControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.background,
        toolbarHeight: 28,
      ),
      backgroundColor: AppColors.background,
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
                    label: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
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
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscure = !_isPasswordObscure;
                        });
                      },
                    ),
                  ),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push('/forgot-password');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Log in Button
                  ElevatedButton.icon(
                    onPressed: loginState.isLoading ? null : _submitLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      backgroundColor: AppColors.primary,
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
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.primary,
                    ),
                    icon:
                        googleSignInState
                            .isLoading // <-- Specific to this button
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: AppColors.primary,
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
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
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
