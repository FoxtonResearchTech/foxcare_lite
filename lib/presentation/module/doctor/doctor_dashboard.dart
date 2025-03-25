import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_rx_list.dart';
import 'package:foxcare_lite/presentation/module/doctor/pharmacy_stocks.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utilities/widgets/text/primary_text.dart';
import 'ip_patients_details.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int selectedIndex = 0;
  int hoveredIndex = -1;
  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  DateTime now = DateTime.now();

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

  Widget buildDrawerContent() {
    String formattedTime = DateFormat('h:mm a').format(now);
    String formattedDate =
        '${getDayWithSuffix(now.day)} ${DateFormat('MMMM').format(now)}';
    String formattedYear = DateFormat('y').format(now);
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Container(
                height: 225,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF21b0d1),
                        Color(0xFF106ac2),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Hi',
                              size: 25,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            CustomText(
                              text: 'Dr.Ramesh',
                              size: 30,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        CustomText(
                          text: 'MBBS,MD(General Medicine)',
                          size: 12,
                          color: Colors.white,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 200,
                              height: 25,
                              child: Center(
                                  child: CustomText(
                                text: 'General Medicine',
                                color: Color(0xFF106ac2),
                              )),
                              color: Colors.white,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 10),
                            CustomText(
                              text: '$formattedTime  ',
                              size: 30,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: formattedDate,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                CustomText(
                                  text: formattedYear,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        )
                      ]),
                ),
              ),
              buildDrawerItem(0, 'Home', () {}, Iconsax.mask),
              Divider(height: 5, color: Colors.white),
              buildDrawerItem(1, ' OP Patient', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DoctorRxList()));
              }, Iconsax.receipt),
              Divider(height: 5, color: Colors.white),
              buildDrawerItem(2, 'IP Patients', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => IpPatientsDetails()));
              }, Iconsax.receipt),
              Divider(height: 5, color: Colors.white),
              buildDrawerItem(3, 'Pharmacy Stocks', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PharmacyStocks()));
              }, Iconsax.add_circle),
              Divider(height: 5, color: Colors.white),
              buildDrawerItem(4, 'Logout', () {
                // Handle logout action
              }, Iconsax.logout),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 45, right: 45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                        image: AssetImage('assets/hospital_logo_demo.png'))),
              ),
              SizedBox(
                width: 2.5,
                height: 50,
                child: Container(
                  color: Colors.grey,
                ),
              ),
              Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                        image: AssetImage('assets/NIH_Logo.png'))),
              )
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 25,
          color: Color(0xFF106ac2),
          child: Center(
            child: CustomText(
              text: 'Main Road, Trivandrum-690001',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDrawerItem(
      int index, String title, VoidCallback onTap, IconData icon) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredIndex = -1;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: selectedIndex == index
              ? const LinearGradient(
                  colors: [Color(0xFF21b0d1), Color(0xFF106ac2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : (hoveredIndex == index
                  ? const LinearGradient(
                      colors: [Color(0xFF42c4e3), Color(0xFF21b0d1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null),
          color: selectedIndex == index || hoveredIndex == index
              ? null
              : Colors.transparent,
        ),
        child: ListTile(
          selected: selectedIndex == index,
          selectedTileColor: Colors.transparent,
          leading: Icon(
            icon,
            color: selectedIndex == index
                ? Colors.white
                : (hoveredIndex == index
                    ? Colors.white
                    : const Color(0xFF106ac2)),
          ),
          title: Text(
            title,
            style: TextStyle(
                color: selectedIndex == index
                    ? Colors.white
                    : (hoveredIndex == index
                        ? Colors.white
                        : const Color(0xFF106ac2)),
                fontWeight: FontWeight.w700,
                fontFamily: 'SanFrancisco'),
          ),
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            onTap();
          },
        ),
      ),
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
