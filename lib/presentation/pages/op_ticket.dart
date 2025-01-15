import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/pages/patient_registration.dart';
import 'package:iconsax/iconsax.dart';

import '../../utilities/widgets/buttons/primary_button.dart';
import '../../utilities/widgets/textField/primary_textField.dart';
import 'admission_status.dart';
import 'ip_admission.dart';

class OpTicketPage extends StatefulWidget {
  @override
  State<OpTicketPage> createState() => _OpTicketPageState();
}

class _OpTicketPageState extends State<OpTicketPage> {
  TimeOfDay now = TimeOfDay.now();
  final date = DateTime.timestamp();
  int selectedIndex = 1;
  String selectedSex = 'Male'; // Default value for Sex
  String selectedBloodGroup =
      'A+'; // Default value for Blood Group\  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController searchOpNumber = TextEditingController();
  final TextEditingController searchPhoneNumber = TextEditingController();

  bool isSearchPerformed = false; // To track if search has been performed
  List<Map<String, String>> searchResults =
      []; // Dynamically manage search results
  Map<String, String>? selectedPatient;

  Future<List<Map<String, String>>> searchPatients(
      String opNumber, String phoneNumber) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Map<String, String>> patientsList = [];
    List<QueryDocumentSnapshot> docs = [];

    // Perform query based on opNumber, phoneNumber, or both
    if (opNumber.isNotEmpty) {
      final QuerySnapshot snapshot = await firestore
          .collection('patients')
          .where('patientID', isEqualTo: opNumber)
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
        'opNumber': doc['patientID'] ?? '',
        'name':
            ((doc['firstName'] ?? '') + ' ' + (doc['lastName'] ?? '')).trim(),
        'age': doc['age'] ?? '',
        'phone': doc['phone1'] ?? '',
        'address': doc['address1'] ?? '',
      });
    }

    return patientsList;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(
                'OP Ticket Dashboard',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: buildDrawerContent(), // Drawer minimized for mobile
            )
          : null, // No AppBar for web view
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 250, // Sidebar width for larger screens
              color: Colors.blue.shade100,
              child: buildDrawerContent(), // Sidebar content
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return buildThreeColumnForm(); // Web view
                  } else {
                    return buildSingleColumnForm(); // Mobile view
                  }
                },
              ),
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
            'Reception',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        // Drawer items here
        buildDrawerItem(0, 'Patient Registration', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PatientRegistration()),
          );
        }, Iconsax.mask),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'OP Ticket', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OpTicketPage()),
          );
        }, Iconsax.receipt),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(2, 'IP Admission', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => IpAdmissionPage()),
          );
        }, Iconsax.add_circle),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'OP Counters', () {}, Iconsax.square),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(4, 'Admission Status', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdmissionStatus()),
          );
        }, Iconsax.status),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(5, 'Doctor Visit Schedule', () {}, Iconsax.hospital),

        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(7, 'Logout', () {
          // Handle logout action
        }, Iconsax.logout),
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
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient Search: ',
              style: TextStyle(
                  fontFamily: 'SanFrancisco',
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Enter OP Number: ',
                  style: TextStyle(fontFamily: 'SanFrancisco', fontSize: 22)),
              SizedBox(
                width: 250,
                child: CustomTextField(
                  hintText: 'OP Number',
                  controller: searchOpNumber,
                  width: null,
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Enter Phone Number: ',
                  style: TextStyle(fontFamily: 'SanFrancisco', fontSize: 22)),
              SizedBox(
                width: 250,
                child: CustomTextField(
                  controller: searchPhoneNumber,
                  hintText: 'Phone Number',
                  width: null,
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                child: CustomButton(
                  label: 'Search',
                  onPressed: () async {
                    // Fetch patients based on OP number and phone number
                    final searchResultsFetched = await searchPatients(
                      searchOpNumber.text,
                      searchPhoneNumber.text,
                    );
                    setState(() {
                      searchResults =
                          searchResultsFetched; // Update searchResults
                      isSearchPerformed = true; // Show the table after search
                    });
                  },
                  width: null,
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          if (isSearchPerformed) ...[
            Text('Search Results: ',
                style: TextStyle(
                    fontFamily: 'SanFrancisco',
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            DataTable(
              columns: [
                DataColumn(label: Text('OP Number')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Age')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Address')),
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
            SizedBox(height: 30),
            if (selectedPatient != null) buildPatientDetailsForm(),
          ],
        ],
      ),
    );
  }

  Widget buildSingleColumnForm() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient Search: ',
                style: TextStyle(
                    fontFamily: 'SanFrancisco',
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Enter OP Number: ',
                    style: TextStyle(fontFamily: 'SanFrancisco', fontSize: 22)),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    hintText: 'OP Number',
                    width: null,
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Enter Phone Number: ',
                    style: TextStyle(fontFamily: 'SanFrancisco', fontSize: 22)),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    hintText: 'Phone Number',
                    width: null,
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 250,
                  child: CustomButton(
                    label: 'Search',
                    onPressed: () {
                      setState(() {
                        isSearchPerformed = true; // Show the table after search
                      });
                    },
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            if (isSearchPerformed) ...[
              Text('Search Results: ',
                  style: TextStyle(
                      fontFamily: 'SanFrancisco',
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('OP Number')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Age')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Address')),
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
              ),
              SizedBox(height: 30),
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
          Text(
            'OP Ticket Generation :',
            style: TextStyle(
                fontFamily: 'SanFrancisco',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
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
                child: buildTextField(
                  'OP Number',
                  initialValue: selectedPatient?['opNumber'],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              SizedBox(
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
                child: buildTextField(
                  'OP Number',
                  initialValue: selectedPatient?['name'],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
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
                child: buildTextField('OP Number',
                    initialValue: selectedPatient?['age'],
                    inputType: TextInputType.number),
              ),
              SizedBox(
                width: 20,
              ),
              SizedBox(
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
                child: buildTextField('Phone',
                    initialValue: selectedPatient?['phone'],
                    inputType: TextInputType.phone),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
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
                child: buildTextField('Address',
                    initialValue: selectedPatient?['address']),
              ),
              SizedBox(
                width: 20,
              ),
              SizedBox(
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
                child: buildTextField('Phone',
                    initialValue: selectedPatient?['phone'],
                    inputType: TextInputType.phone),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Token Information :',
            style: TextStyle(
                fontFamily: 'SanFrancisco',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: 70,
                  child: Text(
                    'Date : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              SizedBox(
                  width: 220,
                  child: buildTextField('sdfsdf', initialValue: '$date')),
              SizedBox(
                width: 30,
              ),
              SizedBox(
                  width: 80,
                  child: Text(
                    'TOKEN : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              SizedBox(
                  width: 220,
                  child: buildTextField(
                    'Enter Token Number',
                  )),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: 80,
                  child: Text(
                    'Counter : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              SizedBox(
                  width: 220,
                  child: buildTextField(
                    'Counter',
                  )),
              SizedBox(
                width: 20,
              ),
              SizedBox(
                  width: 80,
                  child: Text(
                    'Doctor : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              SizedBox(
                  width: 220,
                  child: buildTextField(
                    'Enter Doctor Name',
                  )),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: 80,
                  child: Text(
                    'BP : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              SizedBox(
                  width: 220,
                  child: buildTextField(
                    'Enter Blood Pressure',
                  )),
              SizedBox(
                width: 20,
              ),
              SizedBox(
                  width: 80,
                  child: Text(
                    'TEMP : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              SizedBox(
                  width: 220,
                  child: buildTextField(
                    'Enter Temperature',
                  )),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: 90,
                  child: Text(
                    'Blood Sugar : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  )),
              SizedBox(
                  width: 220,
                  child: buildTextField(
                    'Enter Blood Sugar Level',
                  )),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 600,
            child: CustomTextField(
              hintText: 'Enter Other Comments',
              width: null,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 250),
            child: SizedBox(
              width: 200,
              child: CustomButton(
                label: 'Generate',
                onPressed: () {},
                width: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label,
      {String? initialValue, TextInputType inputType = TextInputType.text}) {
    return TextField(
      decoration: InputDecoration(
        isDense: true,
        enabled: false,

        // Reduces the overall height of the TextField
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        hintText: label,
        hintStyle: TextStyle(
          fontFamily: 'SanFrancisco',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue, width: 1),
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      keyboardType: inputType,
      controller: TextEditingController(text: initialValue),
    );
  }
}
