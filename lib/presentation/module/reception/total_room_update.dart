import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';

import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class TotalRoomUpdate extends StatefulWidget {
  const TotalRoomUpdate({super.key});

  @override
  State<TotalRoomUpdate> createState() => _TotalRoomUpdateState();
}

class _TotalRoomUpdateState extends State<TotalRoomUpdate> {
  // Controllers for user input
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
        SnackBar(content: Text('Room status document not found.')),
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
      SnackBar(content: Text('Room data updated successfully!')),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: CustomText(
            text: 'Total Rooms',
            color: Colors.white,
            size: screenWidth * 0.02,
          ),
        ),
        backgroundColor: AppColors.blue,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.3,
            right: screenWidth * 0.04,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomButton(
                      label: 'Update',
                      onPressed: () {
                        updateRooms();
                        clearController();
                      },
                      width: screenWidth * 0.17),
                  CustomButton(
                      label: 'Set',
                      onPressed: () {
                        setRooms();
                        clearController();
                      },
                      width: screenWidth * 0.17),
                  SizedBox(width: screenWidth * 0.23),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
