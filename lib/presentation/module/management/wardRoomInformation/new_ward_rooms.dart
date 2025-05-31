import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/wardRoomInformation/ward_rooms.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/ward_room_information/ward_room_drawer.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../generalInformation/general_information_admission_status.dart';
import 'delete_ward_rooms.dart';

class NewWardRooms extends StatefulWidget {
  @override
  State<NewWardRooms> createState() => _NewWardRooms();
}

class _NewWardRooms extends State<NewWardRooms> {
  int selectedIndex = 1;
  final TextEditingController _totalRoomsController = TextEditingController();
  final TextEditingController _bookedRoomsController = TextEditingController();

  final TextEditingController _totalWardsController = TextEditingController();
  final TextEditingController _bookedWardsController = TextEditingController();

  final TextEditingController _totalVipRoomsController =
      TextEditingController();
  final TextEditingController _bookedVipRoomsController =
      TextEditingController();

  final TextEditingController _totalICUController = TextEditingController();
  final TextEditingController _bookedICUController = TextEditingController();

  List<String> generateRoomStatus(int total, int booked) {
    return List.generate(
        total, (index) => index < booked ? "booked" : "available");
  }

  Future<void> updateRooms() async {
    int totalRooms = int.tryParse(_totalRoomsController.text) ?? 0;
    int bookedRooms = int.tryParse(_bookedRoomsController.text) ?? 0;

    int totalWards = int.tryParse(_totalWardsController.text) ?? 0;
    int bookedWards = int.tryParse(_bookedWardsController.text) ?? 0;

    int totalVipRooms = int.tryParse(_totalVipRoomsController.text) ?? 0;
    int bookedVipRooms = int.tryParse(_bookedVipRoomsController.text) ?? 0;

    int totalICU = int.tryParse(_totalICUController.text) ?? 0;
    int bookedICU = int.tryParse(_bookedICUController.text) ?? 0;

    DocumentReference docRef =
        FirebaseFirestore.instance.collection('totalRoom').doc('status');
    DocumentSnapshot docSnap = await docRef.get();

    if (!docSnap.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room status document not found.')),
      );
      return;
    }

    Map<String, dynamic> existingData = docSnap.data() as Map<String, dynamic>;

    List<String> updatedRoomStatus = [
      ...(existingData['roomStatus'] as List<dynamic>).cast<String>(),
      ...generateRoomStatus(totalRooms, bookedRooms),
    ];
    List<String> updatedWardStatus = [
      ...(existingData['wardStatus'] as List<dynamic>).cast<String>(),
      ...generateRoomStatus(totalWards, bookedWards),
    ];
    List<String> updatedVipRoomStatus = [
      ...(existingData['viproomStatus'] as List<dynamic>).cast<String>(),
      ...generateRoomStatus(totalVipRooms, bookedVipRooms),
    ];
    List<String> updatedICUStatus = [
      ...(existingData['ICUStatus'] as List<dynamic>).cast<String>(),
      ...generateRoomStatus(totalICU, bookedICU),
    ];

    await docRef.update({
      "roomStatus": updatedRoomStatus,
      "wardStatus": updatedWardStatus,
      "viproomStatus": updatedVipRoomStatus,
      "ICUStatus": updatedICUStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room data updated successfully!')),
    );
  }

  Future<void> setRooms() async {
    int totalRooms = int.tryParse(_totalRoomsController.text) ?? 0;
    int bookedRooms = int.tryParse(_bookedRoomsController.text) ?? 0;

    int totalWards = int.tryParse(_totalWardsController.text) ?? 0;
    int bookedWards = int.tryParse(_bookedWardsController.text) ?? 0;

    int totalVipRooms = int.tryParse(_totalVipRoomsController.text) ?? 0;
    int bookedVipRooms = int.tryParse(_bookedVipRoomsController.text) ?? 0;

    int totalICU = int.tryParse(_totalICUController.text) ?? 0;
    int bookedICU = int.tryParse(_bookedICUController.text) ?? 0;

    Map<String, dynamic> data = {
      "roomStatus": generateRoomStatus(totalRooms, bookedRooms),
      "wardStatus": generateRoomStatus(totalWards, bookedWards),
      "viproomStatus": generateRoomStatus(totalVipRooms, bookedVipRooms),
      "ICUStatus": generateRoomStatus(totalICU, bookedICU),
    };

    await FirebaseFirestore.instance
        .collection('totalRoom')
        .doc('status')
        .set(data);

    CustomSnackBar(context,
        message: 'Room Set Successfully', backgroundColor: Colors.green);
  }

  @override
  void initState() {
    super.initState();
    fetchInitialRoomData();
  }

  Future<void> fetchInitialRoomData() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('totalRoom').doc('status');
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final data = docSnap.data() as Map<String, dynamic>;

        List<String> roomStatus =
            (data['roomStatus'] as List<dynamic>).cast<String>();
        List<String> wardStatus =
            (data['wardStatus'] as List<dynamic>).cast<String>();
        List<String> vipRoomStatus =
            (data['viproomStatus'] as List<dynamic>).cast<String>();
        List<String> icuStatus =
            (data['ICUStatus'] as List<dynamic>).cast<String>();

        setState(() {
          _totalRoomsController.text = roomStatus.length.toString();
          _bookedRoomsController.text =
              roomStatus.where((s) => s == "booked").length.toString();

          _totalWardsController.text = wardStatus.length.toString();
          _bookedWardsController.text =
              wardStatus.where((s) => s == "booked").length.toString();

          _totalVipRoomsController.text = vipRoomStatus.length.toString();
          _bookedVipRoomsController.text =
              vipRoomStatus.where((s) => s == "booked").length.toString();

          _totalICUController.text = icuStatus.length.toString();
          _bookedICUController.text =
              icuStatus.where((s) => s == "booked").length.toString();
        });
      } else {
        print('Room data not found.');
      }
    } catch (e) {
      print('Error loading room data: $e');
    }
  }

  void clearController() {
    _totalRoomsController.clear();
    _bookedRoomsController.clear();
    _totalWardsController.clear();
    _bookedWardsController.clear();
    _totalVipRoomsController.clear();
    _bookedVipRoomsController.clear();
    _totalICUController.clear();
    _bookedICUController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const CustomText(
                text: 'Ward & Rooms Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: WardRoomDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: WardRoomDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
                        text: " New Ward Rooms",
                        size: screenWidth * 0.03,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth * 0.17,
                  height: screenWidth * 0.1,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      image: const DecorationImage(
                          image: AssetImage('assets/foxcare_lite_logo.png'))),
                ),
              ],
            ),
            Center(
              child: Container(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.1,
                  left: screenWidth * 0.17,
                  right: screenWidth * 0.04,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            CustomText(
                              text: "Rooms",
                              size: screenWidth * 0.016,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            CustomTextField(
                                hintText: 'Enter Total Rooms',
                                controller: _totalRoomsController,
                                width: screenWidth * 0.2),
                            SizedBox(height: screenHeight * 0.05),
                            CustomTextField(
                                hintText: 'Enter Booked Rooms',
                                controller: _bookedRoomsController,
                                width: screenWidth * 0.2),
                          ],
                        ),
                        SizedBox(width: screenHeight * 0.05),
                        Column(
                          children: [
                            CustomText(
                              text: "Wards",
                              size: screenWidth * 0.016,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            CustomTextField(
                                hintText: 'Enter Total Wards',
                                controller: _totalWardsController,
                                width: screenWidth * 0.2),
                            SizedBox(height: screenHeight * 0.05),
                            CustomTextField(
                                hintText: 'Enter Booked Wards',
                                controller: _bookedWardsController,
                                width: screenWidth * 0.2),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Row(
                      children: [
                        Column(
                          children: [
                            CustomText(
                              text: "VIP Rooms",
                              size: screenWidth * 0.016,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            CustomTextField(
                                hintText: 'Enter Total VIP Rooms',
                                controller: _totalVipRoomsController,
                                width: screenWidth * 0.2),
                            SizedBox(height: screenHeight * 0.05),
                            CustomTextField(
                                hintText: 'Enter Booked VIP Rooms',
                                controller: _bookedVipRoomsController,
                                width: screenWidth * 0.2),
                          ],
                        ),
                        SizedBox(width: screenHeight * 0.04),
                        Column(
                          children: [
                            CustomText(
                              text: "ICU",
                              size: screenWidth * 0.016,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            CustomTextField(
                                hintText: 'Enter Total ICU Rooms',
                                controller: _totalICUController,
                                width: screenWidth * 0.2),
                            SizedBox(height: screenHeight * 0.05),
                            CustomTextField(
                                hintText: 'Enter Booked ICU Rooms',
                                controller: _bookedICUController,
                                width: screenWidth * 0.2),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                            label: 'Update',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Confirmation'),
                                    ],
                                  ),
                                  content: const Text(
                                    'Are you sure you want to update room details?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        'Confirm',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await updateRooms();
                                clearController();
                              }
                            },
                            width: screenWidth * 0.17),
                        CustomButton(
                            label: 'Set',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Confirmation'),
                                    ],
                                  ),
                                  content: const Text(
                                    'Are you sure you want to set room details (This will overwrite the existing room data)?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        'Confirm',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await setRooms();
                                clearController();
                              }
                            },
                            width: screenWidth * 0.17),
                        SizedBox(width: screenWidth * 0.125),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
}
