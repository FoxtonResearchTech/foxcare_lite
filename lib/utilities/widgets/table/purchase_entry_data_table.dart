import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import '../text/primary_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseEntryDataTable extends StatefulWidget {
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

  PurchaseEntryDataTable({
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
  State<PurchaseEntryDataTable> createState() => _PurchaseEntryDataTable();
}

class _PurchaseEntryDataTable extends State<PurchaseEntryDataTable> {
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
          width: 500,
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
                            title: CustomText(
                                text:
                                    'Product Name : ${product['productName'] ?? ''}'),
                            onTap: () {
                              setState(() {
                                controllers[focusedRowIndex!]['Product Name']
                                    ?.text = product['productName'];
                                widget.tableData[focusedRowIndex!]
                                    ['Product Name'] = product['productName'];
                                widget.tableData[focusedRowIndex!]
                                    ['productDocId'] = product['productDocId'];

                                widget.onValueChanged?.call(focusedRowIndex!,
                                    'Product Name', product['productName']);

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

  Future<void> fetchMatchingProducts(int rowIndex, String query,
      {int pageSize = 10}) async {
    if (query.isEmpty) return;

    Query queryRef = FirebaseFirestore.instance
        .collection('stock')
        .doc('Products')
        .collection('AddedProducts')
        .limit(pageSize);

    DocumentSnapshot? lastDoc;
    bool hasMore = true;

    List<Map<String, dynamic>> allMatches = [];

    while (hasMore) {
      if (lastDoc != null) {
        queryRef = queryRef.startAfterDocument(lastDoc);
      }

      QuerySnapshot snapshot = await queryRef.get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['productDocId'] = doc.id;

        final productName = data['productName'] as String? ?? '';
        if (productName.toLowerCase().contains(query.toLowerCase())) {
          allMatches.add(data);
        }
      }

      lastDoc = snapshot.docs.last;

      // Stop pagination if fewer results than pageSize
      if (snapshot.docs.length < pageSize) {
        hasMore = false;
      }

      // Update UI after each batch
      setState(() {
        productSuggestions[rowIndex] = List.from(allMatches);
      });

      // Optional delay for smoother UI
      await Future.delayed(const Duration(milliseconds: 100));
    }
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
                                if (header == 'Product Name') {
                                  focusedRowIndex = rowIndex;
                                  await fetchMatchingProducts(rowIndex, value);
                                  showSuggestionsOverlay(context);
                                } else {
                                  setState(() {
                                    productSuggestions[rowIndex] = [];
                                  });
                                }
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
                  } else if (isEditable && header == 'Expiry') {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            String formattedDate =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

                            setState(() {
                              widget.tableData[rowIndex][header] =
                                  formattedDate;
                            });

                            widget.onValueChanged
                                ?.call(rowIndex, header, formattedDate);
                          }
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          width: screenWidth * 0.2,
                          height: screenHeight * 0.045,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            row[header]?.toString() ?? 'Select date',
                            style: const TextStyle(fontSize: 14),
                          ),
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
