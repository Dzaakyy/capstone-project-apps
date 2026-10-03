import 'package:flutter/material.dart';

class SnackbarUtil {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.green.shade600, Icons.check_circle_rounded);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.red.shade600, Icons.error_rounded);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.orange.shade700, Icons.warning_rounded);
  }

  static void _showSnackbar(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
