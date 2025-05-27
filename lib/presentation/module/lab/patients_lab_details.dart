import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/lab/patient_report.dart';
import 'package:foxcare_lite/presentation/module/lab/patients_lab_details.dart';
import 'package:foxcare_lite/presentation/module/lab/reports_search.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/lab/lab_module_drawer.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'dashboard.dart';
import 'lab_accounts.dart';
import 'lab_testqueue.dart';

class PatientsLabDetails extends StatefulWidget {
  const PatientsLabDetails({super.key});

  @override
  State<PatientsLabDetails> createState() => _PatientsLabDetails();
}

class _PatientsLabDetails extends State<PatientsLabDetails> {
  final TextEditingController opNumberSearch = TextEditingController();
  final TextEditingController phoneNumberSearch = TextEditingController();
  int selectedIndex = 1;
  bool _isSearching = false;
  DateTime dateTime = DateTime.now();

  final List<String> headers1 = [
    'Token NO',
    'OP Ticket',
    'OP NO',
    'Name',
    'Age',
    'Place',
    'List of Tests',
    'Action',
    'Sample Data',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   fetchData();
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData({String? patientID, String? phoneNumber}) async {
    try {
      final DateTime now = DateTime.now();
      final String todayDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final QuerySnapshot patientSnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var patientDoc in patientSnapshot.docs) {
        final patientData = patientDoc.data() as Map<String, dynamic>;

        // Filter by phone number
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          if ((patientData['phone1'] ?? '') != phoneNumber &&
              (patientData['phone2'] ?? '') != phoneNumber) {
            continue;
          }
        }

        // Filter by opNumber (patientID)
        if (patientID != null &&
            patientID.isNotEmpty &&
            (patientData['opNumber'] ?? '') != patientID) {
          continue;
        }

        final opTicketsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientDoc.id)
            .collection('opTickets')
            .get();

        for (var ticketDoc in opTicketsSnapshot.docs) {
          final data = ticketDoc.data();

          if (!data.containsKey('opTicket')) continue;
          if (data.containsKey('reportNo') && data.containsKey('reportDate'))
            continue;

          // Check for labExaminationPrescribedDate
          final prescribedDate = data['labExaminationPrescribedDate'] ?? '';
          final bool isTodayPrescribed = prescribedDate == todayDate;

          // If searching by phone or patientID, don't filter by date
          final bool skipDateFilter =
              (patientID != null && patientID.isNotEmpty) ||
                  (phoneNumber != null && phoneNumber.isNotEmpty);

          if (!skipDateFilter && !isTodayPrescribed) {
            continue;
          }

          // Skip if Examination is missing
          if (!data.containsKey('Examination') ||
              (data['Examination'] as List).isEmpty) {
            continue;
          }

          // Fetch token number
          String tokenNo = '';
          try {
            final tokenSnapshot = await FirebaseFirestore.instance
                .collection('patients')
                .doc(patientDoc.id)
                .collection('tokens')
                .doc('currentToken')
                .get();

            if (tokenSnapshot.exists) {
              final tokenData = tokenSnapshot.data();
              if (tokenData != null && tokenData['tokenNumber'] != null) {
                tokenNo = tokenData['tokenNumber'].toString();
              }
            }
          } catch (e) {
            print('Error fetching tokenNo for patient ${patientDoc.id}: $e');
          }

          // Check if sample data exists
          String? sampleDate;
          try {
            final sampleDataDoc = await FirebaseFirestore.instance
                .collection('patients')
                .doc(patientDoc.id)
                .collection('opTickets')
                .doc(ticketDoc.id)
                .collection('sampleData')
                .doc('data')
                .get();

            if (sampleDataDoc.exists) {
              sampleDate = sampleDataDoc.data()?['sampleDate'];
            }
          } catch (e) {
            print('Error fetching sampleData: $e');
          }

          // Prepare table data row
          fetchedData.add({
            'Token NO': tokenNo,
            'OP Ticket': data['opTicket'] ?? 'N/A',
            'OP NO': patientData['opNumber'] ?? 'N/A',
            'Name':
                '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                    .trim(),
            'Age': patientData['age'] ?? 'N/A',
            'Place': patientData['state'] ?? 'N/A',
            'Address': patientData['address1'] ?? 'N/A',
            'PinCode': patientData['pincode'] ?? 'N/A',
            'Status': data['status'] ?? 'N/A',
            'List of Tests': data['Examination'] ?? 'N/A',
            'Action': TextButton(
                onPressed: () {
                  final investigation =
                      data['investigationTests'] as Map<String, dynamic>?;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientReport(
                        doctorName: data['doctorName'] ?? 'N/A',
                        sampleDate: sampleDate ?? "N/A",
                        patientID: patientData['opNumber'] ?? 'N/A',
                        opTicket: data['opTicket'] ?? 'N/A',
                        name:
                            '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? 'N/A'}'
                                .trim(),
                        age: patientData['age'] ?? 'N/A',
                        sex: patientData['sex'] ?? 'N/A',
                        place: patientData['state'] ?? 'N/A',
                        dob: patientData['dob'] ?? 'N/A',
                        medication: data['Examination'] ?? 'N/A',
                        address: patientData['address1'] ?? 'N/A',
                        pincode: patientData['pincode'] ?? 'N/A',
                        primaryInfo: investigation?['diagnosisSigns'] ?? 'N/A',
                        temperature: data['temperature'] ?? 'N/A',
                        bloodPressure: data['bloodPressure'] ?? 'N/A',
                        sugarLevel: data['bloodSugarLevel'] ?? 'N/A',
                      ),
                    ),
                  );
                },
                child: const CustomText(text: 'Open')),
            'Sample Data': sampleDate != null
                ? const CustomText(text: 'Sample Date Entered')
                : TextButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('patients')
                            .doc(patientDoc.id)
                            .collection('opTickets')
                            .doc(ticketDoc.id)
                            .collection('sampleData')
                            .doc('data')
                            .set({
                          'sampleDate': todayDate,
                          'sampleTime':
                              "${now.hour}:${now.minute.toString().padLeft(2, '0')}",
                        }, SetOptions(merge: true));
                        await fetchData();
                        CustomSnackBar(context,
                            message: "Sample Date Entered ",
                            backgroundColor: Colors.green);
                      } catch (e) {
                        CustomSnackBar(context,
                            message: 'Failed to save: $e',
                            backgroundColor: Colors.red);
                      }
                    },
                    child: const CustomText(text: 'Enter Sample Data')),
          });
        }
      }

      // Sort by token number
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Token NO']) ?? 0;
        int tokenB = int.tryParse(b['Token NO']) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData1 = fetchedData;
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screeHeight = MediaQuery.of(context).size.height;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text('Laboratory Dashboard'),
            )
          : null, // No AppBar for web view
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
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
            bottom: screenWidth * 0.02,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.01),
                    child: Column(
                      children: [
                        CustomText(
                          text: "OP Patients Lab Test",
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(width: screenHeight * 0.1),

                  // OP Number
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "OP Number",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 5),
                      CustomTextField(
                        controller: opNumberSearch,
                        hintText: '',
                        width: screenWidth * 0.2,
                      ),
                    ],
                  ),

                  // Mobile Number
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mobile Number",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 5),
                      CustomTextField(
                        controller: phoneNumberSearch,
                        hintText: '',
                        width: screenWidth * 0.2,
                      ),
                    ],
                  ),

                  // Search Button aligned vertically with text fields
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height:
                              21), // Adjust as needed to align with TextFields
                      _isSearching
                          ? SizedBox(
                              width: screenWidth * 0.1,
                              height: screenHeight * 0.045,
                              child: Center(
                                child: Lottie.asset(
                                  'assets/button_loading.json', // Customize color if needed
                                ),
                              ),
                            )
                          : CustomButton(
                              label: 'Search',
                              onPressed: () async {
                                setState(() {
                                  _isSearching = true;
                                });

                                final opNumber = opNumberSearch.text.trim();
                                final phone = phoneNumberSearch.text.trim();

                                await fetchData(
                                  patientID:
                                      opNumber.isNotEmpty ? opNumber : null,
                                  phoneNumber: phone.isNotEmpty ? phone : null,
                                );

                                setState(() {
                                  _isSearching = false;
                                });
                              },
                              width: screenWidth * 0.1,
                              height: screenHeight * 0.045,
                            ),
                    ],
                  ),

                  SizedBox(width: screenHeight * 0.1),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData1,
                headers: headers1,
                columnWidths: {
                  6: FixedColumnWidth(screenWidth * 0.15),
                  8: FixedColumnWidth(screenWidth * 0.1),
                },
                rowColorResolver: (row) {
                  return row['Status'] == 'aborted'
                      ? Colors.red.shade200
                      : Colors.transparent;
                },
              ),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
