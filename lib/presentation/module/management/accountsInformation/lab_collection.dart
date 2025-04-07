import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase_still_pending.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admission_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit_list.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/lab_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/op_ticket_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/other_expense.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/surgery_ot_icu_collection.dart';
import 'package:foxcare_lite/utilities/widgets/payment/payment_dialog.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../management_dashboard.dart';
import 'new_patient_register_collection.dart';

class LabCollection extends StatefulWidget {
  @override
  State<LabCollection> createState() => _LabCollection();
}

class _LabCollection extends State<LabCollection> {
  int selectedIndex = 7;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  int hoveredIndex = -1;
  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  DateTime now = DateTime.now();
  final List<String> headers = [
    'Report No',
    'Report Date',
    'OP No',
    'Name',
    'City',
    'Total Amount',
    'Collected',
    'Balance',
    'Pay'
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (singleDate != null) {
        query = query.where('reportDate', isEqualTo: singleDate);
      } else if (fromDate != null && toDate != null) {
        query = query
            .where('reportDate', isGreaterThanOrEqualTo: fromDate)
            .where('reportDate', isLessThanOrEqualTo: toDate);
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
        if (!data.containsKey('opNumber')) continue;
        if (!data.containsKey('reportDate')) continue;

        double opAmount =
            double.tryParse(data['labTotalAmount']?.toString() ?? '0') ?? 0;
        double opAmountCollected =
            double.tryParse(data['labCollected']?.toString() ?? '0') ?? 0;
        double balance = opAmount - opAmountCollected;

        fetchedData.add({
          'OP No': data['opNumber']?.toString() ?? 'N/A',
          'Report No': data['reportNo']?.toString() ?? 'N/A',
          'Report Date': data['reportDate']?.toString() ?? 'N/A',
          'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
              .trim(),
          'City': data['city']?.toString() ?? 'N/A',
          'Total Amount': data['labTotalAmount']?.toString() ?? '0',
          'Collected': data['labCollected']?.toString() ?? '0',
          'Balance': balance,
          'Pay': TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PaymentDialog(
                      patientID: data['opNumber'],
                      firstName: data['firstName'],
                      lastName: data['lastName'],
                      city: data['city'],
                      balance: balance.toString());
                },
              );
            },
            child: CustomText(text: 'Pay'),
          ),
        });
      }

      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Report No'].toString()) ?? 0;
        int tokenB = int.tryParse(b['Report No'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData = fetchedData;
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

  int _totalAmountCollected() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Total Amount'];
        if (value == null) return sum;
        if (value is String) {
          value = int.tryParse(value) ?? 0;
        }
        return sum + (value as int);
      },
    );
  }

  int _totalCollected() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Collected'];
        if (value == null) return sum;
        if (value is String) {
          value = int.tryParse(value) ?? 0;
        }
        return sum + (value as int);
      },
    );
  }

  int _totalBalance() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Balance'];
        if (value == null) return sum;
        // Convert string to double safely
        if (value is String) {
          value = double.tryParse(value) ?? 0.0;
        }
        // Ensure value is double before conversion to int
        if (value is double) {
          value = value.toInt();
        }
        return sum + (value as int);
      },
    );
  }

  @override
  void initState() {
    fetchData();
    _totalAmountCollected();
    _totalCollected();
    _totalBalance();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _toDateController.dispose();
    _fromDateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
                text: 'Accounts Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ManagementAccountsDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ManagementAccountsDrawer(
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
              padding: const EdgeInsets.only(left: 16, right: 16),
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
                          text: "Lab Collection ",
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
                    onTap: () => _selectDate(context, _dateController),
                    icon: Icon(Icons.date_range),
                    controller: _dateController,
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(singleDate: _dateController.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomText(text: 'OR'),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _fromDateController),
                    icon: Icon(Icons.date_range),
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _toDateController),
                    icon: Icon(Icons.date_range),
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(
                        fromDate: _fromDateController.text,
                        toDate: _toDateController.text,
                      );
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              const Row(
                children: [CustomText(text: 'Collection Report Of Date')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData,
                headers: headers,
              ),
              Container(
                width: screenWidth,
                height: screenHeight * 0.030,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: screenWidth * 0.38),
                    CustomText(
                      text: 'Total : ',
                    ),
                    SizedBox(width: screenWidth * 0.086),
                    CustomText(
                      text: '${_totalAmountCollected()}',
                    ),
                    SizedBox(width: screenWidth * 0.08),
                    CustomText(
                      text: '${_totalCollected()}',
                    ),
                    SizedBox(width: screenWidth * 0.083),
                    CustomText(
                      text: '${_totalBalance()}',
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
