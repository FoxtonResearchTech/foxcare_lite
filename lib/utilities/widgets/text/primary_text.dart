import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  const CustomText({
    super.key,
    required this.text,
    this.size = 14,
    this.color = const Color(0xFF000000),
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: size,
          color: color),
    );
  }
}
