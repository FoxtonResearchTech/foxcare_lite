import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../tools/manage_pharmacy_info.dart';

class PartyWiseStatement extends StatefulWidget {
  const PartyWiseStatement({super.key});

  @override
  State<PartyWiseStatement> createState() => _PartyWiseStatement();
}

class _PartyWiseStatement extends State<PartyWiseStatement> {
  String? selectedDistributor;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  final List<String> headers = [
    'Bill NO',
    'Bill Date',
    'Bill Value',
    'Open Bill',
  ];
  List<Map<String, dynamic>> tableData = [];
  List<String> distributorsNames = [];
  double totalAmount = 0.0;

  final List<String> headers2 = [
    'Product Name',
    'Batch',
    'Expiry',
    'Return Quantity',
    'Free',
    'MRP',
    'Rate',
    'Tax',
    'CGST',
    'SGST',
    'Total Tax',
    'Product Total',
  ];
  List<Map<String, dynamic>> tableData2 = [];

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

  Future<void> fetchDistributors() async {
    try {
      QuerySnapshot<Map<String, dynamic>> distributorsSnapshot =
          await FirebaseFirestore.instance
              .collection('pharmacy')
              .doc('distributors')
              .collection('distributor')
              .get();
      List<String> distributors = [];

      for (var doc in distributorsSnapshot.docs) {
        distributors.add(doc['distributorName']);
      }
      setState(() {
        distributorsNames = distributors;
      });
    } catch (e) {
      print('Error fetching distributors: $e');
    }
  }

  Future<void> fetchData({
    String? distributor,
    String? singleDate,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry');
      if (distributor != null) {
        query = query.where('distributor', isEqualTo: distributor);
      }
      if (singleDate != null) {
        query = query.where('billDate', isEqualTo: singleDate);
      } else if (fromDate != null && toDate != null) {
        query = query
            .where('billDate', isGreaterThanOrEqualTo: fromDate)
            .where('billDate', isLessThanOrEqualTo: toDate);
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
          'Bill NO': data['billNo']?.toString() ?? 'N/A',
          'Bill Date': data['billDate']?.toString() ?? 'N/A',
          'Distributor Name': data['distributor']?.toString() ?? 'N/A',
          'Bill Value': data['netTotalAmount']?.toString() ?? 'N/A',
          'Open Bill': TextButton(
            onPressed: () {
              for (var product in data['entryProducts']) {
                tableData2.add({
                  'Product Name': product['Product Name'],
                  'Batch': product['Batch'],
                  'Expiry': product['Expiry'],
                  'Free': product['Free'],
                  'MRP': product['MRP'],
                  'Rate': product['Rate'],
                  'Tax': product['Tax'],
                  'CGST': product['CGST'],
                  'SGST': product['SGST'],
                  'Total Tax': product['Tax Total'],
                  'Return Quantity': product['Quantity'],
                  'Product Total': product['Product Total'],
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
                      height: 150,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                    child: Container(
                                  width: 850,
                                  height: 200,
                                  child: Column(children: [
                                    CustomDataTable(
                                        headers: headers2,
                                        tableData: tableData2),
                                    SizedBox(height: 10),
                                  ]),
                                ))
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
            child: CustomText(text: 'Open Bill'),
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

  void calculateTotals() {
    totalAmount = tableData.fold(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item['Bill Value']?.toString() ?? '0') ?? 0),
    );
  }

  @override
  void initState() {
    fetchDistributors();
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
              TimeDateWidget(text: 'Party Wise Statement'),
              Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.15,
                    child: PharmacyDropDown(
                      label: 'Distributor',
                      items: distributorsNames,
                      selectedItem: selectedDistributor,
                      onChanged: (value) {
                        setState(
                          () {
                            selectedDistributor = value;
                            fetchData(distributor: selectedDistributor);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  PharmacyTextField(
                    onTap: () => _selectDate(context, _dateController),
                    icon: Icon(Icons.date_range),
                    controller: _dateController,
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyButton(
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
                  PharmacyTextField(
                    onTap: () => _selectDate(context, _fromDateController),
                    icon: Icon(Icons.date_range),
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyTextField(
                    onTap: () => _selectDate(context, _toDateController),
                    icon: Icon(Icons.date_range),
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyButton(
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
                children: [CustomText(text: 'Available Party wise List')],
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
            ],
          ),
        ),
      ),
    );
  }
}
