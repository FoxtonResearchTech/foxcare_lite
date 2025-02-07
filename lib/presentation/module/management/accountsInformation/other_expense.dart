import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/surgery_ot_icu_collection.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/patientsInformation/management_register_patient.dart';
import 'package:foxcare_lite/presentation/module/management/user/user_account_creation.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/utilities/widgets/image/custom_image.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utilities/widgets/text/primary_text.dart';
import '../management_dashboard.dart';
import 'hospital_direct_purchase.dart';
import 'hospital_direct_purchase_still_pending.dart';
import 'ip_admission_collection.dart';
import 'lab_collection.dart';
import 'new_patient_register_collection.dart';
import 'op_ticket_collection.dart';

class OtherExpense extends StatefulWidget {
  @override
  State<OtherExpense> createState() => _OtherExpense();
}

class _OtherExpense extends State<OtherExpense> {
  // To store the index of the selected drawer item
  int selectedIndex = 6;

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
                text: 'Accounts Information',
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
            'Accounts Information',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'New Patients Register Collection', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewPatientRegisterCollection()));
        }, Iconsax.mask),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'OP Ticket Collection', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => OpTicketCollection()));
        }, Iconsax.receipt),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(2, 'IP Admission Collection', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => IpAdmissionCollection()));
        }, Iconsax.add_circle),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'Pharmacy Collection', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PharmacyTotalSales()));
        }, Iconsax.square),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(4, 'Hospital Direct Purchase', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HospitalDirectPurchase()));
        }, Iconsax.status),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(5, 'Hospital Direct Purchase Pending Still', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HospitalDirectPurchaseStillPending()));
        }, Iconsax.hospital),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(6, 'Other Expense', () {}, Iconsax.hospital),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(7, 'Surgery | OT | ICU | Observation Collection', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SurgeryOtIcuCollection()));
        }, Iconsax.hospital),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(8, 'Lab Collection', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LabCollection()));
        }, Iconsax.hospital),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(9, 'Back To Management Dashboard', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ManagementDashboard()));
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
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.25,
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.08),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
