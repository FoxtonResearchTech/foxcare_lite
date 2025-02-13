import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/patient_history_dialog.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class ReceptionIpPatient extends StatefulWidget {
  final String patientID;
  final String ipNumber;

  final String name;
  final String age;
  final String place;
  final String address;
  final String pincode;
  final String primaryInfo;
  final String temperature;
  final String bloodPressure;
  final String sugarLevel;

  const ReceptionIpPatient({
    Key? key,
    required this.patientID,
    required this.name,
    required this.age,
    required this.place,
    required this.primaryInfo,
    required this.address,
    required this.pincode,
    required this.temperature,
    required this.bloodPressure,
    required this.sugarLevel,
    required this.ipNumber,
  }) : super(key: key);
  @override
  State<ReceptionIpPatient> createState() => _ReceptionIpPatient();
}

class _ReceptionIpPatient extends State<ReceptionIpPatient> {
  final dateTime = DateTime.timestamp();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _sugarLevelController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _diagnosisSignsController =
      TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _patientHistoryController =
      TextEditingController();
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();

  int selectedIndex = 1;
  String? selectedValue;
  String? selectedIPAdmissionValue;
  bool _isSwitched = false;
  List<bool> roomStatus = [];
  List<bool> wardStatus = [];
  List<bool> viproomStatus = [];
  List<bool> ICUStatus = [];
  String? selectedRoom;

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

  Future<void> updateRoomAvailability() async {
    try {
      await FirebaseFirestore.instance
          .collection('totalRoom')
          .doc('status')
          .update({
        "roomStatus": roomStatus,
        "ICUStatus": ICUStatus,
        "viproomStatus": viproomStatus,
        "wardStatus": wardStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room data updated successfully!')),
      );
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  @override
  void initState() {
    fetchRoomData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _temperatureController.dispose();
    _bloodPressureController.dispose();
    _sugarLevelController.dispose();
    _notesController.dispose();
    _diagnosisSignsController.dispose();
    _symptomsController.dispose();
    _scrollController.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
  }

  Future<void> _savePrescriptionData() async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.ipNumber)
          .collection('ipPrescription')
          .doc('details')
          .set({
        'date': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'time': dateTime.hour.toString() +
            '-' +
            dateTime.minute.toString().padLeft(2, '0') +
            '-' +
            dateTime.second.toString().padLeft(2, '0'),
        'ipAdmission': {
          'roomType': selectedIPAdmissionValue,
          'roomNumber': selectedRoom
        },
      }, SetOptions(merge: true));

      CustomSnackBar(context,
          message: 'Details saved successfully!',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to save: $e', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: CustomText(
          text: "IP Patient Prescription",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: CustomTextField(
                    readOnly: true,
                    controller: TextEditingController(text: widget.ipNumber),
                    hintText: 'IP Number',
                    obscureText: false,
                    width: screenWidth * 0.05,
                  )),
                  const SizedBox(width: 100),
                  Expanded(
                      child: CustomTextField(
                    hintText: 'Date',
                    readOnly: true,
                    obscureText: false,
                    width: screenWidth * 0.05,
                  )),
                ],
              ),
              const SizedBox(height: 26),

              // Row 2: Full Name and Age
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: TextEditingController(text: widget.name),
                      hintText: 'Full Name',
                      obscureText: false,
                      readOnly: true,
                      width: screenWidth * 0.05,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: TextEditingController(text: widget.age),
                      hintText: 'Age',
                      obscureText: false,
                      readOnly: true,
                      width: screenWidth * 0.05,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // Row 3: Address and Pincode
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: TextEditingController(text: widget.address),
                        hintText: 'Address',
                        readOnly: true,
                        obscureText: false,
                        width: screenWidth * 0.05,
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: CustomTextField(
                    controller: TextEditingController(text: widget.pincode),
                    hintText: 'Pin code',
                    readOnly: true,
                    obscureText: false,
                    width: screenWidth * 0.05,
                  )),
                ],
              ),
              const SizedBox(height: 26),
              CustomTextField(
                controller: TextEditingController(text: widget.primaryInfo),
                readOnly: true,
                obscureText: false,
                hintText: 'Basic Info',
                width: screenWidth * 0.9,
                verticalSize: screenWidth * 0.03,
              ),
              const SizedBox(
                height: 20,
              ),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 250,
                  child: CustomDropdown(
                    label: 'Proceed To',
                    items: [
                      'Medication',
                      'Examination',
                      'Appointment',
                      'Investigation'
                    ],
                    selectedItem: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value!;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: CustomDropdown(
                    label: 'Select IP Admission Room',
                    items: ['All', 'Room', 'Ward Room', 'VIP Room', 'ICU'],
                    selectedItem: selectedIPAdmissionValue,
                    onChanged: (value) {
                      setState(() {
                        selectedIPAdmissionValue = value!;
                      });
                    },
                  ),
                ),
                CustomTextField(
                    controller: TextEditingController(
                      text: dateTime.year.toString() +
                          '-' +
                          dateTime.month.toString().padLeft(2, '0') +
                          '-' +
                          dateTime.day.toString().padLeft(2, '0'),
                    ),
                    hintText: 'Date',
                    width: screenWidth * 0.075),
                CustomTextField(
                    controller: TextEditingController(
                      text: dateTime.hour.toString() +
                          '-' +
                          dateTime.minute.toString().padLeft(2, '0') +
                          '-' +
                          dateTime.second.toString().padLeft(2, '0'),
                    ),
                    hintText: 'Time',
                    width: screenWidth * 0.075)
              ]),
              const SizedBox(
                height: 35,
              ),
              Center(child: getAdmissionWidget()),

              const SizedBox(
                height: 35,
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  child: CustomButton(
                    label: 'Admit',
                    onPressed: () {
                      _savePrescriptionData();
                      updateRoomAvailability();
                    },
                    width: screenWidth * 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAdmissionWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    switch (selectedIPAdmissionValue) {
      case 'All':
        return Container(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.03),
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
                                  selectedRoom = (index + 1).toString();
                                  print(selectedRoom);
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
              SizedBox(height: screenHeight * 0.03),
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
                                  selectedRoom = (index + 1).toString();
                                  print(selectedRoom);
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
              SizedBox(height: screenHeight * 0.03),
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
                                  selectedRoom = (index + 1).toString();
                                  print(selectedRoom);
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
              SizedBox(height: screenHeight * 0.03),
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
                                  selectedRoom = (index + 1).toString();
                                  print(selectedRoom);
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
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        );
      case 'Room':
        return Scrollbar(
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
                            selectedRoom = (index + 1).toString();
                            print(selectedRoom);
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
        );
      case 'Ward Room':
        return Scrollbar(
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
                            selectedRoom = (index + 1).toString();
                            print(selectedRoom);
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
        );
      case 'VIP Room':
        return Scrollbar(
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
                            selectedRoom = (index + 1).toString();
                            print(selectedRoom);
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
        );
      case 'ICU':
        return Scrollbar(
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
                            selectedRoom = (index + 1).toString();
                            print(selectedRoom);
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
        );
      default:
        return Container(); // Empty by default
    }
  }
}
