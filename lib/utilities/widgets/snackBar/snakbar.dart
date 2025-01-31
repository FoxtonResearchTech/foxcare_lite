import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';

void CustomSnackBar(
  BuildContext context, {
  required String message,
  Color backgroundColor = Colors.grey,
  IconData? icon,
  double iconSize = 24.0,
  double fontSize = 16.0,
  FontWeight fontWeight = FontWeight.bold,
  Duration duration = const Duration(seconds: 3),
  SnackBarBehavior behavior = SnackBarBehavior.floating,
}) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        if (icon != null) Icon(icon, color: Colors.white, size: iconSize),
        if (icon != null) SizedBox(width: 10),
        Expanded(
          child: Center(
            child: CustomText(
              text: message,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: behavior,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    duration: duration,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
