import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';

/// Branch-scoped feedback. New feedback replaces older messages immediately.
abstract final class AppFeedback {
  static void success(ScaffoldMessengerState messenger, String message) =>
      _show(messenger, message, error: false);

  static void error(ScaffoldMessengerState messenger, String message) =>
      _show(messenger, message, error: true);

  static void _show(
    ScaffoldMessengerState messenger,
    String message, {
    required bool error,
  }) {
    messenger.clearSnackBars();
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: error
            ? AppConfig.errorFeedbackDuration
            : AppConfig.feedbackDuration,
        // Flutter derives its SnackBar Hero tag from content.toString().
        // Distinct notifications in independent tab messengers need identity.
        content: Row(
          key: UniqueKey(),
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_outline,
              color: error ? AppColors.destructive : AppColors.success,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
