import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:iconsax/iconsax.dart';
import 'doctor_schedule.dart';
import 'ip_admission.dart';
import 'ip_patients_admission.dart';
import 'op_counters.dart';
import 'op_ticket.dart';

class AdmissionStatus extends StatefulWidget {
  const AdmissionStatus({super.key});

  @override
  State<AdmissionStatus> createState() => _AdmissionStatusState();
}

class _AdmissionStatusState extends State<AdmissionStatus> {
  int selectedIndex = 4;
  ScrollController _scrollController5 = ScrollController();
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();

  // Example patient data structure with name and address
  List<Map<String, String>> roomData = [
    {'name': 'John Doe', 'address': '123 Street A'},
    {'name': 'Jane Smith', 'address': '456 Street B'},
    {'name': 'Robert Brown', 'address': '789 Street C'},
    // Add more rooms with patient data or empty for vacant rooms
    {'name': '', 'address': ''}, // Vacant room
    // ... add more room entries
  ];

  @override
  void dispose() {
    // Dispose the controller when it's no longer needed
    _scrollController5.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();

    super.dispose();
  }

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
          Expanded(
            child: SingleChildScrollView(
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
        buildDrawerItem(4, 'Admission Status', () {}, Iconsax.status),
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
    // List of room statuses (true = booked, false = available)
    List<bool> roomStatus = [
      true,
      true,
      true,
      true,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ];
    List<String> patientNames = [
      "John",
      "Jane",
      "Alice",
      "Bob",
      "Chris",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
    ];
    List<String> patientPlaces = [
      "Room A",
      "Room B",
      "Room C",
      "Room D",
      "Room E",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
    ];

    List<bool> wardStatus = [
      true,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ];
    List<String> wardNames = [
      "Ward 1",
      "Ward 2",
      "Ward 3",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
    ];
    List<String> wardPlaces = [
      "Ward 1",
      "Ward 2",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
    ];

    List<bool> viproomStatus = [
      true,
      true,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ];
    List<String> viproomNames = [
      "VIP 1",
      "VIP 2",
      "VIP 3",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
    ];
    List<String> viproomPlaces = [
      "VIP 1",
      "VIP 2",
      "VIP 3",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
    ];

    List<bool> ICUStatus = [
      true,
      true,
      false,
      false,
      false,
    ];
    List<String> ICUroomNames = ["ICU 1", "ICU 2", "", "", ""];
    List<String> ICUroomPlaces = ["ICU 1", "ICU 2", "", "", ""];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: isMobile
            ? Alignment.center
            : Alignment.topLeft, // Align top-left for web, center for mobile
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admission Status',
              style: TextStyle(
                  fontFamily: 'SanFrancisco',
                  fontSize: 18,
                  fontWeight: FontWeight.normal),
            ),
            SizedBox(
              height: 15,
            ),
            Scrollbar(
              controller: _scrollController5, // Attach the ScrollController
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController5,
                child: Row(
                  children: [
                    Text('Rooms : '),
                    SizedBox(
                      width: 30,
                    ),
                    Wrap(
                      spacing: 10, // Horizontal spacing between rooms
                      runSpacing: 10, // Vertical spacing between rooms
                      children: List.generate(roomStatus.length, (index) {
                        return GestureDetector(
                          onTap: roomStatus[index]
                              ? null // Disable interaction if the room is booked
                              : () {
                                  // Optional: Add booking functionality here if needed
                                  // setState to toggle room status or handle booking logic
                                },
                          child: Container(
                            width: 70,
                            // Set a fixed width for each room box
                            height: 75,
                            // Set a fixed height for each room box
                            decoration: BoxDecoration(
                              color: roomStatus[index]
                                  ? Colors.green[200]
                                  : Colors.grey,
                              // Red for booked, green for available
                              borderRadius: BorderRadius.circular(2),
                              //border: Border.all(color: Colors.black, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  roomStatus[index]
                                      ? patientNames[index] // Show patient name
                                      : "Vaccant", // Show "Available" if room is free
                                  style: TextStyle(
                                      fontFamily: 'SanFrancisco',
                                      color: Colors.white),
                                ),
                                // Display place of the room
                                Text(
                                  roomStatus[index]
                                      ? patientPlaces[index] // Show place
                                      : "No place", // Show placeholder
                                  style: TextStyle(
                                      fontFamily: 'SanFrancisco',
                                      color: Colors.white),
                                ),
                                Icon(
                                  Icons.bed_sharp,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Scrollbar(
              thumbVisibility: true,
              controller: _scrollController1,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController1,
                child: Row(
                  children: [
                    Text(
                      'Wards : ',
                      style: TextStyle(
                        fontFamily: 'SanFrancisco',
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Wrap(
                      spacing: 10, // Horizontal spacing between rooms
                      runSpacing: 10, // Vertical spacing between rooms
                      children: List.generate(wardStatus.length, (index) {
                        return GestureDetector(
                          onTap: wardStatus[index]
                              ? null // Disable interaction if the room is booked
                              : () {
                                  // Optional: Add booking functionality here if needed
                                  // setState to toggle room status or handle booking logic
                                },
                          child: InkWell(
                            child: Container(
                              width: 70,
                              // Set a fixed width for each room box
                              height: 75,
                              // Set a fixed height for each room box
                              decoration: BoxDecoration(
                                color: wardStatus[index]
                                    ? Colors.green[200]
                                    : Colors.grey,
                                // Red for booked, green for available
                                borderRadius: BorderRadius.circular(2),
                                //border: Border.all(color: Colors.black, width: 1),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Text(
                                    roomStatus[index]
                                        ? wardNames[index] // Show patient name
                                        : "Vaccant", // Show "Available" if room is free
                                    style: TextStyle(
                                        fontFamily: 'SanFrancisco',
                                        color: Colors.white),
                                  ),
                                  // Display place of the room
                                  Text(
                                    roomStatus[index]
                                        ? wardPlaces[index] // Show place
                                        : "No place", // Show placeholder
                                    style: TextStyle(
                                        fontFamily: 'SanFrancisco',
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    Icons.bed_sharp,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              print('${index + 1} pressed');
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Scrollbar(
              thumbVisibility: true,
              controller: _scrollController2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController2,
                child: Row(
                  children: [
                    Text(
                      'VIP Rooms : ',
                      style: TextStyle(
                        fontFamily: 'SanFrancisco',
                      ),
                    ),
                    Wrap(
                      spacing: 10, // Horizontal spacing between rooms
                      runSpacing: 10, // Vertical spacing between rooms
                      children: List.generate(viproomStatus.length, (index) {
                        return GestureDetector(
                          onTap: viproomStatus[index]
                              ? null // Disable interaction if the room is booked
                              : () {
                                  // Optional: Add booking functionality here if needed
                                  // setState to toggle room status or handle booking logic
                                },
                          child: InkWell(
                            child: Container(
                              width: 70,
                              // Set a fixed width for each room box
                              height: 75,
                              // Set a fixed height for each room box
                              decoration: BoxDecoration(
                                color: viproomStatus[index]
                                    ? Colors.green[200]
                                    : Colors.grey,
                                // Red for booked, green for available
                                borderRadius: BorderRadius.circular(2),
                                //border: Border.all(color: Colors.black, width: 1),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Text(
                                    roomStatus[index]
                                        ? viproomNames[
                                            index] // Show patient name
                                        : "Vaccant", // Show "Available" if room is free
                                    style: TextStyle(
                                        fontFamily: 'SanFrancisco',
                                        color: Colors.white),
                                  ),
                                  // Display place of the room
                                  Text(
                                    roomStatus[index]
                                        ? viproomPlaces[index] // Show place
                                        : "No place", // Show placeholder
                                    style: TextStyle(
                                        fontFamily: 'SanFrancisco',
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    Icons.bed_sharp,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              print('${index + 1} pressed');
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Scrollbar(
              thumbVisibility: true,
              controller: _scrollController3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController3,
                child: Row(
                  children: [
                    Text(
                      'ICU : ',
                      style: TextStyle(
                        fontFamily: 'SanFrancisco',
                      ),
                    ),
                    SizedBox(
                      width: 45,
                    ),
                    Wrap(
                      spacing: 10, // Horizontal spacing between rooms
                      runSpacing: 10, // Vertical spacing between rooms
                      children: List.generate(ICUStatus.length, (index) {
                        return GestureDetector(
                          onTap: ICUStatus[index]
                              ? null // Disable interaction if the room is booked
                              : () {
                                  // Optional: Add booking functionality here if needed
                                  // setState to toggle room status or handle booking logic
                                },
                          child: InkWell(
                            child: Container(
                              width: 70,
                              // Set a fixed width for each room box
                              height: 75,
                              // Set a fixed height for each room box
                              decoration: BoxDecoration(
                                color: ICUStatus[index]
                                    ? Colors.green[200]
                                    : Colors.grey,
                                // Red for booked, green for available
                                borderRadius: BorderRadius.circular(2),
                                //border: Border.all(color: Colors.black, width: 1),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Text(
                                    roomStatus[index]
                                        ? ICUroomNames[
                                            index] // Show patient name
                                        : "Vaccant", // Show "Available" if room is free
                                    style: TextStyle(
                                        fontFamily: 'SanFrancisco',
                                        color: Colors.white),
                                  ),
                                  // Display place of the room
                                  Text(
                                    roomStatus[index]
                                        ? ICUroomPlaces[index] // Show place
                                        : "No place", // Show placeholder
                                    style: TextStyle(
                                        fontFamily: 'SanFrancisco',
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    Icons.bed_sharp,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              print('${index + 1} pressed');
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 40,
            ),
            // Add other form fields or content below
          ],
        ),
      ),
    );
  }
}
