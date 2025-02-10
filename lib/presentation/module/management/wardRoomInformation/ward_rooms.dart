import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/colors.dart';

import 'package:iconsax/iconsax.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../utilities/widgets/text/primary_text.dart';
import '../generalInformation/general_information_admission_status.dart';
import 'delete_ward_rooms.dart';
import 'new_ward_rooms.dart';

class WardRooms extends StatefulWidget {
  @override
  State<WardRooms> createState() => _WardRooms();
}

class _WardRooms extends State<WardRooms> {
  // To store the index of the selected drawer item
  bool isFetchingRoomData = false;
  int selectedIndex = 0;
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();
  List<bool> roomStatus = [];
  List<bool> wardStatus = [];
  List<bool> viproomStatus = [];
  List<bool> ICUStatus = [];
  Future<void> fetchRoomData() async {
    try {
      setState(() {
        isFetchingRoomData = true;
      });

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
        setState(() {
          isFetchingRoomData = false;
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
    fetchRoomData();
    super.initState();
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
            child: dashboard(),
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
        buildDrawerItem(0, 'Ward / Rooms', () {}, Iconsax.mask),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'New Ward / Rooms', () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NewWardRooms()));
        }, Iconsax.receipt),
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
        child: Container(
            padding: EdgeInsets.only(
              top: screenHeight * 0.01,
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
            ),
            child: isFetchingRoomData
                ? Center(
                    child: Container(
                        padding: EdgeInsets.only(top: screenHeight * 0.47),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          backgroundColor: AppColors.secondaryColor,
                        )))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: screenHeight * 0.25),
                      Scrollbar(
                        controller:
                            _scrollController, // Attach the ScrollController
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
                                runSpacing:
                                    10, // Vertical spacing between rooms
                                children:
                                    List.generate(roomStatus.length, (index) {
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
                                          borderRadius:
                                              BorderRadius.circular(2),
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
                                        ;
                                      },
                                      onDoubleTap: () {},
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
                                runSpacing:
                                    10, // Vertical spacing between rooms
                                children:
                                    List.generate(wardStatus.length, (index) {
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
                                          borderRadius:
                                              BorderRadius.circular(2),
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
                                      onDoubleTap: () {},
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
                                runSpacing:
                                    10, // Vertical spacing between rooms
                                children: List.generate(viproomStatus.length,
                                    (index) {
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
                                          borderRadius:
                                              BorderRadius.circular(2),
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
                                      onTap: () {},
                                      onDoubleTap: () {},
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
                                runSpacing:
                                    10, // Vertical spacing between rooms
                                children:
                                    List.generate(ICUStatus.length, (index) {
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
                                          borderRadius:
                                              BorderRadius.circular(2),
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
                                      onTap: () {},
                                      onDoubleTap: () {},
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
                  )),
      ),
    );
  }
}
