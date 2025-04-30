import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/doctor/doctor_module_drawer.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/secondary_data_table.dart';
import 'package:intl/intl.dart';

import '../../../utilities/widgets/text/primary_text.dart';
import '../../login/fetch_user.dart';

class DoctorDashboard extends StatefulWidget {
  final String? doctorName;
  const DoctorDashboard({this.doctorName});
  @override
  State<DoctorDashboard> createState() => _DoctorDashboard();
}

class _DoctorDashboard extends State<DoctorDashboard> {
  final UserModel? currentUser = UserSession.currentUser;

  int selectedIndex = 0;
  String? selectedStatus;
  Timer? _timer;

  final counterHeaders = ['Counter'];

  List<Map<String, dynamic>> counterTableData = [{}];

  final headers1 = [
    'OP Number',
    'OP Ticket',
    'Token',
    'Name',
    'Place',
    'Phone Number',
    'Examinations',
    'Status',
  ];
  List<Map<String, dynamic>> tableData1 = [{}];

  int noOfNewPatients = 0;
  int noOfWaitingQueue = 0;
  int noOfOp = 0;

  List<bool> _visibleTables = [false, false, false, false, false];

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
              final QuerySnapshot opTicketsSnapshot = await fireStore
                  .collection('patients')
                  .doc(doc.id)
                  .collection('opTickets')
                  .where('doctorName', isEqualTo: currentUser!.name)
                  .where('tokenDate', isEqualTo: today)
                  .get();

              if (opTicketsSnapshot.docs.isNotEmpty) {
                opCount += opTicketsSnapshot.docs.length;
              }
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

    int missingCount = 0;

    try {
      final QuerySnapshot patientSnapshot =
          await fireStore.collection('patients').get();

      for (var patientDoc in patientSnapshot.docs) {
        final QuerySnapshot opTicketsSnapshot = await fireStore
            .collection('patients')
            .doc(patientDoc.id)
            .collection('opTickets')
            .where('doctorName', isEqualTo: currentUser!.name)
            .where('tokenDate', isEqualTo: today)
            .get();

        for (var opTicketDoc in opTicketsSnapshot.docs) {
          final data = opTicketDoc.data() as Map<String, dynamic>;

          if (!data.containsKey('Medication') &&
              !data.containsKey('Examination')) {
            missingCount++;
          }
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
    final user = UserSession.currentUser;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      List<Map<String, dynamic>> fetchedData = [];

      QuerySnapshot<Map<String, dynamic>> counterSnapshot =
          await FirebaseFirestore.instance
              .collection('employees')
              .where('roles', isEqualTo: 'Doctor')
              .get();

      bool doctorFound = false;

      for (var doc in counterSnapshot.docs) {
        final data = doc.data();
        final String fullName = '${data['firstName']} ${data['lastName']}';

        if (fullName == currentUser!.name) {
          doctorFound = true;

          String combined =
              'Doctor: $fullName | Specialization: ${data['specialization'] ?? 'N/A'}';
          fetchedData.add({
            'Counter': combined,
            'Token': 'N/A',
          });
          break;
        }
      }

      if (!doctorFound) {
        fetchedData.add({
          'Counter': 'Currently No Patients in Queue.',
          'Token': 'N/A',
        });
      }

      QuerySnapshot<Map<String, dynamic>> patientSnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      List<Map<String, dynamic>> tokenData = [];

      for (var patientDoc in patientSnapshot.docs) {
        final patientId = patientDoc.id;

        QuerySnapshot<Map<String, dynamic>> opTicketsSnapshot =
            await FirebaseFirestore.instance
                .collection('patients')
                .doc(patientId)
                .collection('opTickets')
                .where('doctorName', isEqualTo: currentUser!.name)
                .where('tokenDate', isEqualTo: today)
                .get();

        if (opTicketsSnapshot.docs.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> currentTokenSnapshot =
              await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(patientId)
                  .collection('tokens')
                  .doc('currentToken')
                  .get();

          if (currentTokenSnapshot.exists) {
            final currentTokenData = currentTokenSnapshot.data();
            String token =
                currentTokenData?['tokenNumber']?.toString() ?? 'N/A';

            if (token != 'N/A') {
              tokenData.add({
                'tokenNumber': int.tryParse(token) ?? 0,
                'display': {
                  'Counter': 'Token: $token',
                  'Doctor': 'N/A',
                },
              });
            }
          }
        }
      }

      // Sort tokens
      tokenData.sort((a, b) => a['tokenNumber'].compareTo(b['tokenNumber']));

      for (var item in tokenData) {
        fetchedData.add(item['display']);
      }

      if (tokenData.isEmpty) {
        fetchedData.add({
          'Counter': 'No patients found for today.',
          'Token': 'N/A',
        });
      }

      // Step 3: Update UI
      setState(() {
        counterTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<int> getLabOp() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final QuerySnapshot patientSnapshot = await fireStore
          .collection('patients')
          .where('opAdmissionDate', isEqualTo: today)
          .get();

      int matchingCount = 0;
      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        DocumentSnapshot detailsDoc =
            await doc.reference.collection('tokens').doc('currentToken').get();

        Map<String, dynamic>? detailsData = detailsDoc.exists
            ? detailsDoc.data() as Map<String, dynamic>?
            : null;

        final opTicketsSnapshot = await doc.reference
            .collection('opTickets')
            .where('doctorName', isEqualTo: widget.doctorName)
            .get();

        for (var ticketDoc in opTicketsSnapshot.docs) {
          final ticketData = ticketDoc.data();

          if (ticketData.containsKey('Examination')) {
            matchingCount++;

            fetchedData.add({
              'OP Number': data['opNumber'] ?? 'N/A',
              'OP Ticket': ticketDoc.id,
              'Token': detailsData?['tokenNumber']?.toString() ?? 'N/A',
              'Name':
                  '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
              'Place': data['city'] ?? 'N/A',
              'Phone Number': data['phone1'] ?? 'N/A',
              'Examinations': ticketData['Examination'],
              'Status': CustomDropdown(
                focusColor: Colors.white,
                borderColor: Colors.white,
                label: '',
                items: const ['Not Attending Call', 'Come Later', 'Others'],
                onChanged: (value) {},
              ),
            });

            break;
          }
        }
      }

      // Sort by token number
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Token'].toString()) ?? 0;
        int tokenB = int.tryParse(b['Token'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData1 = fetchedData;
      });

      return matchingCount;
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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getNoOfOp();
      getNoOfNewPatients();
      getNoOFWaitingQue();
      getLabOp();
      fetchCounterOneData();
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
              child: DoctorModuleDrawer(
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
              child: DoctorModuleDrawer(
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
                SingleChildScrollView(
                  child: Row(
                    children: [
                      if (counterTableData.isNotEmpty && _visibleTables[0]) ...[
                        Expanded(
                          child: SecondaryDataTable(
                            totalWidth: 100,
                            headerColor: Colors.white,
                            headerBackgroundColor: AppColors.blue,
                            headers: counterHeaders,
                            tableData: counterTableData,
                          ),
                        ),
                      ],
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
                  text: 'Lab OP',
                  size: screenWidth * 0.013,
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomDataTable(
                  columnWidths: const {
                    0: FixedColumnWidth(100.0),
                    1: FixedColumnWidth(100.0),
                    2: FixedColumnWidth(70.0),
                    3: FixedColumnWidth(150.0),
                    4: FixedColumnWidth(125.0),
                    5: FixedColumnWidth(150.0),
                    6: FixedColumnWidth(200.0),
                  },
                  headerColor: Colors.white,
                  headerBackgroundColor: AppColors.blue,
                  headers: headers1,
                  tableData: tableData1,
                ),
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
