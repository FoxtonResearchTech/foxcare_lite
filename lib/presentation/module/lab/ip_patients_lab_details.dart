import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/lab/ip_patient_report.dart';
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

class IpPatientsLabDetails extends StatefulWidget {
  const IpPatientsLabDetails({super.key});

  @override
  State<IpPatientsLabDetails> createState() => _IpPatientsLabDetails();
}

class _IpPatientsLabDetails extends State<IpPatientsLabDetails> {
  final TextEditingController ipNumberSearch = TextEditingController();
  final TextEditingController phoneNumberSearch = TextEditingController();
  int selectedIndex = 2;
  final List<String> headers1 = [
    'Token NO',
    'IP Ticket',
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
  bool _isSearching = false;

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

  Future<void> fetchData({String? opNumber, String? phoneNumber}) async {
    try {
      final DateTime now = DateTime.now();
      final String todayDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final String todayString =
          DateFormat('yyyy-MM-dd').format(DateTime.now());

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

        // Filter by opNumber
        if (opNumber != null &&
            opNumber.isNotEmpty &&
            (patientData['opNumber'] ?? '') != opNumber) {
          continue;
        }

        final ipTicketsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientDoc.id)
            .collection('ipTickets')
            .get();

        for (var ticketDoc in ipTicketsSnapshot.docs) {
          final data = ticketDoc.data();

          if (!data.containsKey('ipTicket')) continue;

          final examSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientDoc.id)
              .collection('ipTickets')
              .doc(ticketDoc.id)
              .collection('Examination')
              .get();

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

          for (var examDoc in examSnapshot.docs) {
            final examData = examDoc.data();
            if (examData.containsKey('reportNo') &&
                examData.containsKey('reportDate')) {
              continue;
            }
            final examDate = examData['date'];
            final examItems = examData['items'];

            // if (examData.containsKey('reportDate')) break;

            // Filter by date if opNumber and phoneNumber not provided
            if ((opNumber == null || opNumber.isEmpty) &&
                (phoneNumber == null || phoneNumber.isEmpty) &&
                (examDate != todayString)) {
              continue;
            }

            final List<String> tests = (examItems is List)
                ? examItems.whereType<String>().toList()
                : [];

            if (tests.isEmpty) continue;

            String? sampleDate;
            try {
              final sampleDataDoc = await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(patientDoc.id)
                  .collection('ipTickets')
                  .doc(ticketDoc.id)
                  .collection('Examination')
                  .doc(examDoc.id)
                  .collection('sampleData')
                  .doc('data')
                  .get();

              if (sampleDataDoc.exists) {
                sampleDate = sampleDataDoc.data()?['sampleDate'];
              }
            } catch (e) {
              print('Error fetching sampleData: $e');
            }

            fetchedData.add({
              'Token NO': tokenNo,
              'IP Ticket': data['ipTicket'] ?? 'N/A',
              'OP NO': patientData['opNumber'] ?? 'N/A',
              'Name':
                  '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                      .trim(),
              'Age': patientData['age'] ?? 'N/A',
              'Place': patientData['state'] ?? 'N/A',
              'Address': patientData['address1'] ?? 'N/A',
              'PinCode': patientData['pincode'] ?? 'N/A',
              'Status': data['status'] ?? 'N/A',
              'List of Tests': tests,
              'Action': TextButton(
                  onPressed: () {
                    final investigation =
                        data['investigationTests'] as Map<String, dynamic>?;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IpPatientReport(
                          doctorName: data['doctorName'] ?? 'N/A',
                          examDocId: examDoc.id.toString(),
                          sampleDate: sampleDate ?? 'N/A',
                          patientID: patientData['opNumber'] ?? 'N/A',
                          ipTicket: data['ipTicket'] ?? 'N/A',
                          name:
                              '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? 'N/A'}'
                                  .trim(),
                          age: patientData['age'] ?? 'N/A',
                          sex: patientData['sex'] ?? 'N/A',
                          place: patientData['state'] ?? 'N/A',
                          dob: patientData['dob'] ?? 'N/A',
                          medication: tests,
                          address: patientData['address1'] ?? 'N/A',
                          pincode: patientData['pincode'] ?? 'N/A',
                          primaryInfo:
                              investigation?['diagnosisSigns'] ?? 'N/A',
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
                        final time =
                            DateFormat('HH:mm:ss').format(DateTime.now());
                        try {
                          await FirebaseFirestore.instance
                              .collection('patients')
                              .doc(patientDoc.id)
                              .collection('ipTickets')
                              .doc(ticketDoc.id)
                              .collection('Examination')
                              .doc(examDoc.id)
                              .collection('sampleData')
                              .doc('data')
                              .set({
                            'sampleDate': todayDate,
                            'sampleTime':
                                "${now.hour}:${now.minute.toString().padLeft(2, '0')}",
                          }, SetOptions(merge: true));

                          CustomSnackBar(context,
                              message: "Sample Date Entered $time",
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
                          text: "IP Patients Lab Test",
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
                        controller: ipNumberSearch,
                        hintText: '',
                        width: screenWidth * 0.2,
                      ),
                    ],
                  ),
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
                  Column(
                    children: [
                      SizedBox(
                        height: 21,
                      ),
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
                                final ipNumber = ipNumberSearch.text.trim();
                                final phone = phoneNumberSearch.text.trim();

                                await fetchData(
                                  opNumber:
                                      ipNumber.isNotEmpty ? ipNumber : null,
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
              SizedBox(height: screenHeight * 0.05)
            ],
          ),
        ),
      ),
    );
  }
}
