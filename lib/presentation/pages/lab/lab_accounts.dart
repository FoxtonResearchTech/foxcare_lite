import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'dashboard.dart';
import 'lab_testqueue.dart';

class LabAccounts extends StatefulWidget {
  const LabAccounts({super.key});

  @override
  State<LabAccounts> createState() => _LabAccountsState();
}

int selectedIndex = 2;

final List<ReportRow> reportData = [
  ReportRow('1', '0001', 'Rahul', '20', 'RBC Count', '5/10/24', '270', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('1', '0001', 'Rahul', '20', 'RBC Count', '5/10/24', '270', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('1', '0001', 'Rahul', '20', 'RBC Count', '5/10/24', '270', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
  ReportRow('2', '0005', 'Krishan', '50', 'Urine', '6/10/24', '500', '-'),
];

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

class _LabAccountsState extends State<LabAccounts> {
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        // This makes the whole content scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Year: ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal, // Horizontal scrolling for wide tables
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FixedColumnWidth(50.0),
                  1: FixedColumnWidth(80.0),
                  2: FixedColumnWidth(120.0),
                  3: FixedColumnWidth(50.0),
                  4: FixedColumnWidth(80.0),
                  5: FixedColumnWidth(120.0),
                  6: FixedColumnWidth(100.0),
                  7: FixedColumnWidth(100.0),
                },
                children: [
                  // Table Header
                  TableRow(
                    children: [
                      tableCell('Sl No'),
                      tableCell('OP Number'),
                      tableCell('Name'),
                      tableCell('Age'),
                      tableCell('Type of Test'),
                      tableCell('Date of Report'),
                      tableCell('Amount Collected'),
                      tableCell('Payment Status'),
                    ],
                  ),
                  // Generate table rows dynamically from the list
                  ...reportData.map((data) {
                    return TableRow(
                      children: [
                        tableCell(data.slNo),
                        tableCell(data.opNumber),
                        tableCell(data.name),
                        tableCell(data.age),
                        tableCell(data.testType),
                        tableCell(data.dateOfReport),
                        tableCell(data.amountCollected),
                        tableCell(data.paymentStatus),
                      ],
                    );
                  }).toList(),
                  // Total row
                  TableRow(
                    children: [
                      tableCell(''),
                      tableCell(''),
                      tableCell(''),
                      tableCell(''),
                      tableCell(''),
                      tableCell('Total'),
                      tableCell('770'), // Example of total value from the list
                      tableCell('500'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tableCell(String text, {int colspan = 1}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Data model for each row
}
