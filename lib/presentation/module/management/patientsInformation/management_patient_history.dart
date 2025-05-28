import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/patient_information/management_patient_information.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../../doctor/patient_history_dialog.dart';
import '../generalInformation/general_information_admission_status.dart';
import 'management_patients_list.dart';
import 'management_register_patient.dart';

class ManagementPatientHistory extends StatefulWidget {
  @override
  State<ManagementPatientHistory> createState() => _ManagementPatientHistory();
}

class _ManagementPatientHistory extends State<ManagementPatientHistory> {
  int selectedIndex = 1;
  TextEditingController _opNumber = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  final List<String> headers1 = [
    'OP NO',
    'Name',
    'Place',
    'Phone No',
    'DOB',
    'View',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  void showPatientHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PatientHistoryDialog();
      },
    );
  }

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
    print('Fetching data with pagination...');
    DocumentSnapshot? lastDocument;
    List<Map<String, dynamic>> allFetchedData = [];

    try {
      while (true) {
        Query query = FirebaseFirestore.instance.collection('patients');

        if (opNumber != null) {
          query = query.where('opNumber', isEqualTo: opNumber);
        } else if (phoneNumber != null) {
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
          if (!data.containsKey('opNumber')) continue;
          allFetchedData.add(
            {
              'OP NO': data['opNumber'] ?? 'N/A',
              'Name':
                  '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                      .trim(),
              'Place': data['state'] ?? 'N/A',
              'Phone No': data['phone1'] ?? 'N/A',
              'DOB': data['dob'] ?? 'N/A',
              'View': TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PatientHistoryDialog(
                        firstName: data['firstName'],
                        lastName: data['lastName'],
                        dob: data['dob'],
                        sex: data['sex'],
                        phone1: data['phone1'],
                        phone2: data['phone2'],
                        opNumber: data['opNumber'],
                        ipNumber: data['ipNumber'],
                        bloodGroup: data['bloodGroup'],
                      );
                    },
                  );
                },
                child: const CustomText(text: 'View'),
              ),
            },
          );
        }

        lastDocument = snapshot.docs.last;

        // Optional: throttle delay to reduce load
        await Future.delayed(delayBetweenPages);
      }

      setState(() {
        tableData1 = allFetchedData;
      });
      print('Finished fetching ${allFetchedData.length} records.');
    } catch (e) {
      print('Error fetching data from Firestore: $e');
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
                text: 'Patient Information',
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
                          text: "Patient History",
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
              LazyDataTable(
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
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
