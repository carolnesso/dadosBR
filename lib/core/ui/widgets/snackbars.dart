import 'package:flutter/material.dart';

class AppSnackbars {
  static void error(BuildContext context, String message) {
    _show(context, message, const Color(0xFFFEABAB));
  }

  static void success(BuildContext context, String message) {
    _show(context, message, const Color(0xFF9EFF8B));
  }

  static void _show(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          content: Text(message),
        ),
      );
  }
}
