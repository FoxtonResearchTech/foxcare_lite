import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  // To store the index of the selected drawer item
  int selectedIndex = 0;

  // List of patients data for the table
  final List<Map<String, dynamic>> patientData = [
    {
      'opNum': 'B00010',
      'name': 'Ramesh',
      'age': '25',
      'basicInfo': 'Fever',
      'tokenNumber': '20',
      'actionFilled': true,
    },
    {
      'opNum': '0045',
      'name': 'Babu',
      'age': '50',
      'basicInfo': 'UTI',
      'tokenNumber': '24',
      'actionFilled': true,
    },
    {
      'opNum': '0045',
      'name': 'Babu',
      'age': '50',
      'basicInfo': 'UTI',
      'tokenNumber': '24',
      'actionFilled': false,
    },
    {
      'opNum': '0045',
      'name': 'Babu',
      'age': '50',
      'basicInfo': 'UTI',
      'tokenNumber': '24',
      'actionFilled': false,
    },
    // Add more rows here if needed
  ];

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text('Reception Dashboard'),
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
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildHeader(),
                  SizedBox(height: 20),
                  Expanded(child: dashboard()),
                ],
              ),
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
            'Doctor - Consultation',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'SanFrancisco',
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Home', () {}, Iconsax.mask),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(1, 'Patient Search', () {}, Iconsax.receipt),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(2, 'Pharmacy Stocks', () {}, Iconsax.add_circle),
        Divider(height: 5, color: Colors.grey),
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
      selectedTileColor: Colors.blueAccent.shade100,
      // Highlight color for the selected item
      leading: Icon(
        icon, // Replace with actual icons
        color: selectedIndex == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
            color: selectedIndex == index ? Colors.blue : Colors.black54,
            fontWeight: FontWeight.w700,
            fontFamily: 'SanFrancisco'),
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
      alignment: isMobile ? Alignment.center : Alignment.center,
      // Align top-left for web, center for mobile
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(),
          columnWidths: {
            0: FixedColumnWidth(100.0),
            1: FixedColumnWidth(200.0),
            2: FixedColumnWidth(50.0),
            3: FixedColumnWidth(100.0),
            4: FixedColumnWidth(80.0),
            5: FixedColumnWidth(200.0),
          },
          children: [
            TableRow(
              children: [
                tableCell('OP Num'),
                tableCell('Name'),
                tableCell('Age'),
                tableCell('Basic Info'),
                tableCell('Token Number'),
                tableCell('Action'),
              ],
            ),
            // Dynamically generate rows from the list
            ...patientData.map((patient) {
              return TableRow(
                children: [
                  tableCell(patient['opNum']),
                  tableCell(patient['name']),
                  tableCell(patient['age']),
                  tableCell(patient['basicInfo']),
                  tableCell(patient['tokenNumber']),
                  tableActionCell(patient['actionFilled']),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget tableActionCell(bool filled) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          color: filled ? Colors.grey : Colors.transparent,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: filled
              ? Text(
                  'Rx Done',
                  style: TextStyle(fontFamily: 'Poppins'),
                )
              : InkWell(
                  onTap: () {
                    print('button pressed');
                  },
                  child: Text(
                    'Rx Prescription',
                    style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Today's Queue",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SanFrancisco'),
            ),
          ],
        ),
        SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Today's OP Reg: ",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SanFrancisco'),
            ),
            Text(
              "Counter: ",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SanFrancisco'),
            ),
          ],
        ),
      ],
    );
  }
}
