import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'dental_appointment.dart';
import 'dental_dashboard.dart';
import 'dental_dr_schedule.dart';
import 'dental_opTickets.dart';
import 'dental_patient_registration.dart';
import 'dental_pending_bills.dart';

class DentalBilling extends StatefulWidget {
  @override
  State<DentalBilling> createState() => _DentalBilling();
}

class _DentalBilling extends State<DentalBilling> {
  // To store the index of the selected drawer item
  int selectedIndex = 4;

  final billingHeaders = [
    'OP No',
    'Patient Name',
    'Age',
    'Procedure',
    'Total Amount',
    'Collected',
    'Balance',
    'Collect',
  ];
  final List<Map<String, dynamic>> billingTableData = [
    {
      'OP No': '',
      'Patient Name': '',
      'Age': '',
      'Procedure': '',
      'Total Amount': '',
      'Collected': '',
      'Balance': '',
      'Collect': Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(onPressed: () {}, child: CustomText(text: 'Collect')),
        ],
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const CustomText(
                text: 'FoxCare Dental',
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
              child: dashboard(),
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
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Billing',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Home', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalDashboard()));
        }, Iconsax.mask),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'Appointment', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalAppointment()));
        }, Iconsax.receipt),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(2, 'Patient Registration', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DentalPatientRegistration()));
        }, Iconsax.add_circle),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'OP Tickets', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalOptickets()));
        }, Iconsax.square),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(4, ' Billing', () {}, Iconsax.status),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(5, 'DR. Schedule', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalDrSchedule()));
        }, Iconsax.hospital),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(6, 'Pending Bills', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalPendingBills()));
        }, Iconsax.hospital),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
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

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.25,
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomText(
                    text: ' Today\'s Payment',
                    size: screenWidth * 0.015,
                  ),
                  SizedBox(width: screenWidth * 0.11),
                  CustomTextField(
                    icon: Icon(Icons.date_range),
                    hintText: 'Date',
                    width: screenWidth * 0.1,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {},
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomText(text: 'OR'),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    icon: Icon(Icons.date_range),
                    hintText: 'From Date',
                    width: screenWidth * 0.1,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    icon: Icon(Icons.date_range),
                    hintText: 'To Date',
                    width: screenWidth * 0.11,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {},
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                  headers: billingHeaders, tableData: billingTableData),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
