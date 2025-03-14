import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';

class CounterSales extends StatefulWidget {
  const CounterSales({super.key});

  @override
  State<CounterSales> createState() => _CounterSales();
}

class _CounterSales extends State<CounterSales> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController patientName = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController place = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController billNo = TextEditingController();
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _composition = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _hsnCode = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _referredByDoctor = TextEditingController();
  final TextEditingController _additionalInformation = TextEditingController();
  String? selectedCategoryFilter;
  String productName = '';
  String companyName = '';
  String hsnCode = '';
  bool isLoading = false;

  double totalAmount = 0.0;
  double taxPercentage = 12;
  double gstPercentage = 10;
  double taxAmount = 0.00;
  double gstAmount = 0.00;
  double totalGst = 0.00;
  double grandTotal = 0.00;
  final List<String> headers = [
    'Product Name',
    'HSN Code',
    'Category',
    'Company',
    'Composition',
    'Type',
    'Action',
  ];
  final List<String> header = [
    'Product Name',
    'Type',
    'Batch',
    'EXP',
    'HSN',
    'Quantity',
    'MRP',
    'Price',
    'Gst',
    'Amount',
  ];

  List<Map<String, dynamic>> tableData = [];

  void calculateTotals() {
    totalAmount = tableData.fold(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item['Amount']?.toString() ?? '0') ?? 0),
    );

    taxAmount = (totalAmount * taxPercentage) / 100;
    gstAmount = (totalAmount * gstPercentage) / 100;
    totalGst = taxAmount + gstAmount;
    grandTotal = totalAmount + totalGst;

    totalAmount = double.parse(totalAmount.toStringAsFixed(2));
    taxAmount = double.parse(taxAmount.toStringAsFixed(2));
    gstAmount = double.parse(gstAmount.toStringAsFixed(2));
    totalGst = double.parse(totalGst.toStringAsFixed(2));
    grandTotal = double.parse(grandTotal.toStringAsFixed(2));
  }

  void resetTotals() {
    totalAmount = 0.00;
    taxAmount = 0.00;
    gstAmount = 0.00;
    totalGst = 0.00;
    grandTotal = 0.00;
    patientName.clear();
    age.clear();
    place.clear();
    gender.clear();
    phoneNumber.clear();
  }

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

  Future<void> submitBillingData() async {
    try {
      DocumentReference billingRef = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billing')
          .collection('countersales')
          .doc();
      List<Map<String, dynamic>> updatedTableData = tableData.map((item) {
        return {
          'Product Name': item['Product Name'] ?? 'N/A',
          'Type': item['Type'] ?? 'N/A',
          'Batch': item['Batch'] ?? 'N/A',
          'EXP': item['EXP'] ?? 'N/A',
          'HSN': item['HSN'] ?? 'N/A',
          'Quantity': item['Quantity'] ?? '0',
          'MPS': item['MRP'] ?? 'N/A',
          'Price': item['Price'] ?? 'N/A',
          'Gst': item['Gst'] ?? '0%',
          'Amount': item['Amount'] ?? '0.00',
        };
      }).toList();
      Map<String, dynamic> billingData = {
        'billNo': billNo.text,
        'billDate': _dateController.text,
        'patientName': patientName.text,
        'age': age.text,
        'place': place.text,
        'gender': gender.text,
        'phoneNumber': phoneNumber.text,
        'totalAmount': totalAmount,
        'taxAmount': taxAmount,
        'gstAmount': gstAmount,
        'totalGst': totalGst,
        'grandTotal': grandTotal,
        'items': updatedTableData,
      };

      await billingRef.set(billingData);
      for (var product in tableData) {
        String productName = product['Product Name'];
        String batch = product['Batch'];
        String hsn = product['HSN'];

        double Quantity = double.tryParse(product['Quantity'].toString()) ?? 0;

        print('Return Quantity: $Quantity');

        if (Quantity > 0) {
          QuerySnapshot<Map<String, dynamic>> productSnapshot =
              await FirebaseFirestore.instance
                  .collection('stock')
                  .doc('Products')
                  .collection('AddedProducts')
                  .where('productName', isEqualTo: productName)
                  .where('batchNumber', isEqualTo: batch)
                  .where('hsnCode', isEqualTo: hsn)
                  .get();

          if (productSnapshot.docs.isEmpty) {
            print(
                'No matching product found for $productName, Batch: $batch, HSN: $hsn');
          } else {
            print('Found ${productSnapshot.docs.length} matching products.');

            for (var doc in productSnapshot.docs) {
              double currentQuantity =
                  double.tryParse(doc['quantity'].toString()) ?? 0;

              double updatedQuantity =
                  (currentQuantity - Quantity).clamp(0, double.infinity);

              print(
                  'Current Quantity: $currentQuantity, Updated Quantity: $updatedQuantity');

              await FirebaseFirestore.instance
                  .collection('stock')
                  .doc('Products')
                  .collection('AddedProducts')
                  .doc(doc.id)
                  .update({
                'quantity': updatedQuantity.toString(),
              });
            }
          }
        }
      }

      CustomSnackBar(context,
          message: 'Billing data submitted successfully',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to submit billing data',
          backgroundColor: Colors.red);

      print('Error submitting billing data: $e');
    }
  }

  List<Map<String, dynamic>> allProducts = [];

  List<Map<String, dynamic>> filteredProducts = [];
  Future<void> fetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> stockSnapshot =
          await FirebaseFirestore.instance
              .collection('stock')
              .doc('Products')
              .collection('AddedProducts')
              .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in stockSnapshot.docs) {
        final data = doc.data();
        fetchedData.add({
          'Product Name': data['productName'],
          'HSN Code': data['hsnCode'],
          'Category': data['category'],
          'Company': data['companyName'],
          'Composition': data['composition'],
          'Type': data['type'],
          'Action': TextButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });

              await Future.delayed(const Duration(seconds: 1));

              setState(() {
                tableData.add({
                  'Product Name': data['productName'],
                  'Type': data['type'],
                  'Batch': data['batchNumber'],
                  'EXP': data['expiry'],
                  'HSN': data['hsnCode'],
                  'Quantity': '',
                  'MRP': data['mrp'],
                  'Price': data['price'],
                  'Gst': data['gst'],
                  'Amount': '',
                });

                isLoading = false;
              });
            },
            child: const CustomText(text: 'Add'),
          ),
        });
      }

      setState(() {
        allProducts = fetchedData;
        filteredProducts = List.from(allProducts); // Update filtered list too
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();

    filteredProducts = List.from(allProducts);
  }

  void clearFields() {
    _productName.clear();
    _composition.clear();
    _quantity.clear();
    _hsnCode.clear();
    _companyName.clear();
    _referredByDoctor.clear();
    _additionalInformation.clear();
  }

  void filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        return (selectedCategoryFilter == null ||
                selectedCategoryFilter == 'All' ||
                product['Category'] == selectedCategoryFilter) &&
            (productName.isEmpty ||
                product['Product Name']!
                    .toLowerCase()
                    .contains(productName.toLowerCase())) &&
            (companyName.isEmpty ||
                product['Company']!
                    .toLowerCase()
                    .contains(companyName.toLowerCase())) &&
            (hsnCode.isEmpty ||
                product['HSN Code']!
                    .toLowerCase()
                    .contains(hsnCode.toLowerCase()));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CustomTextField(
                    controller: billNo,
                    hintText: 'Bill No',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                      controller: patientName,
                      hintText: 'Patient Name',
                      width: screenWidth * 0.25),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                      controller: age,
                      hintText: 'Age',
                      width: screenWidth * 0.25)
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                      controller: place,
                      hintText: 'Place',
                      width: screenWidth * 0.25),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    controller: _dateController,
                    hintText: 'Bill Date',
                    width: screenWidth * 0.15,
                    icon: const Icon(Icons.date_range),
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                      controller: gender,
                      hintText: 'Gender',
                      width: screenWidth * 0.20),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                      controller: phoneNumber,
                      hintText: 'Phone Number',
                      width: screenWidth * 0.20),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomDropdown(
                    label: 'Select Category',
                    items: const [
                      'All',
                      'Medicine',
                      'Equipment',
                      'Supplements',
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryFilter = value;
                      });
                      filterProducts();
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Product Name',
                    width: screenWidth * 0.20,
                    onChanged: (value) {
                      productName = value;
                      filterProducts();
                    },
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'Company Name',
                    width: screenWidth * 0.20,
                    onChanged: (value) {
                      companyName = value;
                      filterProducts();
                    },
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'HSN Code',
                    width: screenWidth * 0.10,
                    onChanged: (value) {
                      hsnCode = value;
                      filterProducts();
                    },
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomButton(
                    label: 'Search',
                    onPressed: filterProducts,
                    width: screenWidth * 0.1,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              CustomDataTable(headers: headers, tableData: filteredProducts),
              SizedBox(height: screenHeight * 0.06),
              if (tableData.isNotEmpty) ...[
                isLoading
                    ? CircularProgressIndicator()
                    : Column(
                        children: [
                          CustomDataTable(
                              tableData: tableData,
                              headers: header,
                              editableColumns: const [
                                'Quantity',
                              ],
                              onValueChanged: (rowIndex, header, value) async {
                                if (rowIndex >= 0 &&
                                    rowIndex < tableData.length) {
                                  setState(() {
                                    tableData[rowIndex][header] = value;

                                    double quantity = double.tryParse(
                                            tableData[rowIndex]['Quantity']
                                                    ?.toString() ??
                                                '0') ??
                                        0;
                                    double price = double.tryParse(
                                            tableData[rowIndex]['Price']
                                                    ?.toString() ??
                                                '0') ??
                                        0;
                                    double gstRate = double.tryParse(
                                            tableData[rowIndex]['Gst']
                                                    ?.replaceAll('%', '') ??
                                                '0') ??
                                        0;

                                    if (tableData.isNotEmpty &&
                                        rowIndex < tableData.length) {
                                      double totalAmountForItem =
                                          quantity * price;
                                      double itemGst =
                                          (totalAmountForItem * gstRate) / 100;

                                      tableData[rowIndex]['Amount'] =
                                          (totalAmountForItem + itemGst)
                                              .toStringAsFixed(2);
                                      calculateTotals();
                                    }
                                  });
                                } else {
                                  print(
                                      "Error: rowIndex $rowIndex is out of range. Table length: ${tableData.length}");
                                }
                              }),
                          Container(
                            padding: EdgeInsets.only(right: screenWidth * 0.03),
                            width: screenWidth,
                            height: screenHeight * 0.030,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomText(
                                  text: 'Total : $totalAmount',
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: screenWidth * 0.08),
                            width: screenWidth,
                            height: screenHeight * 0.025,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: '12% TAX :$taxAmount '),
                                CustomText(text: '10% GST : $gstAmount'),
                                CustomText(text: 'Total GST :$totalGst '),
                                CustomText(text: 'Grand Total :$grandTotal '),
                              ],
                            ),
                          ),
                        ],
                      ),
              ],
              SizedBox(height: screenHeight * 0.08),
              Container(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.15,
                  right: screenWidth * 0.15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      label: 'Payment',
                      onPressed: () {},
                      width: screenWidth * 0.10,
                    ),
                    CustomButton(
                      label: 'Print',
                      onPressed: () => submitBillingData(),
                      width: screenWidth * 0.10,
                    ),
                    CustomButton(
                      label: 'Submit',
                      onPressed: () => submitBillingData(),
                      width: screenWidth * 0.10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
