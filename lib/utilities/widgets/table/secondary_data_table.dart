import 'package:flutter/material.dart';
import '../text/primary_text.dart';

class SecondaryDataTable extends StatelessWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> tableData;
  final double totalWidth;
  final Color headerBackgroundColor;
  final Color headerColor;
  final Color borderColor;

  const SecondaryDataTable({
    super.key,
    required this.headers,
    required this.tableData,
    this.totalWidth = 600,
    this.headerBackgroundColor = Colors.grey,
    this.borderColor = Colors.black,
    this.headerColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final rowCount =
        tableData.length; // Number of rows equals the length of the data list
    final columnCount =
        headers.length; // Column count equals the number of headers
    final columnWidth =
        totalWidth / columnCount; // Distribute the total width evenly

    return SizedBox(
      width: totalWidth,
      child: Table(
        border: TableBorder.all(color: borderColor),
        columnWidths: {
          for (int i = 0; i < columnCount; i++)
            i: FixedColumnWidth(columnWidth),
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(color: headerBackgroundColor),
            children: headers.map((header) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: CustomText(text: header, color: headerColor),
                ),
              );
            }).toList(),
          ),
          // Data Rows
          for (int rowIndex = 0; rowIndex < rowCount; rowIndex++)
            TableRow(
              children: List.generate(columnCount, (colIndex) {
                // Get the value for the current column and row
                final columnData = tableData[rowIndex];
                final key = headers[
                    colIndex]; // Use the header key to get the corresponding value
                final value =
                    columnData.containsKey(key) ? columnData[key] : 'N/A';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: CustomText(text: value.toString()),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
