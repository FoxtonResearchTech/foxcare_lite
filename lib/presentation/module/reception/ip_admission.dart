// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
// import 'package:foxcare_lite/presentation/module/reception/total_room_update.dart';
// import 'package:foxcare_lite/utilities/colors.dart';
// import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
// import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
// import 'package:iconsax/iconsax.dart';
// import '../../../utilities/widgets/buttons/primary_button.dart';
// import 'admission_status.dart';
// import 'doctor_schedule.dart';
// import 'ip_patients_admission.dart';
// import 'op_counters.dart';
// import 'op_ticket.dart';
//
// class IpAdmissionPage extends StatefulWidget {
//   @override
//   State<IpAdmissionPage> createState() => _IpAdmissionPageState();
// }
//
// class _IpAdmissionPageState extends State<IpAdmissionPage> {
//   TimeOfDay now = TimeOfDay.now();
//   final date = DateTime.timestamp();
//   String SelectedRoom = 'Room';
//   String vacantRoom = '1';
//   String nursingStation = 'Station A';
//
//   // List of room statuses (true = booked, false = available)
//   List<String> roomStatus = [];
//   List<String> wardStatus = [];
//   List<String> viproomStatus = [];
//   List<String> ICUStatus = [];
//   int selectedIndex1 = 2;
//
//   //String selectedSex = 'Male'; // Default value for Sex
//   String selectedBloodGroup = 'A+'; // Default value for Blood Group
//
//   bool isSearchPerformed = false; // To track if search has been performed
//   Map<String, String>? selectedPatient;
//   ScrollController _scrollController = ScrollController();
//   ScrollController _scrollController1 = ScrollController();
//   ScrollController _scrollController2 = ScrollController();
//   ScrollController _scrollController3 = ScrollController();
//
//   bool isDataLoaded = false; // To control data loading when button is clicked
//   List<Map<String, dynamic>> patientData = []; // Patient data
//   int? selectedIndex; // Store selected checkbox index
//
//   Future<void> fetchRoomData() async {
//     try {
//       DocumentSnapshot doc = await FirebaseFirestore.instance
//           .collection('totalRoom')
//           .doc('status')
//           .get();
//
//       if (doc.exists) {
//         setState(() {
//           roomStatus = List<String>.from(doc['roomStatus']);
//           wardStatus = List<String>.from(doc['wardStatus']);
//           viproomStatus = List<String>.from(doc['viproomStatus']);
//           ICUStatus = List<String>.from(doc['ICUStatus']);
//         });
//       } else {
//         print("Document does not exist.");
//       }
//     } catch (e) {
//       print("Error fetching data: $e");
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchRoomData();
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isMobile = screenWidth < 600;
//
//     return Scaffold(
//       appBar: isMobile
//           ? AppBar(
//               title: Text(
//                 'OP Ticket Dashboard',
//                 style: TextStyle(
//                   fontFamily: 'SanFrancisco',
//                 ),
//               ),
//             )
//           : null,
//       drawer: isMobile
//           ? Drawer(
//               child: buildDrawerContent(), // Drawer minimized for mobile
//             )
//           : null, // No AppBar for web view
//       body: Row(
//         children: [
//           if (!isMobile)
//             Container(
//               width: 300, // Sidebar width for larger screens
//               color: Colors.blue.shade100,
//               child: buildDrawerContent(), // Sidebar content
//             ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(16.0),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   if (constraints.maxWidth > 600) {
//                     return buildThreeColumnForm(); // Web view
//                   } else {
//                     return buildSingleColumnForm(); // Mobile view
//                   }
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildDrawerContent() {
//     return ListView(
//       padding: EdgeInsets.zero,
//       children: [
//         DrawerHeader(
//           decoration: BoxDecoration(
//             color: Colors.blue,
//           ),
//           child: Text(
//             'Reception',
//             style: TextStyle(
//               fontFamily: 'SanFrancisco',
//               color: Colors.white,
//               fontSize: 24,
//             ),
//           ),
//         ),
//         // Drawer items here
//         buildDrawerItem(0, 'Patient Registration', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => PatientRegistration()),
//           );
//         }, Iconsax.mask),
//         Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(1, 'OP Ticket', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => OpTicketPage()),
//           );
//         }, Iconsax.receipt),
//         Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(2, 'IP Admission', () {}, Iconsax.add_circle),
//         Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(3, 'OP Counters', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => OpCounters()),
//           );
//         }, Iconsax.square),
//         Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(4, 'Admission Status', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => AdmissionStatus()),
//           );
//         }, Iconsax.status),
//         Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(5, 'Doctor Visit Schedule', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => doctorSchedule()),
//           );
//         }, Iconsax.hospital),
//
//         Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(6, 'Ip Patients Admission', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => IpPatientsAdmission()),
//           );
//         }, Icons.approval),
//         const Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(7, 'Logout', () {
//           // Handle logout action
//         }, Iconsax.logout),
//       ],
//     );
//   }
//
//   Widget buildDrawerItem(
//       int index, String title, VoidCallback onTap, IconData icon) {
//     return ListTile(
//       selected: selectedIndex1 == index,
//       selectedTileColor: Colors.blueAccent.shade100,
//       // Highlight color for the selected item
//       leading: Icon(
//         icon, // Replace with actual icons
//         color: selectedIndex1 == index ? Colors.blue : Colors.white,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//             fontFamily: 'SanFrancisco',
//             color: selectedIndex1 == index ? Colors.blue : Colors.black54,
//             fontWeight: FontWeight.w700),
//       ),
//       onTap: () {
//         setState(() {
//           selectedIndex1 = index; // Update the selected index
//         });
//         onTap();
//       },
//     );
//   }
//
//   Widget buildThreeColumnForm() {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//
//     bool isMobile = screenWidth < 600;
//     return Align(
//       alignment: isMobile ? Alignment.center : Alignment.topLeft,
//       // Align top-left for web, center for mobile
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Text(
//             'IP Admission Portal :',
//             style: TextStyle(
//                 fontFamily: 'SanFrancisco',
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold),
//           ),
//           SizedBox(
//             height: 30,
//           ),
//           Row(
//             children: [
//               Text(
//                 'Rooms / Ward Availability',
//                 style: TextStyle(
//                     fontFamily: 'SanFrancisco',
//                     fontSize: 18,
//                     fontWeight: FontWeight.normal),
//               ),
//               SizedBox(width: screenWidth * 0.5),
//               CustomButton(
//                 label: 'Total Rooms',
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => TotalRoomUpdate()));
//                 },
//                 width: screenWidth * 0.1,
//                 height: screenHeight * 0.038,
//               )
//             ],
//           ),
//           SizedBox(
//             height: 15,
//           ),
//           Scrollbar(
//             controller: _scrollController, // Attach the ScrollController
//             thumbVisibility: true,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               controller: _scrollController,
//               child: Row(
//                 children: [
//                   Text(
//                     'Rooms : ',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(
//                     width: 30,
//                   ),
//                   Wrap(
//                     spacing: 10, // Horizontal spacing between rooms
//                     runSpacing: 10, // Vertical spacing between rooms
//                     children: List.generate(roomStatus.length, (index) {
//                       return GestureDetector(
//                         onTap: (roomStatus[index] == "booked" ||
//                                 roomStatus[index] == "available")
//                             ? null
//                             : () {
//                                 // Handle booking or toggling logic
//                               },
//                         child: InkWell(
//                           child: Container(
//                             width: 50,
//                             // Set a fixed width for each room box
//                             height: 60,
//                             // Set a fixed height for each room box
//                             decoration: BoxDecoration(
//                               color: roomStatus[index] == 'booked'
//                                   ? AppColors.blue
//                                   : roomStatus[index] == 'available'
//                                       ? AppColors.lightBlue
//                                       : AppColors.roomDisabled,
//                               // Red for booked, green for available
//                               borderRadius: BorderRadius.circular(2),
//                               //border: Border.all(color: Colors.black, width: 1),
//                             ),
//                             alignment: Alignment.center,
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '${index + 1}',
//                                   style: TextStyle(
//                                     fontFamily: 'SanFrancisco',
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.bed_sharp,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           onTap: () {
//                             if (roomStatus[index] != 'disabled') {
//                               setState(() {
//                                 roomStatus[index] = 'booked';
//                               });
//                               print('${index + 1} pressed');
//                             }
//                           },
//                           onDoubleTap: () {
//                             if (roomStatus[index] != 'disabled') {
//                               setState(() {
//                                 roomStatus[index] = 'available';
//                               });
//                             }
//                           },
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Scrollbar(
//             thumbVisibility: true,
//             controller: _scrollController1,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               controller: _scrollController1,
//               child: Row(
//                 children: [
//                   Text(
//                     'Wards : ',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(
//                     width: 30,
//                   ),
//                   Wrap(
//                     spacing: 10, // Horizontal spacing between rooms
//                     runSpacing: 10, // Vertical spacing between rooms
//                     children: List.generate(wardStatus.length, (index) {
//                       return GestureDetector(
//                         onTap: wardStatus[index]
//                             ? null // Disable interaction if the room is booked
//                             : () {
//                                 // Optional: Add booking functionality here if needed
//                                 // setState to toggle room status or handle booking logic
//                               },
//                         child: InkWell(
//                           child: Container(
//                             width: 50,
//                             // Set a fixed width for each room box
//                             height: 60,
//                             // Set a fixed height for each room box
//                             decoration: BoxDecoration(
//                               color: wardStatus[index]
//                                   ? AppColors.blue
//                                   : AppColors.lightBlue,
//                               // Red for booked, green for available
//                               borderRadius: BorderRadius.circular(2),
//                               //border: Border.all(color: Colors.black, width: 1),
//                             ),
//                             alignment: Alignment.center,
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '${index + 1}',
//                                   style: TextStyle(
//                                     fontFamily: 'SanFrancisco',
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.bed_sharp,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           onTap: () {
//                             if (wardStatus[index] != 'disabled') {
//                               setState(() {
//                                 wardStatus[index] = 'booked';
//                               });
//                               print('${index + 1} pressed');
//                             }
//                           },
//                           onDoubleTap: () {
//                             if (wardStatus[index] != 'disabled') {
//                               setState(() {
//                                 wardStatus[index] = 'available';
//                               });
//                             }
//                           },
//
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Scrollbar(
//             thumbVisibility: true,
//             controller: _scrollController2,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               controller: _scrollController2,
//               child: Row(
//                 children: [
//                   Text(
//                     'VIP Rooms : ',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   Wrap(
//                     spacing: 10, // Horizontal spacing between rooms
//                     runSpacing: 10, // Vertical spacing between rooms
//                     children: List.generate(viproomStatus.length, (index) {
//                       return GestureDetector(
//                         onTap: viproomStatus[index]
//                             ? null // Disable interaction if the room is booked
//                             : () {
//                                 // Optional: Add booking functionality here if needed
//                                 // setState to toggle room status or handle booking logic
//                               },
//                         child: InkWell(
//                           child: Container(
//                             width: 50,
//                             // Set a fixed width for each room box
//                             height: 60,
//                             // Set a fixed height for each room box
//                             decoration: BoxDecoration(
//                               color: viproomStatus[index]
//                                   ? Colors.green[200]
//                                   : Colors.grey,
//                               // Red for booked, green for available
//                               borderRadius: BorderRadius.circular(2),
//                               //border: Border.all(color: Colors.black, width: 1),
//                             ),
//                             alignment: Alignment.center,
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '${index + 1}',
//                                   style: TextStyle(
//                                     fontFamily: 'SanFrancisco',
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.bed_sharp,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           onTap: () {
//                             if (viproomStatus[index] != 'disabled') {
//                               setState(() {
//                                 viproomStatus[index] = 'booked';
//                               });
//                               print('${index + 1} pressed');
//                             }
//                           },
//                           onDoubleTap: () {
//                             if (viproomStatus[index] != 'disabled') {
//                               setState(() {
//                                 viproomStatus[index] = 'available';
//                               });
//                             }
//                           },
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Scrollbar(
//             thumbVisibility: true,
//             controller: _scrollController3,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               controller: _scrollController3,
//               child: Row(
//                 children: [
//                   Text(
//                     'ICU : ',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(
//                     width: 45,
//                   ),
//                   Wrap(
//                     spacing: 10, // Horizontal spacing between rooms
//                     runSpacing: 10, // Vertical spacing between rooms
//                     children: List.generate(ICUStatus.length, (index) {
//                       return GestureDetector(
//                         onTap: ICUStatus[index]
//                             ? null // Disable interaction if the room is booked
//                             : () {
//                                 // Optional: Add booking functionality here if needed
//                                 // setState to toggle room status or handle booking logic
//                               },
//                         child: InkWell(
//                           child: Container(
//                             width: 50,
//                             // Set a fixed width for each room box
//                             height: 60,
//                             // Set a fixed height for each room box
//                             decoration: BoxDecoration(
//                               color: ICUStatus[index]
//                                   ? Colors.green[200]
//                                   : Colors.grey,
//                               // Red for booked, green for available
//                               borderRadius: BorderRadius.circular(2),
//                               //border: Border.all(color: Colors.black, width: 1),
//                             ),
//                             alignment: Alignment.center,
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '${index + 1}',
//                                   style: TextStyle(
//                                     fontFamily: 'SanFrancisco',
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.bed_sharp,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           onTap: () {
//                             if (ICUStatus[index] != 'disabled') {
//                               setState(() {
//                                 ICUStatus[index] = 'booked';
//                               });
//                               print('${index + 1} pressed');
//                             }
//                           },
//                           onDoubleTap: () {
//                             if (ICUStatus[index] != 'disabled') {
//                               setState(() {
//                                 ICUStatus[index] = 'available';
//                               });
//                             }
//                           },
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// }
