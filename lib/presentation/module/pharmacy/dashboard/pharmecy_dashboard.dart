import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';

class SalesChartScreen extends StatefulWidget {
  const SalesChartScreen({Key? key}) : super(key: key);

  @override
  State<SalesChartScreen> createState() => _SalesChartScreenState();
}

class _SalesChartScreenState extends State<SalesChartScreen> {
  final List<String> opBillHeaders = ['Bill No', 'Patient Name', 'Amount'];
  List<Map<String, dynamic>> opBillData = [];
  Timer? _timer;
  int todayTotalBills = 0;
  int todayTotalOpBills = 0;
  int todayTotalIpBills = 0;
  int todayTotalCounterSalesBills = 0;
  bool isPharmacyTotalIncomeLoading = false;
  int pharmacyTotalIncome = 0;
  int i = 1;

  final List<String> nonMovingStocksHeader = [
    'SL No',
    'Product Name',
    'Opening Stock',
    'Remaining Stock',
    'Expiry Date',
    'Non-Moving Details',
  ];
  List<Map<String, dynamic>> nonMovingStocksData = [];
  final List<String> expiryStocksHeader = [
    'SL No',
    'Product Name',
    'Opening Stock',
    'Remaining Stock',
    'Expiry Date',
  ];
  List<Map<String, dynamic>> expiryStocksData = [];

  final Map<int, FixedColumnWidth> columnWidths = {
    0: const FixedColumnWidth(240.0),
    1: const FixedColumnWidth(240.0),
    2: const FixedColumnWidth(240.0),
  };

  Future<void> fetchNearExpiryData() async {
    try {
      final DateTime today = DateTime.now();
      final DateTime tenDaysFromNow = today.add(const Duration(days: 10));

      final QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('AddedProducts')
          .get();

      if (productSnapshot.docs.isEmpty) {
        print("No products found");
        setState(() {
          expiryStocksData = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];
      int slNo = 1;

      for (var productDoc in productSnapshot.docs) {
        final productData = productDoc.data() as Map<String, dynamic>;
        final productName = productData['productName'];

        final purchaseSnapshot = await FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .doc(productDoc.id)
            .collection('purchaseEntry')
            .get();

        for (var entryDoc in purchaseSnapshot.docs) {
          final entryData = entryDoc.data();

          if (entryData.containsKey('fixedQuantity') &&
              entryData.containsKey('quantity') &&
              entryData.containsKey('expiry')) {
            try {
              DateTime expiryDate = DateTime.parse(entryData['expiry']);

              DateTime expiryOnly =
                  DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
              DateTime todayOnly = DateTime(today.year, today.month, today.day);
              DateTime tenDaysOnly = DateTime(tenDaysFromNow.year,
                  tenDaysFromNow.month, tenDaysFromNow.day);

              if ((expiryOnly.isAtSameMomentAs(todayOnly) ||
                      expiryOnly.isAfter(todayOnly)) &&
                  (expiryOnly.isAtSameMomentAs(tenDaysOnly) ||
                      expiryOnly.isBefore(tenDaysOnly))) {
                fetchedData.add({
                  'SL No': slNo++,
                  'Product Name': productName,
                  'Opening Stock': entryData['fixedQuantity'],
                  'Remaining Stock': entryData['quantity'],
                  'Expiry Date': entryData['expiry'],
                });

                if (fetchedData.length >= 5) break;
              }
            } catch (e) {
              print(
                  "Invalid expiry date format in entry: ${entryData['expiry']}");
            }
          }
        }

        if (fetchedData.length >= 5) break;
      }

      setState(() {
        expiryStocksData = fetchedData;
      });
    } catch (e) {
      print('Error fetching near-expiry data: $e');
    }
  }

  Future<void> fetchNonMovingStocksData() async {
    try {
      final addedProductsSnapshot = await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('AddedProducts')
          .limit(5)
          .get();

      if (addedProductsSnapshot.docs.isEmpty) {
        print("No products found");
        setState(() {
          nonMovingStocksData = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];
      int i = 1;

      for (var productDoc in addedProductsSnapshot.docs) {
        final productData = productDoc.data();
        final docId = productDoc.id;

        final purchaseEntriesSnapshot = await FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .doc(docId)
            .collection('purchaseEntry')
            .get();

        for (var purchaseDoc in purchaseEntriesSnapshot.docs) {
          final purchaseData = purchaseDoc.data();

          if (!purchaseData.containsKey('reportDate') ||
              !purchaseData.containsKey('fixedQuantity') ||
              !purchaseData.containsKey('quantity')) continue;

          String reportDateStr = purchaseData['reportDate'];
          DateTime reportDate =
              DateTime.tryParse(reportDateStr) ?? DateTime(1900);

          if (purchaseData['fixedQuantity'] == purchaseData['quantity']) {
            fetchedData.add({
              'SL No': i++,
              'Product Name': productData['productName'],
              'Opening Stock': purchaseData['fixedQuantity'],
              'Remaining Stock': purchaseData['quantity'],
              'Expiry Date': purchaseData['expiry'],
              'Non-Moving Details': TextButton(
                onPressed: () {
                  int daysDifference =
                      DateTime.now().difference(reportDate).inDays;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Non-Moving Stocks Details'),
                        content: Container(
                          width: 350,
                          height: 180,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                  text: 'Product Entry Date: $reportDateStr'),
                              CustomText(
                                  text:
                                      'Product Name: ${productData['productName']}'),
                              CustomText(
                                  text:
                                      'Opening Stock: ${purchaseData['fixedQuantity']}'),
                              CustomText(
                                  text:
                                      'Remaining Stock: ${purchaseData['quantity']}'),
                              CustomText(
                                  text:
                                      'Expiry Date: ${purchaseData['expiry']}'),
                              CustomText(
                                  text:
                                      'Days Since Entry: $daysDifference days'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: CustomText(
                              text: 'Close',
                              color: AppColors.secondaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: CustomText(text: 'View Details'),
              ),
            });
          }
        }
      }

      setState(() {
        nonMovingStocksData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> getPharmacyIncome() async {
    double total = 0.0;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<String> subcollections = ['countersales', 'ipbilling', 'opbilling'];

    try {
      setState(() {
        isPharmacyTotalIncomeLoading = true;
      });

      for (String collection in subcollections) {
        final QuerySnapshot snapshot = await firestore
            .collection('pharmacy')
            .doc('billings')
            .collection(collection)
            .where('billDate', isEqualTo: today)
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          double value =
              double.tryParse(data['netTotalAmount']?.toString() ?? '0') ?? 0;
          total += value;
        }
      }

      setState(() {
        pharmacyTotalIncome = total.toInt();
        isPharmacyTotalIncomeLoading = false;
      });

      print("Pharmacy Total Income (today): $pharmacyTotalIncome");
    } catch (e) {
      print("Error fetching today's pharmacy income: $e");
    }
  }

  Future<void> getLastOPFewBills() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final QuerySnapshot patientSnapshot = await fireStore
          .collection('pharmacy')
          .doc('billings')
          .collection('opbilling')
          .where('billDate', isEqualTo: today)
          .get();

      List<Map<String, dynamic>> fetchedData = [];
      int count = 0;

      for (var doc in patientSnapshot.docs) {
        if (count >= 5) break;

        final data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('opNumber')) continue;

        fetchedData.add({
          'Bill No': data['billNo'] ?? 'N/A',
          'Patient Name': data['patientName'] ?? 'N/A',
          'Amount': data['netTotalAmount'] ?? 'N/A',
        });

        count++;
      }

      setState(() {
        opBillData = fetchedData;
      });
    } catch (e) {
      print('Error fetching documents: $e');
    }
  }

  Future<void> countTotalBillsToday() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int totalBills = 0;

    try {
      final List<String> subcollections = [
        'opbilling',
        'ipbilling',
        'countersales'
      ];

      for (String subcollection in subcollections) {
        final QuerySnapshot snapshot = await fireStore
            .collection('pharmacy')
            .doc('billings')
            .collection(subcollection)
            .where('billDate', isEqualTo: today)
            .get();

        totalBills += snapshot.docs.length;
      }

      setState(() {
        todayTotalBills = totalBills;
      });
    } catch (e) {
      print("Error counting bills: $e");
    }
  }

  Future<void> countTotalOpBillsToday() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int totalBills = 0;

    try {
      final QuerySnapshot snapshot = await fireStore
          .collection('pharmacy')
          .doc('billings')
          .collection('opbilling')
          .where('billDate', isEqualTo: today)
          .get();

      totalBills = snapshot.docs.length;

      setState(() {
        todayTotalOpBills = totalBills;
      });
    } catch (e) {
      print("Error counting bills: $e");
    }
  }

  Future<void> countTotalIpBillsToday() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int totalBills = 0;

    try {
      final QuerySnapshot snapshot = await fireStore
          .collection('pharmacy')
          .doc('billings')
          .collection('ipbilling')
          .where('billDate', isEqualTo: today)
          .get();

      totalBills = snapshot.docs.length;

      setState(() {
        todayTotalIpBills = totalBills;
      });
    } catch (e) {
      print("Error counting bills: $e");
    }
  }

  Future<void> countTotalCounterSalesBillsToday() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int totalBills = 0;

    try {
      final QuerySnapshot snapshot = await fireStore
          .collection('pharmacy')
          .doc('billings')
          .collection('countersales')
          .where('billDate', isEqualTo: today)
          .get();

      totalBills = snapshot.docs.length;

      setState(() {
        todayTotalCounterSalesBills = totalBills;
      });
    } catch (e) {
      print("Error counting bills: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      getLastOPFewBills();
      countTotalBillsToday();
      countTotalOpBillsToday();
      countTotalIpBillsToday();
      countTotalCounterSalesBillsToday();
      fetchNonMovingStocksData();
      fetchNearExpiryData();
    });
    getPharmacyIncome();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenHeight * 0.05,
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
                          text: "Dashboard",
                          size: screenWidth * 0.03,
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
              Column(
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: 'Recent OP Bills ',
                        size: screenWidth * 0.02,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDataTable(
                        headers: opBillHeaders,
                        tableData: opBillData,
                        columnWidths: columnWidths,
                      ),
                      SizedBox(width: screenHeight * 0.15),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildDashboardCard(
                                title: 'Total Bills',
                                value: todayTotalBills.toString(),
                                icon: Icons.dock,
                                width: screenWidth * 0.14,
                                height: screenHeight * 0.14,
                              ),
                              SizedBox(width: screenHeight * 0.05),
                              buildDashboardCard(
                                title: 'Total OP Bills',
                                value: todayTotalOpBills.toString(),
                                icon: Icons.person,
                                width: screenWidth * 0.14,
                                height: screenHeight * 0.14,
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildDashboardCard(
                                title: 'Total IP Bills',
                                value: todayTotalIpBills.toString(),
                                icon: Icons.person,
                                width: screenWidth * 0.14,
                                height: screenHeight * 0.14,
                              ),
                              SizedBox(width: screenHeight * 0.05),
                              buildDashboardCard(
                                title: 'Total Counter Sales Bills',
                                value: todayTotalCounterSalesBills.toString(),
                                icon: Icons.person,
                                width: screenWidth * 0.14,
                                height: screenHeight * 0.14,
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildDashboardCard(
                                title: 'Total Collected Payments',
                                value: isPharmacyTotalIncomeLoading
                                    ? 'Calculating...'
                                    : '₹ ' + pharmacyTotalIncome.toString(),
                                icon: Icons.attach_money,
                                width: screenWidth * 0.29,
                                height: screenHeight * 0.14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Column(
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: 'Non Moving Stocks Products',
                        size: screenWidth * 0.02,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  CustomDataTable(
                    headers: nonMovingStocksHeader,
                    tableData: nonMovingStocksData,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Column(
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: 'Expiry Stocks Products',
                        size: screenWidth * 0.02,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  CustomDataTable(
                    headers: expiryStocksHeader,
                    tableData: expiryStocksData,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required double width,
    required double height,
    Color? color,
  }) {
    color ??= AppColors.blue;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.01),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon, size: screenWidth * 0.02, color: Colors.white),
          CustomText(
            text: title,
            color: Colors.white,
          ),
          CustomText(
            text: value,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
