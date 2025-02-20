import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_appointment.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_billing.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_dr_schedule.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_opTickets.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_patient_registration.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'dental_dashboard.dart';

class DentalPendingBills extends StatefulWidget {
  @override
  State<DentalPendingBills> createState() => _DentalPendingBills();
}

class _DentalPendingBills extends State<DentalPendingBills> {
  int selectedIndex = 6;
  final headers = [
    'OP No ',
    'Patient Name',
    'Age',
    'Address',
    'Phone No',
    'Action',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'OP No ': '',
      'Patient Name': '',
      'Age': '',
      'Address': '',
      'Phone No': '',
      'Action': TextButton(
        onPressed: () {},
        child: CustomText(text: 'View'),
      ),
    }
  ];
  final pendingBillHeaders = [
    'Date',
    'Time',
    'Procedure',
    'Amount',
    'Collected',
    'Balance',
    'Action',
  ];
  final List<Map<String, dynamic>> pendingBillTableData = [
    {
      'Date': '',
      'Time': '',
      'Procedure': '',
      'Amount': '',
      'Collected': '',
      'Balance': '',
      'Action': TextButton(
        onPressed: () {},
        child: CustomText(text: 'Collect'),
      ),
    }
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
            'Pending Bills',
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
        buildDrawerItem(4, ' Billing', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalBilling()));
        }, Iconsax.status),
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
        buildDrawerItem(6, 'Pending Bills', () {}, Iconsax.hospital),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
            bottom: screenWidth * 0.025,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    hintText: 'OP Number',
                    width: screenWidth * 0.15,
                  ),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {},
                    width: screenWidth * 0.1,
                    height: screenHeight * 0.045,
                  ),
                  SizedBox(width: screenWidth * 0.08),
                  CustomTextField(
                    hintText: 'Mobile Number',
                    width: screenWidth * 0.15,
                  ),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {},
                    width: screenWidth * 0.1,
                    height: screenHeight * 0.045,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(headers: headers, tableData: tableData),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomText(
                    text: 'Pending Payments',
                    size: screenWidth * 0.015,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                  headers: pendingBillHeaders, tableData: pendingBillTableData),
            ],
          ),
        ),
      ),
    );
  }
}
