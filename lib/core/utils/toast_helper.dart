import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Toast types for different scenarios
enum ToastType { success, error, warning, info }

/// Delightful toast helper for consistent, beautiful notifications
class ToastHelper {
  static const Color _success = Color(0xFF22C55E);
  static const Color _error = Color(0xFFEF4444);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _info = Color(0xFF3B82F6);

  /// Show a delightful toast notification
  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    ToastType type = ToastType.info,
    Duration autoDismiss = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    final (icon, color) = _getIconAndColor(type);

    DelightToastBar(
      autoDismiss: true,
      snackbarDuration: autoDismiss,
      position: DelightSnackbarPosition.top,
      builder: (context) => ToastCard(
        color: color,
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              )
            : null,
      ),
    ).show(context);
  }

  /// Show a success toast
  static void success(BuildContext context, String title, {String? subtitle}) {
    show(
      context: context,
      title: title,
      subtitle: subtitle,
      type: ToastType.success,
    );
  }

  /// Show an error toast
  static void error(BuildContext context, String title, {String? subtitle}) {
    show(
      context: context,
      title: title,
      subtitle: subtitle,
      type: ToastType.error,
    );
  }

  /// Show a warning toast
  static void warning(BuildContext context, String title, {String? subtitle}) {
    show(
      context: context,
      title: title,
      subtitle: subtitle,
      type: ToastType.warning,
    );
  }

  /// Show an info toast
  static void info(BuildContext context, String title, {String? subtitle}) {
    show(
      context: context,
      title: title,
      subtitle: subtitle,
      type: ToastType.info,
    );
  }

  static (IconData, Color) _getIconAndColor(ToastType type) {
    return switch (type) {
      ToastType.success => (LucideIcons.circleCheck, _success),
      ToastType.error => (LucideIcons.circleX, _error),
      ToastType.warning => (LucideIcons.triangleAlert, _warning),
      ToastType.info => (LucideIcons.info, _info),
    };
  }
}
