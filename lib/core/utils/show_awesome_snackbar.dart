import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

void showAwesomeSnackbar({
  required BuildContext context,
  required String title,
  required String message,
  required ContentType contentType,
}) {
  if (!context.mounted) return;

  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    duration: const Duration(seconds: 4),
    content: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: contentType,
      // Optional: customize colors to match Homify
      color: contentType == ContentType.failure
          ? Colors.red.shade600
          : contentType == ContentType.success
          ? Colors.green.shade600
          : const Color(0xFFE05725),
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
