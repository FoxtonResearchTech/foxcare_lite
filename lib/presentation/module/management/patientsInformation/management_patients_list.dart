import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';

import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/patient_information/management_patient_information.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../../doctor/patient_history_dialog.dart';
import '../generalInformation/general_information_admission_status.dart';
import '../management_dashboard.dart';
import 'management_patient_history.dart';
import 'management_register_patient.dart';

class ManagementPatientsList extends StatefulWidget {
  @override
  State<ManagementPatientsList> createState() => _ManagementRegisterPatient();
}

class _ManagementRegisterPatient extends State<ManagementPatientsList> {
  int selectedIndex = 2;
  TextEditingController _opNumber = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  bool opNumberSearch = false;
  bool phoneNumberSearch = false;

  final List<String> headers1 = [
    'Patient ID',
    'OP / IP Ticket',
    'Ticket Type',
    'Name',
    'Place',
    'Phone No',
    'DOB',
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
    String? opNumber,
    String? phoneNumber,
    int pageSize = 20,
    Duration delayBetweenPages = const Duration(milliseconds: 100),
  }) async {
    print('Fetching all data...');
    DocumentSnapshot? lastDocument;
    List<Map<String, dynamic>> allFetchedData = [];

    try {
      while (true) {
        Query query = FirebaseFirestore.instance.collection('patients');

        if (phoneNumber != null) {
          query = query.where(Filter.or(
            Filter('phone1', isEqualTo: phoneNumber),
            Filter('phone2', isEqualTo: phoneNumber),
          ));
        }

        if (lastDocument != null) {
          query = query.startAfterDocument(lastDocument);
        }

        query = query.limit(pageSize);
        final snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          print('No more documents to fetch.');
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final docRef = doc.reference;

          final opTicketsSnapshot = await docRef.collection('opTickets').get();
          for (var opDoc in opTicketsSnapshot.docs) {
            if (opNumber != null && opNumber.isNotEmpty) {
              if (opNumber.isNotEmpty &&
                  (opDoc.data()['opTicket']?.toString().toLowerCase() !=
                      opNumber.toLowerCase())) {
                continue;
              }
            }

            allFetchedData.add({
              'Patient ID': data['opNumber'] ?? 'N/A',
              'OP / IP Ticket': opDoc.id,
              'Ticket Type': 'OP',
              'Name':
                  '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                      .trim(),
              'Place': data['city'] ?? 'N/A',
              'Phone No': data['phone1'] ?? 'N/A',
              'DOB': data['dob'] ?? 'N/A',
            });
          }

          final ipTicketsSnapshot = await docRef.collection('ipTickets').get();
          for (var ipDoc in ipTicketsSnapshot.docs) {
            if (opNumber != null && opNumber.isNotEmpty) {
              if (opNumber.isNotEmpty &&
                  (ipDoc.data()['ipTicket']?.toString().toLowerCase() !=
                      opNumber.toLowerCase())) {
                continue;
              }
            }

            allFetchedData.add({
              'Patient ID': data['opNumber'] ?? 'N/A',
              'OP / IP Ticket': ipDoc.id,
              'Ticket Type': 'IP',
              'Name':
                  '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                      .trim(),
              'Place': data['state'] ?? 'N/A',
              'Phone No': data['phone1'] ?? 'N/A',
              'DOB': data['dob'] ?? 'N/A',
            });
          }
        }

        lastDocument = snapshot.docs.last;
        setState(() {
          tableData1 = List.from(allFetchedData);
        });
        // Optional throttle delay
        await Future.delayed(delayBetweenPages);
      }

      print('Finished fetching ${allFetchedData.length} total tickets.');
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
              child: ManagementPatientInformation(
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
              child: ManagementPatientInformation(
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
    final double buttonWidth = screenWidth * 0.08;
    final double buttonHeight = screenHeight * 0.040;
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
                    padding: EdgeInsets.only(top: screenWidth * 0.01),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Patient List",
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
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    hintText: 'OP Number',
                    width: screenWidth * 0.18,
                    controller: _opNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  opNumberSearch
                      ? SizedBox(
                          width: screenWidth * 0.1,
                          height: screenHeight * 0.045,
                          child: Center(
                            child: Lottie.asset(
                              'assets/button_loading.json',
                            ),
                          ),
                        )
                      : CustomButton(
                          label: 'Search',
                          onPressed: () async {
                            setState(() => opNumberSearch = true);
                            await fetchData(opNumber: _opNumber.text);
                            setState(() => opNumberSearch = false);
                          },
                          width: buttonWidth,
                          height: buttonHeight,
                        ),
                  SizedBox(width: screenHeight * 0.05),
                  CustomTextField(
                    hintText: 'Phone Number',
                    width: screenWidth * 0.18,
                    controller: _phoneNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  phoneNumberSearch
                      ? SizedBox(
                          width: screenWidth * 0.1,
                          height: screenHeight * 0.045,
                          child: Center(
                            child: Lottie.asset(
                              'assets/button_loading.json',
                            ),
                          ),
                        )
                      : CustomButton(
                          label: 'Search',
                          onPressed: () async {
                            setState(() => phoneNumberSearch = true);
                            await fetchData(phoneNumber: _phoneNumber.text);
                            setState(() => phoneNumberSearch = false);
                          },
                          width: buttonWidth,
                          height: buttonHeight,
                        ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              LazyDataTable(
                tableData: tableData1,
                headers: headers1,
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
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
