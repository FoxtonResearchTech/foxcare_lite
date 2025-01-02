import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  const CustomText({
    super.key,
    required this.text,
    this.size = 14,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: size),
    );
  }
}
