import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/purchase_entry.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/constants.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/refreshLoading/refreshLoading.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../tools/manage_pharmacy_info.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _Purchase();
}

class _Purchase extends State<Purchase> {
  DateTime dateTime = DateTime.now();
  bool distributorSearch = false;
  bool billNoSearch = false;
  TextEditingController _distributor = TextEditingController();
  TextEditingController _billNo = TextEditingController();

  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController collectedAmountController =
      TextEditingController();
  final TextEditingController currentlyPayingAmount = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();
  String? selectedPaymentMode;

  List<String> distributorsNames = [];
  String? selectedDistributor;
  double _originalCollected = 0.0;

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
  final List<String> historyHeaders = [
    'Payment Mode',
    'Payment Details',
    'Payed Date',
    'Payed Time',
    'Collected',
    'Balance',
  ];
  final List<String> headers2 = [
    'Product Name',
    'Batch',
    'Expiry',
    'Quantity',
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
  List<Map<String, dynamic>> historyTableData = [];
  Future<void> savePayment({
    required String docId,
    required String totalAmount,
    required String collected,
    required String balance,
    required String paymentMode,
    required String payingAmount,
  }) async {
    if (selectedPaymentMode == null ||
        paymentDetails.text.isEmpty ||
        currentlyPayingAmount.text.isEmpty) {
      CustomSnackBar(
        context,
        message: "Please fill all the required fields",
        backgroundColor: Colors.orange,
      );
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry')
          .doc(docId)
          .update({
        'netTotalAmount': totalAmount,
        'totalAmount': totalAmount,
        'collectedAmount': collected,
        'balance': balance,
      });
      await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry')
          .doc(docId)
          .collection('payments')
          .doc()
          .set({
        'collected': payingAmount,
        'balance': balance,
        'paymentMode': paymentMode,
        'paymentDetails': paymentDetails.text,
        'payedDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'payedTime': dateTime.hour.toString() +
            ':' +
            dateTime.minute.toString().padLeft(2, '0'),
      });
      fetchData();
      Navigator.of(context).pop();
      CustomSnackBar(context,
          message: "Payment Updated Successfully",
          backgroundColor: Colors.green);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to register patient: $e")),
      );
    }
  }

  Future<void> historyData({required String docId}) async {
    try {
      DocumentReference patientDoc = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry')
          .doc(docId);

      QuerySnapshot snapshot = await patientDoc.collection('payments').get();

      if (snapshot.docs.isEmpty) {
        print("No records found");
        setState(() {
          historyTableData = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        fetchedData.add({
          'Payment Mode': data['paymentMode']?.toString() ?? 'N/A',
          'Payment Details': data['paymentDetails']?.toString() ?? 'N/A',
          'Payed Date': data['payedDate']?.toString() ?? 'N/A',
          'Payed Time': data['payedTime']?.toString() ?? 'N/A',
          'Collected': data['collected']?.toString() ?? 'N/A',
          'Balance': data['balance']?.toString() ?? 'N/A',
        });
      }

      fetchedData.sort((a, b) {
        String formatTime(String time) {
          List<String> parts = time.split(':');
          String hour = parts[0].padLeft(2, '0');
          String minute = parts.length > 1 ? parts[1] : '00';
          return '$hour:$minute';
        }

        String dateTimeStrA =
            '${a['Payed Date']} ${formatTime(a['Payed Time'])}';
        String dateTimeStrB =
            '${b['Payed Date']} ${formatTime(b['Payed Time'])}';

        DateTime dateTimeA = DateTime.tryParse(dateTimeStrA) ?? DateTime(0);
        DateTime dateTimeB = DateTime.tryParse(dateTimeStrB) ?? DateTime(0);

        return dateTimeA.compareTo(dateTimeB);
      });

      setState(() {
        historyTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _payingAmountListener() {
    double paying = double.tryParse(currentlyPayingAmount.text) ?? 0.0;
    double total = double.tryParse(totalAmountController.text) ?? 0.0;

    double newCollected = _originalCollected + paying;
    double newBalance = total - newCollected;

    collectedAmountController.text = newCollected.toStringAsFixed(2);
    balanceController.text = newBalance.toStringAsFixed(2);
  }

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

      const int batchSize = 15;
      DocumentSnapshot? lastDoc;
      List<Map<String, dynamic>> accumulatedData = [];

      while (true) {
        Query paginatedQuery = query.limit(batchSize);

        if (lastDoc != null) {
          paginatedQuery = paginatedQuery.startAfterDocument(lastDoc);
        }

        final QuerySnapshot snapshot = await paginatedQuery.get();

        if (snapshot.docs.isEmpty) {
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          accumulatedData.add({
            'Bill NO': data['billNo']?.toString() ?? 'N/A',
            'Bill Date': data['billDate']?.toString() ?? 'N/A',
            'Ref No': data['rfNo']?.toString() ?? 'N/A',
            'Distributor': '${data['distributor'] ?? 'N/A'}'.trim(),
            'Amount': data['netTotalAmount']?.toString() ?? 'N/A',
            'Paid': data['collectedAmount']?.toString() ?? 'N/A',
            'Balance': data['balance']?.toString() ?? 'N/A',
            'Action': Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    await historyData(docId: doc.id.toString());
                    paymentDetails.clear();

                    double originalCollected = double.tryParse(
                            data['collectedAmount']?.toString() ?? '0') ??
                        0.0;
                    double total = double.tryParse(
                            data['netTotalAmount']?.toString() ?? '0') ??
                        0.0;

                    setState(() {
                      _originalCollected = originalCollected;
                      totalAmountController.text = total.toStringAsFixed(2);
                      collectedAmountController.text =
                          originalCollected.toStringAsFixed(2);
                      balanceController.text =
                          (total - originalCollected).toStringAsFixed(2);
                      currentlyPayingAmount.text = '';
                    });

                    currentlyPayingAmount.removeListener(_payingAmountListener);
                    currentlyPayingAmount.addListener(_payingAmountListener);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const CustomText(
                            text: 'Payment Details ',
                            size: 26,
                          ),
                          content: Container(
                            width: 750,
                            height: 400,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 25),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const CustomText(
                                            text: 'Total Amount',
                                            size: 20,
                                          ),
                                          const SizedBox(height: 5),
                                          PharmacyTextField(
                                              readOnly: true,
                                              controller: totalAmountController,
                                              hintText: '',
                                              width: 175),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const CustomText(
                                            text: 'Collected',
                                            size: 20,
                                          ),
                                          const SizedBox(height: 5),
                                          PharmacyTextField(
                                              readOnly: true,
                                              controller:
                                                  collectedAmountController,
                                              hintText: '',
                                              width: 175),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const CustomText(
                                            text: 'Balance',
                                            size: 20,
                                          ),
                                          const SizedBox(height: 5),
                                          PharmacyTextField(
                                              readOnly: true,
                                              controller: balanceController,
                                              hintText: '',
                                              width: 175),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 50),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: 'Paying Amount ',
                                            size: 20,
                                          ),
                                          SizedBox(height: 7),
                                          PharmacyTextField(
                                            hintText: '',
                                            controller: currentlyPayingAmount,
                                            width: 175,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: 'Payment Mode ',
                                            size: 20,
                                          ),
                                          SizedBox(height: 7),
                                          SizedBox(
                                            width: 175,
                                            child: PharmacyDropDown(
                                              label: '',
                                              items: Constants.paymentMode,
                                              onChanged: (value) {
                                                setState(
                                                  () {
                                                    selectedPaymentMode = value;
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: 'Payment Details ',
                                            size: 20,
                                          ),
                                          SizedBox(height: 7),
                                          PharmacyTextField(
                                            hintText: '',
                                            controller: paymentDetails,
                                            width: 175,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  CustomText(
                                    text: 'History Of Payments',
                                    size: 20,
                                  ),
                                  SizedBox(height: 10),
                                  if (historyTableData.isNotEmpty) ...[
                                    CustomDataTable(
                                        headers: historyHeaders,
                                        tableData: historyTableData),
                                  ],
                                  if (historyTableData.isEmpty) ...[
                                    Center(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 20),
                                          CustomText(
                                              text: 'No Payment History'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                await savePayment(
                                    docId: doc.id.toString(),
                                    totalAmount:
                                        totalAmountController.text.toString(),
                                    collected: collectedAmountController.text
                                        .toString(),
                                    balance: balanceController.text.toString(),
                                    paymentMode: selectedPaymentMode.toString(),
                                    payingAmount:
                                        currentlyPayingAmount.text.toString());
                              },
                              child: CustomText(
                                text: 'Pay',
                                color: AppColors.secondaryColor,
                              ),
                            ),
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
                  child: CustomText(
                    text: 'Pay',
                    color: AppColors.blue,
                    size: 14,
                  ),
                ),
                TextButton(
                  onPressed: () async {
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
                        'Quantity': product['Quantity'],
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
                          title: CustomText(
                            text: 'View Bill',
                            size: 25,
                          ),
                          content: Container(
                            width: 900,
                            height: 350,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SingleChildScrollView(
                                          child: Container(
                                        width: 900,
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
                  child: CustomText(
                    text: 'Open',
                    color: AppColors.blue,
                    size: 14,
                  ),
                ),
              ],
            ),
          });
        }

        // Update UI after each batch
        setState(() {
          tableData = List.from(accumulatedData);
        });

        await Future.delayed(const Duration(milliseconds: 300)); // Smooth UI

        lastDoc = snapshot.docs.last;
      }

      if (accumulatedData.isEmpty) {
        print("No records found");
        setState(() {
          tableData = [];
        });
      } else {
        print(tableData);
      }
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

  void _updatePaymentAndBalance() {
    final double totalAmount =
        double.tryParse(totalAmountController.text) ?? 0.0;
    final double collectedAmount =
        double.tryParse(collectedAmountController.text) ?? 0.0;
    final double payingAmount =
        double.tryParse(currentlyPayingAmount.text) ?? 0.0;

    final double newCollected = collectedAmount + payingAmount;
    final double newBalance = totalAmount - newCollected;

    collectedAmountController.text = newCollected.toStringAsFixed(2);
    balanceController.text = newBalance.toStringAsFixed(2);
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
    currentlyPayingAmount.removeListener(_payingAmountListener);

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
              const TimeDateWidget(text: 'Purchase'),
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
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Bill No  ',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      PharmacyTextField(
                        controller: _billNo,
                        hintText: '',
                        width: screenWidth * 0.18,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.045),
                      billNoSearch
                          ? SizedBox(
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.04,
                              child: Center(
                                child: Lottie.asset(
                                  'assets/button_loading.json',
                                ),
                              ),
                            )
                          : PharmacyButton(
                              label: 'Search',
                              onPressed: () async {
                                setState(() => billNoSearch = true);
                                await fetchData(billNo: _billNo.text);
                                setState(() => billNoSearch = false);
                              },
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.04,
                            ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Distributor ',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      SizedBox(
                        height: screenHeight * 0.04,
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
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.045),
                      distributorSearch
                          ? SizedBox(
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.04,
                              child: Center(
                                child: Lottie.asset(
                                  'assets/button_loading.json',
                                ),
                              ),
                            )
                          : PharmacyButton(
                              label: 'Search',
                              onPressed: () async {
                                setState(() => distributorSearch = true);
                                await fetchData(
                                    distributor: selectedDistributor);
                                setState(() => distributorSearch = false);
                              },
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.04,
                            ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.07),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.035),
                      Row(
                        children: [
                          SizedBox(width: screenWidth * 0.11),
                          PharmacyButton(
                            label: 'Refresh',
                            onPressed: () async {
                              RefreshLoading(
                                context: context,
                                task: () async => await fetchData(),
                              );
                            },
                            width: screenWidth * 0.08,
                            height: screenHeight * 0.04,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomText(
                    text: 'Purchase Bill List',
                    size: screenWidth * 0.015,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              LazyDataTable(
                columnWidths: {
                  7: FixedColumnWidth(screenWidth * 0.15),
                },
                tableData: tableData,
                headers: headers,
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
