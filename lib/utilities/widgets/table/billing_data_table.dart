import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import '../text/primary_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillingDataTable extends StatefulWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> tableData;
  final List<String>? editableColumns;
  final Map<int, TableColumnWidth> columnWidths;
  final Color headerBackgroundColor;
  final Color headerColor;
  final Map<String, List<String>>? dropdownValues;
  final Color borderColor;
  final Color Function(Map<String, dynamic>)? rowColorResolver;
  final Function(int rowIndex, String header, String value)? onValueChanged;
  final List<Map<String, TextEditingController>>? controllers;

  BillingDataTable({
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
    this.dropdownValues,
  }) : headerBackgroundColor = headerBackgroundColor ?? AppColors.blue;

  @override
  State<BillingDataTable> createState() => _BillingDataTable();
}

class _BillingDataTable extends State<BillingDataTable> {
  late List<Map<String, TextEditingController>> controllers;
  late List<List<Map<String, dynamic>>> productSuggestions;
  int? focusedRowIndex;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

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
    productSuggestions = List.generate(widget.tableData.length, (_) => []);
  }

  void showSuggestionsOverlay(BuildContext context) {
    hideSuggestionsOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 750,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 50),
            child: Material(
              elevation: 4.0,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 250),
                child: productSuggestions.isEmpty ||
                        focusedRowIndex == null ||
                        productSuggestions.length <= focusedRowIndex! ||
                        productSuggestions[focusedRowIndex!].isEmpty
                    ? const SizedBox.shrink()
                    : ListView.builder(
                        itemCount: productSuggestions[focusedRowIndex!].length,
                        itemBuilder: (context, index) {
                          final product =
                              productSuggestions[focusedRowIndex!][index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                    text:
                                        'Product Name : ${product['productName'] ?? ''}'),
                                CustomText(
                                    text:
                                        'Batch Number : ${product['batchNumber'] ?? ''}'),
                                CustomText(
                                    text:
                                        'Expiry : ${product['expiry'] ?? ''}'),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                controllers[focusedRowIndex!]['Product Name']
                                    ?.text = product['productName'];
                                widget.tableData[focusedRowIndex!]
                                    ['Product Name'] = product['productName'];

                                widget.tableData[focusedRowIndex!]
                                    ['productDocId'] = product['productDocId'];
                                widget.tableData[focusedRowIndex!]
                                        ['purchaseEntryDocId'] =
                                    product['purchaseEntryDocId'];
                                widget.onValueChanged?.call(focusedRowIndex!,
                                    'Product Name', product['productName']);
                                controllers[focusedRowIndex!]['HSN']?.text =
                                    product['hsn'];
                                widget.tableData[focusedRowIndex!]['HSN'] =
                                    product['hsn'];
                                controllers[focusedRowIndex!]['Batch']?.text =
                                    product['batchNumber'];
                                widget.tableData[focusedRowIndex!]['Batch'] =
                                    product['batchNumber'];
                                controllers[focusedRowIndex!]['Expiry']?.text =
                                    product['expiry'];
                                widget.tableData[focusedRowIndex!]['Expiry'] =
                                    product['expiry'];
                                controllers[focusedRowIndex!]['MRP']?.text =
                                    product['mrp'];
                                widget.tableData[focusedRowIndex!]['MRP'] =
                                    product['mrp'];
                                controllers[focusedRowIndex!]['Rate']?.text =
                                    product['rate'];
                                widget.tableData[focusedRowIndex!]['Rate'] =
                                    product['rate'];
                                controllers[focusedRowIndex!]['Tax']?.text =
                                    product['tax'];
                                widget.tableData[focusedRowIndex!]['Tax'] =
                                    product['tax'];
                                controllers[focusedRowIndex!]['SGST']?.text =
                                    product['sgst'];
                                widget.tableData[focusedRowIndex!]['SGST'] =
                                    product['sgst'];
                                controllers[focusedRowIndex!]['CGST']?.text =
                                    product['cgst'];
                                widget.tableData[focusedRowIndex!]['CGST'] =
                                    product['cgst'];

                                productSuggestions[focusedRowIndex!] = [];
                                hideSuggestionsOverlay();
                              });
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void hideSuggestionsOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    hideSuggestionsOverlay();
    for (var rowControllers in controllers) {
      for (var controller in rowControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> fetchMatchingProducts(int rowIndex, String query) async {
    if (query.isEmpty) return;

    QuerySnapshot productSnapshots = await FirebaseFirestore.instance
        .collection('stock')
        .doc('Products')
        .collection('AddedProducts')
        .where('productName', isGreaterThanOrEqualTo: '')
        .where('productName', isLessThanOrEqualTo: 'z\uf8ff')
        .get();

    List<Map<String, dynamic>> matches = [];

    for (var doc in productSnapshots.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final productDocId = doc.id;
      final productName = data['productName']?.toString() ?? '';

      if (!productName.toLowerCase().contains(query.toLowerCase())) continue;

      QuerySnapshot entrySnapshots =
          await doc.reference.collection('purchaseEntry').get();

      for (var entryDoc in entrySnapshots.docs) {
        final entryData = entryDoc.data() as Map<String, dynamic>;
        matches.add({
          'productDocId': productDocId,
          'purchaseEntryDocId': entryDoc.id,
          'productName': data['productName'],
          'quantity': entryData['quantity'],
          'batchNumber': entryData['batchNumber'],
          'expiry': entryData['expiry'],
          'hsn': entryData['hsn'],
          'mrp': entryData['mrp'],
          'rate': entryData['rate'],
          'sgst': entryData['sgst'],
          'cgst': entryData['cgst'],
          'tax': entryData['tax'],
        });
      }
    }

    setState(() {
      productSuggestions[rowIndex] = matches;
    });
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
                    maxLines: 10,
                    text: header,
                    color: widget.headerColor,
                  ),
                ),
              )
              .toList(),
        ),
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
                  } else if (isEditable && header == 'Product Name') {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CompositedTransformTarget(
                        link: _layerLink,
                        child: SizedBox(
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
                              onChanged: (value) async {
                                focusedRowIndex = rowIndex;
                                await fetchMatchingProducts(rowIndex, value);
                                showSuggestionsOverlay(context);
                                widget.onValueChanged
                                    ?.call(rowIndex, header, value);
                              }),
                        ),
                      ),
                    );
                  } else if (isEditable && dropdownOptions != null) {
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
                              child: CustomText(
                                text: option,
                                maxLines: 10,
                              ),
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
                            onChanged: (value) async {
                              if (focusedRowIndex != rowIndex) {
                                focusedRowIndex = rowIndex;
                              }

                              if (header == 'Product Name') {
                                focusedRowIndex = rowIndex;
                                await fetchMatchingProducts(rowIndex, value);
                                showSuggestionsOverlay(context);
                              } else {
                                hideSuggestionsOverlay();
                              }

                              // Callback
                              widget.onValueChanged
                                  ?.call(rowIndex, header, value);
                            }),
                      ),
                    );
                  } else if (header == 'Delete') {
                    return IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          widget.tableData.removeAt(rowIndex);
                          controllers.removeAt(rowIndex);
                          productSuggestions.removeAt(rowIndex);
                        });
                      },
                    );
                  } else {
                    return Center(
                      child: CustomText(
                        maxLines: 10,
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
