import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class StockReturnStatement extends StatefulWidget {
  const StockReturnStatement({super.key});

  @override
  State<StockReturnStatement> createState() => _StockReturnStatement();
}

class _StockReturnStatement extends State<StockReturnStatement> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  TextEditingController distributorNameController = TextEditingController();
  TextEditingController dlNo1Controller = TextEditingController();
  TextEditingController expiryDate1Controller = TextEditingController();
  TextEditingController dlNo2Controller = TextEditingController();
  TextEditingController expiryDate2Controller = TextEditingController();
  TextEditingController gstNoController = TextEditingController();
  TextEditingController lane1 = TextEditingController();
  TextEditingController lane2 = TextEditingController();
  TextEditingController returnNo = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController phoneNo1 = TextEditingController();
  TextEditingController phoneNO2 = TextEditingController();
  TextEditingController returnDate = TextEditingController();
  TextEditingController totalReturnAmount = TextEditingController();
  double totalAmount = 0.0;
  final List<String> headers = [
    'Bill No',
    'Bill date',
    'Distributor Name',
    'Return value',
    'Bill details',
  ];
  List<Map<String, dynamic>> tableData = [];
  final List<String> headers2 = [
    'Product Name',
    'Batch',
    'Expiry',
    'Quantity',
    'Return Quantity',
    'Free',
    'MRP',
    'Price',
    'Tax',
    'Amount',
    'Return Amount',
  ];
  List<Map<String, dynamic>> tableData2 = [];

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('StockReturn');

      if (singleDate != null) {
        query = query.where('date', isEqualTo: singleDate);
      } else if (fromDate != null && toDate != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: fromDate)
            .where('date', isLessThanOrEqualTo: toDate);
      }
      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No records found");
        setState(() {
          tableData = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        fetchedData.add({
          'Bill No': data['returnNo']?.toString() ?? 'N/A',
          'Bill date': data['returnDate']?.toString() ?? 'N/A',
          'Distributor Name': data['distributor']?.toString() ?? 'N/A',
          'Return value': data['totalReturnAmount']?.toString() ?? 'N/A',
          'Bill details': TextButton(
            onPressed: () {
              distributorNameController.text =
                  data['distributor']?.toString() ?? 'N/A';
              dlNo1Controller.text = data['dlNo1']?.toString() ?? 'N/A';
              expiryDate1Controller.text =
                  data['expiryDate1']?.toString() ?? 'N/A';
              dlNo2Controller.text = data['dlNo2']?.toString() ?? 'N/A';
              expiryDate2Controller.text =
                  data['expiryDate1']?.toString() ?? 'N/A';
              lane1.text = data['lane1']?.toString() ?? 'N/A';
              lane2.text = data['lane2']?.toString() ?? 'N/A';
              city.text = data['city']?.toString() ?? 'N/A';
              state.text = data['state']?.toString() ?? 'N/A';
              pinCode.text = data['pinCode']?.toString() ?? 'N/A';
              emailId.text = data['emailId']?.toString() ?? 'N/A';
              phoneNo1.text = data['phoneNo1']?.toString() ?? 'N/A';
              phoneNO2.text = data['phoneNO2']?.toString() ?? 'N/A';
              returnNo.text = data['returnNo']?.toString() ?? 'N/A';
              returnDate.text = data['returnDate']?.toString() ?? 'N/A';
              totalReturnAmount.text =
                  data['totalReturnAmount']?.toString() ?? 'N/A';
              print(totalReturnAmount);

              for (var product in data['products']) {
                tableData2.add({
                  'Product Name': product['Product Name'],
                  'Batch': product['Batch'],
                  'Expiry': product['Expiry'],
                  'Quantity': product['Quantity'],
                  'Free': product['Free'],
                  'MRP': product['MRP'],
                  'Price': product['Price'],
                  'Tax': product['Tax'],
                  'Amount': product['Amount'],
                  'Return Quantity': product['Return Quantity'],
                  'Return Amount': product['Return Amount'],
                  'HSN Code': product['HSN Code'],
                  'Category': product['Category'],
                  'Company': product['Company'],
                  'Distributor': product['Distributor'],
                });
              }
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('View Bill'),
                    content: Container(
                      width: 850,
                      height: 850,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                  child: Container(
                                    width: 850,
                                    height: 850,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(
                                              text: 'Distributor details ',
                                              size: 16, // Adjusted size
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextField(
                                              controller:
                                                  distributorNameController,
                                              hintText: 'Distributor Name',
                                              width: 250,
                                            ),
                                            CustomTextField(
                                              controller: returnDate,
                                              hintText: 'Return Date',
                                              width: 250,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextField(
                                              controller: dlNo1Controller,
                                              hintText: 'DL / No 1',
                                              width: 250,
                                            ),
                                            CustomTextField(
                                              controller: expiryDate1Controller,
                                              hintText: 'Expiry date',
                                              width: 250,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextField(
                                              controller: dlNo2Controller,
                                              hintText: 'DL / No 2',
                                              width: 250,
                                            ),
                                            CustomTextField(
                                              controller: expiryDate2Controller,
                                              hintText: 'Expiry date',
                                              width: 250,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(
                                              text: 'Stock Return Address',
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextField(
                                              controller: lane1,
                                              hintText: 'Lane 1',
                                              width: 250,
                                            ),
                                            CustomTextField(
                                              controller: lane2,
                                              hintText: 'Lane 2',
                                              width: 250,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextField(
                                              controller: city,
                                              hintText: 'City',
                                              width: 250,
                                            ),
                                            CustomTextField(
                                              controller: state,
                                              hintText: 'State',
                                              width: 250,
                                            ),
                                            CustomTextField(
                                              controller: pinCode,
                                              hintText: 'Pin code',
                                              width: 250,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextField(
                                              controller: emailId,
                                              hintText: 'E-Mail ID',
                                              width: 250,
                                            ),
                                            CustomTextField(
                                              controller: phoneNo1,
                                              hintText: 'Phone NO 1',
                                              width: 250,
                                            ),
                                            CustomTextField(
                                              controller: phoneNO2,
                                              hintText: 'Phone Number 2',
                                              width: 250,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            CustomTextField(
                                              controller: returnNo,
                                              hintText: 'Stock Return Number',
                                              width: 250,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        CustomDataTable(
                                            headers: headers2,
                                            tableData: tableData2),
                                        Container(
                                          padding: EdgeInsets.only(left: 650),
                                          width: 1000,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              CustomText(
                                                text:
                                                    'Total : ${totalReturnAmount.text}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 50),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                          text: 'Ok ',
                          color: AppColors.secondaryColor,
                          size: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                          text: 'Cancel',
                          color: AppColors.secondaryColor,
                          size: 14,
                        ),
                      ),
                    ],
                  );
                },
              ).then((_) {
                tableData2.clear();
              });
            },
            child: CustomText(text: 'Open'),
          ),
        });
      }

      setState(() {
        tableData = fetchedData;
        calculateTotals();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  void calculateTotals() {
    totalAmount = tableData.fold(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item['Return value']?.toString() ?? '0') ?? 0),
    );
  }

  @override
  void initState() {
    fetchData();
    super.initState();
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
            top: screenHeight * 0.02,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.03),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Stock Return Statement",
                          size: screenWidth * 0.0275,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      image: const DecorationImage(
                        image: AssetImage('assets/foxcare_lite_logo.png'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomTextField(
                    onTap: () => _selectDate(context, _dateController),
                    icon: Icon(Icons.date_range),
                    controller: _dateController,
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(singleDate: _dateController.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomText(text: 'OR'),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _fromDateController),
                    icon: Icon(Icons.date_range),
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _toDateController),
                    icon: Icon(Icons.date_range),
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(
                        fromDate: _fromDateController.text,
                        toDate: _toDateController.text,
                      );
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Available Stock Return List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
              Container(
                padding: EdgeInsets.only(left: screenWidth * 0.23),
                width: screenWidth,
                height: screenHeight * 0.030,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    CustomText(
                      text: 'Total : ${totalAmount.toStringAsFixed(2)} ',
                    )
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      label: 'Print',
                      onPressed: () {},
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
