import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/image/custom_image.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utilities/images.dart';
import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import 'admission_status.dart';
import 'doctor_schedule.dart';
import 'ip_admission.dart';
import 'ip_patients_admission.dart';
import 'op_counters.dart';
import 'op_ticket.dart';

class ReceptionDashboard extends StatefulWidget {
  @override
  State<ReceptionDashboard> createState() => _ReceptionDashboardState();
}

class _ReceptionDashboardState extends State<ReceptionDashboard> {
  int selectedIndex = 0;
  String? selectedStatus;

  final headers = ['Counter 1', 'Counter 2', 'Counter 3'];
  final List<Map<String, dynamic>> tableData = [{}];

  final headers1 = [
    'OP Number',
    'Token',
    'Name',
    'Place',
    'Phone Number',
    'Status',
  ];
  final List<Map<String, dynamic>> tableData1 = [
    {
      'OP Number': '',
      'Token': '',
      'Name': '',
      'Place': '',
      'Phone Number': '',
      'Status': CustomDropdown(
          label: '',
          items: ['Not Attending Call', 'Come Later', 'Others'],
          onChanged: (value) {}),
    }
  ];

  int noOfOp = 0;

  Future<int> getNoOFOp() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;

    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print("Today's date (formatted): $today");

    try {
      final QuerySnapshot snapshot = await fireStore
          .collection('patients')
          .where('opAdmissionDate', isEqualTo: today)
          .get();

      setState(() {
        noOfOp = snapshot.docs.length;
      });

      return noOfOp;
    } catch (e) {
      print('Error fetching documents: $e');
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    getNoOFOp();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(
                'Reception Dashboard',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: dashboard(),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        height: screenHeight,
        padding: EdgeInsets.only(
          left: screenWidth * 0.01,
          right: screenWidth * 0.01,
          bottom: screenWidth * 0.01,
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
                        text: "Dashboard",
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.005),
                  width: screenWidth * 0.15,
                  height: screenHeight * 0.15,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomText(text: 'No Of OP'),
                      Center(child: CustomText(text: noOfOp.toString()))
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.005),
                  width: screenWidth * 0.15,
                  height: screenHeight * 0.15,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomText(text: 'Waiting Queue'),
                      Center(child: CustomText(text: '100'))
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.005),
                  width: screenWidth * 0.15,
                  height: screenHeight * 0.15,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomText(text: 'No Of New Patients'),
                      Center(child: CustomText(text: '15'))
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.045),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'OP Waiting Queue',
                  size: screenWidth * 0.013,
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomDataTable(
                  headerColor: Colors.white,
                  headerBackgroundColor: AppColors.blue,
                  headers: headers,
                  tableData: tableData,
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.045),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Missing OP',
                  size: screenWidth * 0.013,
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomDataTable(
                  headerColor: Colors.white,
                  headerBackgroundColor: AppColors.blue,
                  headers: headers1,
                  tableData: tableData1,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
