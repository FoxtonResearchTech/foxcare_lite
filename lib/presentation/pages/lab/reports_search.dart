import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'dashboard.dart';
import 'lab_accounts.dart';
import 'lab_testqueue.dart';

class ReportsSearch extends StatefulWidget {
  const ReportsSearch({super.key});

  @override
  State<ReportsSearch> createState() => _ReportsSearch();
}

int selectedIndex = 3;

class ReportRow {
  final String slNo;
  final String opNumber;
  final String name;
  final String age;
  final String testType;
  final String dateOfReport;
  final String amountCollected;
  final String paymentStatus;

  ReportRow(
    this.slNo,
    this.opNumber,
    this.name,
    this.age,
    this.testType,
    this.dateOfReport,
    this.amountCollected,
    this.paymentStatus,
  );
}

final List<String> headers = [
  'Date',
  'Report Number',
  'Name',
  'OP Number',
  'Report Use'
];
final List<Map<String, dynamic>> tableData = [
  {
    'Date': '',
    'Report Number': '',
    'Name': '',
    'OP Number': '',
    'Report Use': TextButton(
      onPressed: () {},
      child: CustomText(text: 'View'),
    ),
  },
];

class _ReportsSearch extends State<ReportsSearch> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Laboratory Dashboard'),
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
            'Laboratory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Dashboard', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LabDashboard()),
          );
        }, Iconsax.mask),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(1, 'Test Queue', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LabTestQueue()),
          );
        }, Iconsax.receipt),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(2, 'Accounts', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LabAccounts()),
          );
        }, Iconsax.add_circle),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(3, 'Report search', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ReportsSearch()),
          );
        }, Iconsax.search_favorite),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(4, 'Logout', () {
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
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Report Number',
                    width: screenWidth * 0.15,
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
              SizedBox(height: screenHeight * 0.025),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Date',
                    width: screenWidth * 0.15,
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
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
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
                tableData: tableData,
                headers: headers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
