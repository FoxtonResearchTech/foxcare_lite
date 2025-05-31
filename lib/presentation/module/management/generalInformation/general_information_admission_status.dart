import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';

import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import 'general_information_doctor_visit_schedule.dart';
import 'general_information_edit_doctor_visit_schedule.dart';
import 'general_information_ip_admission.dart';

class GeneralInformationAdmissionStatus extends StatefulWidget {
  @override
  State<GeneralInformationAdmissionStatus> createState() =>
      _GeneralInformationAdmissionStatus();
}

class _GeneralInformationAdmissionStatus
    extends State<GeneralInformationAdmissionStatus> {
  int selectedIndex = 2;
  TextEditingController _patientID = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  bool isPhoneLoading = false;
  bool isLoading = false;
  final List<String> headers1 = [
    'OP No',
    'IP Ticket',
    'IP Admit Date',
    'Name',
    'Room/Ward',
    'Consulting Doctor',
  ];
  List<Map<String, dynamic>> tableData1 = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchData({
    String? ipNumber,
    String? phoneNumber,
    int pageSize = 20,
    Duration delayBetweenPages = const Duration(milliseconds: 100),
  }) async {
    print('Fetching data with IP Number: $ipNumber');

    DocumentSnapshot? lastPatientDoc; // for pagination
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
          // No more patients to fetch
          break;
        }

        for (var patientDoc in patientSnapshot.docs) {
          final patientId = patientDoc.id;
          final patientData = patientDoc.data();

          final ipTicketsSnapshot = await patientsCollection
              .doc(patientId)
              .collection('ipTickets')
              .get();

          for (var ipTicketDoc in ipTicketsSnapshot.docs) {
            final ipTicketData = ipTicketDoc.data();

            bool matches = false;

            if (patientData['isIP'] == true) {
              if (ipNumber != null &&
                  ipTicketData['ipTicket'] != null &&
                  ipTicketData['ipTicket'].toString().toLowerCase() ==
                      ipNumber.toLowerCase()) {
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
              if (ipTicketData['discharged'] == true) {
                print(
                    'Skipping discharged IP ticket: ${ipTicketData['ipTicket']}');
                continue;
              }

              DocumentSnapshot ipPrescriptionSnapshot = await patientsCollection
                  .doc(patientId)
                  .collection('ipPrescription')
                  .doc('details')
                  .get();

              Map<String, dynamic>? detailsData = ipPrescriptionSnapshot.exists
                  ? ipPrescriptionSnapshot.data() as Map<String, dynamic>?
                  : null;

              allFetchedData.add({
                'IP Admit Date': ipTicketData['ipAdmitDate'] ?? 'N/A',
                'OP No': patientData['opNumber'] ?? 'N/A',
                'IP Ticket': ipTicketData['ipTicket'] ?? 'N/A',
                'Name':
                    '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                        .trim(),
                'Room/Ward': detailsData?['ipAdmission']?['roomType'] != null &&
                        detailsData?['ipAdmission']?['roomNumber'] != null
                    ? "${detailsData!['ipAdmission']['roomType']} ${detailsData['ipAdmission']['roomNumber']}"
                    : 'N/A',
                'Consulting Doctor': ipTicketData['doctorName'] ?? 'N/A',
              });

              break; // Only add one matching IP ticket per patient
            }
          }
        }

        lastPatientDoc = patientSnapshot.docs.last;

        setState(() {
          tableData1 = List.from(allFetchedData);
          print('Fetched so far: ${tableData1.length}');
        });

        // Optional delay between pages
        await Future.delayed(delayBetweenPages);
      }

      print('Finished fetching ${allFetchedData.length} total IP tickets.');
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
    final double buttonWidth = screenWidth * 0.08;
    final double buttonHeight = screenHeight * 0.040;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
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
                          text: "Admission Status ",
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
                //     mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: 'IP Number'),
                      SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        hintText: '',
                        width: screenWidth * 0.18,
                        controller: _patientID,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    children: [
                      SizedBox(height: 24),
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
                                setState(() => isLoading = true);

                                await fetchData(ipNumber: _patientID.text);

                                setState(() => isLoading = false);
                              },
                              width: buttonWidth,
                              height: buttonHeight,
                            ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: 'Phone Number'),
                      SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        hintText: 'Phone Number',
                        width: screenWidth * 0.18,
                        controller: _phoneNumber,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    children: [
                      SizedBox(height: 24),
                      isPhoneLoading
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
                                setState(() => isPhoneLoading = true);

                                await fetchData(phoneNumber: _phoneNumber.text);

                                setState(() => isPhoneLoading = false);
                              },
                              width: buttonWidth,
                              height: buttonHeight,
                            ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              LazyDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData1,
                headers: headers1,
                rowColorResolver: (row) {
                  return row['Status'] == 'abscond'
                      ? Colors.red.shade300
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
