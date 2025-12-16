import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A beautifully styled dialog that confirms if the user wants to discard a property.
///
/// Use this when a user attempts to leave the add property flow without saving.
class DiscardPropertyDialog extends StatelessWidget {
  /// Optional custom title. Defaults to "Discard Property?"
  final String? title;

  /// Optional custom message. Defaults to "Are you sure you want to discard this new property?"
  final String? message;

  /// Optional callback when discard button is pressed.
  /// If null, just closes the dialog and returns true.
  final VoidCallback? onDiscard;

  /// Optional callback when cancel is pressed.
  /// If null, just closes the dialog and returns false.
  final VoidCallback? onCancel;

  const DiscardPropertyDialog({
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

  /// Shows the discard property confirmation dialog.
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
      builder: (dialogContext) => DiscardPropertyDialog(
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
              child: Icon(LucideIcons.trash2, color: dangerColor, size: 32),
            ),

            const Gap(20),

            // Title
            Text(
              title ?? 'Discard Property?',
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
              message ??
                  'Are you sure you want to discard this new property? All unsaved changes will be lost.',
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
