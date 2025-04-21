import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/accounts/pharmacy/management_pharmacy_accounts.dart';

import 'package:intl/intl.dart';

import '../../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../../utilities/widgets/table/data_table.dart';
import '../../../../../utilities/widgets/text/primary_text.dart';
import '../../../../../utilities/widgets/textField/primary_textField.dart';

class PharmacyTotalSales extends StatefulWidget {
  @override
  State<PharmacyTotalSales> createState() => _PharmacyTotalSales();
}

class _PharmacyTotalSales extends State<PharmacyTotalSales> {
  TextEditingController date = TextEditingController();
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();

  double totalAmount = 0.0;

  int selectedIndex = 0;

  String? chooseType;
  final List<String> headers = [
    'Bill NO',
    'Bill Date',
    'Patient Name',
    'OP NO / IP NO / Counter',
    'Phone Number',
    'Purchased Total',
    'Purchased Tax',
    'Purchased Gst',
    'Purchased Total Gst',
    'Purchased Grand Total',
  ];
  List<Map<String, dynamic>> tableData = [];
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

  Future<void> fetchData({
    String? date,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      resetTotals();

      List<String> collections = ['ipbilling', 'opbilling', 'countersales'];

      List<QuerySnapshot> snapshots = await Future.wait(
        collections.map((collection) {
          Query query = firestore
              .collection('pharmacy')
              .doc('billing')
              .collection(collection);

          if (date != null) {
            query = query.where('billDate', isEqualTo: date);
          } else if (fromDate != null && toDate != null) {
            query = query
                .where('billDate', isGreaterThanOrEqualTo: fromDate)
                .where('billDate', isLessThanOrEqualTo: toDate);
          }
          return query.get();
        }),
      );

      List<Map<String, dynamic>> patientData = [];

      for (var snapshot in snapshots) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (data.isNotEmpty) {
            patientData.add({
              'Bill NO': data['billNo'] ?? 'N/A',
              'Patient Name': data['patientName'] ?? 'N/A',
              'OP NO / IP NO / Counter':
                  data['opNumber'] ?? data['ipNumber'] ?? 'Counter',
              'Bill Date': data['billDate'] ?? 'N/A',
              'Phone Number': data['phoneNumber'] ?? 'N/A',
              'Purchased Total': data['totalAmount'] ?? 'N/A',
              'Purchased Tax': data['taxAmount'] ?? 'N/A',
              'Purchased Gst': data['gstAmount'] ?? 'N/A',
              'Purchased Total Gst': data['totalGst'] ?? 'N/A',
              'Purchased Grand Total': data['grandTotal'] ?? 'N/A',
            });
          }
        }
      }

      if (patientData.isEmpty) {
        setState(() {
          tableData = [];
          resetTotals();
        });
        return;
      }

      final firstEntry = patientData.first;
      setState(() {
        tableData = patientData;
        calculateTotals();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void calculateTotals() {
    totalAmount = tableData.fold(0.0, (sum, item) {
      double amount =
          double.tryParse(item['Purchased Grand Total']?.toString() ?? '0') ??
              0;
      return sum + amount;
    });

    totalAmount = double.parse(totalAmount.toStringAsFixed(2));
  }

  void resetTotals() {
    totalAmount = 0.00;
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
            child: Padding(
              padding: const EdgeInsets.all(8),
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
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.07),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Pharmacy Total Sales",
                          size: screenWidth * .015,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
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
                  CustomTextField(
                    controller: date,
                    onTap: () => _selectDate(context, date),
                    icon: Icon(Icons.date_range),
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(date: date.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomText(text: 'OR'),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, fromDate),
                    controller: fromDate,
                    icon: Icon(Icons.date_range),
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, toDate),
                    controller: toDate,
                    icon: Icon(Icons.date_range),
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(fromDate: fromDate.text, toDate: toDate.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
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
                    CustomText(
                      text: 'Total :        $totalAmount',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
