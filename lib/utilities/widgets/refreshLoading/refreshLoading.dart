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
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        );
      },
    );

    try {
      await task();
    } finally {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
