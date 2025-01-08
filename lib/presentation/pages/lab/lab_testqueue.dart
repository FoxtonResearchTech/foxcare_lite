import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'dashboard.dart';
import 'lab_accounts.dart';

class LabTestQueue extends StatefulWidget {
  const LabTestQueue({super.key});

  @override
  State<LabTestQueue> createState() => _LabTestQueueState();
}

class _LabTestQueueState extends State<LabTestQueue> {
  int selectedIndex = 1;

  final List<Map<String, dynamic>> rows = [
    {
      'opNumber': '123',
      'name': 'John Doe',
      'age': '29',
      'place': 'New York',
      'token': 'A1',
      'counterNo': '2',
      'drName': 'Dr. Smith',
      'typeOfTest': 'Blood Test',
      'dateOfCollection': '2024-10-18',
      'action': 'started'
    },
    {
      'opNumber': '124',
      'name': 'Jane Doe',
      'age': '32',
      'place': 'California',
      'token': 'B2',
      'counterNo': '3',
      'drName': 'Dr. Jones',
      'typeOfTest': 'X-Ray',
      'dateOfCollection': '2024-10-17',
      'action': 'report'
    },
  ];

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: FittedBox(
              fit: BoxFit.contain,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('OP Number')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Age')),
                  DataColumn(label: Text('Place')),
                  DataColumn(label: Text('Token')),
                  DataColumn(label: Text('Counter No')),
                  DataColumn(label: Text('Dr Name')),
                  DataColumn(label: Text('Type of Test')),
                  DataColumn(label: Text('Date of Collection')),
                  DataColumn(label: Text('Action')),
                ],
                rows: rows.map((row) {
                  return DataRow(cells: [
                    DataCell(Text(row['opNumber'])),
                    DataCell(Text(row['name'])),
                    DataCell(Text(row['age'])),
                    DataCell(Text(row['place'])),
                    DataCell(Text(row['token'])),
                    DataCell(Text(row['counterNo'])),
                    DataCell(Text(row['drName'])),
                    DataCell(Text(row['typeOfTest'])),
                    DataCell(Text(row['dateOfCollection'])),
                    DataCell(DropdownButton<String>(
                      value: row['action'],
                      items: ['started', 'report'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          row['action'] = newValue!;
                        });
                      },
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
