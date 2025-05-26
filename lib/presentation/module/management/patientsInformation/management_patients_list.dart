import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';

import 'package:iconsax/iconsax.dart';

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

  Future<void> fetchData({String? opNumber, String? phoneNumber}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (phoneNumber != null) {
        query = query.where(Filter.or(
          Filter('phone1', isEqualTo: phoneNumber),
          Filter('phone2', isEqualTo: phoneNumber),
        ));
      }

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No patient records found");
        setState(() {
          tableData1 = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docRef = doc.reference;

        final opTicketsSnapshot = await docRef.collection('opTickets').get();
        for (var opDoc in opTicketsSnapshot.docs) {
          if (opNumber != null && opNumber.isNotEmpty) {
            if (opDoc.data()['opTicket'] != opNumber) continue;
          }

          fetchedData.add({
            'Patient ID': data['opNumber'] ?? 'N/A',
            'OP / IP Ticket': opDoc.id,
            'Ticket Type': 'OP',
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'Place': data['city'] ?? 'N/A',
            'Phone No': data['phone1'] ?? 'N/A',
            'DOB': data['dob'] ?? 'N/A',
          });
        }

        // Fetch all ipTickets
        final ipTicketsSnapshot = await docRef.collection('ipTickets').get();
        for (var ipDoc in ipTicketsSnapshot.docs) {
          if (opNumber != null && opNumber.isNotEmpty) {
            if (ipDoc.data()['ipTicket'] != opNumber) continue;
          }

          fetchedData.add({
            'Patient ID': data['opNumber'] ?? 'N/A',
            'OP / IP Ticket': ipDoc.id,
            'Ticket Type': 'IP',
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'Place': data['state'] ?? 'N/A',
            'Phone No': data['phone1'] ?? 'N/A',
            'DOB': data['dob'] ?? 'N/A',
          });
        }
      }

      setState(() {
        tableData1 = fetchedData;
      });
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
                    padding: EdgeInsets.only(top: screenWidth * 0.02),
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
                    width: screenWidth * 0.15,
                    controller: _opNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(opNumber: _opNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  CustomTextField(
                    hintText: 'Phone Number',
                    width: screenWidth * 0.15,
                    controller: _phoneNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(phoneNumber: _phoneNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
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
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
