import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/refreshLoading/refreshLoading.dart';
import 'package:lottie/lottie.dart';

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                      label: 'Update',
                      onPressed: () {
                        _showConfirmationDialog();
                      },
                      width: screenWidth * 0.17),
                  CustomButton(
                      label: 'Set',
                      onPressed: () {
                     _showSetConfirmationDialog();

                      },
                      width: screenWidth * 0.17),
              //    Spacer(),
                  CustomButton(
                    label: 'Refresh',
                    onPressed: () async {
                      RefreshLoading(
                        context: context,
                        task: () async => await fetchInitialRoomData(),
                      );
                    },
                      width: screenWidth * 0.17
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// Inside your _TotalRoomUpdateState class:
  bool _isLoading = false;

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Update'),
        content: const Text('Are you sure you want to update the room details?'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startUpdateProcess();
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Yes, Update',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          )


        ],
      ),
    );
  }

  void _startUpdateProcess() async {
    setState(() {
      _isLoading = true;
    });

    // Optional: Show a non-dismissible loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Lottie.asset('assets/login_lottie.json'), // Ensure this file exists
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2)); // simulate API delay
    await updateRooms(); // your real function

    Navigator.of(context).pop(); // dismiss loading dialog

    setState(() {
      _isLoading = false;
    });

    clearController();

    // Optional: show a confirmation SnackBar
    CustomSnackBar(context,
        message: 'Room Updated Successfully', backgroundColor: Colors.green);
  }
  void _showSetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Set'),
        content: const Text('Are you sure you want to set the room details?'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                 _startSetProcess();
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Yes, Set',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          )


        ],
      ),
    );
  }
  void _startSetProcess() async {
    setState(() {
      _isLoading = true;
    });

    // Optional: Show a non-dismissible loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Lottie.asset('assets/login_lottie.json'), // Ensure this file exists
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2)); // simulate API delay
    await    setRooms(); // your real function

    Navigator.of(context).pop(); // dismiss loading dialog

    setState(() {
      _isLoading = false;
    });

    clearController();

    // Optional: show a confirmation SnackBar
    CustomSnackBar(context,
        message: 'Room  Details Set Successfully', backgroundColor: Colors.green);
  }
}
