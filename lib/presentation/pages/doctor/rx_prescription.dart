import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class RxPrescription extends StatefulWidget {
  const RxPrescription({super.key});

  @override
  State<RxPrescription> createState() => _RxPrescriptionState();
}

class _RxPrescriptionState extends State<RxPrescription> {
  int selectedIndex = 1;
  String selectedValue = 'Medication';

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
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
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: dashboard()),
                ],
              ),
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
            'Doctor - Consultation',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Home', () {}, Iconsax.mask),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(1, 'Patient Search', () {}, Iconsax.receipt),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(2, 'Pharmacy Stocks', () {}, Iconsax.add_circle),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(7, 'Logout', () {
          // Handle logout action
        }, Iconsax.logout),
      ],
    );
  }

  // Helper method to build drawer items with the ability to highlight the selected item
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

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: OP Number and Date
          Text(
            'Dr. Kathiresan',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: CustomTextField(
                hintText: 'OP Number',
                obscureText: false,
                width: screenWidth * 0.05,
              )),
              SizedBox(width: 100),
              Expanded(
                  child: CustomTextField(
                hintText: 'Date',
                obscureText: false,
                width: screenWidth * 0.05,
              )),
            ],
          ),
          SizedBox(height: 26),

          // Row 2: Full Name and Age
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: CustomTextField(
                    hintText: 'Full Name',
                    obscureText: false,
                    width: screenWidth * 0.05,
                  )),
              SizedBox(width: 10),
              Expanded(
                  child: CustomTextField(
                hintText: 'Age',
                obscureText: false,
                width: screenWidth * 0.05,
              )),
            ],
          ),
          SizedBox(height: 26),

          // Row 3: Address and Pincode
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: CustomTextField(
                    hintText: 'Address',
                    obscureText: false,
                    width: screenWidth * 0.05,
                  )),
              SizedBox(width: 10),
              Expanded(
                  child: CustomTextField(
                hintText: 'Pincode',
                obscureText: false,
                width: screenWidth * 0.05,
              )),
            ],
          ),
          SizedBox(height: 26),

          // Row 4: Basic Info
          TextFormField(
            decoration: InputDecoration(
              isDense: true,
              // Reduces the overall height of the TextField
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              labelText: 'Basic Info',
              labelStyle: TextStyle(
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
            maxLines: 3, // Allow multiline input for basic info
          ),
          SizedBox(
            height: 35,
          ),
          Text(
            'Basic Diagnosis :',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Temperature :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                'Blood Pressure :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                'Sugar Level :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          // Row 4: Basic Info
          TextFormField(
            decoration: InputDecoration(
              isDense: true,
              // Reduces the overall height of the TextField
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              labelText: 'Patient History',
              labelStyle: TextStyle(
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
            maxLines: 3, // Allow multiline input for basic info
          ),
          SizedBox(
            height: 20,
          ),

          // Row 4: Basic Info
          TextFormField(
            decoration: InputDecoration(
              isDense: true,
              // Reduces the overall height of the TextField
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              labelText: 'Diagnosis Signs',
              labelStyle: TextStyle(
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
            maxLines: 3, // Allow multiline input for basic info
          ),
          SizedBox(
            height: 20,
          ),

          // Row 4: Basic Info
          TextFormField(
            decoration: InputDecoration(
              isDense: true,
              // Reduces the overall height of the TextField
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              labelText: 'Symptoms',
              labelStyle: TextStyle(
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
            maxLines: 3, // Allow multiline input for basic info
          ),
          SizedBox(
            height: 35,
          ),
          Text(
            'Investigation Tests :',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 35,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 200,
                child: CustomButton(
                  label: 'Haemoglobin',
                  onPressed: () {},
                  width: screenWidth * 0.05,
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomButton(
                  label: 'Creatin',
                  onPressed: () {},
                  width: screenWidth * 0.05,
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomButton(
                  label: 'Urea',
                  onPressed: () {},
                  width: screenWidth * 0.05,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),

          TextFormField(
            decoration: InputDecoration(
              isDense: true,
              // Reduces the overall height of the TextField
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              labelText: 'Enter Notes',
              labelStyle: TextStyle(
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
            maxLines: 3, // Allow multiline input for basic info
          ),
          SizedBox(
            height: 35,
          ),

          SizedBox(
            width: 250,
            child: CustomDropdown(
              label: 'Select',
              items: [
                'Medication',
                'Examination',
                'Appointment',
                'Investigation'
              ],
              selectedItem: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value!;
                });
              },
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Prescribed By : Dr Kathiresan ',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomButton(
                  label: 'Change',
                  onPressed: () {},
                  width: screenWidth * 0.5,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 35,
          ),
          Center(
            child: SizedBox(
              width: 300,
              child: CustomButton(
                label: 'Prescribe',
                onPressed: () {},
                width: screenWidth * 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
