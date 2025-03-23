import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_appointment.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_billing.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_dr_schedule.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_opTickets.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_patient_registration.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import 'dental_pending_bills.dart';

class DentalDashboard extends StatefulWidget {
  @override
  State<DentalDashboard> createState() => _DentalDashboard();
}

class _DentalDashboard extends State<DentalDashboard> {
  int selectedIndex = 0;
  final scheduleHeaders = ['Doctor Name', 'Speciality', 'Morning', 'Evening'];
  final List<Map<String, dynamic>> scheduleTableData = [
    {
      'Doctor Name': 'Dr Ramesh',
      'Speciality': 'Dental',
      'Morning': '10:30 | 11:30 | 12:30 | 2:30',
      'Evening': '16:00 | 17:00 | 18:00 | 19:00'
    },
  ];
  final appointmentHeaders = [
    'OP No',
    'Patient Name',
    'Appointment Date | Time',
    'Action'
  ];
  final List<Map<String, dynamic>> appointmentTableData = [
    {
      'OP No': '',
      'Patient Name': '',
      'Appointment Date | Time': '',
      'Action': Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(onPressed: () {}, child: CustomText(text: 'Edit')),
          TextButton(onPressed: () {}, child: CustomText(text: 'Delete')),
          TextButton(onPressed: () {}, child: CustomText(text: 'Confirm'))
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
            'DashBoard',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Home', () {}, Iconsax.mask),
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
                children: [
                  CustomText(
                    text: 'Today\'s Schedule',
                    size: screenWidth * 0.02,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.005),
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomText(text: 'No Of Appointments'),
                        Center(child: CustomText(text: '100'))
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.005),
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomText(text: 'No Of Patients'),
                        Center(child: CustomText(text: '95'))
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.005),
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomText(text: 'No Of Appointments'),
                        Center(child: CustomText(text: '100'))
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.005),
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomText(text: 'No Of Billing'),
                        Center(child: CustomText(text: '15'))
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.005),
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomText(text: 'Today\'s Collection'),
                        Center(child: CustomText(text: '100'))
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.005),
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomText(text: 'No Of Patients'),
                        Center(child: CustomText(text: '95'))
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomText(
                    text: 'Dr Schedule',
                    size: screenWidth * 0.02,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                  headers: scheduleHeaders, tableData: scheduleTableData),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomText(
                    text: 'Appointments',
                    size: screenWidth * 0.02,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                  headers: appointmentHeaders, tableData: appointmentTableData)
            ],
          ),
        ),
      ),
    );
  }
}
