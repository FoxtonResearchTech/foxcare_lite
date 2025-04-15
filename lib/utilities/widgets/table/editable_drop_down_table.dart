import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import '../text/primary_text.dart';

class EditableDropDownTable extends StatefulWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> tableData;
  final List<String>? editableColumns;
  final Map<int, TableColumnWidth> columnWidths;
  final Color headerBackgroundColor;
  final Color headerColor;
  final Color borderColor;
  final Color Function(Map<String, dynamic>)? rowColorResolver;
  final Function(int rowIndex, String header, String value)? onValueChanged;
  final List<Map<String, TextEditingController>>? controllers;
  final Map<String, List<String>>? dropdownValues;

  const EditableDropDownTable({
    super.key,
    required this.headers,
    required this.tableData,
    this.editableColumns,
    this.columnWidths = const {},
    this.headerBackgroundColor = Colors.grey,
    this.borderColor = Colors.black,
    this.rowColorResolver,
    this.onValueChanged,
    this.controllers,
    this.dropdownValues,
    this.headerColor = Colors.black,
  });

  @override
  State<EditableDropDownTable> createState() => _EditableDropDownTable();
}

class _EditableDropDownTable extends State<EditableDropDownTable> {
  late List<Map<String, TextEditingController>> controllers;

  @override
  void initState() {
    super.initState();

    controllers = widget.tableData.map((row) {
      return {
        for (String header in widget.headers)
          if (row[header] is! Widget)
            header: TextEditingController(text: row[header]?.toString() ?? '')
      };
    }).toList();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var rowControllers in controllers) {
      for (var controller in rowControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Table(
      border: TableBorder.all(color: widget.borderColor),
      columnWidths: widget.columnWidths.isNotEmpty
          ? widget.columnWidths
          : {
              for (int i = 0; i < widget.headers.length; i++)
                i: const FlexColumnWidth()
            },
      children: [
        TableRow(
          decoration: BoxDecoration(color: widget.headerBackgroundColor),
          children: widget.headers
              .map(
                (header) => Center(
                  child: CustomText(
                    text: header,
                    color: widget.headerColor,
                  ),
                ),
              )
              .toList(),
        ),
        // Data rows
        ...widget.tableData.asMap().entries.map(
          (entry) {
            final rowIndex = entry.key;
            final row = entry.value;
            final rowColor =
                widget.rowColorResolver?.call(row) ?? Colors.transparent;

            return TableRow(
              decoration: BoxDecoration(color: rowColor),
              children: widget.headers.map(
                (header) {
                  final cellData = row[header];
                  final isEditable =
                      widget.editableColumns?.contains(header) ?? false;
                  final dropdownOptions = widget.dropdownValues?[header];

                  if (cellData is Widget) {
                    return Center(child: cellData);
                  } else if (isEditable && dropdownOptions != null) {
                    // Show dropdown for editable columns
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.045,
                        child: DropdownButton<String>(
                          iconEnabledColor: AppColors.blue,
                          iconDisabledColor: AppColors.blue,
                          value: dropdownOptions.contains(row[header])
                              ? row[header]?.toString()
                              : null,
                          isExpanded: true,
                          items: dropdownOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: CustomText(text: option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              row[header] = value;
                            });
                            if (widget.onValueChanged != null) {
                              widget.onValueChanged!(
                                  rowIndex, header, value ?? '');
                            }
                          },
                        ),
                      ),
                    );
                  } else if (isEditable) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.045,
                        child: TextField(
                          controller: controllers[rowIndex][header],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                          ),
                          onChanged: (value) {
                            row[header] = value;
                            if (widget.onValueChanged != null) {
                              widget.onValueChanged!(rowIndex, header, value);
                            }
                          },
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: CustomText(
                        text: cellData?.toString() ?? '',
                      ),
                    );
                  }
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }
}
