import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import 'general_information_admission_status.dart';
import 'general_information_doctor_visit_schedule.dart';
import 'general_information_edit_doctor_visit_schedule.dart';

class GeneralInformationOpTicket extends StatefulWidget {
  @override
  State<GeneralInformationOpTicket> createState() =>
      _GeneralInformationOpTicket();
}

class _GeneralInformationOpTicket extends State<GeneralInformationOpTicket> {
  final dateTime = DateTime.timestamp();
  int selectedIndex = 0;
  final TextEditingController tokenDate = TextEditingController();
  final TextEditingController counter = TextEditingController();
  final TextEditingController doctorName = TextEditingController();
  final TextEditingController bloodSugarLevel = TextEditingController();
  final TextEditingController temperature = TextEditingController();
  final TextEditingController bloodPressure = TextEditingController();
  final TextEditingController otherComments = TextEditingController();
  final TextEditingController opTicketTotalAmount = TextEditingController();
  final TextEditingController opTicketCollectedAmount = TextEditingController();

  final TextEditingController searchOpNumber = TextEditingController();
  final TextEditingController searchPhoneNumber = TextEditingController();

  bool isSearchPerformed = false;
  List<Map<String, String>> searchResults = [];
  Map<String, String>? selectedPatient;

  int tokenNumber = 0;
  String lastSavedDate = '';

  @override
  void initState() {
    super.initState();
    incrementCounter();
  }

  Future<void> _generateToken(String selectedPatientId) async {
    setState(() {
      tokenNumber++;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      await Future.delayed(const Duration(seconds: 1));
      DocumentSnapshot documentSnapshot =
          await firestore.collection('counters').doc('counterDoc').get();

      var storedTokenValue = documentSnapshot['value'] + 1;

      print('Fetched Token Value from counter collection : $storedTokenValue');

      await firestore
          .collection('patients')
          .doc(selectedPatientId)
          .collection('tokens')
          .doc('currentToken')
          .set({
        'tokenNumber': storedTokenValue,
        'date': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
      });
      await firestore.collection('patients').doc(selectedPatientId).update({
        'TokenDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'counter': counter.text,
        'doctorName': doctorName.text,
        'bloodPressure': bloodPressure.text,
        'bloodSugarLevel': bloodSugarLevel.text,
        'opTicketTotalAmount': opTicketTotalAmount.text,
        'opTicketCollectedAmount': opTicketCollectedAmount.text,
        'temperature': temperature.text,
        'otherComments': otherComments.text,
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Token Detail'),
            content: Container(
              width: 100,
              height: 25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                      text: 'Generated Token Number : $storedTokenValue'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      showMessage('Token saved: $storedTokenValue');
    } catch (e) {
      showMessage('Failed to save token: $e');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<List<Map<String, String>>> searchPatients(
      String opNumber, String phoneNumber) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Map<String, String>> patientsList = [];
    List<QueryDocumentSnapshot> docs = [];

    // Perform query based on opNumber, phoneNumber, or both
    if (opNumber.isNotEmpty) {
      final QuerySnapshot snapshot = await firestore
          .collection('patients')
          .where('opNumber', isEqualTo: opNumber)
          .get();
      docs.addAll(snapshot.docs);
    }

    // Perform query based on phoneNumber for phone1
    if (phoneNumber.isNotEmpty) {
      final QuerySnapshot snapshotPhone1 = await firestore
          .collection('patients')
          .where('phone1', isEqualTo: phoneNumber)
          .get();
      docs.addAll(snapshotPhone1.docs);

      // Perform query based on phoneNumber for phone2
      final QuerySnapshot snapshotPhone2 = await firestore
          .collection('patients')
          .where('phone2', isEqualTo: phoneNumber)
          .get();
      docs.addAll(snapshotPhone2.docs);
    }

    // Eliminate duplicates based on the document ID
    final uniqueDocs = docs.toSet();

    // Map documents to the desired structure
    for (var doc in uniqueDocs) {
      patientsList.add({
        'opNumber': doc['opNumber'] ?? '',
        'name':
            ((doc['firstName'] ?? '') + ' ' + (doc['lastName'] ?? '')).trim(),
        'age': doc['age'] ?? '',
        'phone': doc['phone1'] ?? '',
        'address': doc['address1'] ?? '',
      });
    }

    return patientsList;
  }

  final String documentId = "counterDoc";

  bool _shouldResetCounter(DateTime lastReset) {
    final now = DateTime.now();
    return now.year != lastReset.year ||
        now.month != lastReset.month ||
        now.day != lastReset.day;
  }

  Future<void> incrementCounter() async {
    final docRef =
        FirebaseFirestore.instance.collection('counters').doc('counterDoc');

    try {
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        int currentValue = snapshot.get('value') as int;
        Timestamp lastResetTimestamp = snapshot.get('lastReset') as Timestamp;
        DateTime lastReset = lastResetTimestamp.toDate();

        print("Last reset time: $lastReset");

        if (_shouldResetCounter(lastReset)) {
          print("Resetting the counter...");
          await docRef.update({
            'value': 0,
            'lastReset': FieldValue.serverTimestamp(),
          });
        } else {
          print("Incrementing the counter...");
          await docRef.update({'value': currentValue + 1});
        }
      } else {
        print("Initializing counter...");
        await docRef.set({
          'value': 0,
          'lastReset': FieldValue.serverTimestamp(),
        });
      }
    } catch (e, stackTrace) {
      print("Error in incrementCounter: $e");
      print(stackTrace);
      showMessage("Failed to update counter: $e");
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
              child: ManagementGeneralInformationDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ), // Drawer minimized for mobile
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
              ), //, // Sidebar always open for web view
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: buildThreeColumnForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildThreeColumnForm() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: screenHeight * 0.01,
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
          bottom: screenWidth * 0.25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        text: "OP Ticket Generation ",
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
            const CustomText(
              text: 'Patient Search',
              size: 25,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Enter OP Number            :',
                  size: 18,
                ),
                const SizedBox(
                  width: 25,
                ),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    hintText: 'OP Number',
                    controller: searchOpNumber,
                    width: null,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Enter Phone Number      :',
                  size: 18,
                ),
                const SizedBox(width: 25),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    controller: searchPhoneNumber,
                    hintText: 'Phone Number',
                    width: null,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 200),
                CustomButton(
                  width: 125,
                  height: 35,
                  label: 'Search',
                  onPressed: () async {
                    // Fetch patients based on OP number and phone number
                    final searchResultsFetched = await searchPatients(
                      searchOpNumber.text,
                      searchPhoneNumber.text,
                    );
                    setState(() {
                      searchResults = searchResultsFetched;
                      isSearchPerformed = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (isSearchPerformed) ...[
              const Text('Search Results: ',
                  style: TextStyle(
                      fontFamily: 'SanFrancisco',
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              DataTable(
                columnSpacing: 180,
                columns: [
                  const DataColumn(label: Text('OP Number')),
                  const DataColumn(label: Text('Name')),
                  const DataColumn(label: Text('Age')),
                  const DataColumn(label: Text('Phone')),
                  const DataColumn(label: Text('Address')),
                ],
                rows: searchResults.map((result) {
                  return DataRow(
                    selected: selectedPatient == result,
                    onSelectChanged: (isSelected) {
                      setState(() {
                        selectedPatient = result;
                      });
                    },
                    cells: [
                      DataCell(Text(result['opNumber']!)),
                      DataCell(Text(result['name']!)),
                      DataCell(Text(result['age']!)),
                      DataCell(Text(result['phone']!)),
                      DataCell(Text(result['address']!)),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              if (selectedPatient != null) buildPatientDetailsForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildPatientDetailsForm() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OP Ticket Generation :',
            style: TextStyle(
                fontFamily: 'SanFrancisco',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'OP Number : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomText(
                  text: "${selectedPatient?['opNumber']}",
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              const SizedBox(
                width: 80,
                child: Text(
                  'Name : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomText(text: "${selectedPatient?['name']}"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'AGE : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomText(text: "${selectedPatient?['age']}"),
              ),
              const SizedBox(
                width: 20,
              ),
              const SizedBox(
                width: 80,
                child: Text(
                  'Phone : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomText(text: "${selectedPatient?['phone']}"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'Address : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomText(text: "${selectedPatient?['address']}"),
              ),
              const SizedBox(
                width: 20,
              ),
              const SizedBox(
                width: 80,
                child: Text(
                  'Last OP Date : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomText(text: "${selectedPatient?['lastOpDate']}"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Token Information :',
            style: TextStyle(
                fontFamily: 'SanFrancisco',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                  width: 70,
                  child: Text(
                    'Date : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              CustomTextField(
                hintText: '',
                controller: TextEditingController(
                    text: dateTime.year.toString() +
                        '-' +
                        dateTime.month.toString().padLeft(2, '0') +
                        '-' +
                        dateTime.day.toString().padLeft(2, '0')),
                width: 250,
              ),
              const SizedBox(
                width: 30,
              ),
              const SizedBox(
                width: 80,
                child: Text(
                  'Counter : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
              ),
              CustomTextField(
                hintText: '',
                controller: counter,
                width: 250,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                  width: 80,
                  child: Text(
                    'Doctor : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              CustomTextField(
                hintText: '',
                controller: doctorName,
                width: 250,
              ),
              const SizedBox(
                width: 20,
              ),
              const SizedBox(
                  width: 100,
                  child: Text(
                    'Blood Sugar : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              CustomTextField(
                hintText: '',
                controller: bloodSugarLevel,
                width: 250,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                  width: 80,
                  child: Text(
                    'BP : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              CustomTextField(
                hintText: '',
                controller: bloodPressure,
                width: 250,
              ),
              const SizedBox(
                width: 20,
              ),
              const SizedBox(
                  width: 80,
                  child: Text(
                    'TEMP : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              CustomTextField(
                hintText: '',
                controller: temperature,
                width: 250,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                  width: 80,
                  child: Text(
                    'OP Ticket Amount : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              CustomTextField(
                hintText: '',
                controller: opTicketTotalAmount,
                width: 250,
              ),
              const SizedBox(
                width: 20,
              ),
              const SizedBox(
                  width: 80,
                  child: Text(
                    'Collected : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              CustomTextField(
                hintText: '',
                controller: opTicketCollectedAmount,
                width: 250,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 600,
            child: CustomTextField(
              hintText: 'Enter Other Comments',
              controller: otherComments,
              width: null,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 250),
            child: SizedBox(
              width: 200,
              child: CustomButton(
                label: 'Generate',
                onPressed: () async {
                  String? selectedPatientId = selectedPatient?['opNumber'];
                  print(selectedPatientId);
                  await incrementCounter();
                  await _generateToken(selectedPatientId!);
                },
                width: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
