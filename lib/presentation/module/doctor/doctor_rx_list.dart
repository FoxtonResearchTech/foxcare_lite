import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/billings/counter_sales.dart';
import 'package:foxcare_lite/presentation/billings/ip_billing.dart';
import 'package:foxcare_lite/presentation/billings/medicine_return.dart';
import 'package:foxcare_lite/presentation/login/login.dart';
import 'package:foxcare_lite/presentation/reports/broken_or_damaged_statement.dart';
import 'package:foxcare_lite/presentation/reports/expiry_return_statement.dart';
import 'package:foxcare_lite/presentation/reports/non_moving_stock.dart';
import 'package:foxcare_lite/presentation/reports/party_wise_statement.dart';
import 'package:foxcare_lite/presentation/reports/pending_payment_report.dart';
import 'package:foxcare_lite/presentation/reports/product_wise_statement.dart';
import 'package:foxcare_lite/presentation/reports/stock_return_statement.dart';
import 'package:foxcare_lite/presentation/stock_management/add_product.dart';
import 'package:foxcare_lite/presentation/stock_management/cancel_bill.dart';
import 'package:foxcare_lite/presentation/stock_management/damage_return.dart';
import 'package:foxcare_lite/presentation/stock_management/delete_product.dart';
import 'package:foxcare_lite/presentation/stock_management/expiry_return.dart';
import 'package:foxcare_lite/presentation/stock_management/product_list.dart';
import 'package:foxcare_lite/presentation/stock_management/purchase.dart';
import 'package:foxcare_lite/presentation/stock_management/purchase_order.dart';
import 'package:foxcare_lite/presentation/stock_management/stock_return.dart';
import 'package:foxcare_lite/presentation/tools/add_new_distributor.dart';
import 'package:foxcare_lite/presentation/tools/distributor_list.dart';
import 'package:foxcare_lite/presentation/tools/pharmacy_info.dart';
import 'package:foxcare_lite/presentation/tools/profile.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

class DoctorRxList extends StatefulWidget {
  const DoctorRxList({super.key});

  @override
  State<DoctorRxList> createState() => _DoctorRxList();
}

class _DoctorRxList extends State<DoctorRxList> {
  final List<String> headers1 = [
    'Token NO',
    'OP NO',
    'Name',
    'Age',
    'Place',
    'Primary Info',
    'Action'
  ];
  List<Map<String, dynamic>> tableData1 = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch all documents from the 'patients' collection
      final QuerySnapshot patientSnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        String tokenNo = '';
        try {
          final tokenSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('tokens')
              .doc('currentToken')
              .get();

          if (tokenSnapshot.exists) {
            final tokenData = tokenSnapshot.data();
            if (tokenData != null && tokenData['tokenNumber'] != null) {
              tokenNo = tokenData['tokenNumber'].toString();
            }
          }
        } catch (e) {
          print('Error fetching tokenNo for patient ${doc.id}: $e');
        }

        fetchedData.add({
          'Token NO': tokenNo,
          'OP NO': data['patientID'] ?? '',
          'Name': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
          'Age': data['age'] ?? '',
          'Place': data['state'] ?? '',
          'Primary Info': data['primaryInfo'] ?? '',
          'Action': data['action'] ?? '',
        });
      }

      // Sort data by 'Token NO'
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Token NO']) ?? 0;
        int tokenB = int.tryParse(b['Token NO']) ?? 0;
        return tokenA.compareTo(tokenB); // Ascending order
      });

      setState(() {
        tableData1 = fetchedData;
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: CustomText(
          text: "Doctor RX Prescription",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        backgroundColor: AppColors.secondaryColor,
      ),
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
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                tableData: tableData1,
                headers: headers1,
              ),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
