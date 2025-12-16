import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A beautifully styled dialog that confirms if the user wants to remove a photo.
///
/// Use this when a user attempts to remove an uploaded photo.
class RemovePhotoDialog extends StatelessWidget {
  /// Optional custom title. Defaults to "Remove Photo?"
  final String? title;

  /// Optional custom message. Defaults to "This photo will be removed from the selection."
  final String? message;

  /// Optional callback when remove button is pressed.
  /// If null, just closes the dialog and returns true.
  final VoidCallback? onRemove;

  /// Optional callback when cancel is pressed.
  /// If null, just closes the dialog and returns false.
  final VoidCallback? onCancel;

  const RemovePhotoDialog({
    super.key,
    this.title,
    this.message,
    this.onRemove,
    this.onCancel,
  });

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);
  static const Color dangerColor = Color(0xFFDC3545);

  /// Shows the remove photo confirmation dialog.
  ///
  /// [context] - The build context
  /// [onRemove] - Optional callback for remove button.
  ///              If null, just closes the dialog and returns true.
  /// [onCancel] - Optional callback for cancel button.
  ///              If null, just closes the dialog and returns false.
  ///
  /// Returns `true` if the user chose to remove, `false` otherwise.
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onRemove,
    VoidCallback? onCancel,
    String? title,
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => RemovePhotoDialog(
        title: title,
        message: message,
        onRemove:
            onRemove ??
            () {
              Navigator.pop(dialogContext, true); // Return true for remove
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
              child: Icon(LucideIcons.imageOff, color: dangerColor, size: 32),
            ),

            const Gap(20),

            // Title
            Text(
              title ?? 'Remove Photo?',
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
              message ?? 'This photo will be removed from your selection.',
              style: TextStyle(fontSize: 15, color: textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),

            const Gap(28),

            // Remove Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    onRemove ??
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
                  'Remove',
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
