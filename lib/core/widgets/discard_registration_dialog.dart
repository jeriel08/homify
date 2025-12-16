import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A beautifully styled dialog that confirms if the user wants to discard registration.
///
/// Use this when a user attempts to leave the registration flow.
class DiscardRegistrationDialog extends StatelessWidget {
  /// Optional custom title. Defaults to "Discard Registration?"
  final String? title;

  /// Optional custom message. Defaults to "If you go back, all your progress will be lost."
  final String? message;

  /// Optional callback when discard button is pressed.
  /// If null, just closes the dialog and returns true.
  final VoidCallback? onDiscard;

  /// Optional callback when cancel is pressed.
  /// If null, just closes the dialog and returns false.
  final VoidCallback? onCancel;

  const DiscardRegistrationDialog({
    super.key,
    this.title,
    this.message,
    this.onDiscard,
    this.onCancel,
  });

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);
  static const Color dangerColor = Color(0xFFDC3545);

  /// Shows the discard registration dialog.
  ///
  /// [context] - The build context
  /// [onDiscard] - Optional callback for discard button.
  ///               If null, just closes the dialog and returns true.
  /// [onCancel] - Optional callback for cancel button.
  ///              If null, just closes the dialog and returns false.
  ///
  /// Returns `true` if the user chose to discard, `false` otherwise.
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onDiscard,
    VoidCallback? onCancel,
    String? title,
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => DiscardRegistrationDialog(
        title: title,
        message: message,
        onDiscard:
            onDiscard ??
            () {
              Navigator.pop(dialogContext, true); // Return true for discard
            },
        onCancel:
            onCancel ??
            () {
              Navigator.pop(dialogContext, false); // Return false for cancel
            },
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
              decoration: BoxDecoration(
                color: dangerColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.triangleAlert,
                color: dangerColor,
                size: 32,
              ),
            ),

            const Gap(20),

            // Title
            Text(
              title ?? 'Discard Registration?',
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
              message ?? 'If you go back, all your progress will be lost.',
              style: TextStyle(fontSize: 15, color: textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),

            const Gap(28),

            // Discard Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    onDiscard ??
                    () {
                      Navigator.pop(context, true);
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Discard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const Gap(12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onCancel ?? () => Navigator.pop(context, false),
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
