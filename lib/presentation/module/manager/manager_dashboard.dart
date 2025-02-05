import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/lab/reports_search.dart';
import 'package:foxcare_lite/presentation/module/manager/manager_patient_history.dart';
import 'package:foxcare_lite/presentation/module/manager/manager_patient_info.dart';
import 'package:foxcare_lite/presentation/module/manager/patient_history.dart';
import 'package:foxcare_lite/presentation/module/manager/patient_info.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/decoration/gradient_box.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import '../../dashboard/pharmecy_dashboard.dart';
import '../lab/dashboard.dart';
import '../lab/lab_accounts.dart';
import '../lab/lab_testqueue.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboard();
}

int selectedIndex = 0;

class _ManagerDashboard extends State<ManagerDashboard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Manager Dashboard'),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: buildDrawerContent(),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300,
              color: Colors.blue.shade100,
              child: buildDrawerContent(),
            ),
          Expanded(child: dashboard()),
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
            'Manager',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Dashboard', () {}, Iconsax.mask),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(1, 'Patient Information', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ManagerPatientInfo()),
          );
        }, Iconsax.receipt),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(2, 'Patient History', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ManagerPatientHistory()),
          );
        }, Iconsax.check),
      ],
    );
  }

  Widget buildDrawerItem(
    int index,
    String title,
    VoidCallback onTap,
    IconData icon,
  ) {
    return ListTile(
      selected: selectedIndex == index,
      selectedTileColor: Colors.blueAccent.shade100,
      leading: Icon(
        icon,
        color: selectedIndex == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selectedIndex == index ? Colors.blue : Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        onTap();
      },
    );
  }

  Widget dashboard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.025,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(children: [
            Column(
              children: [
                Row(
                  children: [
                    CustomText(
                      text: 'ABC Hospital',
                      size: screenWidth * 0.05,
                    )
                  ],
                ),
                Row(
                  children: [
                    SizedBox(width: screenWidth * 0.18),
                    CustomText(
                      text: 'ABC Hospital ',
                      size: screenWidth * 0.025,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomText(
                      text: "Today's : ",
                      size: screenWidth * 0.025,
                    ),
                    SizedBox(width: screenWidth * 0.178),
                    SizedBox(
                      width: screenWidth * 0.15,
                      height: screenHeight * 0.2,
                      child: const GradientBox(
                        subText: '₹150000',
                        gradientColors: [
                          Color(0xFF004D40), // Dark Green
                          Color(0xFF00C853), // Emerald Green
                          Color(0xFFB9F6CA), // Light Mint Green
                        ],
                        text: 'Total Lab Collection',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.15,
                      height: screenHeight * 0.2,
                      child: const GradientBox(
                        subText: '75',
                        gradientColors: [
                          Color(0xFF004D40), // Dark Green
                          Color(0xFF00C853), // Emerald Green
                          Color(0xFFB9F6CA), // Light Mint Green
                        ],
                        text: 'Total OP',
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.15,
                      height: screenHeight * 0.2,
                      child: const GradientBox(
                        subText: '15',
                        gradientColors: [
                          Color(0xFF004D40), // Dark Green
                          Color(0xFF00C853), // Emerald Green
                          Color(0xFFB9F6CA), // Light Mint Green
                        ],
                        text: 'Total IP',
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.15,
                      height: screenHeight * 0.2,
                      child: const GradientBox(
                        subText: '₹150000',
                        gradientColors: [
                          Color(0xFF004D40), // Dark Green
                          Color(0xFF00C853), // Emerald Green
                          Color(0xFFB9F6CA), // Light Mint Green
                        ],
                        text: 'Total Bill Collection',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.41,
                      height: screenHeight * 0.2,
                      child: const GradientBox(
                        subText: '₹1000000',
                        gradientColors: [
                          Color(0xFF004D40), // Dark Green
                          Color(0xFF00C853), // Emerald Green
                          Color(0xFFB9F6CA), // Light Mint Green
                        ],
                        text: 'Total Income',
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.15,
                      height: screenHeight * 0.2,
                      child: const GradientBox(
                        subText: '₹10000',
                        gradientColors: [
                          Color(0xFF6A1B9A), // Deep Purple
                          Color(0xFFAB47BC), // Medium Purple
                          Color(0xFFE1BEE7), // Light Mint Green
                        ],
                        text: 'Total Expense',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.08),
                Column(
                  children: [
                    Row(
                      children: [
                        CustomText(
                          text: 'Current OP: ',
                          size: screenWidth * 0.023,
                        )
                      ],
                    )
                  ],
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
