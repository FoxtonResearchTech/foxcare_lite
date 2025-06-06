import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import 'general_information_admission_status.dart';
import 'general_information_edit_doctor_visit_schedule.dart';
import 'general_information_ip_admission.dart';

class GeneralInformationDoctorVisitSchedule extends StatefulWidget {
  @override
  State<GeneralInformationDoctorVisitSchedule> createState() =>
      _GeneralInformationDoctorVisitSchedule();
}

class _GeneralInformationDoctorVisitSchedule
    extends State<GeneralInformationDoctorVisitSchedule> {
  // To store the index of the selected drawer item
  int selectedIndex = 3;

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
        buildDrawerItem(0, 'OP Ticket Generation', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeneralInformationOpTicket()));
        }, Iconsax.mask),
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
        buildDrawerItem(3, 'Doctor Visit  Schedule', () {}, Iconsax.add_circle),
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

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.03,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
