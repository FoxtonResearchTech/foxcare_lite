import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../utilities/widgets/drawer/management/doctor/management_doctor_schedule.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/text/primary_text.dart';

class DoctorWeeklySchedule extends StatefulWidget {
  @override
  _DoctorWeeklyScheduleState createState() => _DoctorWeeklyScheduleState();
}

class _DoctorWeeklyScheduleState extends State<DoctorWeeklySchedule> {
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  Map<String, List<String>> selectedDoctors = {};
  Map<String, String> doctorSpecializations = {};
  Map<String, Map<String, String?>> opTimeIn = {};
  Map<String, Map<String, String?>> opTimeOut = {};
  Map<String, Map<String, String?>> opTimeInEvening = {};
  Map<String, Map<String, String?>> opTimeOutEvening = {};
  int selectedIndex = 2;
  List<String> doctors = [];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

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

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(12),
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
                        text: "Doctor Weekly Schedule ",
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
                      image: AssetImage('assets/foxcare_lite_logo.png'),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  return _buildScheduleCard(days[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 200,
            height: 60,
            margin: EdgeInsets.only(bottom: 12),
            child: FloatingActionButton.extended(
              onPressed: () => confirmAndDeleteCollection(context),
              backgroundColor: Colors.red,
              label: Text(
                "Reset",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              icon: Icon(Icons.delete, size: 28, color: Colors.white),
              elevation: 10,
            ),
          ),
          Container(
            width: 200,
            height: 60,
            child: FloatingActionButton.extended(
              onPressed: saveScheduleToFirestore,
              backgroundColor: Colors.blue,
              label: Text(
                "Save",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              icon: Icon(Icons.save, size: 28, color: Colors.white),
              elevation: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(String day) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.blue.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  day,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900]),
                ),
              ),
              SizedBox(height: 8),
              _buildMultiSelectDoctor(day),
              SizedBox(height: 6),
              if ((selectedDoctors[day] ?? []).isNotEmpty)
                ...selectedDoctors[day]!.map((doctor) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      Text(
                        doctor,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800]),
                      ),
                      SizedBox(height: 4),
                      _buildSpecializationDisplay(doctor),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text("Morning In",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _buildTimeInput(day, doctor, true),
                            ],
                          ),
                          Column(
                            children: [
                              Text("Morning Out",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _buildTimeInput(day, doctor, false),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text("Evening In",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _buildTimeInput(day, doctor, true,
                                  isEvening: true),
                            ],
                          ),
                          Column(
                            children: [
                              Text("Evening Out",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _buildTimeInput(day, doctor, false,
                                  isEvening: true),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectDoctor(String day) {
    return ElevatedButton(
      onPressed: () async {
        final selected = await showDialog<List<String>>(
          context: context,
          builder: (context) {
            List<String> tempSelected = List.from(selectedDoctors[day] ?? []);
            String searchQuery = '';
            List<String> filteredDoctors = List.from(doctors);

            return StatefulBuilder(
              builder: (context, setStateDialog) {
                void filterDoctors(String query) {
                  setStateDialog(() {
                    searchQuery = query;
                    filteredDoctors = doctors
                        .where((doc) =>
                            doc.toLowerCase().contains(query.toLowerCase()))
                        .toList();
                  });
                }

                return AlertDialog(
                  title: Text("Select Doctor(s)"),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Search Doctor",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: filterDoctors,
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: filteredDoctors.map((doc) {
                                return CheckboxListTile(
                                  value: tempSelected.contains(doc),
                                  title: Text(doc),
                                  onChanged: (checked) {
                                    setStateDialog(() {
                                      if (checked == true) {
                                        tempSelected.add(doc);
                                      } else {
                                        tempSelected.remove(doc);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, tempSelected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 20, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            "OK",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );

        if (selected != null) {
          setState(() {
            selectedDoctors[day] = selected;

            for (var doc in selected) {
              opTimeIn[day] ??= {};
              opTimeOut[day] ??= {};
              opTimeIn[day]![doc] ??= null;
              opTimeOut[day]![doc] ??= null;
              opTimeInEvening[day] ??= {};
              opTimeOutEvening[day] ??= {};
              opTimeInEvening[day]![doc] ??= null;
              opTimeOutEvening[day]![doc] ??= null;
            }
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        "Doctor(s)",
        style: TextStyle(
          color: Colors.blue[900],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpecializationDisplay(String doctor) {
    final specialization = doctorSpecializations[doctor] ?? 'Not available';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.medical_services, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            '$specialization',
            style: TextStyle(fontSize: 16, color: Colors.blue[900]),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(String day, String doctor, bool isTimeIn,
      {bool isEvening = false}) {
    String _getTime() {
      if (isEvening) {
        return isTimeIn
            ? (opTimeInEvening[day]?[doctor] ?? "--:--")
            : (opTimeOutEvening[day]?[doctor] ?? "--:--");
      } else {
        return isTimeIn
            ? (opTimeIn[day]?[doctor] ?? "--:--")
            : (opTimeOut[day]?[doctor] ?? "--:--");
      }
    }

    void _setTime(String formattedTime) {
      setState(() {
        if (isEvening) {
          if (isTimeIn) {
            opTimeInEvening[day]?[doctor] = formattedTime;
          } else {
            opTimeOutEvening[day]?[doctor] = formattedTime;
          }
        } else {
          if (isTimeIn) {
            opTimeIn[day]?[doctor] = formattedTime;
          } else {
            opTimeOut[day]?[doctor] = formattedTime;
          }
        }
      });
    }

    return GestureDetector(
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          _setTime(pickedTime.format(context));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _getTime(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
      ),
    );
  }

  void saveScheduleToFirestore() async {
    final scheduleCollection =
        FirebaseFirestore.instance.collection('doctor_weekly_schedule');

    try {
      for (String day in selectedDoctors.keys) {
        List<Map<String, dynamic>> doctorSchedules = [];

        for (String doctor in selectedDoctors[day]!) {
          Map<String, dynamic> schedule = {
            'doctor': doctor,
            'specialization': doctorSpecializations[doctor] ?? 'Not available',
            'morning_in': opTimeIn[day]?[doctor] ?? '--:--',
            'morning_out': opTimeOut[day]?[doctor] ?? '--:--',
            'evening_in': opTimeInEvening[day]?[doctor] ?? '--:--',
            'evening_out': opTimeOutEvening[day]?[doctor] ?? '--:--',
          };
          doctorSchedules.add(schedule);
        }

        await scheduleCollection.doc(day).set({
          'day': day,
          'schedules': doctorSchedules,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Schedule saved successfully!")),
      );
    } catch (e) {
      print("Error saving schedule: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save schedule. Try again.")),
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
          FirebaseFirestore.instance.collection('doctor_weekly_schedule');
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
