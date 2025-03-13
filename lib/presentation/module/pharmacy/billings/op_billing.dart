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
import '../tools/manage_pharmacy_info.dart';
import 'counter_sales.dart';
import 'medicine_return.dart';

class OpBilling extends StatefulWidget {
  const OpBilling({super.key});

  @override
  State<OpBilling> createState() => _OpBilling();
}

class _OpBilling extends State<OpBilling> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _opNumber = TextEditingController();
  TextEditingController patientName = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController place = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController billNo = TextEditingController();

  double totalAmount = 0.0;
  double taxPercentage = 12;
  double gstPercentage = 10;
  double taxAmount = 0.00;
  double gstAmount = 0.00;
  double totalGst = 0.00;
  double grandTotal = 0.00;

  final List<String> headers = [
    'Product Name',
    'Type',
    'Batch',
    'EXP',
    'HSN',
    'Quantity',
    'MPS',
    'Price',
    'Gst',
    'Amount',
  ];

  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({String? opNumber}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (opNumber != null) {
        query = query.where('opNumber', isEqualTo: opNumber);
      }

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          tableData = [];
          resetTotals();
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data.isNotEmpty) {
          setState(() {
            gender.text = data['sex'] ?? 'N/A';
            patientName.text =
                (data['firstName'] ?? '') + ' ' + (data['lastName'] ?? 'N/A');
            age.text = data['age'] ?? 'N/A';
            place.text = data['city'] ?? 'N/A';
            phoneNumber.text = data['phoneNumber'] ?? 'N/A';
          });
        }

        List<dynamic> medicines = data['Medication'] ?? [];

        for (String medicineName in medicines) {
          QuerySnapshot medicineSnapshot = await FirebaseFirestore.instance
              .collection('stock')
              .doc('Products')
              .collection('AddedProducts')
              .where('productName', isEqualTo: medicineName)
              .get();

          for (var medicineDoc in medicineSnapshot.docs) {
            var medicineData = medicineDoc.data() as Map<String, dynamic>;

            fetchedData.add({
              'Product Name': medicineData['productName'] ?? 'N/A',
              'Type': medicineData['type'] ?? 'N/A',
              'Batch': medicineData['batchNumber'] ?? 'N/A',
              'EXP': medicineData['expiry'] ?? 'N/A',
              'HSN': medicineData['hsnCode'] ?? 'N/A',
              'Quantity': '',
              'MPS': medicineData['mrp'] ?? 'N/A',
              'Price': medicineData['price'] ?? 'N/A',
              'Gst': (medicineData['gst'] ?? 0).toString() + '%',
              'Amount': medicineData['amount'] ?? 'N/A',
            });
          }
        }
      }

      setState(() {
        tableData = fetchedData;
        calculateTotals();

        if (opNumber == null) {
          resetTotals();
        }
      });

      print(tableData);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

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
          .collection('opbilling')
          .doc();
      List<Map<String, dynamic>> updatedTableData = tableData.map((item) {
        return {
          'Product Name': item['Product Name'] ?? 'N/A',
          'Type': item['Type'] ?? 'N/A',
          'Batch': item['Batch'] ?? 'N/A',
          'EXP': item['EXP'] ?? 'N/A',
          'HSN': item['HSN'] ?? 'N/A',
          'Quantity': item['Quantity'] ?? '0',
          'MPS': item['MPS'] ?? 'N/A',
          'Price': item['Price'] ?? 'N/A',
          'Gst': item['Gst'] ?? '0%',
          'Amount': item['Amount'] ?? '0.00',
        };
      }).toList();
      Map<String, dynamic> billingData = {
        'billNo': billNo.text,
        'opNumber': _opNumber.text,
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
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                    controller: _opNumber,
                    hintText: 'OP Number',
                    width: screenWidth * 0.25,
                    onChanged: (value) {
                      fetchData(opNumber: value);
                    },
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
              if (tableData.isNotEmpty) ...[
                CustomDataTable(
                    tableData: tableData,
                    headers: headers,
                    editableColumns: ['Quantity'],
                    onValueChanged: (rowIndex, header, value) async {
                      if (header == 'Quantity') {
                        if (rowIndex >= 0 && rowIndex < tableData.length) {
                          setState(() {
                            tableData[rowIndex]['Quantity'] = value;

                            double quantity =
                                double.tryParse(value.toString()) ?? 0;
                            double amountPerUnit = double.tryParse(
                                    tableData[rowIndex]['Amount']?.toString() ??
                                        '0') ??
                                0;
                            double gstRate = double.tryParse(tableData[rowIndex]
                                            ['Gst']
                                        ?.replaceAll('%', '') ??
                                    '0') ??
                                0;

                            double totalAmountForItem =
                                quantity * amountPerUnit;
                            double itemGst =
                                (totalAmountForItem * gstRate) / 100;

                            tableData[rowIndex]['Amount'] =
                                totalAmountForItem.toStringAsFixed(2);
                            calculateTotals();
                          });
                        } else {
                          print("Error: rowIndex $rowIndex is out of range.");
                        }
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
