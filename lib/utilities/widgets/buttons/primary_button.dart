import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';

import '../../colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          padding: const EdgeInsets.all(0), // Keep padding minimal
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Set borderRadius to 12
          ),
        ),
        onPressed: onPressed,
        child: CustomText(
          text: label,
        ),
      ),
    );
  }
}
