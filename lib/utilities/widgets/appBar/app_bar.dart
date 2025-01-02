import '../../colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final List<String> fieldNames;
  final Map<String, Map<String, WidgetBuilder>> navigationMap;

  const CustomAppBar({
    Key? key,
    required this.backgroundColor,
    required this.fieldNames,
    required this.navigationMap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: kToolbarHeight, // Consistent height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: fieldNames.map((fieldName) {
          final options = navigationMap[fieldName]?.keys.toList() ?? [];
          return Expanded(
            child: _OptionField(
              fieldName: fieldName,
              options: options,
              navigationMap: navigationMap[fieldName] ?? {},
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OptionField extends StatelessWidget {
  final String fieldName;
  final List<String> options;
  final Map<String, WidgetBuilder> navigationMap;

  const _OptionField({
    Key? key,
    required this.fieldName,
    required this.options,
    required this.navigationMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        final destinationBuilder = navigationMap[value];
        if (destinationBuilder != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: destinationBuilder),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No page defined for $value')),
          );
        }
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
