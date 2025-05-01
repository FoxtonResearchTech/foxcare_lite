import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/secondary_data_table.dart';
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

  bool isNoOfOpLoading = false;
  bool isNoWaitingQueLoading = false;
  bool isNoOfNewPatientLoading = false;

  final counterOneHeaders = ['Counter 1'];

  List<Map<String, dynamic>> counterOneTableData = [{}];
  final counterTwoHeaders = [
    'Counter 2',
  ];
  List<Map<String, dynamic>> counterTwoTableData = [{}];
  final counterThreeHeaders = [
    'Counter 3',
  ];
  List<Map<String, dynamic>> counterThreeTableData = [{}];
  final counterFourHeaders = [
    'Counter 4',
  ];
  List<Map<String, dynamic>> counterFourTableData = [{}];
  final counterFiveHeaders = [
    'Counter 5',
  ];
  List<Map<String, dynamic>> counterFiveTableData = [{}];

  final headers1 = [
    'OP Number',
    'OP Ticket',
    'Token',
    'Name',
    'Place',
    'Phone Number',
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
    setState(() {
      isNoOfOpLoading = true;
    });
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
        isNoOfOpLoading = false;
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
    setState(() {
      isNoOfNewPatientLoading = true;
    });
    try {
      final QuerySnapshot snapshot = await fireStore
          .collection('patients')
          .where('opAdmissionDate', isEqualTo: today)
          .get();

      setState(() {
        noOfNewPatients = snapshot.docs.length;
        isNoOfNewPatientLoading = false;
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
    setState(() {
      isNoWaitingQueLoading = true;
    });
    int missingCount = 0;

    try {
      final QuerySnapshot patientSnapshot =
          await fireStore.collection('patients').get();

      for (var patientDoc in patientSnapshot.docs) {
        final QuerySnapshot opTicketsSnapshot = await fireStore
            .collection('patients')
            .doc(patientDoc.id)
            .collection('opTickets')
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
        isNoWaitingQueLoading = false;
      });

      return missingCount;
    } catch (e) {
      print('Error fetching documents: $e');
      return 0;
    }
  }

  void normalizeTableDataLength() {
    int maxLength = [
      counterOneTableData.length,
      counterTwoTableData.length,
      counterThreeTableData.length,
      counterFourTableData.length,
      counterFiveTableData.length,
    ].reduce((a, b) => a > b ? a : b);

    _normalizeListLength(counterOneTableData, maxLength);
    _normalizeListLength(counterTwoTableData, maxLength);
    _normalizeListLength(counterThreeTableData, maxLength);
    _normalizeListLength(counterFourTableData, maxLength);
    _normalizeListLength(counterFiveTableData, maxLength);
  }

  void _normalizeListLength(List<Map<String, dynamic>> list, int maxLength) {
    while (list.length < maxLength) {
      list.add({
        'Counter': 'No Patient Found Today',
      });
    }
  }

  Future<void> fetchCounterData(int i) async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String counterString = i.toString();
    final String counterKey = 'Counter $i';

    try {
      List<Map<String, dynamic>> fetchedData = [];

      QuerySnapshot<Map<String, dynamic>> counterSnapshot =
          await FirebaseFirestore.instance
              .collection('doctorSchedulesDaily')
              .where('date', isEqualTo: today)
              .where('counter', isEqualTo: counterString)
              .get();

      if (counterSnapshot.docs.isNotEmpty) {
        for (var doc in counterSnapshot.docs) {
          final data = doc.data();
          String combined =
              'Doctor: ${data['doctor'] ?? 'N/A'} | Specialization: ${data['specialization'] ?? 'N/A'}';
          fetchedData.add({
            counterKey: combined,
            'Token': 'N/A',
          });
        }
      } else {
        fetchedData.add({
          counterKey: 'No doctor data available for today.',
          'Token': 'N/A',
        });
      }

      QuerySnapshot<Map<String, dynamic>> patientsSnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      List<Map<String, dynamic>> tokenData = [];

      if (patientsSnapshot.docs.isNotEmpty) {
        for (var doc in patientsSnapshot.docs) {
          final patientId = doc.id;

          QuerySnapshot<Map<String, dynamic>> ticketsSnapshot =
              await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(patientId)
                  .collection('opTickets')
                  .where('tokenDate', isEqualTo: today)
                  .where('counter', isEqualTo: counterString)
                  .get();

          for (var ticketDoc in ticketsSnapshot.docs) {
            final data = ticketDoc.data();

            if (!data.containsKey('Medication') &&
                !data.containsKey('Examination')) {
              DocumentSnapshot<Map<String, dynamic>> currentTokenDoc =
                  await FirebaseFirestore.instance
                      .collection('patients')
                      .doc(patientId)
                      .collection('tokens')
                      .doc('currentToken')
                      .get();

              String token = 'N/A';

              if (currentTokenDoc.exists) {
                final currentTokenData = currentTokenDoc.data();
                if (currentTokenData != null) {
                  token = currentTokenData['tokenNumber']?.toString() ?? 'N/A';
                }
              }

              if (token != 'N/A') {
                tokenData.add({
                  'tokenNumber': int.tryParse(token) ?? 0,
                  'display': {
                    counterKey: 'Token: $token',
                    'Doctor': 'N/A',
                  },
                });
              }
            }
          }
        }

        tokenData.sort((a, b) => a['tokenNumber'].compareTo(b['tokenNumber']));

        for (var item in tokenData) {
          fetchedData.add(item['display']);
        }
      } else {
        fetchedData.add({
          counterKey: 'No patients found for today.',
          'Token': 'N/A',
        });
      }

      setState(() {
        switch (i) {
          case 1:
            counterOneTableData = fetchedData;
            break;
          case 2:
            counterTwoTableData = fetchedData;
            break;
          case 3:
            counterThreeTableData = fetchedData;
            break;
          case 4:
            counterFourTableData = fetchedData;
            break;
          case 5:
            counterFiveTableData = fetchedData;
            break;
        }
        normalizeTableDataLength();
      });
    } catch (e) {
      print('Error fetching data for Counter $i: $e');
    }
  }

  Future<int> getMissingOp() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final QuerySnapshot patientSnapshot = await fireStore
          .collection('patients')
          .where('opAdmissionDate', isEqualTo: today)
          .get();

      int missingCount = 0;
      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        DocumentSnapshot detailsDoc =
            await doc.reference.collection('tokens').doc('currentToken').get();

        Map<String, dynamic>? detailsData = detailsDoc.exists
            ? detailsDoc.data() as Map<String, dynamic>?
            : null;

        // Fetch opTickets for this patient
        final opTicketsSnapshot = await doc.reference
            .collection('opTickets')
            .where('status', isEqualTo: 'abscond')
            .get();

        for (var ticketDoc in opTicketsSnapshot.docs) {
          final ticketData = ticketDoc.data();

          final hasMedication = ticketData.containsKey('Medication') &&
              ticketData['Medication'] != null &&
              ticketData['Medication'].toString().trim().isNotEmpty;

          final hasExamination = ticketData.containsKey('Examination') &&
              ticketData['Examination'] != null &&
              ticketData['Examination'].toString().trim().isNotEmpty;

          if (!hasMedication && !hasExamination) {
            missingCount++;

            fetchedData.add({
              'OP Number': data['opNumber'] ?? 'N/A',
              'OP Ticket': ticketData['opTicket'] ?? 'N/A',
              'Token': detailsData?['tokenNumber']?.toString() ?? 'N/A',
              'Name':
                  '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
              'Place': data['city'] ?? 'N/A',
              'Phone Number': data['phone1'] ?? 'N/A',
              'Status': CustomDropdown(
                focusColor: Colors.white,
                borderColor: Colors.white,
                label: '',
                items: ['Not Attending Call', 'Come Later', 'Others'],
                onChanged: (value) {},
              ),
            });

            break; // Only count one missing ticket per patient
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getNoOfOp();
      getNoOfNewPatients();
      getNoOFWaitingQue();
      getMissingOp();
      fetchCounterData(1);
      fetchCounterData(2);
      fetchCounterData(3);
      fetchCounterData(4);
      fetchCounterData(5);
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
                      if (counterOneTableData.isNotEmpty &&
                          _visibleTables[0]) ...[
                        Expanded(
                          child: SecondaryDataTable(
                            totalWidth: 100,
                            headerColor: Colors.white,
                            headerBackgroundColor: AppColors.blue,
                            headers: counterOneHeaders,
                            tableData: counterOneTableData,
                          ),
                        ),
                      ],
                      if (counterTwoTableData.isNotEmpty &&
                          _visibleTables[1]) ...[
                        Expanded(
                          child: SecondaryDataTable(
                            totalWidth: 100,
                            headerColor: Colors.white,
                            headerBackgroundColor: AppColors.blue,
                            headers: counterTwoHeaders,
                            tableData: counterTwoTableData,
                          ),
                        ),
                      ],
                      if (counterThreeTableData.isNotEmpty &&
                          _visibleTables[2]) ...[
                        Expanded(
                          child: SecondaryDataTable(
                            totalWidth: 100,
                            headerColor: Colors.white,
                            headerBackgroundColor: AppColors.blue,
                            headers: counterThreeHeaders,
                            tableData: counterThreeTableData,
                          ),
                        ),
                      ],
                      if (counterFourTableData.isNotEmpty &&
                          _visibleTables[3]) ...[
                        Expanded(
                          child: SecondaryDataTable(
                            totalWidth: 100,
                            headerColor: Colors.white,
                            headerBackgroundColor: AppColors.blue,
                            headers: counterFourHeaders,
                            tableData: counterFourTableData,
                          ),
                        ),
                      ],
                      if (counterFourTableData.isNotEmpty &&
                          _visibleTables[4]) ...[
                        Expanded(
                          child: SecondaryDataTable(
                            totalWidth: 100,
                            headerColor: Colors.white,
                            headerBackgroundColor: AppColors.blue,
                            headers: counterFiveHeaders,
                            tableData: counterFiveTableData,
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
                  text: 'Missing OP',
                  size: screenWidth * 0.013,
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomDataTable(
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
