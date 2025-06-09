import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showShortSnackBar(BuildContext context, String message, {String? actionLabel, VoidCallback? onActionPressed}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),  // Reduced from default 4 seconds
        behavior: SnackBarBehavior.floating,
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }
} 