import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

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
    super.initState();
  }

  int selectedIndex = 1;

  String? selectedDoctor;
  String? selectedSpecification;
  String? selectedDegree;

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
  bool isLoading = false;
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

  Map<String, String> doctorSpecializations = {};
  Map<String, String> doctorDegree = {};
  void fetchDoctors() async {
    final employeesSnapshot =
        await FirebaseFirestore.instance.collection('employees').get();

    for (var doc in employeesSnapshot.docs) {
      if (doc['roles'] == 'Doctor') {
        final firstName = doc['firstName'] ?? '';
        final lastName = doc['lastName'] ?? '';
        final doctorName = '$firstName $lastName';
        final specialization = doc['specialization'] ?? '';
        final qualification =
            doc['qualification'] as Map<String, dynamic>? ?? {};

        final ug = qualification['ug'] as Map<String, dynamic>? ?? {};
        final pg = qualification['pg'] as Map<String, dynamic>?;

        final ugDegree = ug['degree'] ?? '';
        final pgDegree = pg != null ? (pg['degree'] ?? '') : null;
        final degree = pgDegree?.isNotEmpty == true
            ? ugDegree + ', ' + pgDegree!
            : ugDegree;

        if (!doctors.contains(doctorName)) {
          setState(() {
            doctors.add(doctorName);
            doctorSpecializations[doctorName] = specialization;
            doctorDegree[doctorName] = degree;
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
  final TextEditingController degreeController = TextEditingController();

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
                    padding: EdgeInsets.only(top: screenWidth * 0.03),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Doctor Daily Schedule ",
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
                    selectedDegree = doctorDegree[value] ?? '';
                    degreeController.text = selectedDegree!;
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
                child: isLoading
                    ? SizedBox(
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.05,
                        child: Lottie.asset(
                          'assets/button_loading.json', // Ensure the file path is correct
                          fit: BoxFit.contain,
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          await saveSchedule();
                        },
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
              SizedBox(height: screenHeight * 0.07)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveSchedule() async {
    setState(() {
      isLoading = true;
    });

    if (selectedDoctor == null || selectedCounter == null) {
      CustomSnackBar(context,
          message: 'Please Fill All The Fields',
          backgroundColor: Colors.orange);
      setState(() => isLoading = false);
      return;
    }

    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now); // e.g., '2025-04-07'

    final collection =
        FirebaseFirestore.instance.collection('doctorSchedulesDaily');

    try {
      final duplicateQuery = await collection
          .where('counter', isEqualTo: selectedCounter)
          .where('date', isEqualTo: today)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        CustomSnackBar(context,
            message: 'Schedule for this counter already exists today',
            backgroundColor: Colors.redAccent);
        setState(() => isLoading = false);
        return;
      }

      final snapshot = await collection.get();
      bool hasOldData = snapshot.docs.any((doc) => doc['date'] != today);

      if (hasOldData) {
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      final scheduleData = {
        'doctor': selectedDoctor,
        'specialization': selectedSpecialization ?? '',
        'morningOpIn': opTime?.format(context),
        'morningOpOut': outTime?.format(context),
        'eveningOpIn': opTimeAfternoon?.format(context) ?? '',
        'eveningOpOut': outTimeAfternoon?.format(context) ?? '',
        'counter': selectedCounter,
        'createdAt': FieldValue.serverTimestamp(),
        'degree': selectedDegree,
        'date': today,
      };

      await collection.add(scheduleData);

      CustomSnackBar(context,
          message: 'Schedule Added Successfully',
          backgroundColor: Colors.green);

      // 🧹 Reset form state
      setState(() {
        selectedDoctor = null;
        selectedSpecialization = null;
        opTime = null;
        outTime = null;
        opTimeAfternoon = null;
        outTimeAfternoon = null;
        specializationController.clear();
        isLoading = false;
      });
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed To Save', backgroundColor: Colors.red);
      setState(() => isLoading = false);
    }
  }
}
