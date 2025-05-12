import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/purchase_entry.dart';
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

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _Purchase();
}

class _Purchase extends State<Purchase> {
  TextEditingController _distributor = TextEditingController();
  TextEditingController _billNo = TextEditingController();

  List<String> distributorsNames = [];
  String? selectedDistributor;

  final List<String> headers = [
    'Bill NO',
    'Bill Date',
    'Ref No',
    'Distributor',
    'Amount',
    'Paid',
    'Balance',
    'Action'
  ];
  List<Map<String, dynamic>> tableData = [];
  Future<void> fetchData({String? distributor, String? billNo}) async {
    try {
      CollectionReference productsCollection = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry');

      Query query = productsCollection;
      if (distributor != null) {
        query = query.where('distributor', isEqualTo: distributor);
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

        fetchedData.add(
          {
            'Bill NO': data['billNo']?.toString() ?? 'N/A',
            'Bill Date': data['billDate']?.toString() ?? 'N/A',
            'Ref No': data['rfNo']?.toString() ?? 'N/A',
            'Distributor': '${data['distributor'] ?? 'N/A'}'.trim(),
            'Amount': data['totalAmount']?.toString() ?? 'N/A',
            'Paid': data['collectedAmount']?.toString() ?? 'N/A',
            'Balance': data['balance']?.toString() ?? 'N/A',
            'Action': Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {},
                  child: CustomText(
                    text: 'Pay',
                    color: AppColors.blue,
                    size: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: CustomText(
                    text: 'Open',
                    color: AppColors.blue,
                    size: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: CustomText(
                    text: 'Abscond',
                    color: AppColors.blue,
                    size: 14,
                  ),
                ),
              ],
            ),
          },
        );
      }

      setState(() {
        tableData = fetchedData;
      });
      print(tableData);
    } catch (e) {
      print('Error fetching data: $e');
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

  @override
  void initState() {
    fetchData();
    fetchDistributors();

    super.initState();
  }

  @override
  void dispose() {
    _distributor.dispose();
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
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              TimeDateWidget(text: 'Purchase'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PharmacyButton(
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
                  PharmacyTextField(
                    controller: _billNo,
                    hintText: 'Bill No',
                    width: screenWidth * 0.25,
                    verticalSize: screenHeight * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyButton(
                      label: 'Search',
                      onPressed: () {
                        fetchData(billNo: _billNo.text);
                      },
                      width: screenWidth * 0.08),
                  SizedBox(width: screenHeight * 0.2),
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
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(distributor: selectedDistributor);
                    },
                    width: screenWidth * 0.08,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Bill List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                columnWidths: {
                  7: FixedColumnWidth(screenWidth * 0.15),
                },
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
