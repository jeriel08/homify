import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A beautifully styled dialog that prompts guest users to log in.
///
/// Use this when a guest attempts to access a feature that requires authentication.
class LoginRequiredDialog extends StatelessWidget {
  /// Optional custom title. Defaults to "Login Required"
  final String? title;

  /// Optional custom message. Defaults to "Please log in to access this feature."
  final String? message;

  /// Optional callback when login button is pressed.
  /// If null, navigates to landing page by default.
  final VoidCallback? onLogin;

  /// Optional callback when cancel is pressed.
  /// If null, just closes the dialog.
  final VoidCallback? onCancel;

  const LoginRequiredDialog({
    super.key,
    this.title,
    this.message,
    this.onLogin,
    this.onCancel,
  });

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  /// Shows the login required dialog.
  ///
  /// [context] - The build context
  /// [onLogin] - Optional callback for login button.
  ///             If null, navigates to '/' (landing page)
  /// [closeSheet] - Whether to close the parent sheet before navigating
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onLogin,
    bool closeSheet = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => LoginRequiredDialog(
        onLogin:
            onLogin ??
            () {
              Navigator.pop(dialogContext); // Close dialog
              if (closeSheet) {
                Navigator.pop(context); // Close sheet if needed
              }
              context.go('/'); // Go to landing page
            },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
              child: Icon(LucideIcons.logIn, color: primary, size: 32),
            ),

            const Gap(20),

            // Title
            Text(
              title ?? 'Login Required',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const Gap(12),

            // Message
            Text(
              message ?? 'Please log in to access this feature.',
              style: TextStyle(fontSize: 15, color: textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),

            const Gap(28),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    onLogin ??
                    () {
                      Navigator.pop(context);
                      context.go('/');
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const Gap(12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onCancel ?? () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
