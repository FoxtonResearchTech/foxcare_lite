import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_admission_status.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/colors.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../reception/reception_ip_patient.dart';
import 'general_information_doctor_visit_schedule.dart';
import 'general_information_edit_doctor_visit_schedule.dart';

class GeneralInformationIpAdmission extends StatefulWidget {
  @override
  State<GeneralInformationIpAdmission> createState() =>
      _GeneralInformationIpAdmission();
}

class _GeneralInformationIpAdmission
    extends State<GeneralInformationIpAdmission> {
  // To store the index of the selected drawer item
  int selectedIndex = 1;
  final List<String> headers1 = [
    'IP Ticket',
    'OP NO',
    'IP Admit Date',
    'Status',
    'Name',
    'Age',
    'Place',
    'Primary Info',
    'Action',
    'Abort',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData({String? ipNumber, String? phoneNumber}) async {
    print('Fetching data with OP Number: $ipNumber');

    try {
      List<Map<String, dynamic>> fetchedData = [];
      bool hasIpPrescription = false;
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final QuerySnapshot<Map<String, dynamic>> patientSnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      for (var patientDoc in patientSnapshot.docs) {
        final patientId = patientDoc.id;
        final patientData = patientDoc.data();

        final opTicketsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .collection('ipTickets')
            .get();

        bool found = false;

        for (var ipTicketDoc in opTicketsSnapshot.docs) {
          final ipTicketData = ipTicketDoc.data();
          print(
              'opTicketData: ${ipTicketData['opTicket']}'); // Debugging print statement

          bool matches = false;

          if (patientData['isIP'] == true) {
            if (ipNumber != null && ipTicketData['ipTicket'] == ipNumber) {
              matches = true;
            } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
              if (patientData['phone1'] == phoneNumber ||
                  patientData['phone2'] == phoneNumber) {
                matches = true;
              }
            } else if (ipNumber == null &&
                (phoneNumber == null || phoneNumber.isEmpty)) {
              matches = true;
            }
          }

          if (matches) {
            String tokenNo = '';
            String tokenDate = '';

            try {
              final tokenSnapshot = await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(patientId)
                  .collection('tokens')
                  .doc('currentToken')
                  .get();

              if (tokenSnapshot.exists) {
                final tokenData = tokenSnapshot.data();
                if (tokenData != null && tokenData['tokenNumber'] != null) {
                  tokenNo = tokenData['tokenNumber'].toString();
                }
                if (tokenData != null && tokenData['date'] != null) {
                  tokenDate = tokenData['date'];
                }
                final ipPrescriptionSnapshot = await FirebaseFirestore.instance
                    .collection('patients')
                    .doc(patientId)
                    .collection('ipPrescription')
                    .get();

                if (ipPrescriptionSnapshot.docs.isNotEmpty) {
                  hasIpPrescription = true;
                }
              }
            } catch (e) {
              print('Error fetching tokenNo for patient $patientId: $e');
            }

            if (ipTicketData['discharged'] == true) {
              print(
                  'Skipping discharged IP ticket: ${ipTicketData['ipTicket']}');
              continue;
            }

            fetchedData.add({
              'Token NO': tokenNo,
              'IP Admit Date': ipTicketData['ipAdmitDate'] ?? 'N/A',
              'OP NO': patientData['opNumber'] ?? 'N/A',
              'IP Ticket': ipTicketData['ipTicket'] ?? 'N/A',
              'Name':
                  '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                      .trim(),
              'Age': patientData['age'] ?? 'N/A',
              'Place': patientData['city'] ?? 'N/A',
              'Address': patientData['address1'] ?? 'N/A',
              'PinCode': patientData['pincode'] ?? 'N/A',
              'Status': ipTicketData['status'] ?? 'N/A',
              'Primary Info': patientData['otherComments'] ?? 'N/A',
              'Action': TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceptionIpPatient(
                        date: ipTicketData['ipAdmitDate'] ?? 'N/A',
                        patientID: patientData['opNumber'] ?? 'N/A',
                        ipNumber: ipTicketData['ipTicket'] ?? 'N/A',
                        name:
                            '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? 'N/A'}'
                                .trim(),
                        age: patientData['age'] ?? 'N/A',
                        place: patientData['state'] ?? 'N/A',
                        address: patientData['address1'] ?? 'N/A',
                        pincode: patientData['pincode'] ?? 'N/A',
                        primaryInfo: ipTicketData['otherComments'] ?? 'N/A',
                        temperature: ipTicketData['temperature'] ?? 'N/A',
                        bloodPressure: ipTicketData['bloodPressure'] ?? 'N/A',
                        sugarLevel: ipTicketData['bloodSugarLevel'] ?? 'N/A',
                      ),
                    ),
                  );
                },
                child: const CustomText(text: 'IP Rooms'),
              ),
              'Abscond': TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('patients')
                          .doc(patientId)
                          .collection('ipTickets')
                          .doc(ipTicketData['ipTicket'])
                          .update({'status': 'abscond'});

                      CustomSnackBar(context,
                          message: 'Status updated to abscond');
                    } catch (e) {
                      print('Error updating status: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to update status')),
                      );
                    }
                  },
                  child: const CustomText(text: 'Abort')),
            });

            found = true;
            break;
          }
        }
      }

      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Token NO']) ?? 0;
        int tokenB = int.tryParse(b['Token NO']) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData1 = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
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
                text: 'General Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ManagementGeneralInformationDrawer(
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
              child: ManagementGeneralInformationDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ), // Sidebar always open for web view
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
    double screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.33,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                          text: "IP Admission ",
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
              CustomDataTable(
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
                tableData: tableData1,
                headers: headers1,
                rowColorResolver: (row) {
                  return row['Status'] == 'aborted'
                      ? Colors.red.shade200
                      : Colors.transparent;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
