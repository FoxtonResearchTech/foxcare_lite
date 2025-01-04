import 'package:flutter/material.dart';

import '../../colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final double width;
  final double verticalSize;
  final double horizontalSize;

  final TextEditingController? controller;
  final Icon? icon;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.icon,
    required this.width,
    this.verticalSize = 8.0,
    this.horizontalSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          isDense: true,
          // Reduces the overall height of the TextField
          contentPadding: EdgeInsets.symmetric(
              vertical: verticalSize, horizontal: horizontalSize),
          labelText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
          ),
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
          ),
          floatingLabelStyle:
              TextStyle(fontFamily: 'Poppins', color: AppColors.secondaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.textField, width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: icon,
          suffixIconColor: AppColors.secondaryColor,
        ),
      ),
    );
  }
}
