import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:intl/intl.dart';

import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../utilities/widgets/text/primary_text.dart';

class ReceptionDashboard extends StatefulWidget {
  @override
  State<ReceptionDashboard> createState() => _ReceptionDashboardState();
}

class _ReceptionDashboardState extends State<ReceptionDashboard> {
  int selectedIndex = 0;
  String? selectedStatus;
  Timer? _timer;

  final counterOneHeaders = [
    'Counter 1',
    'Doctor',
    'Specialization',
    'Morning OP In',
    'Morning OP Out',
    'Evening OP In',
    'Evening OP Out',
  ];
  List<Map<String, dynamic>> counterOneTableData = [{}];
  final counterTwoHeaders = [
    'Counter 2',
    'Doctor',
    'Specialization',
    'Morning OP In',
    'Morning OP Out',
    'Evening OP In',
    'Evening OP Out',
  ];
  List<Map<String, dynamic>> counterTwoTableData = [{}];
  final counterThreeHeaders = [
    'Counter 3',
    'Doctor',
    'Specialization',
    'Morning OP In',
    'Morning OP Out',
    'Evening OP In',
    'Evening OP Out',
  ];
  List<Map<String, dynamic>> counterThreeTableData = [{}];
  final counterFourHeaders = [
    'Counter 4',
    'Doctor',
    'Specialization',
    'Morning OP In',
    'Morning OP Out',
    'Evening OP In',
    'Evening OP Out',
  ];
  List<Map<String, dynamic>> counterFourTableData = [{}];
  final counterFiveHeaders = [
    'Counter 5',
    'Doctor',
    'Specialization',
    'Morning OP In',
    'Morning OP Out',
    'Evening OP In',
    'Evening OP Out',
  ];
  List<Map<String, dynamic>> counterFiveTableData = [{}];

  final headers1 = [
    'OP Number',
    'Token',
    'Name',
    'Place',
    'Phone Number',
    'Status',
  ];
  List<Map<String, dynamic>> tableData1 = [{}];

  List<bool> _visibleTables = [false, false, false, false, false];

  int noOfNewPatients = 0;
  int noOfWaitingQueue = 0;
  int noOfOp = 0;

  Future<int> getNoOfOp() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int opCount = 0;

    try {
      final QuerySnapshot patientSnapshot =
          await fireStore.collection('patients').get();

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('opNumber') ||
            !data.containsKey('opAdmissionDate')) continue;

        try {
          final DocumentSnapshot tokenSnapshot = await fireStore
              .collection('patients')
              .doc(doc.id)
              .collection('tokens')
              .doc('currentToken')
              .get();

          if (tokenSnapshot.exists) {
            final tokenData = tokenSnapshot.data() as Map<String, dynamic>?;

            final String? tokenDate = tokenData?['date'];

            if (tokenDate == today) {
              opCount++;
            }
          }
        } catch (e) {
          print('Error fetching token for patient ${doc.id}: $e');
        }
      }

      setState(() {
        noOfOp = opCount;
      });

      return opCount;
    } catch (e) {
      print('Error fetching patients: $e');
      return 0;
    }
  }

  Future<int> getNoOfNewPatients() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;

    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final QuerySnapshot snapshot = await fireStore
          .collection('patients')
          .where('opAdmissionDate', isEqualTo: today)
          .get();

      setState(() {
        noOfNewPatients = snapshot.docs.length;
      });

      return noOfNewPatients;
    } catch (e) {
      print('Error fetching documents: $e');
      return 0;
    }
  }

  Future<int> getNoOFWaitingQue() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final QuerySnapshot snapshot = await fireStore
          .collection('patients')
          .where('opAdmissionDate', isEqualTo: today)
          .get();

      int missingCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('Medication') &&
            !data.containsKey('Examination')) {
          missingCount++;
        }
      }

      setState(() {
        noOfWaitingQueue = missingCount;
      });

      return missingCount;
    } catch (e) {
      print('Error fetching documents: $e');
      return 0;
    }
  }

  Future<void> fetchCounterOneData() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      QuerySnapshot<Map<String, dynamic>> counterSnapshot =
          await FirebaseFirestore.instance
              .collection('doctorSchedulesDaily')
              .where('date', isEqualTo: today)
              .where('counter', isEqualTo: '1')
              .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in counterSnapshot.docs) {
        final data = doc.data();
        fetchedData.add({
          'Counter 1': data['counter'],
          'Doctor': data['doctor'],
          'Specialization': data['specialization'],
          'Morning OP In': data['morningOpIn'],
          'Morning OP Out': data['morningOpOut'],
          'Evening OP In': data['eveningOpIn'],
          'Evening OP Out': data['eveningOpOut'],
        });
      }
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Counter'].toString()) ?? 0;
        int tokenB = int.tryParse(b['Counter'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });
      setState(() {
        counterOneTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchCounterTwoData() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      QuerySnapshot<Map<String, dynamic>> counterSnapshot =
          await FirebaseFirestore.instance
              .collection('doctorSchedulesDaily')
              .where('date', isEqualTo: today)
              .where('counter', isEqualTo: '2')
              .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in counterSnapshot.docs) {
        final data = doc.data();
        fetchedData.add({
          'Counter 2': data['counter'],
          'Doctor': data['doctor'],
          'Specialization': data['specialization'],
          'Morning OP In': data['morningOpIn'],
          'Morning OP Out': data['morningOpOut'],
          'Evening OP In': data['eveningOpIn'],
          'Evening OP Out': data['eveningOpOut'],
        });
      }
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Counter'].toString()) ?? 0;
        int tokenB = int.tryParse(b['Counter'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });
      setState(() {
        counterTwoTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchCounterThreeData() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      QuerySnapshot<Map<String, dynamic>> counterSnapshot =
          await FirebaseFirestore.instance
              .collection('doctorSchedulesDaily')
              .where('date', isEqualTo: today)
              .where('counter', isEqualTo: '3')
              .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in counterSnapshot.docs) {
        final data = doc.data();
        fetchedData.add({
          'Counter 3': data['counter'],
          'Doctor': data['doctor'],
          'Specialization': data['specialization'],
          'Morning OP In': data['morningOpIn'],
          'Morning OP Out': data['morningOpOut'],
          'Evening OP In': data['eveningOpIn'],
          'Evening OP Out': data['eveningOpOut'],
        });
      }
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Counter'].toString()) ?? 0;
        int tokenB = int.tryParse(b['Counter'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });
      setState(() {
        counterThreeTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchCounterFourData() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      QuerySnapshot<Map<String, dynamic>> counterSnapshot =
          await FirebaseFirestore.instance
              .collection('doctorSchedulesDaily')
              .where('date', isEqualTo: today)
              .where('counter', isEqualTo: '4')
              .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in counterSnapshot.docs) {
        final data = doc.data();
        fetchedData.add({
          'Counter 4': data['counter'],
          'Doctor': data['doctor'],
          'Specialization': data['specialization'],
          'Morning OP In': data['morningOpIn'],
          'Morning OP Out': data['morningOpOut'],
          'Evening OP In': data['eveningOpIn'],
          'Evening OP Out': data['eveningOpOut'],
        });
      }
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Counter'].toString()) ?? 0;
        int tokenB = int.tryParse(b['Counter'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });
      setState(() {
        counterFourTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchCounterFiveData() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      QuerySnapshot<Map<String, dynamic>> counterSnapshot =
          await FirebaseFirestore.instance
              .collection('doctorSchedulesDaily')
              .where('date', isEqualTo: today)
              .where('counter', isEqualTo: '5')
              .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in counterSnapshot.docs) {
        final data = doc.data();
        fetchedData.add({
          'Counter 5': data['counter'],
          'Doctor': data['doctor'],
          'Specialization': data['specialization'],
          'Morning OP In': data['morningOpIn'],
          'Morning OP Out': data['morningOpOut'],
          'Evening OP In': data['eveningOpIn'],
          'Evening OP Out': data['eveningOpOut'],
        });
      }
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Counter'].toString()) ?? 0;
        int tokenB = int.tryParse(b['Counter'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });
      setState(() {
        counterFiveTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<int> getMissingOp() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final QuerySnapshot snapshot = await fireStore
          .collection('patients')
          .where('opAdmissionDate', isEqualTo: today)
          .where('status', isEqualTo: 'abscond')
          .get();

      int missingCount = 0;
      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        DocumentSnapshot detailsDoc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(doc.id)
            .collection('tokens')
            .doc('currentToken')
            .get();

        Map<String, dynamic>? detailsData = detailsDoc.exists
            ? detailsDoc.data() as Map<String, dynamic>?
            : null;

        if (!data.containsKey('Medication') &&
            !data.containsKey('Examination')) {
          fetchedData.add({
            'OP Number': data['opNumber'] ?? 'N/A',
            'Token': detailsData?['tokenNumber'] ?? 'N/A',
            'Name': data['name'] ?? 'N/A',
            'Place': data['place'] ?? 'N/A',
            'Phone Number': data['phoneNumber'] ?? 'N/A',
            'Status': CustomDropdown(
                focusColor: Colors.white,
                borderColor: Colors.white,
                label: '',
                items: ['Not Attending Call', 'Come Later', 'Others'],
                onChanged: (value) {}),
          });
        }
      }

      setState(() {
        tableData1 = fetchedData;
      });

      return missingCount;
    } catch (e) {
      print('Error fetching documents: $e');
      return 0;
    }
  }

  void _showTablesWithDelay() async {
    for (int i = 0; i < _visibleTables.length; i++) {
      await Future.delayed(Duration(milliseconds: 250));
      setState(() {
        _visibleTables[i] = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      getNoOfOp();
      getNoOfNewPatients();
      getNoOFWaitingQue();
      getMissingOp();

      fetchCounterOneData();
      fetchCounterTwoData();
      fetchCounterThreeData();
      fetchCounterFourData();
      fetchCounterFiveData();
      _showTablesWithDelay();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
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
                buildDashboardCard(
                  title: 'No Of OP',
                  value: noOfOp.toString(),
                  icon: Icons.person,
                  width: screenWidth * 0.17,
                  height: screenHeight * 0.17,
                ),
                buildDashboardCard(
                  title: 'Waiting Queue',
                  value: noOfWaitingQueue.toString(),
                  icon: Icons.access_time,
                  width: screenWidth * 0.17,
                  height: screenHeight * 0.17,
                ),
                buildDashboardCard(
                  title: 'No Of New Patients',
                  value: noOfNewPatients.toString(),
                  icon: Icons.person_add_alt,
                  width: screenWidth * 0.17,
                  height: screenHeight * 0.17,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(
                      text: 'OP Waiting Queue',
                      size: screenWidth * 0.013,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                if (counterOneTableData.isNotEmpty && _visibleTables[0]) ...[
                  CustomDataTable(
                    headerColor: Colors.white,
                    headerBackgroundColor: AppColors.blue,
                    headers: counterOneHeaders,
                    tableData: counterOneTableData,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
                if (counterTwoTableData.isNotEmpty && _visibleTables[1]) ...[
                  CustomDataTable(
                    headerColor: Colors.white,
                    headerBackgroundColor: AppColors.blue,
                    headers: counterTwoHeaders,
                    tableData: counterTwoTableData,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
                if (counterThreeTableData.isNotEmpty && _visibleTables[2]) ...[
                  CustomDataTable(
                    headerColor: Colors.white,
                    headerBackgroundColor: AppColors.blue,
                    headers: counterThreeHeaders,
                    tableData: counterThreeTableData,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
                if (counterFourTableData.isNotEmpty && _visibleTables[3]) ...[
                  CustomDataTable(
                    headerColor: Colors.white,
                    headerBackgroundColor: AppColors.blue,
                    headers: counterFourHeaders,
                    tableData: counterFourTableData,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
                if (counterFiveTableData.isNotEmpty && _visibleTables[4]) ...[
                  CustomDataTable(
                    headerColor: Colors.white,
                    headerBackgroundColor: AppColors.blue,
                    headers: counterFiveHeaders,
                    tableData: counterFiveTableData,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
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

  Widget buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required double width,
    required double height,
    Color? color,
  }) {
    color ??= AppColors.blue;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.01),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon, size: screenWidth * 0.025, color: Colors.white),
          CustomText(
            text: title,
            color: Colors.white,
          ),
          CustomText(
            text: value,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
