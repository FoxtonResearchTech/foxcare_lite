import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:iconsax/iconsax.dart';
import '../../utilities/widgets/buttons/primary_button.dart';
import '../../utilities/widgets/textField/primary_textField.dart';
import 'admission_status.dart';
import 'ip_admission.dart';
import 'op_counters.dart';
import 'op_ticket.dart';

class PatientRegistration extends StatefulWidget {
  @override
  State<PatientRegistration> createState() => _PatientRegistrationState();
}

class _PatientRegistrationState extends State<PatientRegistration> {
  int selectedIndex = 0;
  String selectedSex = 'Male'; // Default value for Sex
  String selectedBloodGroup = 'A+'; // Default value for Blood Group
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController middlename = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController address1 = TextEditingController();
  final TextEditingController address2 = TextEditingController();
  final TextEditingController landmark = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController phone1 = TextEditingController();
  final TextEditingController phone2 = TextEditingController();

  // final Uri uuid = Uuid(); // Create an instance of Uuid

  // Function to generate a unique ID
  String generateNumericUid() {
    var random = Random();
    // Generate a 6-digit random number and concatenate it with "Fox"
    return 'Fox' +
        List.generate(6, (_) => random.nextInt(10).toString()).join();
  }

  String uid = '';

  @override
  void initState() {
    // Call the method to generate the UID and assign it to 'uid'
    uid = generateNumericUid();
    super.initState();
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
              width: 300, // Sidebar width for larger screens
              color: Colors.blue.shade100,
              child: buildDrawerContent(), // Sidebar content
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(28.0),
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

  // Sidebar content for desktop view
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
        buildDrawerItem(3, 'OP Counters', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OpCounters()),
          );
        }, Iconsax.square),
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
      selectedTileColor: Colors.blueAccent.shade100,
      // Highlight color for the selected item
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

  // Form layout for web with three columns
  Widget buildThreeColumnForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Patient Information :',
                style: TextStyle(
                    fontFamily: 'SanFrancisco',
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 60),
        Row(
          children: [
            Expanded(
                child: CustomTextField(
              hintText: 'First Name',
              controller: firstname,
              width: null,
            )),
            SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: 'Middle Name',
              controller: middlename,
              width: null,
            )),
            SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: 'Last Name',
              controller: lastname,
              width: null,
            )),
          ],
        ),
        SizedBox(height: 40),
        Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                'SEX :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            ),
            Expanded(
              child: CustomDropdown(
                label: 'Sex',
                items: ['Male', 'Female', 'Other'],
                selectedItem: selectedSex,
                onChanged: (value) {
                  setState(() {
                    selectedSex = value!;
                  });
                },
              ),
            ),
            SizedBox(width: 20),
            SizedBox(
              width: 40,
              child: Text(
                'AGE :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            ),
            Expanded(
              child: CustomTextField(
                hintText: '',
                controller: age,
                width: null,
              ),
            ),
            SizedBox(width: 20),
            SizedBox(
              width: 40,
              child: Text(
                'DOB :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            ),
            Expanded(
                child: CustomTextField(
              hintText: '(YYYY-MM-DD)',
              controller: dob,
              width: null,
            )),
          ],
        ),
        SizedBox(height: 40),
        CustomTextField(
          hintText: 'Address Line 1',
          controller: address1,
          width: null,
        ),
        SizedBox(height: 30),
        CustomTextField(
          hintText: 'Address Line 2',
          controller: address2,
          width: null,
        ),
        SizedBox(height: 40),
        Row(
          children: [
            Expanded(
                child: CustomTextField(
              hintText: "Land Mark",
              controller: landmark,
              width: null,
            )),
            SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: "City",
              controller: city,
              width: null,
            )),
            SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: "State",
              controller: state,
              width: null,
            )),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: CustomTextField(
              hintText: 'Pincode',
              controller: pincode,
              width: null,
            )),
            SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: 'Phone Number 1',
              controller: phone1,
              width: null,
            )),
            SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: 'Phone Number 2',
              controller: phone2,
              width: null,
            )),
          ],
        ),
        SizedBox(height: 40),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                'BLOOD GROUP :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            ),
            CustomDropdown(
                label: 'Blood Group',
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                selectedItem: selectedBloodGroup,
                onChanged: (value) {
                  setState(() {
                    selectedBloodGroup = value!;
                  });
                }),
          ],
        ),
        SizedBox(height: 20),
        Center(
          child: SizedBox(
              width: 400,
              child: CustomButton(
                label: 'Register',
                onPressed: () {},
                width: null,
              )),
        )
      ],
    );
  }

  // Form layout for mobile with one column
  Widget buildSingleColumnForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('OP Number ',
                    style: TextStyle(
                        fontFamily: 'SanFrancisco',
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                    width: 200.0,
                    child: CustomTextField(
                      hintText: 'Enter OP Number',
                      width: null,
                    )),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        CustomTextField(
          hintText: 'First Name',
          controller: firstname,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'Middle Name',
          controller: middlename,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'Last Name',
          controller: lastname,
          width: null,
        ),
        SizedBox(height: 16),
        CustomDropdown(
            label: 'Sex',
            items: ['Male', 'Female', 'Other'],
            selectedItem: selectedSex,
            onChanged: (value) {
              setState(() {
                selectedSex = value!;
              });
            }),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'Age',
          controller: age,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'DOB (YYYY-MM-DD)',
          controller: dob,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'Address Line 1',
          controller: address1,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'Address Line 2',
          controller: address2,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'Land Mark',
          controller: landmark,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'City',
          controller: city,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'State',
          controller: state,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'Pincode',
          controller: pincode,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'Mobile 1',
          controller: phone1,
          width: null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          hintText: 'Mobile 2',
          controller: phone2,
          width: null,
        ),
        SizedBox(height: 16),
        CustomDropdown(
            label: 'Blood Group',
            items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
            selectedItem: selectedBloodGroup,
            onChanged: (value) {
              setState(() {
                selectedBloodGroup = value!;
              });
            }),
        SizedBox(height: 20),
        Center(
          child: SizedBox(
              width: 250,
              child: CustomButton(
                label: 'Register',
                onPressed: () {},
                width: null,
              )),
        ),
      ],
    );
  }

  // Helper widget to create Dropdowns
  Widget buildDrop(String label, List<String> items, String selectedItem,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'SanFrancisco',
        ),
        border: OutlineInputBorder(),
      ),
      value: selectedItem,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
