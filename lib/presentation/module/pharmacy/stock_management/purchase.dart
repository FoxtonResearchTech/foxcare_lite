import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/purchase_entry.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _Purchase();
}

class _Purchase extends State<Purchase> {
  TextEditingController _purchaseBillNo = TextEditingController();
  TextEditingController _billNo = TextEditingController();

  final List<String> headers = [
    'Bill NO',
    'Bill Date',
    'Distributor Name',
    'Bill Amount',
    'Due Date',
  ];
  List<Map<String, dynamic>> tableData = [];
  Future<void> fetchData({String? purchaseBillNo, String? billNo}) async {
    try {
      CollectionReference productsCollection = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry');

      Query query = productsCollection;
      if (purchaseBillNo != null) {
        query = query.where('purchaseBillNo', isEqualTo: purchaseBillNo);
      } else if (billNo != null) {
        query = query.where('billNo', isEqualTo: billNo);
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
          'Bill Date': data['reportDate']?.toString() ?? 'N/A',
          'Distributor Name': '${data['distributor'] ?? 'N/A'}'.trim(),
          'Bill Amount': data['amount']?.toString() ?? 'N/A',
          'Due Date': data['DueDate']?.toString() ?? 'N/A',
        });
      }

      setState(() {
        tableData = fetchedData;
      });
      print(tableData);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    fetchData();

    super.initState();
  }

  @override
  void dispose() {
    _purchaseBillNo.dispose();
    _billNo.dispose();
    super.dispose();
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
                          text: "Purchase",
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    label: 'Purchase Entry',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PurchaseEntry()));
                    },
                    width: screenWidth * 0.12,
                    height: screenHeight * 0.04,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    controller: _purchaseBillNo,
                    hintText: 'Purchase Bill No',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                      label: 'Search',
                      onPressed: () {
                        fetchData(purchaseBillNo: _purchaseBillNo.text);
                      },
                      width: screenWidth * 0.08),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    controller: _billNo,
                    hintText: 'Bill No',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                      label: 'Search',
                      onPressed: () {
                        fetchData(billNo: _billNo.text);
                      },
                      width: screenWidth * 0.08),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Bill List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
