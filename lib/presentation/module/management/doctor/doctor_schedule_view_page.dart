import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class DayPickerScreen extends StatefulWidget {
  @override
  _DayPickerScreenState createState() => _DayPickerScreenState();
}

class _DayPickerScreenState extends State<DayPickerScreen> {
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  String? selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose a Day",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Day",
                      prefixIcon:
                          Icon(Icons.calendar_today, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                    ),
                    value: selectedDay,
                    items: days.map((day) {
                      return DropdownMenuItem(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedOpacity(
                      opacity: selectedDay == null ? 0.6 : 1,
                      duration: Duration(milliseconds: 300),
                      child: ElevatedButton.icon(
                        onPressed: selectedDay == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorSchedulePage(
                                        documentId: selectedDay!),
                                  ),
                                );
                              },
                        icon: Icon(Icons.schedule, color: Colors.white),
                        label: Text(
                          "View Schedule",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 8,
                          shadowColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ).copyWith(
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered))
                                return Colors.blue.shade700;
                              if (states.contains(MaterialState.pressed))
                                return Colors.blue.shade800;
                              return null; // Defer to default
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DoctorSchedulePage extends StatelessWidget {
  final String documentId;

  DoctorSchedulePage({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          "$documentId Schedule",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 4,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctor_weekly_schedule')
            .doc(documentId)
            .snapshots(), // 👈 Real-time stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No data available for $documentId",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var schedules = data['schedules'];

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3 / 2,
            ),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              var schedule = schedules[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditScheduleScreen(
                        documentId: documentId,
                        scheduleIndex: index,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.person, color: Colors.blue, size: 28),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          schedule['doctor'] ?? 'Unknown Doctor',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          schedule['specialization'] ?? 'Specialization: N/A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          "Morning: ${schedule['morning_in'] ?? 'No time'} - ${schedule['morning_out'] ?? 'No time'}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Evening: ${schedule['evening_in'] ?? 'No time'} - ${schedule['evening_out'] ?? 'No time'}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      )

    );
  }
}
// edit_schedule_screen.dart

class EditScheduleScreen extends StatefulWidget {
  final String documentId;
  final int scheduleIndex;

  EditScheduleScreen({required this.documentId, required this.scheduleIndex});

  @override
  _EditScheduleScreenState createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  TextEditingController doctorController = TextEditingController();
  TextEditingController specializationController = TextEditingController();
  TextEditingController morningInController = TextEditingController();
  TextEditingController morningOutController = TextEditingController();
  TextEditingController eveningInController = TextEditingController();
  TextEditingController eveningOutController = TextEditingController();

  List<String> doctors = []; // To store fetched doctor names
  Map<String, String> doctorSpecializations =
  {}; // To store doctor-specialization map
  String? selectedDoctor; // Selected doctor for the dropdown
  String selectedSpecialization = ''; // Declare selectedSpecialization

  @override
  void initState() {
    super.initState();
    fetchDoctors(); // Fetch doctors from Firestore
    loadScheduleData(); // Load existing schedule data from Firestore
  }

  // Fetch doctors and their specializations from Firestore
  void fetchDoctors() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('employees').get();

    List<String> fetchedDoctors = [];
    Map<String, String> tempSpecializations =
    {}; // Temporary map to store specializations

    for (var doc in snapshot.docs) {
      if (doc['roles'] == 'Doctor') {
        final name = doc['firstName'];
        final specialization = doc['specialization'] ?? 'Not Available';

        if (!fetchedDoctors.contains(name)) {
          fetchedDoctors.add(name);
        }

        tempSpecializations[name] = specialization;
      }
    }

    setState(() {
      doctors = fetchedDoctors;
      doctorSpecializations = tempSpecializations;
      // Set the default selected doctor if not already set
      if (doctors.isNotEmpty && selectedDoctor == null) {
        selectedDoctor = doctors[0];
        specializationController.text =
            doctorSpecializations[selectedDoctor] ?? '';
      }
    });

    print("Doctors: $doctors");
    print("Specializations: $doctorSpecializations");
  }

  // Load existing schedule data for the selected doctor
  Future<void> loadScheduleData() async {
    var doc = await FirebaseFirestore.instance
        .collection('doctor_weekly_schedule')
        .doc(widget.documentId)
        .get();

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      var schedule = data['schedules'][widget.scheduleIndex];

      doctorController.text = schedule['doctor'];
      morningInController.text = schedule['morning_in'];
      morningOutController.text = schedule['morning_out'];
      eveningInController.text = schedule['evening_in'];
      eveningOutController.text = schedule['evening_out'];

      // Set the selected doctor and its specialization
      setState(() {
        selectedDoctor = schedule['doctor'];
        selectedSpecialization = doctorSpecializations[selectedDoctor ?? ''] ?? '';  // Update selectedSpecialization
        specializationController.text = selectedSpecialization;
      });
    }
  }

  // Save the updated schedule back to Firestore
  Future<void> saveChanges() async {
    var docRef = FirebaseFirestore.instance
        .collection('doctor_weekly_schedule')
        .doc(widget.documentId);

    var snapshot = await docRef.get();
    var data = snapshot.data() as Map<String, dynamic>;
    List schedules = List.from(data['schedules']);

    schedules[widget.scheduleIndex] = {
      'doctor': selectedDoctor,
      'specialization': selectedSpecialization,  // Use selectedSpecialization
      'morning_in': morningInController.text,
      'morning_out': morningOutController.text,
      'evening_in': eveningInController.text,
      'evening_out': eveningOutController.text,
    };

    await docRef.update({'schedules': schedules});
    Navigator.pop(context);
  }

  @override
  void dispose() {
    doctorController.dispose();
    specializationController.dispose();
    morningInController.dispose();
    morningOutController.dispose();
    eveningInController.dispose();
    eveningOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text("Edit Schedule", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 6,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    doctors.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : DropdownSearch<String>(
                      items: doctors, // List of doctors
                      selectedItem: selectedDoctor,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select Doctor",
                          prefixIcon: Icon(Icons.person, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.blue.shade50,
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true, // Enable search box
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: "Search Doctor",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedDoctor = value;
                          selectedSpecialization =
                              doctorSpecializations[selectedDoctor ?? ''] ?? '';
                          specializationController.text = selectedSpecialization;  // Update the specialization
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: specializationController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Specialization",
                        prefixIcon: Icon(Icons.medical_services, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTimePickerField(
                      context,
                      controller: morningInController,
                      label: "Morning In",
                      icon: Icons.wb_sunny,
                    ),
                    const SizedBox(height: 12),

                    _buildTimePickerField(
                      context,
                      controller: morningOutController,
                      label: "Morning Out",
                      icon: Icons.wb_sunny_outlined,
                    ),
                    const SizedBox(height: 12),

                    _buildTimePickerField(
                      context,
                      controller: eveningInController,
                      label: "Evening In",
                      icon: Icons.nights_stay,
                    ),
                    const SizedBox(height: 12),

                    _buildTimePickerField(
                      context,
                      controller: eveningOutController,
                      label: "Evening Out",
                      icon: Icons.nights_stay_outlined,
                    ),
                    const SizedBox(height: 30),

                    Center(
                      child: SizedBox(
                        width: 220,
                        child: ElevatedButton.icon(
                          onPressed: saveChanges,
                          icon: Icon(Icons.save, color: Colors.white),
                          label: Text("Save Changes", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable time picker field
  Widget _buildTimePickerField(BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => _selectTime(context, controller),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.none,
        ),
      ),
    );
  }
}

// Create a reusable time field widget:
    Widget _buildTimePickerField(BuildContext context, {
      required TextEditingController controller,
      required String label,
      required IconData icon,
    }) {
      return GestureDetector(
        onTap: () => _selectTime(context, controller),
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.none,
          ),
        ),
      );
    }



  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      String formattedTime =
          pickedTime.format(context); // Format the time as HH:mm
      controller.text = formattedTime;
    }
  }

