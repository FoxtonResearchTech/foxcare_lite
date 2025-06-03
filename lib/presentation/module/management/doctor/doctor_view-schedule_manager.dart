import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/add_schedule.dart';
import 'package:lottie/lottie.dart';
import '../../../../utilities/widgets/drawer/management/doctor/management_doctor_schedule.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/text/primary_text.dart';

class DoctorScheduleViewManager extends StatefulWidget {
  @override
  State<DoctorScheduleViewManager> createState() =>
      _DoctorScheduleViewManagerState();
}

class _DoctorScheduleViewManagerState extends State<DoctorScheduleViewManager> {
  int selectedIndex = 0;
  List<Map<String, dynamic>> doctors = [];

  final String formattedDate = DateFormat('d MMMM, y').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchDoctorSchedules();
  }

  Future<void> fetchDoctorSchedules() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('doctorSchedulesDaily')
          .get();

      final List<Map<String, dynamic>> fetchedDoctors =
          snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'doctor': data['doctor'] ?? 'Unknown',
          'counter': data['counter'] ?? '0',
          'specialization': data['specialization'] ?? 'Unknown',
          'morningOpIn': data['morningOpIn'] ?? 'N/A',
          'morningOpOut': data['morningOpOut'] ?? 'N/A',
          'eveningOpIn': data['eveningOpIn'] ?? 'N/A',
          'eveningOpOut': data['eveningOpOut'] ?? 'N/A',
          'date': data['date'] ?? 'N/A',
        };
      }).toList();

      setState(() {
        doctors = fetchedDoctors;
      });
    } catch (e) {
      print('Error fetching doctor schedules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const CustomText(text: 'General Information'),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: ManagementDoctorSchedule(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300,
              color: Colors.blue.shade100,
              child: ManagementDoctorSchedule(
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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.03),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Doctor View Schedule Manager ",
                          size: screenWidth * .025,
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
                        image: AssetImage('assets/foxcare_lite_logo.png'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Today's Doctor Schedule",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 4;
                  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

// Filter doctors for today
                  final todayDoctors = doctors.where((doctor) {
                    final dateStr = doctor['date'];
                    if (dateStr == null) return false;

                    try {
                      final doctorDate = DateFormat('yyyy-MM-dd')
                          .format(DateTime.parse(dateStr));
                      return doctorDate == today;
                    } catch (e) {
                      return false;
                    }
                  }).toList();

// Show message if no data
                  if (todayDoctors.isEmpty) {
                    return Center(
                      child: Lottie.asset("assets/no_data.json",
                          height: 500, width: 500),
                    );
                  }
                  return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: doctors.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.6,
                      ),
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];

                        return Card(
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.lightBlueAccent
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0, right: 30.0, top: 12, bottom: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      doctor['counter'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                    ),
                                  ),
                                  const SizedBox(height: 24.0),
                                  Text(
                                    doctor['doctor'],
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    doctor['specialization'],
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Morning In',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            height: screenWidth * 0.006,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              doctor['morningOpIn'],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: screenWidth * 0.0275),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Morning Out',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            height: screenWidth * 0.006,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              doctor['morningOpOut'],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Evening In',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            height: screenWidth * 0.006,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              doctor['eveningOpIn'],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: screenWidth * 0.0275),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Evening Out',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            height: screenWidth * 0.006,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              doctor['eveningOpOut'],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: Padding(
      //   padding: EdgeInsets.only(bottom: screenHeight * 0.05),
      //   child: SpeedDial(
      //     animatedIcon: AnimatedIcons.menu_close,
      //     iconTheme: const IconThemeData(color: Colors.white),
      //     backgroundColor: Colors.blue,
      //     foregroundColor: Colors.white,
      //     children: [
      //       SpeedDialChild(
      //         child: const Icon(Icons.calendar_today, color: Colors.white),
      //         backgroundColor: Colors.green,
      //         label: 'Daily Schedule',
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //                 builder: (context) => const AddDoctorSchedule()),
      //           );
      //         },
      //       ),
      //       SpeedDialChild(
      //         child: const Icon(Icons.calendar_view_week, color: Colors.white),
      //         backgroundColor: Colors.orange,
      //         label: 'Weekly Schedule',
      //         onTap: () {
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             const SnackBar(content: Text('Weekly Schedule Selected')),
      //           );
      //         },
      //       ),
      //       SpeedDialChild(
      //         child: const Icon(Icons.calendar_month, color: Colors.white),
      //         backgroundColor: Colors.purple,
      //         label: 'Monthly Schedule',
      //         onTap: () {
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             const SnackBar(content: Text('Monthly Schedule Selected')),
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
