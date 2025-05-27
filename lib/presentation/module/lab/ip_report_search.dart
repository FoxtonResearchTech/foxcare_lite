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

class IpReportSearch extends StatefulWidget {
  const IpReportSearch({super.key});

  @override
  State<IpReportSearch> createState() => _IpReportSearch();
}

class _IpReportSearch extends State<IpReportSearch> {
  int selectedIndex = 6;

  TextEditingController _reportNumber = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();

  final List<String> headers = [
    'Report Date',
    'Report No',
    'IP Ticket',
    'OP Number',
    'Name',
    'Report'
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
    String? reportNo,
  }) async {
    try {
      final QuerySnapshot patientSnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var patientDoc in patientSnapshot.docs) {
        final patientData = patientDoc.data() as Map<String, dynamic>;
        final patientId = patientDoc.id;

        final ipTicketsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .collection('ipTickets')
            .get();

        for (var ticketDoc in ipTicketsSnapshot.docs) {
          final ticketData = ticketDoc.data();
          final ticketId = ticketDoc.id;

          final examSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .collection('ipTickets')
              .doc(ticketId)
              .collection('Examination')
              .get();

          for (var examDoc in examSnapshot.docs) {
            final examData = examDoc.data();

            if (!examData.containsKey('reportNo') ||
                !examData.containsKey('reportDate')) continue;

            final String reportDate = examData['reportDate'].toString();
            final String reportNumber = examData['reportNo'].toString();

            bool matches = false;

            if (singleDate != null) {
              matches = reportDate == singleDate;
            } else if (fromDate != null && toDate != null) {
              matches = reportDate.compareTo(fromDate) >= 0 &&
                  reportDate.compareTo(toDate) <= 0;
            } else if (reportNo != null) {
              matches = reportNumber == reportNo;
            } else {
              matches = true;
            }

            if (matches) {
              final List<String> tests = (examData['items'] is List)
                  ? (examData['items'] as List).whereType<String>().toList()
                  : [];

              fetchedData.add({
                'Report Date': reportDate,
                'Report No': reportNumber,
                'Name':
                    '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                        .trim(),
                'IP Ticket': ticketData['ipTicket']?.toString() ?? 'N/A',
                'OP Number': patientData['opNumber']?.toString() ?? 'N/A',
                'Tests': tests.join(', '),
              });
            }
          }
        }
      }

      // Sort by Report No
      fetchedData.sort((a, b) {
        int aNo = int.tryParse(a['Report No'].toString()) ?? 0;
        int bNo = int.tryParse(b['Report No'].toString()) ?? 0;
        return aNo.compareTo(bNo);
      });

      setState(() {
        tableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching IP examination data: $e');
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
                          text: " IP Ticket Reports",
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
              SizedBox(height: screenHeight * 0.05)
            ],
          ),
        ),
      ),
    );
  }
}
