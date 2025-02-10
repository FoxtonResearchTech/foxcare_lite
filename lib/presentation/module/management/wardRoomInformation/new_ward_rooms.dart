import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/wardRoomInformation/ward_rooms.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../generalInformation/general_information_admission_status.dart';
import 'delete_ward_rooms.dart';

class NewWardRooms extends StatefulWidget {
  @override
  State<NewWardRooms> createState() => _NewWardRooms();
}

class _NewWardRooms extends State<NewWardRooms> {
  // To store the index of the selected drawer item
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

  /// Generates a List<bool> based on total rooms and booked count
  List<bool> generateRoomStatus(int totalRooms, int bookedRooms) {
    bookedRooms = bookedRooms.clamp(0, totalRooms); // Ensure valid range
    return List.generate(totalRooms, (index) => index < bookedRooms);
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

    Map<String, dynamic> data = {
      "roomStatus": generateRoomStatus(totalRooms, bookedRooms),
      "wardStatus": generateRoomStatus(totalWards, bookedWards),
      "viproomStatus": generateRoomStatus(totalVipRooms, bookedVipRooms),
      "ICUStatus": generateRoomStatus(totalICU, bookedICU),
    };

    await FirebaseFirestore.instance
        .collection('totalRoom')
        .doc('status')
        .update(data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Room data updated successfully!')),
    );
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
              title: CustomText(
                text: 'Ward & Rooms Information',
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer content reused for both web and mobile
  Widget buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Ward & Rooms Information',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Ward / Rooms', () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => WardRooms()));
        }, Iconsax.mask),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'New Ward / Rooms', () {}, Iconsax.receipt),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(2, 'Delete Ward / Rooms', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DeleteWardRooms()));
        }, Iconsax.add_circle),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'Back To Management Dashboard', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ManagementDashboard()));
        }, Iconsax.backward),
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
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.only(
              top: screenHeight * 0.25,
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
                        CustomText(text: "Rooms"),
                        SizedBox(height: screenHeight * 0.01),
                        CustomTextField(
                            hintText: 'Enter Total Rooms',
                            controller: _totalRoomsController,
                            width: screenWidth * 0.2),
                        SizedBox(height: screenHeight * 0.01),
                        CustomTextField(
                            hintText: 'Enter Booked Rooms',
                            controller: _bookedRoomsController,
                            width: screenWidth * 0.2),
                      ],
                    ),
                    SizedBox(width: screenHeight * 0.05),
                    Column(
                      children: [
                        CustomText(text: "Wards"),
                        SizedBox(height: screenHeight * 0.01),
                        CustomTextField(
                            hintText: 'Enter Total Wards',
                            controller: _totalWardsController,
                            width: screenWidth * 0.2),
                        SizedBox(height: screenHeight * 0.01),
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
                        CustomText(text: "VIP Rooms"),
                        SizedBox(height: screenHeight * 0.01),
                        CustomTextField(
                            hintText: 'Enter Total VIP Rooms',
                            controller: _totalVipRoomsController,
                            width: screenWidth * 0.2),
                        SizedBox(height: screenHeight * 0.01),
                        CustomTextField(
                            hintText: 'Enter Booked VIP Rooms',
                            controller: _bookedVipRoomsController,
                            width: screenWidth * 0.2),
                      ],
                    ),
                    SizedBox(width: screenHeight * 0.04),
                    Column(
                      children: [
                        CustomText(text: "ICU"),
                        SizedBox(height: screenHeight * 0.01),
                        CustomTextField(
                            hintText: 'Enter Total ICU Rooms',
                            controller: _totalICUController,
                            width: screenWidth * 0.2),
                        SizedBox(height: screenHeight * 0.01),
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
                  children: [
                    SizedBox(width: screenHeight * 0.2),
                    CustomButton(
                        label: 'Update',
                        onPressed: () {
                          updateRooms();
                          clearController();
                        },
                        width: screenWidth * 0.2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
