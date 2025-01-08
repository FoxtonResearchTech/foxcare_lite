import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';

import '../../colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  const CustomButton(
      {super.key,
      required this.label,
      required this.onPressed,
      required this.width,
      this.height = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          padding: const EdgeInsets.all(0), // Keep padding minimal
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Set borderRadius to 12
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}
