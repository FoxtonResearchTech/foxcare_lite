import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/colors.dart';

import 'package:iconsax/iconsax.dart';

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

  final List<String> headers1 = [
    'Patient ID',
    'Name',
    'Room/Ward',
    'Consulting Doctor',
    'Admission Date',
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

  Future<void> fetchData({String? patientId, String? phoneNumber}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (patientId != null) {
        query = query.where('opNumber', isEqualTo: patientId);
      } else if (phoneNumber != null) {
        query = query.where(Filter.or(
          Filter('phone1', isEqualTo: phoneNumber),
          Filter('phone2', isEqualTo: phoneNumber),
        ));
      }

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No records found");
        setState(() {
          tableData1 = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        bool hasOpNumber =
            data.containsKey('opNumber') && data['opNumber'] != null;

        DocumentSnapshot detailsDoc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(doc.id)
            .collection('ipPrescription')
            .doc('details')
            .get();

        Map<String, dynamic>? detailsData = detailsDoc.exists
            ? detailsDoc.data() as Map<String, dynamic>?
            : null;

        fetchedData.add(
          {
            'Patient ID': hasOpNumber
                ? data['opNumber'] ?? 'N/A'
                : data['ipNumber'] ?? 'N/A',
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'Room/Ward': detailsData?['ipAdmission']?['roomType'] != null &&
                    detailsData?['ipAdmission']?['roomNumber'] != null
                ? "${detailsData!['ipAdmission']['roomType']} ${detailsData['ipAdmission']['roomNumber']}"
                : 'N/A',
            'Consulting Doctor': data['consultingDoctor'] ?? 'N/A',
            'Admission Date': data['opAdmissionDate'] ?? 'N/A',
          },
        );
      }

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

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.03,
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
                          text: "Admission Status ",
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    hintText: 'OP Number',
                    width: screenWidth * 0.15,
                    controller: _patientID,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(patientId: _patientID.text);
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
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData1,
                headers: headers1,
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
