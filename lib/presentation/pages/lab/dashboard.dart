import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utilities/widgets/textField/primary_textField.dart';
import 'lab_accounts.dart';
import 'lab_testqueue.dart';

class LabDashboard extends StatefulWidget {
  const LabDashboard({super.key});

  @override
  State<LabDashboard> createState() => _LabDashboardState();
}

class _LabDashboardState extends State<LabDashboard> {
  // To store the index of the selected drawer item
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screeHeight = MediaQuery.of(context).size.height;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text('Laboratory Dashboard'),
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
              padding: const EdgeInsets.all(16.0),
              child: dashboard(),
            ),
          ),
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
      selectedTileColor:
          Colors.blueAccent.shade100, // Highlight color for the selected item
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
          selectedIndex = index; // Update the selected index
        });
        onTap();
      },
    );
  }

  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screeHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and Year
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

        // Today's Report Section
        Text(
          "Today's Report",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'No. of Tests: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
                flex: 3,
                child: CustomTextField(
                  hintText: 'Enter Number',
                  width: screenWidth * 0.5,
                )),
            Expanded(
              flex: 1,
              child: Text(''),
            )
          ],
        ),
        SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'Total Blood Test: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
                flex: 3,
                child: CustomTextField(
                  hintText: 'Enter total test',
                  width: screenWidth * 0.5,
                )),
            Expanded(
              flex: 1,
              child: Text(''),
            )
          ],
        ),
        SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'Total Urine Test: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
                flex: 3,
                child: CustomTextField(
                  hintText: 'Enter Number',
                  width: screenWidth * 0.5,
                )),
            Expanded(
              flex: 1,
              child: Text(''),
            )
          ],
        ),
        SizedBox(height: 20),

        // Table Section
        Text(
          'Today\'s Test OP/IP',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        // Wrapping the table in a single child scroll view for horizontal scrolling
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FixedColumnWidth(100), // Adjust the widths as per your content
              1: FixedColumnWidth(150),
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(120),
              4: FixedColumnWidth(120),
              5: FixedColumnWidth(120),
              6: FixedColumnWidth(100),
            },
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('OP Number'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Name'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Age'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Token Number'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Dr. Name'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Family Name'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Type of Test'),
                    ),
                  ),
                ],
              ),
              // Additional rows
              TableRow(
                children: List.generate(7, (index) {
                  return TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 100, // Set a width for each text field
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                            isDense: true, // Makes the TextField more compact
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
