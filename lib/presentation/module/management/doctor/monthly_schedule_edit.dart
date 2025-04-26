import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/widgets/drawer/management/doctor/management_doctor_schedule.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/text/primary_text.dart';

class MonthlyScheduleEdit extends StatefulWidget {
  const MonthlyScheduleEdit({super.key});

  @override
  State<MonthlyScheduleEdit> createState() => _MonthlyScheduleEdit();
}

class _MonthlyScheduleEdit extends State<MonthlyScheduleEdit> {
  final TextEditingController searchDate = TextEditingController();
  final TextEditingController specialization = TextEditingController();
  List<Map<String, dynamic>> monthlySchedules = [];

  int selectedIndex = 5;
  Map<String, String> doctorSpecializationMap = {};
  List<String> doctorNames = [];
  String? selectedDoctor;

  final TextEditingController doctorName = TextEditingController();

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm').format(
        DateTime(
            now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
      );
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  Future<void> fetchDoctorSchedules(String dateString) async {
    try {
      String formattedInputDate =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(dateString));
      String firestoreDate = formattedInputDate +
          "T00:00:00.000"; // Add the time part to match Firestore format

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('doctorSchedulesMonthly')
          .where('date', isEqualTo: firestoreDate)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No documents found for this date');
      } else {
        print('Found ${snapshot.docs.length} schedules');
      }

      final List<Map<String, dynamic>> schedules = snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();

      setState(() {
        monthlySchedules = schedules;
      });

      for (var schedule in schedules) {
        print('Schedule: $schedule');
      }
    } catch (e) {
      print('Error fetching schedules: $e');
    }
  }

  Future<void> fetchDoctorAndSpecialization() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      QuerySnapshot<Map<String, dynamic>> doctorsSnapshot =
          await FirebaseFirestore.instance
              .collection('employees')
              .where('roles', isEqualTo: 'Doctor')
              .get();

      if (doctorsSnapshot.docs.isNotEmpty) {
        doctorSpecializationMap.clear();
        doctorNames.clear();

        for (var doc in doctorsSnapshot.docs) {
          final data = doc.data();
          final doctor = data['firstName'] + ' ' + data['lastName'] ?? '';
          final spec = data['specialization'] ?? '';

          if (doctor.isNotEmpty) {
            doctorSpecializationMap[doctor] = spec;
            doctorNames.add(doctor);
          }
        }

        // Set default selected doctor and specialization
        final defaultDoctor = doctorNames.first;
        setState(() {
          selectedDoctor = defaultDoctor;
          doctorName.text = defaultDoctor;
          specialization.text = doctorSpecializationMap[defaultDoctor] ?? '';
        });
      } else {
        setState(() {
          doctorNames.clear();
          selectedDoctor = '';
          doctorName.text = '';
          specialization.text = '';
        });
      }
    } catch (e) {
      print('Error fetching doctors: $e');
    }
  }

  void _editSchedule(BuildContext context, Map<String, dynamic> schedule) {
    TextEditingController doctorController =
        TextEditingController(text: schedule['doctorName']);
    TextEditingController fromTimeController =
        TextEditingController(text: schedule['fromTimeMorning']);
    TextEditingController toTimeController =
        TextEditingController(text: schedule['toTimeMorning']);
    TextEditingController eveningFromTimeController =
        TextEditingController(text: schedule['fromTimeEvening']);
    TextEditingController eveningToTimeController =
        TextEditingController(text: schedule['toTimeEvening']);
    TextEditingController specializationController =
        TextEditingController(text: schedule['specialization']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Schedule"),
          content: Container(
            width: 300,
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use CustomDropdown for doctor selection
                SizedBox(
                  width: 250,
                  child: CustomDropdown(
                    label: "Doctor",
                    items: doctorNames,
                    selectedItem: doctorController.text,
                    onChanged: (value) {
                      setState(() {
                        doctorController.text = value!;
                        specializationController.text =
                            doctorSpecializationMap[value] ?? '';
                      });
                    },
                  ),
                ),
                CustomTextField(
                  controller: specializationController,
                  hintText: 'Specialization',
                  width: 250,
                  readOnly: true,
                ),
                CustomTextField(
                  hintText: '',
                  controller: fromTimeController,
                  icon: Icon(Icons.access_time_filled_outlined),
                  onTap: () async {
                    await _selectTime(context, fromTimeController);
                  },
                  width: 250,
                ),
                CustomTextField(
                  hintText: '',
                  controller: toTimeController,
                  icon: Icon(Icons.access_time_filled_outlined),
                  onTap: () async {
                    await _selectTime(context, toTimeController);
                  },
                  width: 250,
                ),
                CustomTextField(
                  hintText: '',
                  controller: eveningFromTimeController,
                  icon: Icon(Icons.access_time_filled_outlined),
                  onTap: () async {
                    await _selectTime(context, eveningFromTimeController);
                  },
                  width: 250,
                ),
                CustomTextField(
                  hintText: '',
                  controller: eveningToTimeController,
                  icon: Icon(Icons.access_time_filled_outlined),
                  onTap: () async {
                    await _selectTime(context, eveningToTimeController);
                  },
                  width: 250,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('doctorSchedulesMonthly')
                      .doc(schedule['id'])
                      .update({
                    'doctorName': doctorController.text,
                    'fromTimeMorning': fromTimeController.text,
                    'toTimeMorning': toTimeController.text,
                    'fromTimeEvening': eveningFromTimeController.text,
                    'toTimeEvening': eveningToTimeController.text,
                    'specialization': specializationController.text,
                  });
                  fetchDoctorSchedules(searchDate.text);
                  CustomSnackBar(context,
                      message: 'Monthly Schedule Updated',
                      backgroundColor: Colors.green);
                  Navigator.of(context).pop();
                } catch (e) {
                  CustomSnackBar(context,
                      message: 'Failed To Update Monthly Schedule',
                      backgroundColor: Colors.red);

                  print('Error updating schedule: $e');
                }
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchDoctorAndSpecialization();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const CustomText(
                text: 'General Information',
              ),
            )
          : null, // No AppBar for web view
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
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
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
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.07),
                          child: Column(
                            children: [
                              CustomText(
                                text: "Monthly Doctor Schedule Edit ",
                                size: screenWidth * .015,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.15,
                          height: screenWidth * 0.15,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.05),
                              image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/foxcare_lite_logo.png'))),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        fixedSize: const Size.fromHeight(
                            56), // Set only height, let width adapt
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        print('Button pressed');
                        await _selectDate(context, searchDate);
                        print(
                            'Selected Date: ${searchDate.text}'); // Check what date is selected

                        if (searchDate.text.isNotEmpty) {
                          await fetchDoctorSchedules(searchDate.text);
                        }
                      },
                      icon: const Icon(Icons.date_range),
                      label: const Text(
                        "Select Date ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true, // Add this line
                      physics:
                          NeverScrollableScrollPhysics(), // Disable grid scroll
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: monthlySchedules.length,
                      itemBuilder: (context, index) {
                        final doctor = monthlySchedules[index];
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
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white),
                                        onPressed: () {
                                          _editSchedule(context, doctor);
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    doctor['doctorName'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    doctor['specialization'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            doctor['fromTimeMorning'] ?? '-',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            doctor['toTimeMorning'] ?? '-',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            doctor['fromTimeEvening'] ?? '-',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            doctor['toTimeEvening'] ?? '-',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 🗑️ Delete Button
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
