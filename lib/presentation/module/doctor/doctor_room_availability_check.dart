import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/total_room_update.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/doctor/doctor_module_drawer.dart';
import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';

class DoctorRoomAvailabilityCheck extends StatefulWidget {
  @override
  State<DoctorRoomAvailabilityCheck> createState() =>
      _DoctorRoomAvailabilityCheck();
}

class _DoctorRoomAvailabilityCheck extends State<DoctorRoomAvailabilityCheck> {
  TimeOfDay now = TimeOfDay.now();
  final date = DateTime.timestamp();
  String SelectedRoom = 'Room';
  String vacantRoom = '1';
  String nursingStation = 'Station A';

  List<String> roomStatus = [];
  List<String> wardStatus = [];
  List<String> viproomStatus = [];
  List<String> ICUStatus = [];
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
          roomStatus = List<String>.from(doc['roomStatus']);
          wardStatus = List<String>.from(doc['wardStatus']);
          viproomStatus = List<String>.from(doc['viproomStatus']);
          ICUStatus = List<String>.from(doc['ICUStatus']);
        });
      } else {
        print("Document does not exist.");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

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
              child: DoctorModuleDrawer(
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
              child: DoctorModuleDrawer(
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
                    return buildThreeColumnForm(); // Mobile view
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
                      text: "Room Availability",
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
          const Row(
            children: [
              Text(
                'Rooms / Ward Availability',
                style: TextStyle(
                    fontFamily: 'SanFrancisco',
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
          const SizedBox(
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
                  const Text(
                    'Rooms : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Wrap(
                    spacing: 10, // Horizontal spacing between rooms
                    runSpacing: 10, // Vertical spacing between rooms
                    children: List.generate(roomStatus.length, (index) {
                      return GestureDetector(
                        onTap: (roomStatus[index] == "booked" ||
                                roomStatus[index] == "available")
                            ? null
                            : () {
                                // Handle booking or toggling logic
                              },
                        child: InkWell(
                          child: Container(
                            width: 50,
                            // Set a fixed width for each room box
                            height: 60,
                            // Set a fixed height for each room box
                            decoration: BoxDecoration(
                              color: roomStatus[index] == 'booked'
                                  ? AppColors.blue
                                  : roomStatus[index] == 'available'
                                      ? AppColors.lightBlue
                                      : AppColors.roomDisabled,

                              borderRadius: BorderRadius.circular(2),
                              //border: Border.all(color: Colors.black, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'SanFrancisco',
                                  ),
                                ),
                                const Icon(
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
          const SizedBox(
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
                  const Text(
                    'Wards : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Wrap(
                    spacing: 10, // Horizontal spacing between rooms
                    runSpacing: 10, // Vertical spacing between rooms
                    children: List.generate(wardStatus.length, (index) {
                      return GestureDetector(
                        onTap: (wardStatus[index] == "booked" ||
                                wardStatus[index] == "available")
                            ? null
                            : () {
                                // Handle booking or toggling logic
                              },
                        child: InkWell(
                          child: Container(
                            width: 50,
                            // Set a fixed width for each room box
                            height: 60,
                            // Set a fixed height for each room box
                            decoration: BoxDecoration(
                              color: wardStatus[index] == 'booked'
                                  ? AppColors.blue
                                  : wardStatus[index] == 'available'
                                      ? AppColors.lightBlue
                                      : AppColors.roomDisabled,

                              // Red for booked, green for available
                              borderRadius: BorderRadius.circular(2),
                              //border: Border.all(color: Colors.black, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'SanFrancisco',
                                  ),
                                ),
                                const Icon(
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
          const SizedBox(
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
                  const Text(
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
                        onTap: (viproomStatus[index] == "booked" ||
                                viproomStatus[index] == "available")
                            ? null
                            : () {
                                // Handle booking or toggling logic
                              },
                        child: InkWell(
                          child: Container(
                            width: 50,
                            // Set a fixed width for each room box
                            height: 60,
                            // Set a fixed height for each room box
                            decoration: BoxDecoration(
                              color: viproomStatus[index] == 'booked'
                                  ? AppColors.blue
                                  : viproomStatus[index] == 'available'
                                      ? AppColors.lightBlue
                                      : AppColors.roomDisabled,

                              borderRadius: BorderRadius.circular(2),
                              //border: Border.all(color: Colors.black, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'SanFrancisco',
                                  ),
                                ),
                                const Icon(
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
          const SizedBox(
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
                  const Text(
                    'ICU : ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                    ),
                  ),
                  const SizedBox(
                    width: 45,
                  ),
                  Wrap(
                    spacing: 10, // Horizontal spacing between rooms
                    runSpacing: 10, // Vertical spacing between rooms
                    children: List.generate(ICUStatus.length, (index) {
                      return GestureDetector(
                        onTap: (ICUStatus[index] == "booked" ||
                                ICUStatus[index] == "available")
                            ? null
                            : () {
                                // Handle booking or toggling logic
                              },
                        child: InkWell(
                          child: Container(
                            width: 50,
                            // Set a fixed width for each room box
                            height: 60,
                            // Set a fixed height for each room box
                            decoration: BoxDecoration(
                              color: ICUStatus[index] == 'booked'
                                  ? AppColors.blue
                                  : ICUStatus[index] == 'available'
                                      ? AppColors.lightBlue
                                      : AppColors.roomDisabled,

                              borderRadius: BorderRadius.circular(2),
                              //border: Border.all(color: Colors.black, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'SanFrancisco',
                                  ),
                                ),
                                const Icon(
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
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
