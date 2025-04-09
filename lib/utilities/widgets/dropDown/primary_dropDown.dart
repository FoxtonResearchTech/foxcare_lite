import 'package:flutter/material.dart';

import '../../colors.dart';
import '../text/primary_text.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedItem;
  final Color? iconColor;
  final ValueChanged<String?> onChanged;

  CustomDropdown({
    Key? key,
    required this.label,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    Color? iconColor,
  })  : iconColor = iconColor ?? AppColors.blue,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.05,
      width: screenWidth * 0.25,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration.collapsed(
          focusColor: AppColors.blue,
          hintText: label,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        value: selectedItem,
        icon: Icon(
          Icons.arrow_drop_down,
          color: iconColor,
        ), // Drop-down icon
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: CustomText(
              text: item,
            ),
          );
        }).toList(),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(5),
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
