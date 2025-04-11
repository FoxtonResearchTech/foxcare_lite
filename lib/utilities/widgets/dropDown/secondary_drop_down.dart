import 'package:flutter/material.dart';
import '../../colors.dart';

class SecondaryDropdown extends StatelessWidget {
  final String hintText;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;
  final double? width;
  final double verticalSize;
  final double horizontalSize;
  final bool showFilled;
  final Icon? icon;

  const SecondaryDropdown({
    Key? key,
    required this.hintText,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.width,
    this.verticalSize = 8.0,
    this.horizontalSize = 12.0,
    this.showFilled = true,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        value: selectedItem,
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
          labelStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
          floatingLabelStyle: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Colors.black, Colors.grey],
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
          suffixIcon: icon,
          suffixIconColor: AppColors.secondaryColor,
        ),
        dropdownColor: AppColors.blue,
        borderRadius: BorderRadius.circular(10),
        iconEnabledColor: AppColors.secondaryColor,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
