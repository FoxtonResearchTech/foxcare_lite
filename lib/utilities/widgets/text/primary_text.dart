import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final int maxLines;

  const CustomText({
    super.key,
    required this.text,
    this.size = 14,
    this.color = const Color(0xFF000000),
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        fontSize: size,
        color: color,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      softWrap: false,
    );
  }
}
