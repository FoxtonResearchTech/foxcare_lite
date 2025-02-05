import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/lab/patient_report.dart';
import 'package:foxcare_lite/presentation/module/lab/patients_lab_details.dart';
import 'package:foxcare_lite/presentation/module/lab/reports_search.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

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
  int selectedIndex = 4;
  final List<String> headers1 = [
    'Token NO',
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      // Query to fetch patients with non-empty Medications field
      final QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('Medications',
              isNotEqualTo: null) // Ensures Medications exists
          .where('Medications',
              isNotEqualTo: '') // Ensures Medications is not empty
          .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        String tokenNo = '';
        try {
          final tokenSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
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
          print('Error fetching tokenNo for patient ${doc.id}: $e');
        }

        fetchedData.add({
          'Token NO': tokenNo,
          'OP NO': data['opNumber'] ?? 'N/A',
          'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
              .trim(),
          'Age': data['age'] ?? 'N/A',
          'Place': data['state'] ?? 'N/A',
          'Address': data['address1'] ?? 'N/A',
          'PinCode': data['pincode'] ?? 'N/A',
          'Status': data['status'] ?? 'N/A',
          'List of Tests': data['Medications'] ?? 'N/A',
          'Action': TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientReport(
                      patientID: data['opNumber'] ?? 'N/A',
                      name:
                          '${data['firstName'] ?? ''} ${data['lastName'] ?? 'N/A'}'
                              .trim(),
                      age: data['age'] ?? 'N/A',
                      sex: data['sex'] ?? 'N/A',
                      place: data['state'] ?? 'N/A',
                      dob: data['dob'] ?? 'N/A',
                      medication: data['Medications'] ?? 'N/A',
                      address: data['address1'] ?? 'N/A',
                      pincode: data['pincode'] ?? 'N/A',
                      primaryInfo: data['otherComments'] ?? 'N/A',
                      temperature: data['temperature'] ?? 'N/A',
                      bloodPressure: data['bloodPressure'] ?? 'N/A',
                      sugarLevel: data['bloodSugarLevel'] ?? 'N/A',
                    ),
                  ),
                );
              },
              child: const CustomText(text: 'Open')),
          'Sample Data': TextButton(
              onPressed: () async {
                final time = DateFormat('HH:mm:ss').format(DateTime.now());
                try {
                  await FirebaseFirestore.instance
                      .collection('patients')
                      .doc(data['opNumber'])
                      .collection('sampleData')
                      .doc('data')
                      .set({
                    'Time': time,
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
              child: const CustomText(text: 'Enter Sample Data'))
        });
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
              child: buildDrawerContent(), // Drawer minimized for mobile
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: buildDrawerContent(), // Sidebar always open for web view
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

  Widget buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Laboratory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Dashboard', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LabDashboard()),
          );
        }, Iconsax.mask),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(1, 'Test Queue', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LabTestQueue()),
          );
        }, Iconsax.receipt),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(2, 'Accounts', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LabAccounts()),
          );
        }, Iconsax.add_circle),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(3, 'Report search', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ReportsSearch()),
          );
        }, Iconsax.search_favorite),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(
            4, 'Patient Lab Details', () {}, Iconsax.search_favorite),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(5, 'Logout', () {}, Iconsax.logout),
      ],
    );
  }

  Widget buildDrawerItem(
      int index, String title, VoidCallback onTap, IconData icon) {
    return ListTile(
      selected: selectedIndex == index,
      selectedTileColor:
          Colors.blueAccent.shade100, // Highlight color for the selected item
      leading: Icon(
        icon,
        color: selectedIndex == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selectedIndex == index ? Colors.blue : Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: () {
        setState(() {
          selectedIndex = index; // Update the selected index
        });
        onTap();
      },
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
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
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
