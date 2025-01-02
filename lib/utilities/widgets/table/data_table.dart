import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> tableData;
  final Map<int, TableColumnWidth> columnWidths;
  final Color headerBackgroundColor;
  final Color borderColor;

  const CustomDataTable({
    super.key,
    required this.headers,
    required this.tableData,
    this.columnWidths = const {},
    this.headerBackgroundColor = Colors.grey,
    this.borderColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: borderColor),
      columnWidths: columnWidths.isNotEmpty
          ? columnWidths
          : {
              for (int i = 0; i < headers.length; i++)
                i: const FlexColumnWidth()
            },
      children: [
        // Table header row
        TableRow(
          decoration: BoxDecoration(color: headerBackgroundColor),
          children: headers
              .map(
                (header) => Center(
                  child: Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
        ),
        // Data rows
        ...tableData.map(
          (row) => TableRow(
            children: headers.map(
              (header) {
                final cellData = row[header];
                if (cellData is Widget) {
                  // If the cell data is a Widget, display it directly
                  return Center(child: cellData);
                } else {
                  // Otherwise, display it as a Text
                  return Center(
                    child: Text(
                      cellData?.toString() ?? '',
                      style: const TextStyle(),
                    ),
                  );
                }
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}
