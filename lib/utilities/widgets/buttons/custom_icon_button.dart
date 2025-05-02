import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import '../../colors.dart';

class CustomIconButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final double? prefixWidth;
  final double? suffixWidth;

  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const CustomIconButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.width,
    this.height = 50,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixWidth,
    this.suffixWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, color: Colors.white, size: 18),
              SizedBox(width: prefixWidth),
            ],
            CustomText(
              text: label,
              color: Colors.white,
            ),
            if (suffixIcon != null) ...[
              SizedBox(width: suffixWidth),
              Icon(suffixIcon, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
