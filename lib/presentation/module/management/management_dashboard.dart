import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/mangement_module_drawer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class ManagementDashboard extends StatefulWidget {
  @override
  State<ManagementDashboard> createState() => _ManagementDashboard();
}

class _ManagementDashboard extends State<ManagementDashboard> {
  final TextEditingController _fromDate = TextEditingController();
  final TextEditingController _toDate = TextEditingController();

  int selectedIndex = 0;

  Timer? _timer;

  bool isTotalOpLoading = false;
  bool isTotalIpLoading = false;

  bool isTotalIncomeLoading = false;
  bool isTotalExpenseLoading = false;

  bool isPharmacyTotalIncomeLoading = false;
  bool isPharmacyTotalExpenseLoading = false;

  int noOfOp = 0;
  int noOfIp = 0;

  int noOfNewPatients = 0;
  int todayNoOfOp = 0;

  int totalIncome = 0;
  int totalExpense = 0;

  int pharmacyTotalIncome = 0;
  int pharmacyTotalExpense = 0;

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

      for (String collection in subcollections) {
        final QuerySnapshot snapshot = await firestore
            .collection('pharmacy')
            .doc('billings')
            .collection(collection)
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String? billDate = data['billDate'];

          if (isInRange(billDate)) {
            double value =
                double.tryParse(data['netTotalAmount']?.toString() ?? '0') ?? 0;
            total += value;
          }
        }
      }

      setState(() {
        pharmacyTotalIncome = total.toInt();
        isPharmacyTotalIncomeLoading = false;
      });

      print("Pharmacy Total Income (after returns): $pharmacyTotalIncome");
    } catch (e) {
      print("Error fetching pharmacy totals: $e");
      setState(() {
        isPharmacyTotalIncomeLoading = false;
      });
    }
  }

  Future<void> getPharmacyExpense({String? fromDate, String? toDate}) async {
    double total = 0.0;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
        isPharmacyTotalExpenseLoading = true;
      });

      // Purchase Entry
      final QuerySnapshot purchaseSnapshot = await firestore
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry')
          .get();

      for (var doc in purchaseSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String? reportDate = data['billDate'];
        if (isInRange(reportDate)) {
          double value =
              double.tryParse(data['netTotalAmount']?.toString() ?? '0') ?? 0;
          total += value;
        }
      }

      // Return Collections
      List<String> returnCollections = [
        'StockReturn',
        'ExpiryReturn',
        'DamageReturn'
      ];

      for (String collection in returnCollections) {
        final QuerySnapshot returnSnapshot = await firestore
            .collection('stock')
            .doc('Products')
            .collection(collection)
            .get();

        for (var doc in returnSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String? dateStr = data['returnDate'];

          if (isInRange(dateStr)) {
            double returnValue =
                double.tryParse(data['netTotalAmount']?.toString() ?? '0') ?? 0;
            total -= returnValue;
          }
        }
      }

      setState(() {
        pharmacyTotalExpense = total.toInt();
        isPharmacyTotalExpenseLoading = false;
      });

      print("Pharmacy Total Expense (after returns): $pharmacyTotalExpense");
    } catch (e) {
      print("Error calculating pharmacy expense: $e");
      setState(() {
        isPharmacyTotalExpenseLoading = false;
      });
    }
  }

  Future<int> getTotalIncome({String? fromDate, String? toDate}) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    int income = 0;

    try {
      final QuerySnapshot patientSnapshot =
          await fireStore.collection('patients').get();

      setState(() {
        isTotalIncomeLoading = true;
      });

      DateTime? from = fromDate != null ? DateTime.tryParse(fromDate) : null;
      DateTime? to = toDate != null ? DateTime.tryParse(toDate) : null;

      bool isInRange(String? dateStr) {
        if (dateStr == null) return false;
        DateTime? d = DateTime.tryParse(dateStr);
        if (d == null) return false;
        if (from != null && d.isBefore(from)) return false;
        if (to != null && d.isAfter(to)) return false;
        return true;
      }

      int parseAmount(String? value) {
        if (value == null || value.trim().isEmpty) return 0;
        return int.tryParse(value) ?? 0;
      }

      for (var doc in patientSnapshot.docs) {
        final patientId = doc.id;

        // 1. Get all opAmountPayments
        try {
          final opPaymentsSnapshot = await fireStore
              .collection('patients')
              .doc(patientId)
              .collection('opAmountPayments')
              .get();

          for (var payDoc in opPaymentsSnapshot.docs) {
            final payData = payDoc.data();
            final collectedStr = payData['collected']?.toString();
            final payedDateStr = payData['payedDate']?.toString();

            if (isInRange(payedDateStr)) {
              income += parseAmount(collectedStr);
            }
          }
        } catch (e) {
          print('Error fetching opAmountPayments for $patientId: $e');
        } // 2. Get all opTickets and sum their opTicketPayments
        try {
          final opTicketsSnapshot = await fireStore
              .collection('patients')
              .doc(patientId)
              .collection('opTickets')
              .get();

          for (var opTicketDoc in opTicketsSnapshot.docs) {
            final opTicketId = opTicketDoc.id;

            try {
              final opTicketPaymentsSnapshot = await fireStore
                  .collection('patients')
                  .doc(patientId)
                  .collection('opTickets')
                  .doc(opTicketId)
                  .collection('opTicketPayments')
                  .get();

              for (var paymentDoc in opTicketPaymentsSnapshot.docs) {
                final paymentData = paymentDoc.data();
                final collectedStr = paymentData['collected']?.toString();
                final payedDateStr = paymentData['payedDate']?.toString();

                if (isInRange(payedDateStr)) {
                  income += parseAmount(collectedStr);
                }
              }
            } catch (e) {
              print(
                  'Error fetching opTicketPayments for $opTicketId of $patientId: $e');
            }
          }
        } catch (e) {
          print('Error fetching opTickets for $patientId: $e');
        } // 3. Get all ipTickets and sum their ipAdmitPayments
        try {
          final ipTicketsSnapshot = await fireStore
              .collection('patients')
              .doc(patientId)
              .collection('ipTickets')
              .get();

          for (var ipTicketDoc in ipTicketsSnapshot.docs) {
            final ipTicketId = ipTicketDoc.id;

            try {
              final ipAdmitPaymentsSnapshot = await fireStore
                  .collection('patients')
                  .doc(patientId)
                  .collection('ipTickets')
                  .doc(ipTicketId)
                  .collection('ipAdmitPayments')
                  .get();

              for (var paymentDoc in ipAdmitPaymentsSnapshot.docs) {
                final paymentData = paymentDoc.data();
                final collectedStr = paymentData['collected']?.toString();
                final payedDateStr = paymentData['payedDate']?.toString();

                if (isInRange(payedDateStr)) {
                  income += parseAmount(collectedStr);
                }
              }
            } catch (e) {
              print(
                  'Error fetching ipAdmitPayments for $ipTicketId of $patientId: $e');
            }
          }
        } catch (e) {
          print('Error fetching ipTickets for $patientId: $e');
        } // 4. Sum labPayments inside opTickets
        try {
          final opTicketsSnapshot = await fireStore
              .collection('patients')
              .doc(patientId)
              .collection('opTickets')
              .get();

          for (var opTicketDoc in opTicketsSnapshot.docs) {
            final opTicketId = opTicketDoc.id;

            try {
              final labPaymentsSnapshot = await fireStore
                  .collection('patients')
                  .doc(patientId)
                  .collection('opTickets')
                  .doc(opTicketId)
                  .collection('labPayments')
                  .get();

              for (var labDoc in labPaymentsSnapshot.docs) {
                final labData = labDoc.data();
                final collectedStr = labData['collected']?.toString();
                final payedDateStr = labData['payedDate']?.toString();

                if (isInRange(payedDateStr)) {
                  income += parseAmount(collectedStr);
                }
              }
            } catch (e) {
              print('Error fetching op labPayments for $opTicketId: $e');
            }
          }
        } catch (e) {
          print('Error fetching opTickets for labPayments: $e');
        } // 5. Sum labPayments inside ipTickets ➜ Examination ➜ labPayments
        try {
          final ipTicketsSnapshot = await fireStore
              .collection('patients')
              .doc(patientId)
              .collection('ipTickets')
              .get();

          for (var ipTicketDoc in ipTicketsSnapshot.docs) {
            final ipTicketId = ipTicketDoc.id;

            try {
              final examinationSnapshot = await fireStore
                  .collection('patients')
                  .doc(patientId)
                  .collection('ipTickets')
                  .doc(ipTicketId)
                  .collection('Examination')
                  .get();

              for (var examDoc in examinationSnapshot.docs) {
                final examId = examDoc.id;

                try {
                  final labPaymentsSnapshot = await fireStore
                      .collection('patients')
                      .doc(patientId)
                      .collection('ipTickets')
                      .doc(ipTicketId)
                      .collection('Examination')
                      .doc(examId)
                      .collection('labPayments')
                      .get();

                  for (var labDoc in labPaymentsSnapshot.docs) {
                    final labData = labDoc.data();
                    final collectedStr = labData['collected']?.toString();
                    final payedDateStr = labData['payedDate']?.toString();

                    if (isInRange(payedDateStr)) {
                      income += parseAmount(collectedStr);
                    }
                  }
                } catch (e) {
                  print(
                      'Error fetching labPayments in Examination $examId: $e');
                }
              }
            } catch (e) {
              print('Error fetching Examination for ipTicket $ipTicketId: $e');
            }
          }
        } catch (e) {
          print('Error fetching ipTickets for labPayments: $e');
        }
      }

      setState(() {
        totalIncome = income;
        isTotalIncomeLoading = false;
      });

      return income;
    } catch (e) {
      print('Error fetching patients: $e');
      return 0;
    }
  }

  double parseAmount(dynamic value) {
    if (value == null) return 0.0;

    try {
      final parsed = double.tryParse(value.toString());
      return parsed ?? 0.0;
    } catch (e) {
      print('Error parsing amount: $value');
      return 0.0;
    }
  }

  Future<int> getTotalExpense({String? fromDate, String? toDate}) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    int expense = 0;
    setState(() {
      isTotalExpenseLoading = true;
    });

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

    int parseAmount(dynamic value) {
      if (value == null) return 0;
      return int.tryParse(value.toString()) ?? 0;
    }

    try {
      final directPurchaseSnapshot = await fireStore
          .collection('hospital')
          .doc('purchase')
          .collection('directPurchase')
          .get();

      for (var doc in directPurchaseSnapshot.docs) {
        final data = doc.data();
        if (isInRange(data['purchaseDate'])) {
          expense += parseAmount(data['collected']);
        }
      }

      final otherExpenseSnapshot = await fireStore
          .collection('hospital')
          .doc('purchase')
          .collection('otherExpense')
          .get();

      for (var doc in otherExpenseSnapshot.docs) {
        final data = doc.data();
        if (isInRange(data['billDate'])) {
          expense += parseAmount(data['collected']);
        }
      }

      setState(() {
        totalExpense = expense;
        isTotalExpenseLoading = false;
      });

      return expense;
    } catch (e) {
      print('Error fetching expenses: $e');
      return 0;
    }
  }

  Future<int> getNoOfOp({String? fromDate, String? toDate}) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    int opCount = 0;

    setState(() {
      isTotalOpLoading = true;
    });

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
      final QuerySnapshot patientSnapshot =
          await fireStore.collection('patients').get();

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        try {
          final opTicketsSnapshot = await fireStore
              .collection('patients')
              .doc(doc.id)
              .collection('opTickets')
              .get();

          for (var opDoc in opTicketsSnapshot.docs) {
            final opData = opDoc.data();
            final opDateStr = opData['tokenDate'];

            if (isInRange(opDateStr)) {
              opCount++;
            }
          }
        } catch (e) {
          print('Error fetching ipTickets for ${doc.id}: $e');
        }
      }

      setState(() {
        noOfOp = opCount;
        isTotalOpLoading = false;
      });

      return opCount;
    } catch (e) {
      print('Error fetching patients: $e');
      return 0;
    }
  }

  Future<int> getNoOfIp({String? fromDate, String? toDate}) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    int ipCount = 0;

    setState(() {
      isTotalIpLoading = true;
    });

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
      final QuerySnapshot patientSnapshot =
          await fireStore.collection('patients').get();

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        try {
          final ipTicketsSnapshot = await fireStore
              .collection('patients')
              .doc(doc.id)
              .collection('ipTickets')
              .get();

          for (var ipDoc in ipTicketsSnapshot.docs) {
            final ipData = ipDoc.data();
            final ipDateStr = ipData['ipAdmitDate'];

            if (isInRange(ipDateStr)) {
              ipCount++;
            }
          }
        } catch (e) {
          print('Error fetching ipTickets for ${doc.id}: $e');
        }
      }

      setState(() {
        noOfIp = ipCount;
        isTotalIpLoading = false;
      });

      return ipCount;
    } catch (e) {
      print('Error fetching patients: $e');
      return 0;
    }
  }

  Future<int> getTodayNoOfOp() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int opCount = 0;

    try {
      final QuerySnapshot patientSnapshot =
          await fireStore.collection('patients').get();

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('opNumber') ||
            !data.containsKey('opAdmissionDate')) continue;

        try {
          final DocumentSnapshot tokenSnapshot = await fireStore
              .collection('patients')
              .doc(doc.id)
              .collection('tokens')
              .doc('currentToken')
              .get();

          if (tokenSnapshot.exists) {
            final tokenData = tokenSnapshot.data() as Map<String, dynamic>?;

            final String? tokenDate = tokenData?['date'];

            if (tokenDate == today) {
              opCount++;
            }
          }
        } catch (e) {
          print('Error fetching token for patient ${doc.id}: $e');
        }
      }

      setState(() {
        todayNoOfOp = opCount;
      });

      return opCount;
    } catch (e) {
      print('Error fetching patients: $e');
      return 0;
    }
  }

  Future<int> getNoOfNewPatients() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;

    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final QuerySnapshot snapshot = await fireStore
          .collection('patients')
          .where('opAdmissionDate', isEqualTo: today)
          .get();

      setState(() {
        noOfNewPatients = snapshot.docs.length;
      });

      return noOfNewPatients;
    } catch (e) {
      print('Error fetching documents: $e');
      return 0;
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

  String message = '';
  String status = '';
  Color backgroundColor = Colors.yellow.shade100;
  Color borderColor = Colors.yellow.shade700;
  IconData icon = Icons.warning_amber_rounded;

  @override
  void initState() {
    super.initState();
    fetchMessage();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      getTodayNoOfOp();
      getNoOfNewPatients();
    });
    final now = DateTime.now();
    final String fromDate = DateFormat('yyyy-MM-01').format(now);
    final String toDate = DateFormat('yyyy-MM-dd').format(
      DateTime(now.year, now.month + 1, 0),
    );
    getNoOfOp(fromDate: fromDate, toDate: toDate);
    getNoOfIp(fromDate: fromDate, toDate: toDate);
    getTotalExpense(fromDate: fromDate, toDate: toDate);
    getTotalIncome(fromDate: fromDate, toDate: toDate);
    getPharmacyIncome(fromDate: fromDate, toDate: toDate);
    getPharmacyExpense(fromDate: fromDate, toDate: toDate);
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void fetchMessage() async {
    // Replace with your actual Firestore document path
    var doc = await FirebaseFirestore.instance
        .collection('admin_message') // Your Firestore collection
        .doc('opMuI4flH4BhvvhnZwEn') // Replace with your document ID
        .get();

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      setState(() {
        message = data['message'] ?? ''; // Message field
        status = data['status'] ?? 'warning'; // Status field

        // Set color and icon based on status
        if (status == 'warning') {
          backgroundColor = Colors.yellow.shade100;
          borderColor = Colors.yellow.shade700;
          icon = Icons.warning_amber_rounded;
        } else if (status == 'bad') {
          backgroundColor = Colors.red.shade100;
          borderColor = Colors.red.shade700;
          icon = Icons.error_outline;
        } else if (status == 'good') {
          backgroundColor = Colors.green.shade100;
          borderColor = Colors.green.shade700;
          icon = Icons.check_circle_outline;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const CustomText(
                text: 'Management Dashboard',
              ),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: ManagementModuleDrawer(
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
              width: 300,
              color: Colors.blue.shade100,
              child: ManagementModuleDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    onTap: () => _selectDate(context, _fromDate),
                    icon: Icon(Icons.date_range),
                    controller: _fromDate,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _toDate),
                    icon: Icon(Icons.date_range),
                    controller: _toDate,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      getNoOfOp(
                        fromDate: _fromDate.text,
                        toDate: _toDate.text,
                      );
                      getNoOfIp(
                        fromDate: _fromDate.text,
                        toDate: _toDate.text,
                      );
                      getTotalIncome(
                        fromDate: _fromDate.text,
                        toDate: _toDate.text,
                      );
                      getTotalExpense(
                        fromDate: _fromDate.text,
                        toDate: _toDate.text,
                      );
                      getPharmacyIncome(
                        fromDate: _fromDate.text,
                        toDate: _toDate.text,
                      );
                      getPharmacyExpense(
                        fromDate: _fromDate.text,
                        toDate: _toDate.text,
                      );
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.027,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              status == 'All Good'
                  ? SizedBox()
                  : Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: backgroundColor, // Dynamic background color
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: borderColor), // Dynamic border color
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                icon, // Dynamic icon based on status
                                color: borderColor,
                              ),
                              SizedBox(width: 8), // Space between icon and text
                              Expanded(
                                child: Text(
                                  '${message} ', // Dynamic message
                                  style: TextStyle(
                                    color:
                                        borderColor, // Apply dynamic color here
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  8), // Space between message and contact info
                          Align(
                            alignment:
                                Alignment.centerRight, // Align to the right
                            child: TextButton(
                              onPressed: () async {
                                // Launch the URL when the button is pressed
                                final Uri url =
                                    Uri.parse('https://foxtonresearch.com/');
                                if (await canLaunch(url.toString())) {
                                  await launch(url.toString());
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                              child: Text(
                                "If you have any queries, contact us",
                                // Contact information
                                style: TextStyle(
                                  color:
                                      Colors.blue, // Apply dynamic color here
                                  fontWeight: FontWeight.bold,
                                  // Underline the text
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              SizedBox(height: screenHeight * 0.075),
              Row(
                children: [
                  Expanded(
                    child: buildDashboardCard(
                      title: 'No Of OP',
                      value: isTotalOpLoading
                          ? 'Calculating...'
                          : noOfOp.toString(),
                      icon: Icons.person,
                      width: double.infinity,
                      height: screenHeight * 0.18,
                    ),
                  ),
                  SizedBox(width: 12), // spacing between cards
                  Expanded(
                    child: buildDashboardCard(
                      title: 'No Of IP',
                      value: isTotalIpLoading
                          ? 'Calculating...'
                          : noOfIp.toString(),
                      icon: Icons.person,
                      width: double.infinity,
                      height: screenHeight * 0.18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: buildDashboardCard(
                      title: 'Today No Of New Patients',
                      value: noOfNewPatients.toString(),
                      icon: Icons.person_add_alt,
                      width: double.infinity,
                      height: screenHeight * 0.18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: buildDashboardCard(
                      title: 'Today No of OP Patients',
                      value: todayNoOfOp.toString(),
                      icon: Icons.person_add_alt,
                      width: double.infinity,
                      height: screenHeight * 0.18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                children: [
                  Expanded(
                    child: buildDashboardCard(
                      title: 'Total Income',
                      value: isTotalIncomeLoading
                          ? 'Calculating...'
                          : '₹ ' + totalIncome.toString(),
                      icon: Iconsax.money_recive,
                      width: double.infinity,
                      height: screenHeight * 0.18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: buildDashboardCard(
                      title: 'Total Expense',
                      value: isTotalExpenseLoading
                          ? 'Calculating...'
                          : '₹ ' + totalExpense.toString(),
                      icon: Iconsax.money_remove,
                      width: double.infinity,
                      height: screenHeight * 0.18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: buildDashboardCard(
                      title: 'Pharmacy Sales',
                      value: isPharmacyTotalIncomeLoading
                          ? 'Calculating...'
                          : '₹ ' + pharmacyTotalIncome.toString(),
                      icon: Iconsax.money_recive,
                      width: double.infinity,
                      height: screenHeight * 0.18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: buildDashboardCard(
                      title: 'Pharmacy Expense',
                      value: isPharmacyTotalExpenseLoading
                          ? 'Calculating...'
                          : '₹ ' + pharmacyTotalExpense.toString(),
                      icon: Iconsax.money_remove,
                      width: double.infinity,
                      height: screenHeight * 0.18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05)
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
          Icon(icon, size: screenWidth * 0.025, color: Colors.white),
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
