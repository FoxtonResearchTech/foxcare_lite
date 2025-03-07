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

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../tools/manage_pharmacy_info.dart';

class StockReturn extends StatefulWidget {
  const StockReturn({super.key});

  @override
  State<StockReturn> createState() => _StockReturn();
}

class _StockReturn extends State<StockReturn> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController dlNo1Controller = TextEditingController();
  TextEditingController expiryDate1Controller = TextEditingController();
  TextEditingController dlNo2Controller = TextEditingController();
  TextEditingController expiryDate2Controller = TextEditingController();
  TextEditingController lane1 = TextEditingController();
  TextEditingController lane2 = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController phoneNo1 = TextEditingController();
  TextEditingController phoneNO2 = TextEditingController();

  String? selectedCategory;
  String productName = '';
  String companyName = '';
  String hsnCode = '';
  String? selectedDistributor;
  String returnNo = '';

  List<Map<String, dynamic>> allProducts = [];
  List<String> distributorsNames = [];

  List<Map<String, dynamic>> filteredProducts = [];
  String generateNumericUid() {
    var random = Random();
    returnNo = 'StockReturnNo' +
        List.generate(6, (_) => random.nextInt(10).toString()).join();
    return returnNo;
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

  Map<String, dynamic> distributorsDetails = {}; // Store distributor details

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

        // Store distributor details
        distributorsDetails = {
          for (var doc in distributorsSnapshot.docs)
            doc['distributorName']: doc.data(),
        };
      });
    } catch (e) {
      print('Error fetching distributors: $e');
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

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in stockSnapshot.docs) {
        final data = doc.data();
        fetchedData.add({
          'Product Name': data['productName'] ?? 'N/A',
          'Batch': data['batch'] ?? 'N/A',
          'Expiry': data['expiry'] ?? 'N/A',
          'Quantity': data['quantity'] ?? 'N/A',
          'Free': data['free'] ?? 'N/A',
          'MRP': data['mrp'] ?? 'N/A',
          'Price': data['price'] ?? 'N/A',
          'Tax': data['gst'] ?? 'N/A',
          'Amount': data['amount'] ?? 'N/A',
          'Distributor': data['distributor'] ?? '',
          'HSN Code': data['hsnCode'],
          'Category': data['category'],
          'Company': data['companyName'],
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

  Future<void> submitStockReturn() async {
    if (selectedDistributor == null || selectedDistributor!.isEmpty) {
      CustomSnackBar(context,
          message: 'Please select a distributor', backgroundColor: Colors.red);
      return;
    }

    try {
      // Create stock return data
      Map<String, dynamic> stockReturnData = {
        'returnNo': returnNo,
        'distributor': selectedDistributor,
        'date': _dateController.text,
        'dlNo1': dlNo1Controller.text,
        'expiryDate1': expiryDate1Controller.text,
        'dlNo2': dlNo2Controller.text,
        'expiryDate2': expiryDate2Controller.text,
        'lane1': lane1.text,
        'lane2': lane2.text,
        'city': city.text,
        'pinCode': pinCode.text,
        'emailId': emailId.text,
        'phoneNo1': phoneNo1.text,
        'phoneNo2': phoneNO2.text,
        'products': filteredProducts,
        'returnDate': _dateController.text,
      };

      await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('StockReturn')
          .doc(returnNo) // Using return number as document ID
          .set(stockReturnData);

      CustomSnackBar(context,
          message: 'Stock return submitted successfully',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Error submitting stock return: $e',
          backgroundColor: Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDistributors();
    generateNumericUid();

    filteredProducts = List.from(allProducts);
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    dlNo1Controller.dispose();
    expiryDate1Controller.dispose();
    dlNo2Controller.dispose();
    expiryDate2Controller.dispose();
    lane1.dispose();
    lane2.dispose();
    city.dispose();
    pinCode.dispose();
    emailId.dispose();
    phoneNo1.dispose();
    phoneNO2.dispose();
  }

  void filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        return (selectedCategory == null ||
                selectedCategory == 'All' ||
                product['Category'] == selectedCategory) &&
            (selectedDistributor == null ||
                selectedDistributor == 'All' ||
                product['Distributor'] == selectedDistributor) &&
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

  final List<String> headers = [
    'Product Name',
    'Batch',
    'Expiry',
    'Quantity',
    'Free',
    'MRP',
    'Price',
    'Tax',
    'Amount',
  ];

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
                  CustomText(
                    text: 'Stock Return ',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
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

                          if (distributorsDetails.containsKey(value)) {
                            var distributorData = distributorsDetails[value];

                            dlNo1Controller.text =
                                distributorData['dlNo1'] ?? '';
                            expiryDate1Controller.text =
                                distributorData['expiryDate1'] ?? '';
                            dlNo2Controller.text =
                                distributorData['dlNo2'] ?? '';
                            expiryDate2Controller.text =
                                distributorData['expiryDate2'] ?? '';
                            lane1.text = distributorData['lane1'] ?? '';
                            lane2.text = distributorData['lane2'] ?? '';
                            city.text = distributorData['city'] ?? '';
                            pinCode.text = distributorData['pinCode'] ?? '';
                            emailId.text = distributorData['emailId'] ?? '';
                            phoneNo1.text = distributorData['phoneNo1'] ?? '';
                            phoneNO2.text = distributorData['phoneNo2'] ?? '';
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(width: screenHeight * 1),
                  CustomTextField(
                    controller: TextEditingController(text: returnNo),
                    hintText: 'Return Number',
                    width: screenWidth * 0.15,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'DL No',
                    width: screenWidth * 0.10,
                    controller: dlNo1Controller,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Exp',
                    width: screenWidth * 0.10,
                    controller: expiryDate1Controller,
                  ),
                  SizedBox(width: screenHeight * 0.835),
                  CustomTextField(
                    controller: _dateController,
                    hintText: 'Return Date',
                    width: screenWidth * 0.15,
                    icon: const Icon(Icons.date_range),
                    onTap: () => _selectDate(context),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'DL No',
                    width: screenWidth * 0.10,
                    controller: dlNo2Controller,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Exp',
                    width: screenWidth * 0.10,
                    controller: expiryDate2Controller,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Address Lane 1',
                    width: screenWidth * 0.15,
                    controller: lane1,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Address Lane 2',
                    width: screenWidth * 0.15,
                    controller: lane2,
                  ),
                  SizedBox(width: screenHeight * 0.087),
                  CustomTextField(
                    hintText: 'Phone 1',
                    width: screenWidth * 0.15,
                    controller: phoneNo1,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Email-ID',
                    width: screenWidth * 0.234,
                    controller: emailId,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'City',
                    width: screenWidth * 0.15,
                    controller: city,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Pin code',
                    width: screenWidth * 0.15,
                    controller: pinCode,
                  ),
                  SizedBox(width: screenHeight * 0.08),
                  CustomTextField(
                    hintText: 'Phone 2',
                    width: screenWidth * 0.15,
                    controller: phoneNO2,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomText(text: 'Product List', size: screenWidth * 0.012),
                ],
              ),
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
                        selectedCategory = value;
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
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      label: 'Submit',
                      onPressed: () {
                        submitStockReturn();
                      },
                      width: screenWidth * 0.1)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
