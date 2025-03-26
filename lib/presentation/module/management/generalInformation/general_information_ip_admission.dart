import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_admission_status.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';

import 'package:iconsax/iconsax.dart';

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
    'Token NO',
    'IP NO',
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

  Future<void> fetchData() async {
    try {
      final QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('ipNumber', isGreaterThan: '')
          .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        String tokenNo = '';
        bool hasIpPrescription = false;

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
          final ipPrescriptionSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipPrescription')
              .get();

          if (ipPrescriptionSnapshot.docs.isNotEmpty) {
            hasIpPrescription = true;
          }
        } catch (e) {
          print('Error fetching token No for patient ${doc.id}: $e');
        }

        if (!hasIpPrescription) {
          fetchedData.add({
            'Token NO': tokenNo,
            'OP NO': data['opNumber'] ?? 'N/A',
            'IP NO': data['ipNumber'] ?? 'N/A',
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'Age': data['age'] ?? 'N/A',
            'Place': data['state'] ?? 'N/A',
            'Address': data['address1'] ?? 'N/A',
            'PinCode': data['pincode'] ?? 'N/A',
            'Status': data['status'] ?? 'N/A',
            'Primary Info': data['otherComments'] ?? 'N/A',
            'Action': TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceptionIpPatient(
                        patientID: data['opNumber'] ?? 'N/A',
                        ipNumber: data['ipNumber'] ?? 'N/A',
                        name:
                            '${data['firstName'] ?? ''} ${data['lastName'] ?? 'N/A'}'
                                .trim(),
                        age: data['age'] ?? 'N/A',
                        place: data['state'] ?? 'N/A',
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
                child: const CustomText(text: 'IP Rooms')),
            'Abort': TextButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('patients')
                        .doc(data['ipNumber'])
                        .update({'status': 'aborted'});

                    CustomSnackBar(context,
                        message: 'Status updated to aborted');
                  } catch (e) {
                    print(
                        'Error updating status for patient ${data['patientID']}: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update status')),
                    );
                  }
                },
                child: const CustomText(text: 'Abort'))
          });
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
                text: 'General Information',
              ),
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
              padding: const EdgeInsets.all(16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer content reused for both web and mobile
  Widget buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'General Information',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'OP Ticket Generation', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeneralInformationOpTicket()));
        }, Iconsax.mask),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'IP Admission', () {}, Iconsax.receipt),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(2, 'Admission Status', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeneralInformationAdmissionStatus()));
        }, Iconsax.add_circle),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'Doctor Visit  Schedule', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      GeneralInformationDoctorVisitSchedule()));
        }, Iconsax.add_circle),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(4, 'Doctor Visit  Schedule Edit', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      GeneralInformationEditDoctorVisitSchedule()));
        }, Iconsax.add_circle),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(5, 'Back To Management Dashboard', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ManagementDashboard()));
        }, Iconsax.backward),
      ],
    );
  }

  // Helper method to build drawer items with the ability to highlight the selected item
  Widget buildDrawerItem(
      int index, String title, VoidCallback onTap, IconData icon) {
    return ListTile(
      selected: selectedIndex == index,
      selectedTileColor:
          Colors.blueAccent.shade100, // Highlight color for the selected item
      leading: Icon(
        icon, // Replace with actual icons
        color: selectedIndex == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
            fontFamily: 'SanFrancisco',
            color: selectedIndex == index ? Colors.blue : Colors.black54,
            fontWeight: FontWeight.w700),
      ),
      onTap: () {
        setState(() {
          selectedIndex = index; // Update the selected index
        });
        onTap();
      },
    );
  }

  // The form displayed in the body
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
              CustomDataTable(
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
