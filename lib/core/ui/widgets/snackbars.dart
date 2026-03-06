import 'package:flutter/material.dart';

class AppSnackbars {
  static void error(BuildContext context, String message) {
    _show(
      context,
      message,
      const Color(0xFFFEABAB),
      const Color(0xFF2A0505),
    );
  }

  static void success(BuildContext context, String message) {
    _show(
      context,
      message,
      const Color(0xFF9EFF8B),
      const Color(0xFF062A00),
    );
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          content: Text(
            message,
            style: TextStyle(color: foregroundColor),
          ),
        ),
      );
  }
}
