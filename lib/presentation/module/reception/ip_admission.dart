import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/presentation/module/reception/total_room_update.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import 'admission_status.dart';
import 'doctor_schedule.dart';
import 'ip_patients_admission.dart';
import 'op_counters.dart';
import 'op_ticket.dart';

class IpAdmissionPage extends StatefulWidget {
  @override
  State<IpAdmissionPage> createState() => _IpAdmissionPageState();
}

class _IpAdmissionPageState extends State<IpAdmissionPage> {
  TimeOfDay now = TimeOfDay.now();
  final date = DateTime.timestamp();
  String SelectedRoom = 'Room';
  String vacantRoom = '1';
  String nursingStation = 'Station A';

  // List of room statuses (true = booked, false = available)
  List<bool> roomStatus = [];
  List<bool> wardStatus = [];
  List<bool> viproomStatus = [];
  List<bool> ICUStatus = [];
  int selectedIndex1 = 2;

  //String selectedSex = 'Male'; // Default value for Sex
  String selectedBloodGroup = 'A+'; // Default value for Blood Group

  bool isSearchPerformed = false; // To track if search has been performed
  Map<String, String>? selectedPatient;
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();

  bool isDataLoaded = false; // To control data loading when button is clicked
  List<Map<String, dynamic>> patientData = []; // Patient data
  int? selectedIndex; // Store selected checkbox index
  Future<void> fetchRoomData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('totalRoom')
          .doc('status')
          .get();

      if (doc.exists) {
        setState(() {
          roomStatus = List<bool>.from(doc['roomStatus']);
          wardStatus = List<bool>.from(doc['wardStatus']);
          viproomStatus = List<bool>.from(doc['viproomStatus']);
          ICUStatus = List<bool>.from(doc['ICUStatus']);
        });
      } else {
        print("Document does not exist.");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Sample dummy data for patients
  List<Map<String, dynamic>> samplePatients = [
    {
      "opNumber": "OP001",
      "name": "John Doe",
      "age": 30,
      "address": "123 Street, City",
      "ipFromDate": "2024-01-10",
      "ipToDate": "2024-01-20"
    },
    {
      "opNumber": "OP002",
      "name": "Jane Smith",
      "age": 40,
      "address": "456 Avenue, City",
      "ipFromDate": "2024-01-05",
      "ipToDate": "2024-01-15"
    },
    {
      "opNumber": "OP003",
      "name": "Robert Brown",
      "age": 50,
      "address": "789 Boulevard, City",
      "ipFromDate": "2024-01-08",
      "ipToDate": "2024-01-18"
    }
  ];
  @override
  void initState() {
    super.initState();
    fetchRoomData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(
                'OP Ticket Dashboard',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: buildDrawerContent(), // Drawer minimized for mobile
            )
          : null, // No AppBar for web view
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Sidebar width for larger screens
              color: Colors.blue.shade100,
              child: buildDrawerContent(), // Sidebar content
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return buildThreeColumnForm(); // Web view
                  } else {
                    return buildSingleColumnForm(); // Mobile view
                  }
                },
              ),
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
        // Drawer items here
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
        buildDrawerItem(2, 'IP Admission', () {}, Iconsax.add_circle),
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
        buildDrawerItem(4, 'Admission Status', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdmissionStatus()),
          );
        }, Iconsax.status),
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

  Widget buildDrawerItem(
      int index, String title, VoidCallback onTap, IconData icon) {
    return ListTile(
      selected: selectedIndex1 == index,
      selectedTileColor: Colors.blueAccent.shade100,
      // Highlight color for the selected item
      leading: Icon(
        icon, // Replace with actual icons
        color: selectedIndex1 == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
            fontFamily: 'SanFrancisco',
            color: selectedIndex1 == index ? Colors.blue : Colors.black54,
            fontWeight: FontWeight.w700),
      ),
      onTap: () {
        setState(() {
          selectedIndex1 = index; // Update the selected index
        });
        onTap();
      },
    );
  }

  Widget buildThreeColumnForm() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;
    return Align(
      alignment: isMobile ? Alignment.center : Alignment.topLeft,
      // Align top-left for web, center for mobile
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'IP Admission Portal :',
            style: TextStyle(
                fontFamily: 'SanFrancisco',
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Text(
                'Rooms / Ward Availability',
                style: TextStyle(
                    fontFamily: 'SanFrancisco',
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(width: screenWidth * 0.5),
              CustomButton(
                label: 'Total Rooms',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TotalRoomUpdate()));
                },
                width: screenWidth * 0.1,
                height: screenHeight * 0.038,
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Scrollbar(
            controller: _scrollController, // Attach the ScrollController
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children: [
                  Text(
                    'Rooms : ',
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
                    children: List.generate(roomStatus.length, (index) {
                      return GestureDetector(
                        onTap: roomStatus[index]
                            ? null // Disable interaction if the room is booked
                            : () {
                                // Optional: Add booking functionality here if needed
                                // setState to toggle room status or handle booking logic
                              },
                        child: InkWell(
                          child: Container(
                            width: 50,
                            // Set a fixed width for each room box
                            height: 60,
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
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontFamily: 'SanFrancisco',
                                  ),
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
                            setState(() {
                              roomStatus[index] =
                                  true; // Correctly update the value
                            });
                            print('${index + 1} pressed');
                          },
                          onDoubleTap: () {
                            setState(() {
                              roomStatus[index] =
                                  false; // Correctly update the value
                            });
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
                            width: 50,
                            // Set a fixed width for each room box
                            height: 60,
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
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontFamily: 'SanFrancisco',
                                  ),
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
                            setState(() {
                              wardStatus[index] =
                                  true; // Correctly update the value
                            });
                            print('${index + 1} pressed');
                          },
                          onDoubleTap: () {
                            setState(() {
                              wardStatus[index] =
                                  false; // Correctly update the value
                            });
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
                            width: 50,
                            // Set a fixed width for each room box
                            height: 60,
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
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontFamily: 'SanFrancisco',
                                  ),
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
                            setState(() {
                              viproomStatus[index] =
                                  true; // Correctly update the value
                            });
                            print('${index + 1} pressed');
                          },
                          onDoubleTap: () {
                            setState(() {
                              viproomStatus[index] =
                                  false; // Correctly update the value
                            });
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
                            width: 50,
                            // Set a fixed width for each room box
                            height: 60,
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
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontFamily: 'SanFrancisco',
                                  ),
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
                            setState(() {
                              ICUStatus[index] =
                                  true; // Correctly update the value
                            });
                            print('${index + 1} pressed');
                          },
                          onDoubleTap: () {
                            setState(() {
                              ICUStatus[index] =
                                  false; // Correctly update the value
                            });
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

          Text(
            'IP Initiation :',
            style: TextStyle(
                fontFamily: 'SanFrancisco',
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 30,
          ),

          // Inpatient Registration Check button

          SizedBox(
            width: 350,
            child: CustomButton(
              label: "Inpatient Registration Check",
              onPressed: () {
                setState(() {
                  isDataLoaded = true; // Show the data list on button click
                  patientData = samplePatients; // Load patient data
                });
              },
              width: null,
            ),
          ),
          SizedBox(height: 20),
          // Display the list of patient data after button click
          isDataLoaded ? buildPatientList() : Container(),
          SizedBox(height: 20),

          // Display selected patient details in text fields
          selectedIndex != null ? buildSelectedPatientDetails() : Container(),

          // Add other form fields or content below
        ],
      ),
    );
  }

  Widget buildSingleColumnForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'IP Admission Portal :',
          style: TextStyle(
              fontFamily: 'SanFrancisco',
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          'Rooms / Ward Availability',
          style: TextStyle(
              fontFamily: 'SanFrancisco',
              fontSize: 18,
              fontWeight: FontWeight.normal),
        ),
        SizedBox(
          height: 15,
        ),
        Scrollbar(
          controller: _scrollController, // Attach the ScrollController
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: [
                Text(
                  'Rooms : ',
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
                  children: List.generate(roomStatus.length, (index) {
                    return GestureDetector(
                      onTap: roomStatus[index]
                          ? null // Disable interaction if the room is booked
                          : () {
                              // Optional: Add booking functionality here if needed
                              // setState to toggle room status or handle booking logic
                            },
                      child: InkWell(
                        child: Container(
                          width: 50,
                          // Set a fixed width for each room box
                          height: 60,
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
                                '${index + 1}',
                                style: TextStyle(
                                  fontFamily: 'SanFrancisco',
                                ),
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
                          width: 50,
                          // Set a fixed width for each room box
                          height: 60,
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
                                '${index + 1}',
                                style: TextStyle(
                                  fontFamily: 'SanFrancisco',
                                ),
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
                          width: 50,
                          // Set a fixed width for each room box
                          height: 60,
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
                                '${index + 1}',
                                style: TextStyle(
                                  fontFamily: 'SanFrancisco',
                                ),
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
                          width: 50,
                          // Set a fixed width for each room box
                          height: 60,
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
                                '${index + 1}',
                                style: TextStyle(
                                  fontFamily: 'SanFrancisco',
                                ),
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

        Text(
          'IP Initiation :',
          style: TextStyle(
              fontFamily: 'SanFrancisco',
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 30,
        ),

        // Inpatient Registration Check button

        SizedBox(
          width: 350,
          child: CustomButton(
            label: "Inpatient Registration Check",
            onPressed: () {
              setState(() {
                isDataLoaded = true; // Show the data list on button click
                patientData = samplePatients; // Load patient data
              });
            },
            width: null,
          ),
        ),
        SizedBox(height: 20),
        // Display the list of patient data after button click
        isDataLoaded ? buildPatientList() : Container(),
        SizedBox(height: 20),

        // Display selected patient details in text fields
        selectedIndex != null ? buildSelectedPatientDetails() : Container(),

        // Add other form fields or content below
      ],
    );
  }

  // Build the list of patients with checkboxes
  Widget buildPatientList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: patientData.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(
            "${patientData[index]['opNumber']} - ${patientData[index]['name']}",
            style: TextStyle(
              fontFamily: 'SanFrancisco',
            ),
          ),
          subtitle: Text(
            "Age: ${patientData[index]['age']} - IP from ${patientData[index]['ipFromDate']} to ${patientData[index]['ipToDate']}",
            style: TextStyle(
              fontFamily: 'SanFrancisco',
            ),
          ),
          value: selectedIndex == index,
          onChanged: (bool? value) {
            setState(() {
              selectedIndex = index; // Set the selected patient
            });
          },
        );
      },
    );
  }

  Widget buildTextField(String label,
      {String? initialValue, TextInputType inputType = TextInputType.text}) {
    return TextField(
      decoration: InputDecoration(
        isDense: true,
        // Reduces the overall height of the TextField
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        hintText: label,
        hintStyle: TextStyle(
          fontFamily: 'SanFrancisco',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue, width: 1),
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      keyboardType: inputType,
      controller: TextEditingController(text: initialValue),
    );
  }

  Widget buildSelectedPatientDetails() {
    var selectedPatient = patientData[selectedIndex!];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'OP Number :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: selectedPatient['opNumber'],
                  width: null,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Name :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: selectedPatient['name'],
                  width: null,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Text(
                'Age :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(width: 65),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: selectedPatient['age'].toString(),
                  width: null,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Address :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: selectedPatient['address'],
                  width: null,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Text(
                'From Date :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: selectedPatient['ipFromDate'],
                  width: null,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'To Date :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: selectedPatient['ipToDate'],
                  width: null,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Text(
                'Stay :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(width: 60),
              SizedBox(
                width: 200,
                child: CustomDropdown(
                    label: 'Stay',
                    items: ['Room', 'Ward', 'vipRoom', 'ICU'],
                    selectedItem: SelectedRoom,
                    onChanged: (value) {
                      SelectedRoom = value!;
                    }),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Availablility :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(width: 15),
              SizedBox(
                width: 200,
                child: CustomDropdown(
                    label: 'Vacant',
                    items: ['1', '2', '3', '4'],
                    selectedItem: vacantRoom,
                    onChanged: (value) {
                      vacantRoom = value!;
                    }),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Text(
                'Nursing Station :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: CustomDropdown(
                    label: 'Station',
                    items: ['Station A', 'Station B', 'ICU Station'],
                    selectedItem: nursingStation,
                    onChanged: (value) {
                      nursingStation = value!;
                    }),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            'By Stander Information :',
            style: TextStyle(
                fontFamily: 'SanFrancisco',
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                'By Stander Name : ',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: 'Enter Name',
                  width: null,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Phone Number : ',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: 'Enter Phone No',
                  width: null,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                'Relation : ',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
              SizedBox(
                width: 30,
              ),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: 'Relation with patient',
                  width: null,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              SizedBox(
                width: 50,
              ),
              SizedBox(
                width: 250,
                child: CustomButton(
                  label: 'Register',
                  onPressed: () {},
                  width: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
