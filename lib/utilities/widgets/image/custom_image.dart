import 'package:flutter/cupertino.dart';

class CustomImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;

  const CustomImage({
    Key? key,
    required this.path,
    this.width = 250,
    this.height = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path, // Replace with your image path
      width: width,
      height: height,
    );
  }
}
