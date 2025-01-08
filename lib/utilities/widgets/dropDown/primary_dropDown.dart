import 'package:flutter/material.dart';

import '../text/primary_text.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.items,
    this.selectedItem,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40, // Adjust the height as needed
      width: 100, // Adjust the width as needed
      padding:
          const EdgeInsets.symmetric(horizontal: 6), // Add some padding inside
      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlue, width: 2), // Blue border
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration.collapsed(
          focusColor: Colors.lightBlue,
          hintText: label,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        value: selectedItem,
        icon: const Icon(Icons.arrow_drop_down), // Drop-down icon
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
