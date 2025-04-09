import 'package:flutter/material.dart';
import '../../colors.dart';

class SecondaryTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final double? width;
  final double verticalSize;
  final bool readOnly;
  final double horizontalSize;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final GestureTapCallback? onTap;
  final TextEditingController? controller;
  final Icon? icon;
  final bool showFilled;
  final Color? textColor;

  const SecondaryTextField({
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
    this.showFilled = true,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        onChanged: onChanged,
        maxLines: obscureText ? 1 : null,
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        focusNode: focusNode,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Poppins',
        ),
        decoration: InputDecoration(
          isDense: true,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: verticalSize,
            horizontal: horizontalSize,
          ),
          labelText: hintText,
          hintStyle: TextStyle(
            color: AppColors.lightBlue,
            fontFamily: 'Poppins',
          ),
          labelStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
          floatingLabelStyle: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: <Color>[
                  Colors.black, // top half
                  Colors.grey, // bottom half
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
            height: 1.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: showFilled,
          fillColor: AppColors.blue,
          focusColor: AppColors.blue,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightBlue, width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.lightBlue, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: icon != null
              ? GestureDetector(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon!,
                    ],
                  ),
                )
              : null,
          suffixIconColor: AppColors.secondaryColor,
        ),
      ),
    );
  }
}
