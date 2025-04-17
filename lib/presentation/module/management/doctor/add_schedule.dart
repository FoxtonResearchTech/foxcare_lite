import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/widgets/drawer/management/doctor/management_doctor_schedule.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/text/primary_text.dart';

class AddDoctorSchedule extends StatefulWidget {
  const AddDoctorSchedule({super.key});

  @override
  State<AddDoctorSchedule> createState() => _AddDoctorScheduleState();
}

class _AddDoctorScheduleState extends State<AddDoctorSchedule> {
  @override
  void initState() {
    fetchDoctors();
    // TODO: implement initState
    super.initState();
  }

  int selectedIndex = 1;

  String? selectedDoctor;
  String? selectedSpecification;
  String? selectedCounter;
  TimeOfDay? opTime;
  TimeOfDay? outTime;
  TimeOfDay? opTimeAfternoon;
  TimeOfDay? outTimeAfternoon;

  List<String> doctors = [];
  final List<String> specifications = [
    'Cardiologist',
    'Dentist',
    'Neurologist'
  ];
  String? selectedSpecialization;
  final List<String> counterValues =
      List.generate(5, (index) => (index + 1).toString());

  Future<void> _selectTime(BuildContext context, bool isOpTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOpTime) {
          opTime = picked;
        } else {
          outTime = picked;
        }
      });
    }
  }

  Future<void> _selectTimeAfternoon(BuildContext context, bool isOpTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOpTime) {
          opTimeAfternoon = picked;
        } else {
          outTimeAfternoon = picked;
        }
      });
    }
  }

  Map<String, String> doctorSpecializations =
      {}; // {doctorName: specialization}
  void fetchDoctors() async {
    final employeesSnapshot =
        await FirebaseFirestore.instance.collection('employees').get();

    for (var doc in employeesSnapshot.docs) {
      if (doc['roles'] == 'Doctor') {
        final firstName = doc['firstName'] ?? '';
        final lastName = doc['lastName'] ?? '';
        final doctorName = '$firstName $lastName';
        final specialization = doc['specialization'] ?? '';

        if (!doctors.contains(doctorName)) {
          setState(() {
            doctors.add(doctorName);
            doctorSpecializations[doctorName] = specialization;
          });
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      print('Doctors: $doctors');
      print('Specializations: $doctorSpecializations');
    });
  }

  final TextEditingController specializationController =
      TextEditingController();

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

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          text: "Doctor Daily Schedule ",
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
              const Center(
                child: Text(
                  'Add Doctor Schedule',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 30),

// Inside your build method:
              DropdownSearch<String>(
                items: doctors,
                selectedItem: selectedDoctor,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: const InputDecoration(
                    labelText: 'Select Doctor',
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                onChanged: (value) {
                  setState(() {
                    selectedDoctor = value;
                    selectedSpecialization =
                        doctorSpecializations[value!] ?? '';
                    specializationController.text = selectedSpecialization!;
                  });
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: specializationController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Morning OP',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Time In',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 250, // ✅ Increased width
                        child: InkWell(
                          onTap: () => _selectTime(context, true),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  opTime == null
                                      ? 'OP Time In'
                                      : opTime!.format(context),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Time Out',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 250, // ✅ Increased width
                        child: InkWell(
                          onTap: () => _selectTime(context, false),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  outTime == null
                                      ? 'OP Time Out'
                                      : outTime!.format(context),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Evening OP',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Time In',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 250, // ✅ Increased width
                        child: InkWell(
                          onTap: () => _selectTimeAfternoon(context, true),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  opTimeAfternoon == null
                                      ? 'OP Time In'
                                      : opTimeAfternoon!.format(context),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Time Out',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 250, // ✅ Increased width
                        child: InkWell(
                          onTap: () => _selectTimeAfternoon(context, false),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  outTimeAfternoon == null
                                      ? 'OP Time Out'
                                      : outTimeAfternoon!.format(context),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Counter',
                  border: OutlineInputBorder(),
                ),
                value: selectedCounter,
                items: counterValues.map((count) {
                  return DropdownMenuItem<String>(
                    value: count,
                    child: Text(count, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedCounter = value),
              ),
              const SizedBox(height: 30),
              Center(
                child: InkWell(
                  onTap: saveSchedule,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                        // Blue gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Create Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveSchedule() async {
    if (selectedDoctor == null ||
        opTime == null ||
        outTime == null ||
        selectedCounter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now); // '2025-04-07'

    final scheduleData = {
      'doctor': selectedDoctor,
      'specialization': selectedSpecialization ?? '',
      'morningOpIn': opTime!.format(context),
      'morningOpOut': outTime!.format(context),
      'eveningOpIn': opTimeAfternoon?.format(context) ?? '',
      'eveningOpOut': outTimeAfternoon?.format(context) ?? '',
      'counter': selectedCounter,
      'createdAt': FieldValue.serverTimestamp(),
      'date': today, // 🔥 Add date field
    };

    try {
      final collection =
          FirebaseFirestore.instance.collection('doctorSchedulesDaily');

      // Step 1: Check if all docs are from today
      final snapshot = await collection.get();
      bool hasOldData = snapshot.docs.any((doc) => doc['date'] != today);

      // Step 2: If old data exists, delete all docs
      if (hasOldData) {
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Step 3: Add new schedule
      await collection.add(scheduleData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule added successfully!')),
      );

      setState(() {
        selectedDoctor = null;
        selectedSpecialization = null;
        opTime = null;
        outTime = null;
        opTimeAfternoon = null;
        outTimeAfternoon = null;
        specializationController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }
}
