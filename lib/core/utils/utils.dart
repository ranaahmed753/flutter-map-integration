import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  // Private constructor to prevent instantiation
  AppSnackbar._();

  /// Show a success toast message
  static void showSuccess({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
  }) {
    CherryToast.success(
      title: Text(
        title ?? "Successful",
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(color: Colors.green),
      ),
      toastDuration: duration ?? const Duration(seconds: 2),
      height: 70,
      toastPosition: Position.top,
      shadowColor: Colors.white,
      animationType: AnimationType.fromTop,
      displayCloseButton: false,
      backgroundColor: Colors.green.withAlpha(40),
    ).show(context);
  }

  /// Show an error toast message
  static void showError({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
  }) {
    CherryToast.error(
      title: Text(
        title ?? "Error",
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
      toastDuration: duration ?? const Duration(seconds: 2),
      height: 70,
      toastPosition: Position.top,
      shadowColor: Colors.white,
      animationType: AnimationType.fromTop,
      displayCloseButton: false,
      backgroundColor: Colors.red.withAlpha(40),
    ).show(context);
  }

  /// Show a warning toast message
  static void showWarning({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
  }) {
    CherryToast.warning(
      title: Text(
        title ?? "Warning",
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(color: Colors.orange),
      ),
      toastDuration: duration ?? const Duration(seconds: 2),
      height: 70,
      toastPosition: Position.top,
      shadowColor: Colors.white,
      animationType: AnimationType.fromTop,
      displayCloseButton: false,
      backgroundColor: Colors.orange.withAlpha(40),
    ).show(context);
  }

  /// Show an info toast message
  static void showInfo({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
  }) {
    CherryToast.info(
      title: Text(
        title ?? "Info",
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(color: Colors.blue),
      ),
      toastDuration: duration ?? const Duration(seconds: 2),
      height: 70,
      toastPosition: Position.top,
      shadowColor: Colors.white,
      animationType: AnimationType.fromTop,
      displayCloseButton: false,
      backgroundColor: Colors.blue.withAlpha(40),
    ).show(context);
  }

  /// Generic method to show toast based on type
  static void show({
    required BuildContext context,
    required SnackbarType type,
    required String message,
    String? title,
    Duration? duration,
  }) {
    switch (type) {
      case SnackbarType.success:
        showSuccess(
          context: context,
          message: message,
          title: title,
          duration: duration,
        );
        break;
      case SnackbarType.error:
        showError(
          context: context,
          message: message,
          title: title,
          duration: duration,
        );
        break;
      case SnackbarType.warning:
        showWarning(
          context: context,
          message: message,
          title: title,
          duration: duration,
        );
        break;
      case SnackbarType.info:
        showInfo(
          context: context,
          message: message,
          title: title,
          duration: duration,
        );
        break;
    }
  }
}

// USAGE EXAMPLES:

/*

// Example 1: Success message
AppSnackbar.showSuccess(
  context: context,
  message: "Location updated successfully",
);

// Example 2: Error message
AppSnackbar.showError(
  context: context,
  message: "Failed to fetch route",
);

// Example 3: Custom title and duration
AppSnackbar.showSuccess(
  context: context,
  message: "Rider is on the way!",
  title: "Great!",
  duration: const Duration(seconds: 3),
);

// Example 4: Warning message
AppSnackbar.showWarning(
  context: context,
  message: "GPS accuracy is low",
);

// Example 5: Info message
AppSnackbar.showInfo(
  context: context,
  message: "Tap on the marker to view details",
);

// Example 6: Using generic method
AppSnackbar.show(
  context: context,
  type: SnackbarType.success,
  message: "Operation completed",
);

*/