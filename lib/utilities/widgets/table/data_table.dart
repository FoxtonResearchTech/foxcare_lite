import 'package:flutter/material.dart';
import '../../colors.dart';
import '../text/primary_text.dart';

class CustomDataTable extends StatefulWidget {
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

  CustomDataTable({
    super.key,
    required this.headers,
    required this.tableData,
    this.editableColumns,
    this.columnWidths = const {},
    Color? headerBackgroundColor,
    this.borderColor = Colors.black,
    this.rowColorResolver,
    this.onValueChanged,
    this.controllers,
    this.headerColor = Colors.white,
  }) : headerBackgroundColor = headerBackgroundColor ?? AppColors.blue;

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
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
        // Table header row
        TableRow(
          decoration: BoxDecoration(color: widget.headerBackgroundColor),
          children: widget.headers
              .map(
                (header) => Center(
                  child: CustomText(
                    maxLines: 5,
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

                  if (cellData is Widget) {
                    return Center(child: cellData);
                  } else if (isEditable) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: screenWidth * 0.02,
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
                        maxLines: 25,
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
