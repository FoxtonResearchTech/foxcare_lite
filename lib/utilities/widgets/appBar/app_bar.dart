import '../../colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final List<String> fieldNames;
  final List<List<String>> fieldOptions;

  const CustomAppBar({
    Key? key,
    required this.backgroundColor,
    required this.fieldNames,
    required this.fieldOptions,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      flexibleSpace: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(fieldNames.length, (index) {
          return Expanded(
            child: _OptionField(
              fieldName: fieldNames[index],
              options: fieldOptions[index],
            ),
          );
        }),
      ),
    );
  }
}

class _OptionField extends StatelessWidget {
  final String fieldName;
  final List<String> options;

  const _OptionField({
    Key? key,
    required this.fieldName,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Action to perform when an option is selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $value')),
        );
      },
      itemBuilder: (BuildContext context) {
        return options
            .map((option) => PopupMenuItem<String>(
                  value: option,
                  child: Text(option),
                ))
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: AppColors.appBar,
        ),
        child: Center(
          child: Text(
            fieldName,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
