import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/wardRoomInformation/ward_rooms.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../utilities/widgets/drawer/management/ward_room_information/ward_room_drawer.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../generalInformation/general_information_admission_status.dart';
import 'new_ward_rooms.dart';

class DeleteWardRooms extends StatefulWidget {
  @override
  State<DeleteWardRooms> createState() => _DeleteWardRooms();
}

class _DeleteWardRooms extends State<DeleteWardRooms> {
  int selectedIndex = 2;
  final TextEditingController _startIndexController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  String? selectedRoomType;
  final Map<String, String> roomTypeMap = {
    'Room': 'roomStatus',
    'Ward': 'wardStatus',
    'VIP Room': 'viproomStatus',
    'ICU': 'ICUStatus',
  };

  Future<void> disableRooms({
    required String roomType,
    required int startRoomNumber,
    int count = 1,
  }) async {
    final docRef =
        FirebaseFirestore.instance.collection('totalRoom').doc('status');
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      CustomSnackBar(context,
          message: 'Room data not found.', backgroundColor: Colors.red);
      return;
    }

    List<dynamic> roomList = List.from(docSnap[roomType] ?? []);
    int startIndex = startRoomNumber - 1;

    if (startIndex < 0 || startIndex >= roomList.length) {
      CustomSnackBar(context,
          message: 'Invalid room number.', backgroundColor: Colors.red);
      return;
    }

    int endIndex = (startIndex + count).clamp(0, roomList.length);

    for (int i = startIndex; i < endIndex; i++) {
      roomList[i] = "disabled";
    }

    await docRef.update({roomType: roomList});

    CustomSnackBar(context,
        message: "Room(s) disabled successfully.",
        backgroundColor: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
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

  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.25,
          ),
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
                          text: " Delete Rooms",
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
              SizedBox(height: screenHeight * 0.04),
              CustomDropdown(
                  label: '',
                  items: const [
                    'Room',
                    'Ward',
                    'VIP Room',
                    'ICU',
                  ],
                  onChanged: (value) {
                    selectedRoomType = value;
                  }),
              SizedBox(height: screenHeight * 0.04),
              CustomTextField(
                controller: _startIndexController,
                hintText: ' Room No to Disable',
                width: screenWidth * 0.25,
                verticalSize: screenHeight * 0.02,
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomTextField(
                controller: _countController,
                hintText: 'No of Rooms to Disable',
                width: screenWidth * 0.25,
                verticalSize: screenHeight * 0.02,
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomButton(
                  label: 'Disable',
                  onPressed: () async {
                    int startIndex =
                        int.tryParse(_startIndexController.text) ?? 0;
                    int count = int.tryParse(_countController.text) ?? 1;
                    await disableRooms(
                      roomType: roomTypeMap[selectedRoomType]!,
                      startRoomNumber: startIndex,
                      count: count,
                    );
                  },
                  width: screenWidth * 0.25)
            ],
          ),
        ),
      ),
    );
  }
}
