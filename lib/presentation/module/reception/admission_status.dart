import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/presentation/module/reception/total_room_update.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import 'admission_status.dart';
import 'doctor_schedule.dart';
import 'ip_admission.dart';
import 'ip_patients_admission.dart';
import 'op_counters.dart';
import 'op_ticket.dart';

class AdmissionStatus extends StatefulWidget {
  @override
  State<AdmissionStatus> createState() => _AdmissionStatus();
}

class _AdmissionStatus extends State<AdmissionStatus> {
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
  int selectedIndex1 = 4;

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
    // Dispose the controller when it's no longer needed
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
              child: ReceptionDrawer(
                selectedIndex: selectedIndex1,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No AppBar for web view
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Sidebar width for larger screens
              color: Colors.blue.shade100,
              child: ReceptionDrawer(
                selectedIndex: selectedIndex1,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
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

  Widget buildThreeColumnForm() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;
    return Align(
      alignment: isMobile ? Alignment.center : Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.02),
                child: Column(
                  children: [
                    CustomText(
                      text: "Admission Status",
                      size: screenWidth * 0.03,
                    ),
                  ],
                ),
              ),
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.1,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    image: const DecorationImage(
                        image: AssetImage('assets/foxcare_lite_logo.png'))),
              ),
            ],
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
                width: screenWidth * 0.12,
                height: screenHeight * 0.05,
              ),
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
                                  ? AppColors.blue
                                  : AppColors.lightBlue,
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
                            // setState(() {
                            //   roomStatus[index] =
                            //       true; // Correctly update the value
                            // });
                            print('${index + 1} pressed');
                          },
                          onDoubleTap: () {
                            // setState(() {
                            //   roomStatus[index] =
                            //       false; // Correctly update the value
                            // });
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
                                  ? AppColors.blue
                                  : AppColors.lightBlue,
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
                            // setState(() {
                            //   wardStatus[index] =
                            //       true; // Correctly update the value
                            // });
                            print('${index + 1} pressed');
                          },
                          onDoubleTap: () {
                            // setState(() {
                            //   wardStatus[index] =
                            //       false; // Correctly update the value
                            // });
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
                                  ? AppColors.blue
                                  : AppColors.lightBlue,
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
                            // setState(() {
                            //   viproomStatus[index] =
                            //       true; // Correctly update the value
                            // });
                            print('${index + 1} pressed');
                          },
                          onDoubleTap: () {
                            // setState(() {
                            //   viproomStatus[index] =
                            //       false; // Correctly update the value
                            // });
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
                                  ? AppColors.blue
                                  : AppColors.lightBlue,
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
                            // setState(() {
                            //   ICUStatus[index] =
                            //       true; // Correctly update the value
                            // });
                            print('${index + 1} pressed');
                          },
                          onDoubleTap: () {
                            // setState(() {
                            //   ICUStatus[index] =
                            //       false; // Correctly update the value
                            // });
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
                                ? AppColors.blue
                                : AppColors.lightBlue,
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
                                ? AppColors.blue
                                : AppColors.lightBlue,
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
                                ? AppColors.blue
                                : AppColors.lightBlue,
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
                                ? AppColors.blue
                                : AppColors.lightBlue,
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
}
