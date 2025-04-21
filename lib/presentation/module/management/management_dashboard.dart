import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/mangement_module_drawer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/text/primary_text.dart';

class ManagementDashboard extends StatefulWidget {
  @override
  State<ManagementDashboard> createState() => _ManagementDashboard();
}

class _ManagementDashboard extends State<ManagementDashboard> {
  int selectedIndex = 0;

  Timer? _timer;
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

  Future<void> getPharmacyIncome() async {
    double total = 0.0;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<String> subcollections = ['countersales', 'ipbilling', 'opbilling'];

    try {
      setState(() {
        isPharmacyTotalIncomeLoading = true;
      });

      for (String collection in subcollections) {
        final QuerySnapshot snapshot = await firestore
            .collection('pharmacy')
            .doc('billing')
            .collection(collection)
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          double value =
              double.tryParse(data['grandTotal']?.toString() ?? '0') ?? 0;
          total += value;
        }
      }

      final QuerySnapshot returnSnapshot = await firestore
          .collection('pharmacy')
          .doc('billing')
          .collection('medicinereturn')
          .get();

      for (var doc in returnSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double returnValue =
            double.tryParse(data['grandTotal']?.toString() ?? '0') ?? 0;
        total -= returnValue;
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

  Future<void> getPharmacyExpense() async {
    double total = 0.0;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final QuerySnapshot purchaseSnapshot = await firestore
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry')
          .get();
      setState(() {
        isPharmacyTotalExpenseLoading = true;
      });

      for (var doc in purchaseSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double value = double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
        total += value;
      }

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
          double returnValue =
              double.tryParse(data['totalReturnAmount']?.toString() ?? '0') ??
                  0;
          total -= returnValue;
        }
      }

      setState(() {
        pharmacyTotalExpense = total.toInt();
        isPharmacyTotalExpenseLoading = false;
      });

      print("Pharmacy Total Expense (after returns): $pharmacyTotalExpense");
    } catch (e) {
      print("Error calculating pharmacy expense: $e");
    }
  }

  Future<int> getTotalIncome() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    int income = 0;

    try {
      final QuerySnapshot patientSnapshot =
          await fireStore.collection('patients').get();

      setState(() {
        isTotalIncomeLoading = true;
      });
      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        int parseAmount(dynamic value) {
          if (value == null) return 0;
          return int.tryParse(value.toString()) ?? 0;
        }

        income += parseAmount(data['opAmountCollected']);
        income += parseAmount(data['opTicketCollectedAmount']);
        income += parseAmount(data['labCollected']);

        try {
          final DocumentSnapshot ipAdmissionDoc = await fireStore
              .collection('patients')
              .doc(doc.id)
              .collection('ipAdmissionPayments')
              .doc('payments')
              .get();

          if (ipAdmissionDoc.exists) {
            final ipData = ipAdmissionDoc.data() as Map<String, dynamic>;
            income += parseAmount(ipData['ipAdmissionCollected']);
          }
        } catch (e) {
          print('Error fetching ipAdmissionPayments for ${doc.id}: $e');
        }

        // Add from /ipPrescription/details
        try {
          final DocumentSnapshot ipPrescriptionDoc = await fireStore
              .collection('patients')
              .doc(doc.id)
              .collection('ipPrescription')
              .doc('details')
              .get();

          if (ipPrescriptionDoc.exists) {
            final ipPrescData =
                ipPrescriptionDoc.data() as Map<String, dynamic>;
            income += parseAmount(ipPrescData['ipAdmissionCollected']);
          }
        } catch (e) {
          print('Error fetching ipPrescription for ${doc.id}: $e');
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

  Future<int> getTotalExpense() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    int expense = 0;

    int parseAmount(dynamic value) {
      if (value == null) return 0;
      return int.tryParse(value.toString()) ?? 0;
    }

    try {
      final QuerySnapshot directPurchaseSnapshot = await fireStore
          .collection('hospital')
          .doc('purchase')
          .collection('directPurchase')
          .get();
      setState(() {
        isTotalExpenseLoading = true;
      });

      for (var doc in directPurchaseSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        expense += parseAmount(data['collected']);
      }

      // Fetch from otherExpense
      final QuerySnapshot otherExpenseSnapshot = await fireStore
          .collection('hospital')
          .doc('purchase')
          .collection('otherExpense')
          .get();

      for (var doc in otherExpenseSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        expense += parseAmount(data['collected']);
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

  Future<int> getNoOfOp() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;

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
            opCount++;
          }
        } catch (e) {
          print('Error fetching token for patient ${doc.id}: $e');
        }
      }

      setState(() {
        noOfOp = opCount;
      });

      return opCount;
    } catch (e) {
      print('Error fetching patients: $e');
      return 0;
    }
  }

  Future<int> getNoOfIp() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int ipCount = 0;

    try {
      final QuerySnapshot patientSnapshot =
          await fireStore.collection('patients').get();

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('ipNumber') ||
            !data.containsKey('opAdmissionDate')) continue;

        try {
          final DocumentSnapshot tokenSnapshot = await fireStore
              .collection('patients')
              .doc(doc.id)
              .collection('tokens')
              .doc('currentToken')
              .get();

          if (tokenSnapshot.exists) {
            ipCount++;
          }
        } catch (e) {
          print('Error fetching token for patient ${doc.id}: $e');
        }
      }

      setState(() {
        noOfIp = ipCount;
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

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      getNoOfOp();
      getNoOfIp();
      getTodayNoOfOp();
      getNoOfNewPatients();
    });
    getTotalExpense();
    getTotalIncome();
    getPharmacyIncome();
    getPharmacyExpense();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
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
          : null, // No AppBar for web view
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
              SizedBox(height: screenHeight * 0.15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildDashboardCard(
                    title: 'No Of OP',
                    value: noOfOp.toString(),
                    icon: Icons.person,
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.17,
                  ),
                  buildDashboardCard(
                    title: 'No Of IP',
                    value: noOfIp.toString(),
                    icon: Icons.person,
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.17,
                  ),
                  buildDashboardCard(
                    title: 'Today No Of New Patients',
                    value: noOfNewPatients.toString(),
                    icon: Icons.person_add_alt,
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.17,
                  ),
                  buildDashboardCard(
                    title: 'Today No of Patients',
                    value: todayNoOfOp.toString(),
                    icon: Icons.person_add_alt,
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.17,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildDashboardCard(
                    title: 'Total Income',
                    value: isTotalIncomeLoading
                        ? 'Calculating...'
                        : '₹ ' + totalIncome.toString(),
                    icon: Iconsax.money_recive,
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.17,
                  ),
                  buildDashboardCard(
                    title: 'Total Expense',
                    value: isTotalIncomeLoading
                        ? 'Calculating...'
                        : '₹ ' + totalExpense.toString(),
                    icon: Iconsax.money_remove,
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.17,
                  ),
                  buildDashboardCard(
                    title: 'Pharmacy Sales',
                    value: isPharmacyTotalIncomeLoading
                        ? 'Calculating...'
                        : '₹ ' + pharmacyTotalIncome.toString(),
                    icon: Iconsax.money_recive,
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.17,
                  ),
                  buildDashboardCard(
                    title: 'Pharmacy Expense',
                    value: isPharmacyTotalExpenseLoading
                        ? 'Calculating...'
                        : '₹ ' + pharmacyTotalExpense.toString(),
                    icon: Iconsax.money_remove,
                    width: screenWidth * 0.17,
                    height: screenHeight * 0.17,
                  ),
                ],
              ),
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
