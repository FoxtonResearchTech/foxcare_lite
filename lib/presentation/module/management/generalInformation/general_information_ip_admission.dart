import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_admission_status.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';

import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
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
  TextEditingController _ipNumber = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  int selectedIndex = 1;
  bool isLoading = false;
  bool isLoading2 = false;
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
  ];
  List<Map<String, dynamic>> tableData1 = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData({
    String? ipNumber,
    String? phoneNumber,
    int pageSize = 20,
    Duration delayBetweenPages = const Duration(milliseconds: 100),
  }) async {
    print('Fetching data with IP Number: $ipNumber');

    DocumentSnapshot? lastPatientDoc;
    List<Map<String, dynamic>> allFetchedData = [];
    final patientsCollection =
        FirebaseFirestore.instance.collection('patients');

    try {
      while (true) {
        Query<Map<String, dynamic>> query = patientsCollection.limit(pageSize);
        if (lastPatientDoc != null) {
          query = query.startAfterDocument(lastPatientDoc);
        }

        final patientSnapshot = await query.get();

        if (patientSnapshot.docs.isEmpty) {
          break;
        }

        for (var patientDoc in patientSnapshot.docs) {
          final patientId = patientDoc.id;
          final patientData = patientDoc.data();

          Query ipTicketsQuery =
              patientsCollection.doc(patientId).collection('ipTickets');
          final ipTicketsSnapshot = await ipTicketsQuery.get();

          for (var ipTicketDoc in ipTicketsSnapshot.docs) {
            final ipTicketData = ipTicketDoc.data() as Map<String, dynamic>;

            bool matches = false;
            if (patientData['isIP'] == true) {
              if (ipNumber != null &&
                  ipTicketData['ipTicket'] != null &&
                  ipTicketData['ipTicket'].toString().toLowerCase().trim() ==
                      ipNumber.toLowerCase().trim()) {
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
                final tokenSnapshot = await patientsCollection
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
                }
              } catch (e) {
                print('Error fetching tokenNo for patient $patientId: $e');
              }

              if (ipTicketData['discharged'] == true) {
                print(
                    'Skipping discharged IP ticket: ${ipTicketData['ipTicket']}');
                continue;
              }

              allFetchedData.add({
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
                          specialization:
                              ipTicketData['specialization'] ?? 'N/A',
                          doctor: ipTicketData['doctorName'] ?? 'N/A',
                          dob: patientData['dob'] ?? 'N/A',
                          sex: patientData['sex'] ?? 'N/A',
                          phone1: patientData['phone1'] ?? 'N/A',
                          phone2: patientData['phone2'] ?? 'N/A',
                          bloodGroup: patientData['bloodGroup'] ?? 'N/A',
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
                          primaryInfo: (ipTicketData['investigationTests']
                                      ?['diagnosisSigns'] ??
                                  'N/A') +
                              ' & ' +
                              (ipTicketData['investigationTests']
                                      ?['symptoms'] ??
                                  'N/A'),
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
                        await patientsCollection
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

              break;
            }
          }
        }

        lastPatientDoc = patientSnapshot.docs.last;

        setState(() {
          tableData1 = List.from(allFetchedData);
        });

        await Future.delayed(delayBetweenPages);
      }

      print('Finished fetching total: ${allFetchedData.length}');
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final double buttonWidth = screenWidth * 0.08;
    final double buttonHeight = screenHeight * 0.040;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
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
                    padding: EdgeInsets.only(top: screenWidth * 0.03),
                    child: Column(
                      children: [
                        CustomText(
                          text: "IP Admission ",
                          size: screenWidth * .03,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                //  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IP Number section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'IP Number'),
                          SizedBox(height: 5),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.18,
                            controller: _ipNumber,
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.02),

                      // Button aligned with text field
                      Column(
                        children: [
                          SizedBox(height: 24), // Adjust this value if needed
                          isLoading
                              ? SizedBox(
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  child: Lottie.asset(
                                    'assets/button_loading.json',
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : CustomButton(
                                  label: 'Search',
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await fetchData(ipNumber: _ipNumber.text);

                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  width: buttonWidth,
                                  height: buttonHeight,
                                ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(width: screenHeight * 0.05),

                  // Phone Number section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: 'Phone Number'),
                      SizedBox(height: 5),
                      CustomTextField(
                        hintText: '',
                        width: screenWidth * 0.18,
                        controller: _phoneNumber,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),

                  // Button aligned with text field
                  Column(
                    children: [
                      SizedBox(
                          height: 24), // Adjust this value to match the field
                      isLoading2
                          ? SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: Lottie.asset(
                                'assets/button_loading.json',
                                fit: BoxFit.contain,
                              ),
                            )
                          : CustomButton(
                              label: 'Search',
                              onPressed: () async {
                                setState(() {
                                  isLoading2 = true;
                                });

                                await fetchData(phoneNumber: _phoneNumber.text);

                                setState(() {
                                  isLoading2 = false;
                                });
                              },
                              width: buttonWidth,
                              height: buttonHeight,
                            ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              LazyDataTable(
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
                tableData: tableData1,
                headers: headers1,
                rowColorResolver: (row) {
                  return row['Status'] == 'abscond'
                      ? Colors.red.shade300
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
