// import 'package:flutter/material.dart';
// import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
// import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
// import 'package:iconsax/iconsax.dart';
// import 'admission_status.dart';
// import 'ip_admission.dart';
// import 'ip_patients_admission.dart';
// import 'op_counters.dart';
// import 'op_ticket.dart';
//
// class doctorSchedule extends StatefulWidget {
//   const doctorSchedule({super.key});
//
//   @override
//   State<doctorSchedule> createState() => _doctorScheduleState();
// }
//
// class _doctorScheduleState extends State<doctorSchedule> {
//   int selectedIndex = 6;
//
//   @override
//   Widget build(BuildContext context) {
//     // Get the screen width using MediaQuery
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isMobile = screenWidth < 600;
//     double x = screenWidth / 1.2;
//
//     return Scaffold(
//       appBar: isMobile
//           ? AppBar(
//               title: const Text(
//                 'Reception Dashboard',
//                 style: TextStyle(
//                   fontFamily: 'SanFrancisco',
//                 ),
//               ),
//             )
//           : null, // No AppBar for web view
//       drawer: isMobile
//           ? Drawer(
//               child: buildDrawerContent(), // Drawer minimized for mobile
//             )
//           : null, // No drawer for web view (permanently open)
//       body: Row(
//         children: [
//           if (!isMobile)
//             Container(
//               width: 300, // Fixed width for the sidebar
//               color: Colors.blue.shade100,
//               child: buildDrawerContent(), // Sidebar always open for web view
//             ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: dashboard(),
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
//         const DrawerHeader(
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
//         buildDrawerItem(0, 'Patient Registration', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => PatientRegistration(),
//             ),
//           );
//         }, Iconsax.mask),
//         const Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(1, 'OP Ticket', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => OpTicketPage(),
//             ),
//           );
//         }, Iconsax.receipt),
//         const Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(2, 'IP Admission', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => IpAdmissionPage(),
//             ),
//           );
//         }, Iconsax.add_circle),
//         const Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(3, 'OP Counters', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => const OpCounters(),
//             ),
//           );
//         }, Iconsax.square),
//         const Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(4, 'Admission Status', () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => AdmissionStatus(),
//             ),
//           );
//         }, Iconsax.status),
//         const Divider(
//           height: 5,
//           color: Colors.grey,
//         ),
//         buildDrawerItem(5, 'Doctor Visit Schedule', () {}, Iconsax.hospital),
//         const Divider(
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
//   // Helper method to build drawer items with the ability to highlight the selected item
//   Widget buildDrawerItem(
//       int index, String title, VoidCallback onTap, IconData icon) {
//     return ListTile(
//       selected: selectedIndex == index,
//       selectedTileColor:
//           Colors.blueAccent.shade100, // Highlight color for the selected item
//       leading: Icon(
//         icon, // Replace with actual icons
//         color: selectedIndex == index ? Colors.blue : Colors.white,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//             fontFamily: 'SanFrancisco',
//             color: selectedIndex == index ? Colors.blue : Colors.black54,
//             fontWeight: FontWeight.w700),
//       ),
//       onTap: () {
//         setState(() {
//           selectedIndex = index; // Update the selected index
//         });
//         onTap();
//       },
//     );
//   }
//
//   // The form displayed in the body
//   Widget dashboard() {
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isMobile = screenWidth < 600;
//
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Align(
//         alignment: isMobile
//             ? Alignment.center
//             : Alignment.topLeft, // Align top-left for web, center for mobile
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Todays Doctor Schedule',
//               style: TextStyle(
//                   fontFamily: 'SanFrancisco',
//                   fontSize: 18,
//                   fontWeight: FontWeight.normal),
//             ),
//
//             const SizedBox(
//               height: 20,
//             ),
//             const Row(
//               children: [
//                 Text(
//                   'Counter 1 :',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(width: 65),
//                 SizedBox(
//                   width: 200,
//                   child: CustomTextField(
//                     hintText: 'Enter Counter Number',
//                     width: null,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Text(
//                     'Doctor Name :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 65),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter Doctor Name',
//                       width: null,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Text(
//                     'Speciality :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter Speciality',
//                       width: null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Text(
//                     'OP Intime :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 65),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter time in',
//                       width: null,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Text(
//                     'OP Outtime :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter to time',
//                       width: null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SizedBox(
//               width: 700,
//               child: Divider(
//                 color: Colors.grey, // Color of the divider
//                 thickness: 2, // Thickness of the line
//                 indent: 0, // Indent from the start (left side)
//                 endIndent: 0, // Indent from the end (right side)
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             const SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Text(
//                     'Counter 2 :',
//                     style: TextStyle(
//                         fontFamily: 'SanFrancisco',
//                         fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(width: 65),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter Counter Number',
//                       width: null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Text(
//                     'Doctor Name :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 65),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter Doctor Name',
//                       width: null,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Text(
//                     'Speciality :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter Speciality',
//                       width: null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Text(
//                     'OP Intime :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 65),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter time in',
//                       width: null,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Text(
//                     'OP Outtime :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter to time',
//                       width: null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SizedBox(
//               width: 700,
//               child: Divider(
//                 color: Colors.grey, // Color of the divider
//                 thickness: 2, // Thickness of the line
//                 indent: 0, // Indent from the start (left side)
//                 endIndent: 0, // Indent from the end (right side)
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Text(
//                     'Counter 3 :',
//                     style: TextStyle(
//                         fontFamily: 'SanFrancisco',
//                         fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(width: 65),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter Counter Number',
//                       width: null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Text(
//                     'Doctor Name :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 65),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter Doctor Name',
//                       width: null,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Text(
//                     'Speciality :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter Speciality',
//                       width: null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Text(
//                     'OP Intime :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 65),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter time in',
//                       width: null,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Text(
//                     'OP Outtime :',
//                     style: TextStyle(
//                       fontFamily: 'SanFrancisco',
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   SizedBox(
//                     width: 200,
//                     child: CustomTextField(
//                       hintText: 'Enter to time',
//                       width: null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(
//               height: 20,
//             ),
//
//             const SizedBox(
//               width: 700,
//               child: Divider(
//                 color: Colors.grey, // Color of the divider
//                 thickness: 2, // Thickness of the line
//                 indent: 0, // Indent from the start (left side)
//                 endIndent: 0, // Indent from the end (right side)
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.vertical, // Enable vertical scrolling
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal, // Enable horizontal scrolling
//                 child: SizedBox(
//                   width: 800,
//                   child: DataTable(
//                     columnSpacing: 20.0, // Add space between columns
//                     dataRowHeight: 140.0, // Increase the height of each row
//                     columns: [
//                       const DataColumn(
//                           label: Text(
//                         'Day',
//                         style: TextStyle(
//                             fontFamily: 'SanFrancisco',
//                             fontWeight: FontWeight.bold),
//                       )),
//                       const DataColumn(
//                           label: Text(
//                         'Counter 1',
//                         style: TextStyle(
//                             fontFamily: 'SanFrancisco',
//                             fontWeight: FontWeight.bold),
//                       )),
//                       const DataColumn(
//                           label: Text(
//                         'Counter 2',
//                         style: TextStyle(
//                             fontFamily: 'SanFrancisco',
//                             fontWeight: FontWeight.bold),
//                       )),
//                       const DataColumn(
//                           label: Text(
//                         'Counter 3',
//                         style: TextStyle(
//                             fontFamily: 'SanFrancisco',
//                             fontWeight: FontWeight.bold),
//                       )),
//                     ],
//                     rows: [
//                       createRow('Monday'),
//                       createRow('Tuesday'),
//                       createRow('Wednesday'),
//                       createRow('Thursday'),
//                       createRow('Friday'),
//                       createRow('Saturday'),
//                       createRow('Sunday'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Add other form fields or content below
//           ],
//         ),
//       ),
//     );
//   }
//
//   DataRow createRow(String day) {
//     return DataRow(
//       cells: [
//         DataCell(Padding(
//           padding: const EdgeInsets.symmetric(
//               vertical: 20.0), // Add vertical padding
//           child: Text(day),
//         )),
//         DataCell(Padding(
//           padding: const EdgeInsets.symmetric(
//               vertical: 20.0), // Add vertical padding
//           child: ScheduleInput(),
//         )), // First Counter
//         DataCell(Padding(
//           padding: const EdgeInsets.symmetric(
//               vertical: 20.0), // Add vertical padding
//           child: ScheduleInput(),
//         )), // Second Counter
//         DataCell(Padding(
//           padding: const EdgeInsets.symmetric(
//               vertical: 20.0), // Add vertical padding
//           child: ScheduleInput(),
//         )), // Third Counter
//       ],
//     );
//   }
// }
//
// class ScheduleInput extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const SizedBox(
//       height: 350, // Reduced height
//       child: Column(
//         children: [
//           SizedBox(
//             height: 30, // Reduced size for each field
//             child: CustomTextField(
//               hintText: 'Doctor Name',
//               width: null,
//             ),
//           ),
//           SizedBox(height: 4),
//           SizedBox(
//               height: 30, // Reduced size for each field
//               child: CustomTextField(
//                 hintText: 'Specialist',
//                 width: null,
//               )),
//           SizedBox(height: 4),
//           Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 30, // Reduced height for input fields
//                   child: CustomTextField(
//                     hintText: 'In Time',
//                     width: null,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 4),
//               Expanded(
//                 child: SizedBox(
//                   height: 30, // Reduced height for input fields
//                   child: CustomTextField(
//                     hintText: 'Out Time',
//                     width: null,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
