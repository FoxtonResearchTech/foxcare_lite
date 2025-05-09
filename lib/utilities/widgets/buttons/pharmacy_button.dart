import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import '../../colors.dart';

class PharmacyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final Color? color;

  PharmacyButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.width,
    this.height = 50,
    Color? color,
  }) : color = color ?? AppColors.lightBlue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          onPressed: onPressed,
          child: CustomText(
            text: label,
            color: Colors.white,
          )),
    );
  }
}
