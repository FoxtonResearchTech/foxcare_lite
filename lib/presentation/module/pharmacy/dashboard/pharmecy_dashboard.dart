import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
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
    'Batch Number',
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
    'Batch Number',
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

      List<Map<String, dynamic>> allFetchedData = [];
      int slNo = 1;
      DocumentSnapshot? lastDoc;
      const int batchSize = 10;
      bool done = false;

      while (!done) {
        Query query = FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .limit(batchSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final productSnapshot = await query.get();

        if (productSnapshot.docs.isEmpty) break;

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
                DateTime todayOnly =
                    DateTime(today.year, today.month, today.day);
                DateTime tenDaysOnly = DateTime(tenDaysFromNow.year,
                    tenDaysFromNow.month, tenDaysFromNow.day);

                if ((expiryOnly.isAtSameMomentAs(todayOnly) ||
                        expiryOnly.isAfter(todayOnly)) &&
                    (expiryOnly.isAtSameMomentAs(tenDaysOnly) ||
                        expiryOnly.isBefore(tenDaysOnly))) {
                  allFetchedData.add({
                    'SL No': slNo++,
                    'Product Name': productName,
                    'Opening Stock': entryData['fixedQuantity'],
                    'Batch Number': entryData['batchNumber'],
                    'Remaining Stock': entryData['quantity'],
                    'Expiry Date': entryData['expiry'],
                  });

                  setState(() {
                    expiryStocksData = List.from(allFetchedData);
                  });

                  if (allFetchedData.length >= 5) {
                    done = true;
                    break;
                  }
                }
              } catch (e) {
                print(
                    "Invalid expiry date format in entry: ${entryData['expiry']}");
              }
            }
          }

          if (done) break;
        }

        lastDoc = productSnapshot.docs.last;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (allFetchedData.isEmpty) {
        print("No near-expiry products found");
        setState(() {
          expiryStocksData = [];
        });
      }
    } catch (e) {
      print('Error fetching near-expiry data: $e');
    }
  }

  Future<void> fetchNonMovingStocksData() async {
    try {
      List<Map<String, dynamic>> fetchedData = [];
      int i = 1;
      DocumentSnapshot? lastProductDoc;
      const int batchSize = 10;
      bool done = false;

      while (!done) {
        Query query = FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .limit(batchSize);

        if (lastProductDoc != null) {
          query = query.startAfterDocument(lastProductDoc);
        }

        final addedProductsSnapshot = await query.get();

        if (addedProductsSnapshot.docs.isEmpty) break;

        for (var productDoc in addedProductsSnapshot.docs) {
          final productData = productDoc.data() as Map<String, dynamic>;
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
                'Batch Number': purchaseData['batchNumber'],
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
                          title: const CustomText(
                            text: 'Non-Moving Stocks Details',
                            size: 22,
                          ),
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

              // Update UI for each matching entry
              setState(() {
                nonMovingStocksData = List.from(fetchedData);
              });

              if (fetchedData.length >= 5) {
                done = true;
                break;
              }
            }
          }

          if (done) break;
        }

        lastProductDoc = addedProductsSnapshot.docs.last;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // If nothing matched
      if (fetchedData.isEmpty) {
        print("No non-moving stocks found");
        setState(() {
          nonMovingStocksData = [];
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> getPharmacyIncome({String? fromDate, String? toDate}) async {
    double total = 0.0;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<String> subcollections = ['countersales', 'ipbilling', 'opbilling'];

    DateTime? from = fromDate != null ? DateTime.tryParse(fromDate) : null;
    DateTime? to = toDate != null ? DateTime.tryParse(toDate) : null;

    bool isInRange(String? dateStr) {
      if (dateStr == null) return false;
      final date = DateTime.tryParse(dateStr);
      if (date == null) return false;
      if (from != null && date.isBefore(from)) return false;
      if (to != null && date.isAfter(to)) return false;
      return true;
    }

    try {
      setState(() {
        isPharmacyTotalIncomeLoading = true;
      });

      const int pageSize = 10;

      for (String collection in subcollections) {
        DocumentSnapshot? lastDoc;
        bool hasMore = true;

        while (hasMore) {
          Query query = firestore
              .collection('pharmacy')
              .doc('billings')
              .collection(collection)
              .orderBy(FieldPath.documentId)
              .limit(pageSize);

          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          }

          final snapshot = await query.get();
          if (snapshot.docs.isEmpty) break;

          for (var doc in snapshot.docs) {
            final docId = doc.id;

            try {
              final paymentsSnapshot = await firestore
                  .collection('pharmacy')
                  .doc('billings')
                  .collection(collection)
                  .doc(docId)
                  .collection('payments')
                  .get();

              for (var payDoc in paymentsSnapshot.docs) {
                final payData = payDoc.data();
                final collectedStr = payData['collected']?.toString();
                final payedDateStr = payData['payedDate']?.toString();

                if (isInRange(payedDateStr)) {
                  final value = double.tryParse(collectedStr ?? '0') ?? 0;
                  total += value;
                }
              }
            } catch (e) {
              print('Error fetching payments in $collection/$docId: $e');
            }
          }

          lastDoc = snapshot.docs.last;
          hasMore = snapshot.docs.length == pageSize;
        }
      }

      setState(() {
        pharmacyTotalIncome = total.toInt();
        isPharmacyTotalIncomeLoading = false;
      });

      print("Pharmacy Total Income: $pharmacyTotalIncome");
    } catch (e) {
      print("Error fetching pharmacy income: $e");
    }
  }

  Future<void> getLastOPFewBills() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      List<Map<String, dynamic>> fetchedData = [];
      DocumentSnapshot? lastDoc;
      const int batchSize = 10;
      bool done = false;

      while (!done) {
        Query query = fireStore
            .collection('pharmacy')
            .doc('billings')
            .collection('opbilling')
            .where('billDate', isEqualTo: today)
            .limit(batchSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final QuerySnapshot patientSnapshot = await query.get();

        if (patientSnapshot.docs.isEmpty) break;

        for (var doc in patientSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (!data.containsKey('opNumber')) continue;

          fetchedData.add({
            'Bill No': data['billNo'] ?? 'N/A',
            'Patient Name': data['patientName'] ?? 'N/A',
            'Amount': data['netTotalAmount'] ?? 'N/A',
          });

          // Update after each match
          setState(() {
            opBillData = List.from(fetchedData);
          });

          if (fetchedData.length >= 5) {
            done = true;
            break;
          }
        }

        lastDoc = patientSnapshot.docs.last;

        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Ensure only 5 are shown
      setState(() {
        opBillData = fetchedData.take(5).toList();
      });
    } catch (e) {
      print('Error fetching documents: $e');
    }
  }

  Future<void> countTotalBillsToday() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<String> subcollections = ['opbilling', 'ipbilling', 'countersales'];

    int grandTotal = 0;

    try {
      for (String subcollection in subcollections) {
        int count = 0;
        DocumentSnapshot? lastDoc;
        const int batchSize = 20;
        bool done = false;

        while (!done) {
          Query query = fireStore
              .collection('pharmacy')
              .doc('billings')
              .collection(subcollection)
              .where('billDate', isEqualTo: today)
              .limit(batchSize);

          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          }

          final snapshot = await query.get();

          if (snapshot.docs.isEmpty) break;

          count += snapshot.docs.length;
          lastDoc = snapshot.docs.last;

          print('[$subcollection] Processed so far: $count');

          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Update respective counters
        if (subcollection == 'opbilling') {
          setState(() {
            todayTotalOpBills = count;
          });
        } else if (subcollection == 'ipbilling') {
          setState(() {
            todayTotalIpBills = count;
          });
        } else if (subcollection == 'countersales') {
          setState(() {
            todayTotalCounterSalesBills = count;
          });
        }

        grandTotal += count;
      }

      setState(() {
        todayTotalBills = grandTotal;
      });
    } catch (e) {
      print("Error counting bills: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      countTotalBillsToday();
      getLastOPFewBills();
      if (!mounted) return;
    });

    fetchNonMovingStocksData();
    fetchNearExpiryData();
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
              TimeDateWidget(text: 'Dashboard'),
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
                      LazyDataTable(
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
                              SizedBox(width: screenHeight * 0.02),
                              buildDashboardCard(
                                title: 'Total OP Bills',
                                value: todayTotalOpBills.toString(),
                                icon: Icons.person,
                                width: screenWidth * 0.14,
                                height: screenHeight * 0.14,
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
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
                              SizedBox(width: screenHeight * 0.02),
                              buildDashboardCard(
                                title: 'Total Counter Sales Bills',
                                value: todayTotalCounterSalesBills.toString(),
                                icon: Icons.person,
                                width: screenWidth * 0.14,
                                height: screenHeight * 0.14,
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.03),
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
                  LazyDataTable(
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
                  LazyDataTable(
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
