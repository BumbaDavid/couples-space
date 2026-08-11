import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';

/// App-wide confirmation toasts.
///
/// Use for mutations whose result isn't already obvious on screen — deletes,
/// renames, and saves that navigate away. Skip it where the change is visible
/// anyway (a logged protein row appears immediately and already has its own
/// undo toast; a second toast on top is just noise).
///
/// **Colour:** both variants use the same dark surface, differing only by
/// icon. Errors are deliberately *not* red — the protein feature forbids red
/// for any of its states, and one visual language app-wide beats a special
/// case that's easy to get wrong.
abstract class AppSnack {
  /// Confirmation. Safe while [context] is still mounted.
  static void show(BuildContext context, String message) =>
      showOn(ScaffoldMessenger.of(context), message);

  /// Something didn't work. Same surface, different icon, longer on screen.
  static void error(BuildContext context, String message) =>
      errorOn(ScaffoldMessenger.of(context), message);

  /// For use *after* the originating context is gone — e.g. once a screen has
  /// popped. Capture the messenger with `ScaffoldMessenger.of(context)`
  /// **before** navigating away, then pass it here.
  static void showOn(ScaffoldMessengerState messenger, String message) =>
      _post(messenger, message, isError: false);

  static void errorOn(ScaffoldMessengerState messenger, String message) =>
      _post(messenger, message, isError: true);

  static void _post(
    ScaffoldMessengerState messenger,
    String message, {
    required bool isError,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.info_outline : Icons.check_circle,
                size: 20,
                color: isError
                    ? AppColors.onToastAction
                    : AppColors.primarySoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onToast,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.text,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          duration: Duration(seconds: isError ? 4 : 2),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
  }
}
