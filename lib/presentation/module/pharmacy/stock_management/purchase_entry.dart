import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';

class PurchaseEntry extends StatefulWidget {
  const PurchaseEntry({super.key});

  @override
  State<PurchaseEntry> createState() => _PurchaseEntry();
}

class _PurchaseEntry extends State<PurchaseEntry> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _billNo = TextEditingController();
  TextEditingController _entryNo = TextEditingController();
  double totalAmount = 0.0;

  final List<String> headers = [
    'Product Name',
    'HSN Code',
    'Quantity',
    'Batch Number',
    'Expiry',
    'Free',
    'MRP',
    'Price',
    'GST',
    'Amount',
    'Product Total',
  ];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, TextEditingController>> controllers = [];

  String? selectedDistributor;
  List<String> distributorsNames = [];
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> stockSnapshot =
          await FirebaseFirestore.instance
              .collection('stock')
              .doc('Products')
              .collection('AddedProducts')
              .get();

      List<Map<String, dynamic>> fetchedData = stockSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'Product Name': data['productName'] ?? '',
          'HSN Code': data['hsnCode'] ?? '',
          'Quantity': data['quantity'] ?? '',
          'Batch Number': '',
          'Expiry': '',
          'Free': '',
          'MRP': '',
          'Price': '',
          'GST': '',
          'Amount': '',
          'Product Total': '',
          'Distributor': data['distributor'] ?? ''
        };
      }).toList();

      setState(() {
        allProducts = fetchedData;
        filterProducts();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void filterProducts() {
    List<Map<String, dynamic>> newFilteredProducts =
        allProducts.where((product) {
      final String productDistributor =
          (product['Distributor'] ?? '').toString().trim().toLowerCase();
      final String selected = (selectedDistributor ?? '').trim().toLowerCase();
      return selected.isEmpty || productDistributor == selected;
    }).toList();

    setState(() {
      filteredProducts = newFilteredProducts;
      controllers = filteredProducts.map((row) {
        return {
          for (String header in headers)
            if ([
              'Batch Number',
              'Expiry',
              'Free',
              'MRP',
              'Price',
              'GST',
              'Amount',
              'Product Total',
            ].contains(header))
              header: TextEditingController(text: row[header]?.toString() ?? '')
        };
      }).toList();
    });
  }

  Future<void> fetchDistributors() async {
    try {
      QuerySnapshot<Map<String, dynamic>> distributorsSnapshot =
          await FirebaseFirestore.instance
              .collection('pharmacy')
              .doc('distributors')
              .collection('distributor')
              .get();
      setState(() {
        distributorsNames = distributorsSnapshot.docs
            .map((doc) => doc['distributorName'].toString())
            .toList();
      });
    } catch (e) {
      print('Error fetching distributors: $e');
    }
  }

  Future<void> fetchEntryNo() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('counters')
              .doc('entry')
              .get();

      if (documentSnapshot.exists) {
        int entry = (documentSnapshot.data()?['entryValue'] ?? 0) + 1;

        // Set the incremented entry number in UI (but not updating Firestore yet)
        setState(() {
          _entryNo.text = entry.toString();
        });
      } else {}
    } catch (e) {
      print('Error fetching entry number: $e');
    }
  }

  Future<void> updateEntryNo() async {
    try {
      int entry = int.tryParse(_entryNo.text) ?? 1;

      await FirebaseFirestore.instance
          .collection('counters')
          .doc('entry')
          .update({'entryValue': entry});

      print('Entry number updated successfully!');
    } catch (e) {
      print('Error updating entry number: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDistributors();
    fetchData();
    fetchEntryNo();
  }

  @override
  void dispose() {
    for (var rowControllers in controllers) {
      for (var controller in rowControllers.values) {
        controller.dispose();
      }
    }
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        title: Center(
            child: CustomText(
                text: 'Purchase Entry',
                size: screenWidth * 0.012,
                color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, vertical: screenHeight * 0.05),
          child: Column(
            children: [
              Row(children: [
                CustomText(text: 'Purchase Entry ', size: screenWidth * 0.012)
              ]),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.15,
                    child: CustomDropdown(
                      label: 'Distributor',
                      items: distributorsNames,
                      selectedItem: selectedDistributor,
                      onChanged: (value) {
                        setState(() {
                          selectedDistributor = value;
                          filterProducts();
                        });
                      },
                    ),
                  ),
                  CustomTextField(
                      controller: _billNo,
                      hintText: 'Bill NO',
                      width: screenWidth * 0.10),
                  CustomTextField(
                    controller: _dateController,
                    hintText: 'Report Date',
                    width: screenWidth * 0.125,
                    icon: const Icon(Icons.date_range),
                    onTap: () => _selectDate(context),
                  ),
                  CustomTextField(
                      controller: TextEditingController(text: _entryNo.text),
                      hintText: 'Entry No',
                      width: screenWidth * 0.10),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              if (filteredProducts.isNotEmpty) ...[
                CustomDataTable(
                  tableData: filteredProducts,
                  headers: headers,
                  controllers: controllers,
                  editableColumns: const [
                    'Batch Number',
                    'Expiry',
                    'Free',
                    'MRP',
                    'Price',
                    'GST',
                  ],
                  onValueChanged: (rowIndex, header, value) {
                    setState(() {
                      filteredProducts[rowIndex][header] = value;
                      controllers[rowIndex][header]?.text = value;

                      if (header == 'Price' || header == 'GST') {
                        double price = double.tryParse(
                                controllers[rowIndex]['Price']?.text ?? '0') ??
                            0;
                        double gst = double.tryParse(
                                controllers[rowIndex]['GST']?.text ?? '0') ??
                            0;

                        double amount = price * (1 + (gst / 100));

                        // Update Amount field
                        controllers[rowIndex]['Amount']?.text =
                            amount.toStringAsFixed(2);
                        filteredProducts[rowIndex]['Amount'] =
                            amount.toStringAsFixed(2);
                      }

                      // Calculate Product Total = Quantity * Amount
                      double quantity = double.tryParse(
                              filteredProducts[rowIndex]['Quantity'] ?? '0') ??
                          0;
                      double amount = double.tryParse(
                              filteredProducts[rowIndex]['Amount'] ?? '0') ??
                          0;
                      double productTotal = quantity * amount;

                      controllers[rowIndex]['Product Total']?.text =
                          productTotal.toStringAsFixed(2);
                      filteredProducts[rowIndex]['Product Total'] =
                          productTotal.toStringAsFixed(2);

                      // Update totalAmount
                      totalAmount = filteredProducts.fold(
                        0.0,
                        (sum, item) =>
                            sum +
                            (double.tryParse(item['Product Total'] ?? '0') ??
                                0),
                      );
                    });
                  },
                ),
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.030,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: screenWidth * 0.73),
                      CustomText(
                          text:
                              'Grand Total :    ${totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ] else ...[
                const Center(child: Text('No products available.')),
              ],
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      label: 'Update',
                      onPressed: () async {
                        try {
                          for (int i = 0; i < filteredProducts.length; i++) {
                            String productName =
                                filteredProducts[i]['Product Name'];
                            String hsnCode = filteredProducts[i]['HSN Code'];
                            String distributor =
                                filteredProducts[i]['Distributor'];
                            String amount = filteredProducts[i]['Amount'];

                            QuerySnapshot<Map<String, dynamic>> querySnapshot =
                                await FirebaseFirestore.instance
                                    .collection('stock')
                                    .doc('Products')
                                    .collection('AddedProducts')
                                    .where('productName',
                                        isEqualTo: productName)
                                    .where('hsnCode', isEqualTo: hsnCode)
                                    .where('distributor',
                                        isEqualTo: distributor)
                                    .get();

                            if (querySnapshot.docs.isNotEmpty) {
                              DocumentReference productRef =
                                  querySnapshot.docs.first.reference;

                              await productRef.update({
                                'reportDate': _dateController.text ?? '',
                                'billNo': _billNo.text ?? '',
                                'entryNo': _entryNo.text ?? '',
                                'batchNumber':
                                    controllers[i]['Batch Number']?.text ?? '',
                                'expiry': controllers[i]['Expiry']?.text ?? '',
                                'free': controllers[i]['Free']?.text ?? '',
                                'mrp': controllers[i]['MRP']?.text ?? '',
                                'price': controllers[i]['Price']?.text ?? '',
                                'gst': controllers[i]['GST']?.text ?? '',
                                'amount': amount ?? '',
                              });
                            }
                          }
                          await FirebaseFirestore.instance
                              .collection('stock')
                              .doc('Products')
                              .collection('PurchaseEntry')
                              .doc()
                              .set({
                            'reportDate': _dateController.text ?? '',
                            'billNo': _billNo.text ?? '',
                            'entryNo': _entryNo.text ?? '',
                            'amount': totalAmount.toStringAsFixed(2) ?? '',
                            'entryProducts': filteredProducts,
                            'distributor': selectedDistributor,
                          });
                          updateEntryNo();
                          fetchEntryNo();
                          CustomSnackBar(context,
                              message: 'Products updated successfully',
                              backgroundColor: Colors.green);
                        } catch (e) {
                          print('Error updating products: $e');
                          CustomSnackBar(context,
                              message: 'Failed to update products',
                              backgroundColor: Colors.red);
                        }
                      },
                      width: screenWidth * 0.1),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
