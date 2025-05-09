import 'package:flutter/material.dart';
import '../../colors.dart';

class PharmacyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final double? width;
  final double verticalSize;
  final bool readOnly;
  final double horizontalSize;
  final FocusNode? focusNode;
  final onChanged;
  final GestureTapCallback? onTap;
  final TextEditingController? controller;
  final Icon? icon;

  const PharmacyTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.icon,
    this.readOnly = false,
    required this.width,
    this.verticalSize = 8.0,
    this.horizontalSize = 12.0,
    this.focusNode,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        onTap: onTap,
        onChanged: onChanged,
        maxLines: obscureText ? 1 : null,
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        decoration: InputDecoration(
          isDense: true, // Reduces the overall height of the TextField
          contentPadding: EdgeInsets.symmetric(
              vertical: verticalSize, horizontal: horizontalSize),
          labelText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
          ),
          floatingLabelStyle:
              TextStyle(fontFamily: 'Poppins', color: AppColors.lightBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightBlue, width: 3.0),
            borderRadius: BorderRadius.circular(4),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightBlue, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          suffixIcon: icon != null
              ? Row(
                  mainAxisSize:
                      MainAxisSize.min, // Ensures the icon does not expand
                  children: [
                    icon!,
                  ],
                )
              : null,
          suffixIconColor: AppColors.lightBlue,
        ),
      ),
    );
  }
}
