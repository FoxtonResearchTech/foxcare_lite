import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RefreshLoading {
  RefreshLoading({
    required BuildContext context,
    required Future<void> Function() task,
  }) {
    _run(context, task);
  }

  void _run(BuildContext context, Future<void> Function() task) async {
    bool dialogStillOpen = true;

    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: true, // Allow manual close
      builder: (dialogContext) {
        final screenWidth = MediaQuery.of(dialogContext).size.width;
        final screenHeight = MediaQuery.of(dialogContext).size.height;

        return WillPopScope(
          onWillPop: () async => true, // allow back button to close
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: screenWidth * 0.08,
                height: screenHeight * 0.15,
                child: Lottie.asset(
                  'assets/login_lottie.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      dialogStillOpen = false; // dialog manually closed
    });

    try {
      await task();
    } finally {
      if (dialogStillOpen) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}
