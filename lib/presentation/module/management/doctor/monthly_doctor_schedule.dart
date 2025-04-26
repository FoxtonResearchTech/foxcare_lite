import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../../../utilities/widgets/drawer/management/doctor/management_doctor_schedule.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/text/primary_text.dart';

class MonthlyDoctorSchedule extends StatefulWidget {
  const MonthlyDoctorSchedule({super.key});

  @override
  State<MonthlyDoctorSchedule> createState() => _MonthlyDoctorScheduleState();
}

class _MonthlyDoctorScheduleState extends State<MonthlyDoctorSchedule> {
  List<Map<String, dynamic>> schedules = [];
  int selectedIndex = 3;

  List<Map<String, String>> doctorList = [
    {"name": "Dr. Aisha Khan", "specialization": "Cardiologist"},
    {"name": "Dr. Ravi Patel", "specialization": "Dermatologist"},
    {"name": "Dr. Susan Lee", "specialization": "Neurologist"},
    {"name": "Dr. Arjun Menon", "specialization": "Pediatrician"},
  ];

  void _addSchedule(DateTime selectedDate) {
    setState(() {
      schedules.add({
        'date': selectedDate,
        'doctorName': '', // Default empty string
        'specialization': '',
        'fromTimeMorning': TimeOfDay.now(),
        'toTimeMorning': TimeOfDay.now(),
        'fromTimeEvening': TimeOfDay.now(),
        'toTimeEvening': TimeOfDay.now(),
      });
    });
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      _addSchedule(pickedDate);
    }
  }

  Future<void> _selectTime(int index, String key) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: schedules[index][key],
    );

    if (picked != null) {
      setState(() {
        schedules[index][key] = picked;
      });
    }
  }

  Future<void> _selectTimeEvening(int index, String key) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: schedules[index][key],
    );

    if (picked != null) {
      setState(() {
        schedules[index][key] = picked;
      });
    }
  }

  String? selectedDoctor;
  String specialization = '';
  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Map<String, List<String>> selectedDoctors = {};
  Map<String, String> doctorSpecializations = {};
  List<String> doctors = [];
  void fetchDoctors() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('employees').get();

    List<String> fetchedDoctors = [];

    for (var doc in snapshot.docs) {
      if (doc['roles'] == 'Doctor') {
        final firstName = doc['firstName'] ?? '';
        final lastName = doc['lastName'] ?? '';
        final doctorName = '$firstName $lastName';
        final specialization = doc['specialization'] ?? 'Not Available';

        if (!fetchedDoctors.contains(doctorName)) {
          fetchedDoctors.add(doctorName);
        }

        doctorSpecializations[doctorName] = specialization;
      }
    }

    setState(() {
      doctors = fetchedDoctors;
    });

    print("Doctors: $doctors");
    print("Specializations: $doctorSpecializations");
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
      body: Padding(
        padding: const EdgeInsets.all(12),
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
                        text: "Monthly Doctor Schedule",
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
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      image: const DecorationImage(
                          image: AssetImage('assets/foxcare_lite_logo.png'))),
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
              onPressed: _selectDate,
              icon: const Icon(Icons.date_range),
              label: const Text(
                "Select Date to Add Doctor",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: schedules.isEmpty
                  ? const Center(
                      child: Text(
                        "No schedules added yet.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        String? selectedDoctor = schedule['doctor'];
                        String specialization = selectedDoctor != null
                            ? (doctorList.firstWhere(
                                  (doc) => doc['name'] == selectedDoctor,
                                  orElse: () =>
                                      {'specialization': 'Not Available'},
                                )['specialization'] ??
                                'Not Available')
                            : '';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date + Close button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "📅 ${schedule['date'].toLocal().toString().split(' ')[0]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        setState(() {
                                          schedules.removeAt(index);
                                        });
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Doctor Dropdown
                                DropdownSearch<String>(
                                  items: doctors,
                                  selectedItem: selectedDoctor,
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: "Select Doctor",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Search Doctor",
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      schedules[index]['doctorName'] = value;
                                      schedules[index]['specialization'] =
                                          doctorSpecializations[value!] ??
                                              'Not Available';
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Specialization Display
                                TextField(
                                  controller: TextEditingController(
                                    text: schedule['specialization'] ?? "",
                                  ),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "Specialization",
                                    prefixIcon:
                                        const Icon(Icons.local_hospital),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Time Buttons Row
                                // MORNING OP
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 8.0, left: 4),
                                      child: Text(
                                        "Morning OP",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // FROM MORNING
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => _selectTime(
                                                index, 'fromTimeMorning'),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: _buildTimeCard(
                                                "From",
                                                schedules[index]
                                                    ['fromTimeMorning'],
                                                context),
                                          ),
                                        ),
                                        // TO MORNING
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => _selectTime(
                                                index, 'toTimeMorning'),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: _buildTimeCard(
                                                "To",
                                                schedules[index]
                                                    ['toTimeMorning'],
                                                context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

// EVENING OP
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 8.0, left: 4),
                                      child: Text(
                                        "Evening OP",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // FROM EVENING
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => _selectTime(
                                                index, 'fromTimeEvening'),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: _buildTimeCard(
                                                "From",
                                                schedules[index]
                                                    ['fromTimeEvening'],
                                                context),
                                          ),
                                        ),
                                        // TO EVENING
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => _selectTime(
                                                index, 'toTimeEvening'),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: _buildTimeCard(
                                                "To",
                                                schedules[index]
                                                    ['toTimeEvening'],
                                                context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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
              child: FloatingActionButton.extended(
                onPressed: () => confirmAndDeleteCollection(context),
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
                label: const Text(
                  "Delete All",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 💾 Save Button
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
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
              child: FloatingActionButton.extended(
                onPressed: _saveSchedules,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(
                  Icons.save_alt_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  "Save All",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(String label, TimeOfDay time, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF90CAF9), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            "$label: ${time.format(context)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  void _saveSchedules() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final scheduleCollection = firestore.collection('doctorSchedulesMonthly');

      for (var schedule in schedules) {
        await scheduleCollection.add({
          'date': schedule['date'].toIso8601String(),
          'doctorName': schedule['doctorName'],
          'specialization': schedule['specialization'],
          'fromTimeMorning': schedule['fromTimeMorning'].format(context),
          'toTimeMorning': schedule['toTimeMorning'].format(context),
          'fromTimeEvening': schedule['fromTimeEvening'].format(context),
          'toTimeEvening': schedule['toTimeEvening'].format(context),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedules saved to Firestore ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e")),
      );
    }
  }

  void confirmAndDeleteCollection(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text(
            "Are you sure you want to delete the entire schedule collection? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      deleteEntireCollection();
    }
  }

  void deleteEntireCollection() async {
    try {
      final collectionRef =
          FirebaseFirestore.instance.collection('doctorSchedulesMonthly');
      final snapshot = await collectionRef.get();

      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('Entire collection deleted successfully');
    } catch (e) {
      print('Error deleting collection: $e');
    }
  }
}
