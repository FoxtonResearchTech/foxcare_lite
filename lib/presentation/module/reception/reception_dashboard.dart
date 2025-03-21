import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/utilities/widgets/image/custom_image.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utilities/images.dart';
import 'admission_status.dart';
import 'doctor_schedule.dart';
import 'ip_admission.dart';
import 'ip_patients_admission.dart';
import 'op_counters.dart';
import 'op_ticket.dart';

class ReceptionDashboard extends StatefulWidget {
  @override
  State<ReceptionDashboard> createState() => _ReceptionDashboardState();
}

class _ReceptionDashboardState extends State<ReceptionDashboard> {
  int selectedIndex = 0;

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: dashboard(),
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
        buildDrawerItem(5, 'Doctor Visit Schedule', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => doctorSchedule()),
          );
        }, Iconsax.hospital),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(6, 'Ip Patients Admission', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => IpPatientsAdmission()),
          );
        }, Icons.approval),
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
    bool isMobile = screenWidth < 600;

    return Align(
      alignment: isMobile
          ? Alignment.center
          : Alignment.topLeft, // Align top-left for web, center for mobile
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImage(path: AppImages.logo),
          // Add other form fields or content below
        ],
      ),
    );
  }
}
