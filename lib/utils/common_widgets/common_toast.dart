import 'package:flutter/material.dart';
import '../../main.dart';

class CommonToast {
  static void show(
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: textColor ?? Colors.white),
          ),
          backgroundColor: backgroundColor ?? Colors.black87,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      debugPrint("Toast: $message");
    }
  }
}
