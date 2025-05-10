import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/table/pharmacy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class PurchaseEntry extends StatefulWidget {
  const PurchaseEntry({super.key});

  @override
  State<PurchaseEntry> createState() => _PurchaseEntry();
}

class _PurchaseEntry extends State<PurchaseEntry> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _billNo = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController mail = TextEditingController();
  TextEditingController dlNo1 = TextEditingController();
  TextEditingController dlNo2 = TextEditingController();
  TextEditingController gstIn = TextEditingController();

  double totalAmount = 0.0;
  bool isAdding = false;
  final List<String> headers = [
    'Product Name',
    'HSN',
    'Batch',
    'Expiry',
    'Quantity',
    'Free',
    'MRP',
    'Price',
    'Tax',
    'SGST',
    'CGST',
    'Tax Total',
    'Product Total',
    'Delete',
  ];

  final List<String> editableColumns = [
    'Product Name',
    'HSN',
    'Batch',
    'Expiry',
    'Quantity',
    'Free',
    'MRP',
    'Price',
    'Tax',
  ];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, TextEditingController>> controllers = [];
  List<List<Map<String, dynamic>>> productSuggestions = [];

  String? selectedDistributor;
  List<String> distributorsNames = [];
  String rfNo = '';

  Future<String> generateUniqueRfNo() async {
    const chars = '0123456789';
    Random random = Random.secure();
    String no = '';

    bool exists = true;

    while (exists) {
      String randomString =
          List.generate(8, (index) => chars[random.nextInt(chars.length)])
              .join();
      no = 'RfNo$randomString';

      var querySnapshot = await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry')
          .where('rfNo', isEqualTo: no)
          .limit(1)
          .get();

      exists = querySnapshot.docs.isNotEmpty;
    }

    return no;
  }

  Future<void> initializeRfNo() async {
    rfNo = await generateUniqueRfNo();
    setState(() {});
  }

  Future<void> fetchMatchingProducts(int rowIndex, String query) async {
    if (query.isEmpty) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('stock')
        .doc('Products')
        .collection('AddedProducts')
        .where('productName', isGreaterThanOrEqualTo: query)
        .where('productName', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    List<Map<String, dynamic>> matches = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .where((product) {
      String productName = product['productName'] as String;
      return productName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      productSuggestions[rowIndex] = matches;
    });
  }

  void addNewRow() {
    setState(() {
      allProducts.add({
        for (var header in headers) header: '',
      });
    });
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

  Future<void> getDistributorDetails({required String distributorName}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> distributorsSnapshot =
          await FirebaseFirestore.instance
              .collection('pharmacy')
              .doc('distributors')
              .collection('distributor')
              .where('distributorName', isEqualTo: distributorName)
              .get();
      setState(() {
        address.text = distributorsSnapshot.docs[0]['lane1'].toString();
        phone.text = distributorsSnapshot.docs[0]['phoneNo1'].toString();
        mail.text = distributorsSnapshot.docs[0]['emailId'].toString();
        dlNo1.text = distributorsSnapshot.docs[0]['dlNo1'].toString();
        dlNo2.text = distributorsSnapshot.docs[0]['dlNo2'].toString();
        gstIn.text = distributorsSnapshot.docs[0]['gstNo'].toString();
      });
    } catch (e) {
      print('Error fetching distributors: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDistributors();
    initializeRfNo();
    productSuggestions = List.generate(allProducts.length, (_) => []);

    addNewRow();
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
              color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06, vertical: screenHeight * 0.04),
          child: Column(
            children: [
              const TimeDateWidget(text: 'Purchase Entry'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Bill No ',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      PharmacyTextField(
                        hintText: '',
                        width: screenWidth * 0.2,
                        controller: _billNo,
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Date ',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      PharmacyTextField(
                        hintText: '',
                        width: screenWidth * 0.2,
                        controller: _dateController,
                        icon: const Icon(Icons.date_range),
                        onTap: () => _selectDate(context),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Reference No',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      PharmacyTextField(
                        readOnly: true,
                        hintText: '',
                        width: screenWidth * 0.2,
                        controller: TextEditingController(text: rfNo),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Distributor Name',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Row(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.15,
                            child: PharmacyDropDown(
                              label: '',
                              items: distributorsNames,
                              selectedItem: selectedDistributor,
                              onChanged: (value) {
                                setState(() {
                                  selectedDistributor = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          PharmacyButton(
                            label: 'Select',
                            onPressed: () {
                              getDistributorDetails(
                                  distributorName:
                                      selectedDistributor.toString());
                            },
                            width: screenWidth * 0.1,
                            height: screenHeight * 0.05,
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Distributor Name : ${selectedDistributor}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'Address : ${address.text}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'Phone : ${phone.text}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'Mail : ${mail.text}',
                        size: screenWidth * 0.012,
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'DL NO 1 : ${dlNo1.text}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'DL NO 2 : ${dlNo2.text}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'GSTIN : ${gstIn.text}',
                        size: screenWidth * 0.012,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              isAdding
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              isAdding = true;
                            });
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            setState(() {
                              addNewRow();
                              isAdding = false;
                            });
                          },
                          icon: Icon(
                            Icons.add,
                            color: AppColors.blue,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.85,
                          child: PharmacyDataTable(
                            headers: headers,
                            tableData: allProducts,
                            editableColumns: editableColumns,
                            dropdownValues: const {
                              'Tax': ['6.0', '12.0', '18.0', '24.0'],
                            },
                            onValueChanged: (rowIndex, header, value) {
                              setState(() {
                                allProducts[rowIndex][header] = value;
                                fetchMatchingProducts(rowIndex, value);

                                if (header == 'Tax') {
                                  final tax = double.tryParse(value);
                                  final quantity = double.tryParse(
                                          allProducts[rowIndex]['Quantity'] ??
                                              '0') ??
                                      0;
                                  final price = double.tryParse(
                                          allProducts[rowIndex]['Price'] ??
                                              '0') ??
                                      0;
                                  final totalQuantity = quantity;
                                  final totalWithoutTax = totalQuantity * price;

                                  if (tax != null) {
                                    final splitValue =
                                        (tax / 2).toStringAsFixed(1);
                                    allProducts[rowIndex]['SGST'] = splitValue;
                                    allProducts[rowIndex]['CGST'] = splitValue;

                                    final taxAmount =
                                        totalWithoutTax * (tax / 100);
                                    final totalWithTax =
                                        totalWithoutTax + taxAmount;

                                    allProducts[rowIndex]['Tax Total'] =
                                        taxAmount.toStringAsFixed(2);
                                    allProducts[rowIndex]['Product Total'] =
                                        totalWithTax.toStringAsFixed(2);
                                  } else {
                                    allProducts[rowIndex]['SGST'] = '';
                                    allProducts[rowIndex]['CGST'] = '';
                                    allProducts[rowIndex]['Tax Total'] = '';
                                    allProducts[rowIndex]['Product Total'] = '';
                                  }
                                }

                                if (header == 'Price') {
                                  final tax = double.tryParse(
                                          allProducts[rowIndex]['Tax'] ??
                                              '0') ??
                                      0;
                                  final quantity = double.tryParse(
                                          allProducts[rowIndex]['Quantity'] ??
                                              '0') ??
                                      0;
                                  final price = double.tryParse(value);
                                  final totalQuantity = quantity;

                                  if (price != null) {
                                    final totalWithoutTax =
                                        totalQuantity * price;
                                    final taxAmount =
                                        totalWithoutTax * (tax / 100);
                                    final totalWithTax =
                                        totalWithoutTax + taxAmount;

                                    allProducts[rowIndex]['Tax Total'] =
                                        taxAmount.toStringAsFixed(2);
                                    allProducts[rowIndex]['Product Total'] =
                                        totalWithTax.toStringAsFixed(2);
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.395),
                child: Container(
                  padding: EdgeInsets.only(left: screenWidth * 0.02),
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.030,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomText(
                        text: 'Total : ',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.6),
                child: Container(
                  padding: EdgeInsets.only(left: screenWidth * 0.02),
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.04,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomText(
                        text: 'Discount ',
                      ),
                      PharmacyTextField(
                          hintText: '', width: screenWidth * 0.05),
                      CustomText(
                        text: '  % :',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.6),
                child: Container(
                  padding: EdgeInsets.only(left: screenWidth * 0.02),
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.04,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomText(
                        text: 'Net Total : ',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.09, right: screenWidth * 0.09),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PharmacyButton(
                        color: AppColors.blue,
                        label: 'Cancel',
                        onPressed: () {},
                        width: screenWidth * 0.1),
                    PharmacyButton(
                        color: AppColors.blue,
                        label: 'Print',
                        onPressed: () {},
                        width: screenWidth * 0.1),
                    PharmacyButton(
                        color: AppColors.blue,
                        label: 'Submit',
                        onPressed: () {},
                        width: screenWidth * 0.1),
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
