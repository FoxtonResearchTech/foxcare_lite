import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/lab/ip_patients_lab_details.dart';
import 'package:foxcare_lite/presentation/module/lab/patients_lab_details.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/lab/lab_module_drawer.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/secondary_data_table.dart';
import 'package:intl/intl.dart';

import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/text/primary_text.dart';

class LabDashboard extends StatefulWidget {
  @override
  State<LabDashboard> createState() => _LabDashboard();
}

class _LabDashboard extends State<LabDashboard> {
  int selectedIndex = 0;
  String? selectedStatus;
  Timer? _timer;

  final opHeader = [
    'Token NO',
    'OP Ticket',
    'OP NO',
    'Name',
    'Age',
    'Place',
    'Status',
    'List of Tests',
  ];
  List<Map<String, dynamic>> opTableData = [];

  final ipHeader = [
    'IP Ticket',
    'OP NO',
    'Name',
    'Age',
    'Place',
    'Status',
    'List of Tests',
  ];
  List<Map<String, dynamic>> ipTableData = [];

  int noOfPatientsTestCompleted = 0;
  int noOfPatientsTestInCompleted = 0;

  int noOfWaitingQueue = 0;
  int noOfOp = 0;

  Future<int> getNoOfOp({int pageSize = 20}) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int opCount = 0;
    DocumentSnapshot? lastDoc;

    try {
      while (true) {
        Query query = fireStore.collection('patients').limit(pageSize);
        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final QuerySnapshot patientSnapshot = await query.get();
        if (patientSnapshot.docs.isEmpty) break;

        for (var doc in patientSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (!data.containsKey('opNumber') ||
              !data.containsKey('opAdmissionDate')) {
            continue;
          }

          try {
            final DocumentSnapshot tokenSnapshot = await doc.reference
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

        lastDoc = patientSnapshot.docs.last;
      }

      setState(() {
        noOfOp = opCount;
      });

      return opCount;
    } catch (e) {
      print('Error during pagination: $e');
      return 0;
    }
  }

  Future<int> getNoOfPatientsTestDone() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    const int pageSize = 20;
    DocumentSnapshot? lastPatientDoc;
    int count = 0;
    bool hasMore = true;

    try {
      while (hasMore) {
        Query<Map<String, dynamic>> patientQuery =
            fireStore.collection('patients').limit(pageSize);

        if (lastPatientDoc != null) {
          patientQuery = patientQuery.startAfterDocument(lastPatientDoc);
        }

        QuerySnapshot<Map<String, dynamic>> patientSnapshot =
            await patientQuery.get();

        if (patientSnapshot.docs.isEmpty) {
          break;
        }

        for (var patientDoc in patientSnapshot.docs) {
          final opTicketsSnapshot = await fireStore
              .collection('patients')
              .doc(patientDoc.id)
              .collection('opTickets')
              .get();

          for (var ticketDoc in opTicketsSnapshot.docs) {
            final data = ticketDoc.data();

            if (data['labExaminationPrescribedDate'] == today &&
                data['reportDate'] == today &&
                data.containsKey('opTicket')) {
              count++;
            }
          }
        }

        lastPatientDoc = patientSnapshot.docs.last;
        hasMore = patientSnapshot.docs.length == pageSize;
        setState(() {
          noOfPatientsTestCompleted = count;
          noOfPatientsTestInCompleted =
              (noOfWaitingQueue - noOfPatientsTestCompleted)
                  .clamp(0, double.infinity)
                  .toInt();
        });

        // Optional delay to smooth things out
        await Future.delayed(const Duration(milliseconds: 300));
      }

      return count;
    } catch (e) {
      print('Error fetching test data: $e');
      return 0;
    }
  }

  Future<int> getNoOFWaitingQue() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    const int pageSize = 20;
    DocumentSnapshot? lastPatientDoc;
    int missingCount = 0;
    bool hasMore = true;

    try {
      while (hasMore) {
        Query<Map<String, dynamic>> patientQuery =
            fireStore.collection('patients').limit(pageSize);

        if (lastPatientDoc != null) {
          patientQuery = patientQuery.startAfterDocument(lastPatientDoc);
        }

        QuerySnapshot<Map<String, dynamic>> patientSnapshot =
            await patientQuery.get();

        if (patientSnapshot.docs.isEmpty) {
          break;
        }

        for (var patientDoc in patientSnapshot.docs) {
          final opTicketsSnapshot = await fireStore
              .collection('patients')
              .doc(patientDoc.id)
              .collection('opTickets')
              .get();

          for (var ticketDoc in opTicketsSnapshot.docs) {
            final data = ticketDoc.data();

            if (data['labExaminationPrescribedDate'] == today &&
                data.containsKey('Examination') &&
                data.containsKey('opTicket')) {
              final testSnapshot = await fireStore
                  .collection('patients')
                  .doc(patientDoc.id)
                  .collection('opTickets')
                  .doc(ticketDoc.id)
                  .collection('tests')
                  .limit(1)
                  .get();

              if (testSnapshot.docs.isEmpty) {
                missingCount++;
              }
            }
          }
        }

        lastPatientDoc = patientSnapshot.docs.last;
        hasMore = patientSnapshot.docs.length == pageSize;
        setState(() {
          noOfWaitingQueue = missingCount;
        });

        // Optional short delay to avoid throttling
        await Future.delayed(const Duration(milliseconds: 300));
      }

      return missingCount;
    } catch (e) {
      print('Error fetching waiting queue: $e');
      return 0;
    }
  }

  Future<void> getWaitingLabTestOpPatients() async {
    try {
      final DateTime now = DateTime.now();
      final String todayDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final int pageSize = 10;
      DocumentSnapshot? lastDoc;
      bool hasMore = true;
      List<Map<String, dynamic>> finalList = [];

      while (hasMore) {
        Query<Map<String, dynamic>> query =
            FirebaseFirestore.instance.collection('patients').limit(pageSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snapshot = await query.get();
        final docs = snapshot.docs;
        if (docs.isEmpty) break;

        for (final patientDoc in docs) {
          final patientData = patientDoc.data();

          final ticketsSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientDoc.id)
              .collection('opTickets')
              .get();

          for (final ticketDoc in ticketsSnapshot.docs) {
            final data = ticketDoc.data();

            if (!data.containsKey('opTicket')) continue;
            if (data.containsKey('reportNo') && data.containsKey('reportDate'))
              continue;
            if (!data.containsKey('Examination') ||
                (data['Examination'] as List).isEmpty) continue;
            if (data['labExaminationPrescribedDate'] != todayDate) continue;

            String tokenNo = '';
            try {
              final tokenSnapshot = await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(patientDoc.id)
                  .collection('tokens')
                  .doc('currentToken')
                  .get();
              if (tokenSnapshot.exists) {
                final tokenData = tokenSnapshot.data();
                tokenNo = tokenData?['tokenNumber']?.toString() ?? '';
              }
            } catch (e) {
              print('Token fetch error: $e');
            }

            finalList.add({
              'Token NO': tokenNo,
              'OP Ticket': data['opTicket'],
              'OP NO': patientData['opNumber'],
              'Name': '${patientData['firstName']} ${patientData['lastName']}',
              'Age': patientData['age'],
              'Place': patientData['city'],
              'Address': patientData['address1'],
              'PinCode': patientData['pincode'],
              'Status': data['status'],
              'List of Tests': data['Examination'],
            });
          }
        }

        lastDoc = docs.last;
        hasMore = docs.length == pageSize;

        setState(() {
          opTableData = List.from(finalList);
        });
        await Future.delayed(Duration(milliseconds: 100));
      }
      finalList.sort((a, b) =>
          (int.tryParse(a['Token NO']) ?? 0) -
          (int.tryParse(b['Token NO']) ?? 0));
    } catch (e) {
      print('Error in OP: $e');
    }
  }

  Future<void> getWaitingLabTestIpPatients() async {
    try {
      final DateTime now = DateTime.now();
      final String todayDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final int pageSize = 10;
      DocumentSnapshot? lastDoc;
      bool hasMore = true;
      List<Map<String, dynamic>> finalList = [];

      while (hasMore) {
        Query<Map<String, dynamic>> query =
            FirebaseFirestore.instance.collection('patients').limit(pageSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snapshot = await query.get();
        final docs = snapshot.docs;
        if (docs.isEmpty) break;

        for (final patientDoc in docs) {
          final patientData = patientDoc.data();

          final ticketsSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientDoc.id)
              .collection('ipTickets')
              .get();

          for (final ticketDoc in ticketsSnapshot.docs) {
            final ticketData = ticketDoc.data();
            if (!ticketData.containsKey('ipTicket')) continue;

            final examSnapshot = await FirebaseFirestore.instance
                .collection('patients')
                .doc(patientDoc.id)
                .collection('ipTickets')
                .doc(ticketDoc.id)
                .collection('Examination')
                .get();

            for (final examDoc in examSnapshot.docs) {
              final examData = examDoc.data();

              final hasReport = examData.containsKey('reportNo') &&
                  examData.containsKey('reportDate');
              if (hasReport) continue;

              if (examData['date'] != todayDate) continue;

              final examItems = examData['items'];
              final List<String> tests = (examItems is List)
                  ? examItems.whereType<String>().toList()
                  : [];

              if (tests.isEmpty) continue;

              finalList.add({
                'IP Ticket': ticketData['ipTicket'],
                'OP NO': patientData['opNumber'],
                'Name':
                    '${patientData['firstName']} ${patientData['lastName']}',
                'Age': patientData['age'],
                'Place': patientData['state'],
                'Address': patientData['address1'],
                'PinCode': patientData['pincode'],
                'Status': ticketData['status'],
                'List of Tests': tests,
              });
            }
          }
        }

        lastDoc = docs.last;
        hasMore = docs.length == pageSize;
        setState(() {
          ipTableData = List.from(finalList);
        });
        await Future.delayed(Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error in IP: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    getWaitingLabTestOpPatients();
    getWaitingLabTestIpPatients();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      getNoOfOp();
      getNoOfPatientsTestDone();
      getNoOFWaitingQue();
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
              child: LabModuleDrawer(
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
              child: LabModuleDrawer(
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
                  padding: EdgeInsets.only(top: screenWidth * 0.01),
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
            SizedBox(height: screenHeight * 0.075),
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
                  title: 'No Of Patients Test Completed',
                  value: noOfPatientsTestCompleted.toString(),
                  icon: Icons.done_all_outlined,
                  width: screenWidth * 0.17,
                  height: screenHeight * 0.17,
                ),
                buildDashboardCard(
                  title: 'No Of Patients Test InCompleted',
                  value: noOfPatientsTestInCompleted.toString(),
                  icon: Icons.incomplete_circle_outlined,
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
                LazyDataTable(
                  headerColor: Colors.white,
                  headerBackgroundColor: AppColors.blue,
                  headers: opHeader,
                  tableData: opTableData,
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: CustomButton(
                    label: 'View More',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PatientsLabDetails()));
                    },
                    width: screenWidth * 0.1,
                    height: screenHeight * 0.05,
                  ),
                )
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
                      text: 'IP Waiting Queue',
                      size: screenWidth * 0.013,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                LazyDataTable(
                  headerColor: Colors.white,
                  headerBackgroundColor: AppColors.blue,
                  headers: ipHeader,
                  tableData: ipTableData,
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: CustomButton(
                    label: 'View More',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IpPatientsLabDetails()));
                    },
                    width: screenWidth * 0.1,
                    height: screenHeight * 0.05,
                  ),
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.07)
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
