import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/lab/patients_lab_details.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/lab/lab_module_drawer.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'dashboard.dart';
import 'lab_accounts.dart';
import 'lab_testqueue.dart';

class ReportsSearch extends StatefulWidget {
  const ReportsSearch({super.key});

  @override
  State<ReportsSearch> createState() => _ReportsSearch();
}

int selectedIndex = 4;

class ReportRow {
  final String slNo;
  final String opNumber;
  final String name;
  final String age;
  final String testType;
  final String dateOfReport;
  final String amountCollected;
  final String paymentStatus;

  ReportRow(
    this.slNo,
    this.opNumber,
    this.name,
    this.age,
    this.testType,
    this.dateOfReport,
    this.amountCollected,
    this.paymentStatus,
  );
}

class _ReportsSearch extends State<ReportsSearch> {
  TextEditingController _reportNumber = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();

  final List<String> headers = [
    'Report Date',
    'Report No',
    'Name',
    'OP Number',
    'Report Use'
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData(
      {String? singleDate,
      String? fromDate,
      String? toDate,
      String? reportNo}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (singleDate != null) {
        query = query.where('reportDate', isEqualTo: singleDate);
      } else if (fromDate != null && toDate != null) {
        query = query
            .where('reportDate', isGreaterThanOrEqualTo: fromDate)
            .where('reportDate', isLessThanOrEqualTo: toDate);
      } else if (reportNo != null) {
        int? reportNoInt = int.tryParse(reportNo);
        if (reportNoInt != null) {
          query = query.where('reportNo', isEqualTo: reportNoInt);
        }
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
        if (!data.containsKey('reportNo')) continue;
        if (!data.containsKey('reportDate')) continue;
        if (!data.containsKey('opNumber')) continue;
        fetchedData.add({
          'Report Date': data['reportDate']?.toString() ?? 'N/A',
          'Report No': data['reportNo']?.toString() ?? 'N/A',
          'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
              .trim(),
          'OP Number': data['opNumber']?.toString() ?? 'N/A',
          'Total Amount': data['labTotalAmount']?.toString() ?? '0',
          'Collected': data['labCollected']?.toString() ?? '0',
          'Balance': data['labBalance']?.toString() ?? '0',
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

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _toDateController.dispose();
    _fromDateController.dispose();
    _reportNumber.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Laboratory Dashboard'),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: LabModuleDrawer(
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
              child: LabModuleDrawer(
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
              padding: const EdgeInsets.all(16.0),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
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
                          text: "Reports",
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
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Report Number',
                    width: screenWidth * 0.15,
                    controller: _reportNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(reportNo: _reportNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                    icon: Icon(Icons.date_range),
                    controller: _dateController,
                    onTap: () => _selectDate(context, _dateController),
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
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                    icon: Icon(Icons.date_range),
                    onTap: () => _selectDate(context, _fromDateController),
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                    icon: Icon(Icons.date_range),
                    onTap: () => _selectDate(context, _toDateController),
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
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
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
