import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/accounts/pharmacy/management_pharmacy_accounts.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../../utilities/constants.dart';
import '../../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../../utilities/widgets/table/data_table.dart';
import '../../../../../utilities/widgets/text/primary_text.dart';
import '../../../../../utilities/widgets/textField/primary_textField.dart';

class PharmacyTotalSales extends StatefulWidget {
  @override
  State<PharmacyTotalSales> createState() => _PharmacyTotalSales();
}

class _PharmacyTotalSales extends State<PharmacyTotalSales> {
  DateTime dateTime = DateTime.now();

  TextEditingController date = TextEditingController();
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController collectedAmountController =
      TextEditingController();
  final TextEditingController currentlyPayingAmount = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();
  String? selectedPaymentMode;
  double _originalCollected = 0.0;

  double totalAmount = 0.0;
  double collected = 0.0;
  double balance = 0.0;

  bool isLoading = false;
  int selectedIndex = 0;

  String? chooseType;
  final List<String> headers = [
    'Bill NO',
    'Bill Date',
    'Patient Name',
    'OP NO / IP NO / Counter',
    'Phone Number',
    'Total Amount',
    'Collected',
    'Balance',
    'Pay'
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
  List<Map<String, dynamic>> historyTableData = [];
  Future<void> savePayment({
    required String billType,
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
          .collection('pharmacy')
          .doc('billings')
          .collection(billType)
          .doc(docId)
          .update({
        'netTotalAmount': totalAmount,
        'totalAmount': totalAmount,
        'collectedAmount': collected,
        'balance': balance,
      });
      await FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billings')
          .collection(billType)
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

  Future<void> historyData(
      {required String docId, required String billType}) async {
    try {
      DocumentReference patientDoc = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billings')
          .collection(billType)
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

  void _payingAmountListener() {
    double paying = double.tryParse(currentlyPayingAmount.text) ?? 0.0;
    double total = double.tryParse(totalAmountController.text) ?? 0.0;

    double newCollected = _originalCollected + paying;
    double newBalance = total - newCollected;

    collectedAmountController.text = newCollected.toStringAsFixed(2);
    balanceController.text = newBalance.toStringAsFixed(2);
  }

  Future<void> fetchData({
    String? date,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      resetTotals();

      List<String> collections = ['ipbilling', 'opbilling', 'countersales'];
      List<Map<String, dynamic>> allData = [];

      const int pageSize = 10;

      for (String collection in collections) {
        DocumentSnapshot? lastDoc;
        bool hasMore = true;

        while (hasMore) {
          Query query = firestore
              .collection('pharmacy')
              .doc('billings')
              .collection(collection)
              .limit(pageSize);

          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          }

          if (date != null) {
            query = query.where('billDate', isEqualTo: date);
            query = query.orderBy('billDate');
          } else if (fromDate != null && toDate != null) {
            query = query
                .where('billDate', isGreaterThanOrEqualTo: fromDate)
                .where('billDate', isLessThanOrEqualTo: toDate)
                .orderBy('billDate');
          }

          QuerySnapshot snapshot = await query.get();

          if (snapshot.docs.isEmpty) {
            hasMore = false;
            break;
          }

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;

            allData.add({
              'Bill NO': data['billNo'] ?? 'N/A',
              'Patient Name': data['patientName'] ?? 'N/A',
              'OP NO / IP NO / Counter':
                  data['opTicket'] ?? data['ipTicket'] ?? 'Counter',
              'Bill Date': data['billDate'] ?? 'N/A',
              'Phone Number': data['phone'] ?? 'N/A',
              'Total Amount': data['netTotalAmount']?.toString() ?? 'N/A',
              'Collected': data['collectedAmount']?.toString() ?? 'N/A',
              'Balance': data['balance']?.toString() ?? 'N/A',
              'Pay': Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async {
                      String billType = data['opTicket'] != null
                          ? 'opbilling'
                          : data['ipTicket'] != null
                              ? 'ipbilling'
                              : 'countersales';

                      await historyData(
                          docId: doc.id.toString(), billType: billType);
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

                      currentlyPayingAmount
                          .removeListener(_payingAmountListener);
                      currentlyPayingAmount.addListener(_payingAmountListener);

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const CustomText(
                              text: 'Payment Details Details',
                              size: 26,
                            ),
                            content: Container(
                              width: 750,
                              height: 400,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 25),
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
                                            CustomTextField(
                                                readOnly: true,
                                                controller:
                                                    totalAmountController,
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
                                            CustomTextField(
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
                                            CustomTextField(
                                                readOnly: true,
                                                controller: balanceController,
                                                hintText: '',
                                                width: 175),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 50),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const CustomText(
                                              text: 'Paying Amount ',
                                              size: 20,
                                            ),
                                            const SizedBox(height: 7),
                                            CustomTextField(
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
                                            const CustomText(
                                              text: 'Payment Mode ',
                                              size: 20,
                                            ),
                                            const SizedBox(height: 7),
                                            SizedBox(
                                              width: 175,
                                              child: CustomDropdown(
                                                label: '',
                                                items: Constants.paymentMode,
                                                onChanged: (value) {
                                                  setState(
                                                    () {
                                                      selectedPaymentMode =
                                                          value;
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
                                            const CustomText(
                                              text: 'Payment Details ',
                                              size: 20,
                                            ),
                                            const SizedBox(height: 7),
                                            CustomTextField(
                                              hintText: '',
                                              controller: paymentDetails,
                                              width: 175,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    const CustomText(
                                      text: 'History Of Payments',
                                      size: 20,
                                    ),
                                    const SizedBox(height: 10),
                                    if (historyTableData.isNotEmpty) ...[
                                      CustomDataTable(
                                          headers: historyHeaders,
                                          tableData: historyTableData),
                                    ],
                                    if (historyTableData.isEmpty) ...[
                                      const Center(
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
                                      billType: billType,
                                      docId: doc.id.toString(),
                                      totalAmount:
                                          totalAmountController.text.toString(),
                                      collected: collectedAmountController.text
                                          .toString(),
                                      balance:
                                          balanceController.text.toString(),
                                      paymentMode:
                                          selectedPaymentMode.toString(),
                                      payingAmount: currentlyPayingAmount.text
                                          .toString());
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
                ],
              ),
            });
          }

          // Update UI with each batch
          setState(() {
            tableData = List.from(allData);
            calculateTotals();
          });

          lastDoc = snapshot.docs.last;

          // Delay after updating UI
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      if (allData.isEmpty) {
        setState(() {
          tableData = [];
          resetTotals();
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void calculateTotals() {
    totalAmount = tableData.fold(0.0, (sum, item) {
      double amount =
          double.tryParse(item['Total Amount']?.toString() ?? '0') ?? 0;
      return sum + amount;
    });
    balance = tableData.fold(0.0, (sum, item) {
      double amount = double.tryParse(item['Balance']?.toString() ?? '0') ?? 0;
      return sum + amount;
    });
    collected = tableData.fold(0.0, (sum, item) {
      double amount =
          double.tryParse(item['Collected']?.toString() ?? '0') ?? 0;
      return sum + amount;
    });

    totalAmount = double.parse(totalAmount.toStringAsFixed(2));
    collected = double.parse(collected.toStringAsFixed(2));
    balance = double.parse(balance.toStringAsFixed(2));
  }

  void resetTotals() {
    totalAmount = 0.00;
    collected = 0.00;
    balance = 0.00;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    date.dispose();
    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const CustomText(
                text: 'Pharmacy Accounts Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ManagementPharmacyAccounts(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ManagementPharmacyAccounts(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: dashboard(),
          ),
        ],
      ),
    );
  }

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
            bottom: screenWidth * 0.01,
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
                          text: "Pharmacy Total Sales",
                          size: screenWidth * .025,
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
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                children: [
                  // CustomTextField(
                  //   controller: date,
                  //   onTap: () => _selectDate(context, date),
                  //   icon: Icon(Icons.date_range),
                  //   hintText: 'Date',
                  //   width: screenWidth * 0.15,
                  // ),
                  // SizedBox(width: screenHeight * 0.02),
                  // CustomButton(
                  //   label: 'Search',
                  //   onPressed: () {
                  //     fetchData(date: date.text);
                  //   },
                  //   width: screenWidth * 0.08,
                  //   height: screenWidth * 0.02,
                  // ),
                  // SizedBox(width: screenHeight * 0.02),
                  // CustomText(text: 'OR'),
                  // SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, fromDate),
                    controller: fromDate,
                    icon: const Icon(Icons.date_range),
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, toDate),
                    controller: toDate,
                    icon: const Icon(Icons.date_range),
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  isLoading
                      ? SizedBox(
                          width: screenWidth * 0.09,
                          height: screenWidth * 0.03,
                          child: Lottie.asset(
                            'assets/button_loading.json', // Ensure the file path is correct
                            fit: BoxFit.contain,
                          ),
                        )
                      : CustomButton(
                          label: 'Search',
                          onPressed: () async {
                            setState(() => isLoading = true);
                            await fetchData(
                                fromDate: fromDate.text, toDate: toDate.text);
                            setState(() => isLoading = false);
                          },
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.025,
                        ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomText(
                    text: 'Bill List',
                    size: screenWidth * 0.0125,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              LazyDataTable(
                tableData: tableData,
                headers: headers,
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
              ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CustomText(
                      text: 'Total : ',
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    CustomText(
                      text: '$totalAmount',
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    CustomText(
                      text: '$collected',
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    CustomText(
                      text: '$balance',
                    ),
                    SizedBox(width: screenWidth * 0.07)
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05)
            ],
          ),
        ),
      ),
    );
  }
}
