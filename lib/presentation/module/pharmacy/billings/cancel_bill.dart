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

class CancelBill extends StatefulWidget {
  const CancelBill({super.key});

  @override
  State<CancelBill> createState() => _CancelBill();
}

class _CancelBill extends State<CancelBill> {
  final dateTime = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final List<String> opHeaders = [
    'Bill No',
    'Bill Date',
    'Patient Name',
    'OP No',
    'Doctor Name',
    'Action',
  ];
  List<Map<String, dynamic>> opTableData = [];
  final List<String> ipHeaders = [
    'Bill No',
    'Bill Date',
    'Patient Name',
    'IP No',
    'Doctor Name',
    'Action',
  ];
  List<Map<String, dynamic>> ipTableData = [];
  final List<String> counterSalesHeaders = [
    'Bill No',
    'Bill Date',
    'Patient Name',
    'Doctor Name',
    'Action',
  ];
  List<Map<String, dynamic>> counterSalesTableData = [];
  String formatDate(DateTime dateTime) {
    return dateTime.day.toString().padLeft(2, '0') +
        getDaySuffix(dateTime.day) +
        ' ' +
        DateFormat('MMM').format(dateTime) +
        ' ' +
        dateTime.year.toString();
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> fetchOpBills({String? billDate}) async {
    String todaysDate = dateTime.year.toString() +
        '-' +
        dateTime.month.toString().padLeft(2, '0') +
        '-' +
        dateTime.day.toString().padLeft(2, '0');
    billDate = todaysDate;
    try {
      Query query = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billing')
          .collection('opbilling');

      if (billDate != null) {
        query = query.where('billDate', isEqualTo: billDate);
      }

      final QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> fetchedData = [];

      for (var bills in snapshot.docs) {
        final data = bills.data() as Map<String, dynamic>;

        if (data.isNotEmpty) {
          fetchedData.add({
            'Bill No': data['billNo'] ?? 'N/A',
            'Patient Name': data['patientName'] ?? 'N/A',
            'OP No': data['opNumber'] ?? 'N/A',
            'Bill Date': data['billDate'] ?? 'N/A',
            'Doctor Name': data['doctorName'] ?? 'N/A',
            'Action': TextButton(
              onPressed: () => cancelOpBill(
                  bills.id, data['items'] ?? []), // Pass bill ID and items
              child: CustomText(text: 'Cancel'),
            ),
          });
        }
      }

      setState(() {
        opTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> cancelOpBill(String billId, List<dynamic> items) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      for (var item in items) {
        String productName = item['Product Name'];
        String batchNumber = item['Batch'];
        String hsnCode = item['HSN'];
        int quantityToAdd = int.tryParse(item['Quantity'].toString()) ?? 0;

        QuerySnapshot productQuery = await firestore
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .where('productName', isEqualTo: productName)
            .where('batchNumber', isEqualTo: batchNumber)
            .where('hsnCode', isEqualTo: hsnCode)
            .get();

        if (productQuery.docs.isNotEmpty) {
          DocumentReference productRef = productQuery.docs.first.reference;

          batch.update(productRef, {
            'quantity': FieldValue.increment(quantityToAdd),
          });
        }
      }

      DocumentReference billRef = firestore
          .collection('pharmacy')
          .doc('billing')
          .collection('opbilling')
          .doc(billId);

      batch.delete(billRef);

      await batch.commit();
      CustomSnackBar(context,
          message: 'Bill canceled, and product quantities updated successfully',
          backgroundColor: Colors.green);

      print('Bill canceled, and product quantities updated successfully');
      fetchOpBills();
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed tp cancel bill and product quantities ',
          backgroundColor: Colors.red);

      print('Error canceling bill: $e');
    }
  }

  Future<void> fetchIpBills({String? billDate}) async {
    String todaysDate = dateTime.year.toString() +
        '-' +
        dateTime.month.toString().padLeft(2, '0') +
        '-' +
        dateTime.day.toString().padLeft(2, '0');
    billDate = todaysDate;
    try {
      Query query = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billing')
          .collection('ipbilling');

      if (billDate != null) {
        query = query.where('billDate', isEqualTo: billDate);
      }

      final QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var bills in snapshot.docs) {
        final data = bills.data() as Map<String, dynamic>;

        if (data.isNotEmpty) {
          fetchedData.add({
            'Bill NO': data['billNo'] ?? 'N/A',
            'Patient Name': data['patientName'] ?? 'N/A',
            'IP No': data['ipNumber'] ?? 'N/A',
            'Bill Date': data['billDate'] ?? 'N/A',
            'Doctor Name': data['doctorName'] ?? 'N/A',
            'Action': TextButton(
              onPressed: () => cancelIpBill(
                  bills.id, data['items'] ?? []), // Pass bill ID and items
              child: CustomText(text: 'Cancel'),
            ),
          });
        }
      }

      setState(() {
        ipTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> cancelIpBill(String billId, List<dynamic> items) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      for (var item in items) {
        String productName = item['Product Name'];
        String batchNumber = item['Batch'];
        String hsnCode = item['HSN'];
        int quantityToAdd = int.tryParse(item['Quantity'].toString()) ?? 0;

        QuerySnapshot productQuery = await firestore
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .where('productName', isEqualTo: productName)
            .where('batchNumber', isEqualTo: batchNumber)
            .where('hsnCode', isEqualTo: hsnCode)
            .get();

        if (productQuery.docs.isNotEmpty) {
          DocumentReference productRef = productQuery.docs.first.reference;

          batch.update(productRef, {
            'quantity': FieldValue.increment(quantityToAdd),
          });
        }
      }

      DocumentReference billRef = firestore
          .collection('pharmacy')
          .doc('billing')
          .collection('ipbilling')
          .doc(billId);

      batch.delete(billRef);

      await batch.commit();
      CustomSnackBar(context,
          message: 'Bill canceled, and product quantities updated successfully',
          backgroundColor: Colors.green);
      print('Bill canceled, and product quantities updated successfully.');
      fetchOpBills();
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed tp cancel bill and product quantities ',
          backgroundColor: Colors.red);

      print('Error canceling bill: $e');
    }
  }

  Future<void> fetchCounterSalesBills({String? billDate}) async {
    String todaysDate = dateTime.year.toString() +
        '-' +
        dateTime.month.toString().padLeft(2, '0') +
        '-' +
        dateTime.day.toString().padLeft(2, '0');
    billDate = todaysDate;
    try {
      Query query = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billing')
          .collection('countersales');

      if (billDate != null) {
        query = query.where('billDate', isEqualTo: billDate);
      }

      final QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var bills in snapshot.docs) {
        final data = bills.data() as Map<String, dynamic>;

        if (data.isNotEmpty) {
          fetchedData.add({
            'Bill NO': data['billNo'] ?? 'N/A',
            'Patient Name': data['patientName'] ?? 'N/A',
            'Bill Date': data['billDate'] ?? 'N/A',
            'Doctor Name': data['doctorName'] ?? 'N/A',
            'Action': TextButton(
              onPressed: () => cancelCounterSalesBill(
                  bills.id, data['items'] ?? []), // Pass bill ID and items
              child: CustomText(text: 'Cancel'),
            ),
          });
        }
      }

      setState(() {
        counterSalesTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> cancelCounterSalesBill(
      String billId, List<dynamic> items) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      for (var item in items) {
        String productName = item['Product Name'];
        String batchNumber = item['Batch'];
        String hsnCode = item['HSN'];
        int quantityToAdd = int.tryParse(item['Quantity'].toString()) ?? 0;

        QuerySnapshot productQuery = await firestore
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .where('productName', isEqualTo: productName)
            .where('batchNumber', isEqualTo: batchNumber)
            .where('hsnCode', isEqualTo: hsnCode)
            .get();

        if (productQuery.docs.isNotEmpty) {
          DocumentReference productRef = productQuery.docs.first.reference;

          batch.update(productRef, {
            'quantity': FieldValue.increment(quantityToAdd),
          });
        }
      }

      DocumentReference billRef = firestore
          .collection('pharmacy')
          .doc('billing')
          .collection('countersales')
          .doc(billId);

      batch.delete(billRef);

      await batch.commit();

      CustomSnackBar(context,
          message: 'Bill canceled, and product quantities updated successfully',
          backgroundColor: Colors.green);

      print('Bill canceled, and product quantities updated successfully');
      fetchOpBills();
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed tp cancel bill and product quantities ',
          backgroundColor: Colors.red);
      print('Error canceling bill: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOpBills();
    fetchIpBills();
    fetchCounterSalesBills();
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
                  CustomText(
                    text: 'OP Billing',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  CustomText(
                    text: '${formatDate(dateTime)}',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomDataTable(headers: opHeaders, tableData: opTableData),
              SizedBox(height: screenHeight * 0.05),
              Row(
                children: [
                  CustomText(
                    text: 'IP Billing ',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  CustomText(
                    text: '${formatDate(dateTime)}',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomDataTable(headers: ipHeaders, tableData: ipTableData),
              SizedBox(height: screenHeight * 0.05),
              Row(
                children: [
                  CustomText(
                    text: 'Counter Sales',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  CustomText(
                    text: '${formatDate(dateTime)}',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomDataTable(
                  headers: counterSalesHeaders,
                  tableData: counterSalesTableData),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
