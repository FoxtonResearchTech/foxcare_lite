import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../utilities/widgets/buttons/primary_button.dart';
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
        'date': _currentDateString(),
      });
      await firestore.collection('patients').doc(selectedPatientId).update({
        'date': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'counter': counter.text,
        'doctorName': doctorName.text,
        'bloodPressure': bloodPressure.text,
        'bloodSugarLevel': bloodSugarLevel.text,
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

  String _currentDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
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
        FirebaseFirestore.instance.collection('counters').doc(documentId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        // Get the current value and last reset timestamp
        int currentValue = snapshot.get('value') as int;
        Timestamp lastResetTimestamp = snapshot.get('lastReset') as Timestamp;

        DateTime lastReset = lastResetTimestamp.toDate();
        print(lastReset);

        // Check if it's time to reset
        if (_shouldResetCounter(lastReset)) {
          print("Resetting the counter...");
          // Reset the counter and update the last reset timestamp
          transaction.update(docRef, {
            'value': 0,
            'lastReset': FieldValue.serverTimestamp(),
          });
        } else {
          print("Incrementing the counter...");
          // Increment the counter
          transaction.update(docRef, {'value': currentValue + 1});
        }
      } else {
        // Initialize the counter if it doesn't exist
        print("Initializing counter...");
        transaction.set(docRef, {
          'value': 0,
          'lastReset': FieldValue.serverTimestamp(),
        });
      }
    });
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
              child: buildThreeColumnForm(),
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
        buildDrawerItem(0, 'OP Ticket Generation', () {}, Iconsax.mask),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'IP Admission', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeneralInformationIpAdmission()));
        }, Iconsax.receipt),
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
        Divider(
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
