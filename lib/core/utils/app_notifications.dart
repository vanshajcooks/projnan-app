import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class AppToast {
  AppToast._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      icon: LucideIcons.checkCircle2,
      accentColor: AppTheme.success,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      icon: LucideIcons.alertCircle,
      accentColor: AppTheme.error,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      icon: LucideIcons.info,
      accentColor: AppTheme.primaryLight,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color accentColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.surfaceElevated,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accentColor.withAlpha(120), width: 1),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, size: 20, color: accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
