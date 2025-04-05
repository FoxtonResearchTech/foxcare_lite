import 'package:flutter/material.dart';

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

  final List<String> doctors = [
    "Dr. John Doe",
    "Dr. Smith",
    "Dr. Emily",
    "Dr. Kevin",
    "Dr. Lisa",
    "Dr. Raj"
  ];

  final List<String> specializations = [
    "Cardiologist",
    "Dermatologist",
    "Neurologist",
    "Pediatrician",
    "ENT",
    "Orthopedic"
  ];

  Map<String, List<String>> selectedDoctors = {};
  Map<String, Map<String, List<String>>> doctorSpecializations = {};
  Map<String, Map<String, String?>> opTimeIn = {};
  Map<String, Map<String, String?>> opTimeOut = {};

  int selectedIndex = 5;

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
              child: ManagementGeneralInformationDrawer(
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
              child: ManagementGeneralInformationDrawer(
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
                          image: AssetImage('assets/foxcare_lite_logo.png'))),
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
      floatingActionButton: Container(
        width: 200,
        height: 60,
        child: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Schedule Saved Successfully!")),
            );
          },
          backgroundColor: Colors.blue,
          label: Text("Save",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          icon: Icon(Icons.save, size: 28, color: Colors.white),
          elevation: 10,
        ),
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
                      Text(doctor,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800])),
                      SizedBox(height: 4),
                      _buildSpecializationSelector(day, doctor),
                      SizedBox(height: 6),
                      Text("Specializations:"),
                      Wrap(
                        spacing: 4,
                        children: (doctorSpecializations[day]?[doctor] ?? [])
                            .map((spec) {
                          return Chip(
                              label: Text(spec),
                              backgroundColor: Colors.blue[100]);
                        }).toList(),
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text("Time In",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _buildTimeInput(day, doctor, true),
                            ],
                          ),
                          Column(
                            children: [
                              Text("Time Out",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _buildTimeInput(day, doctor, false),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text("Time In",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _buildTimeInput(day, doctor, true),
                            ],
                          ),
                          Column(
                            children: [
                              Text("Time Out",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _buildTimeInput(day, doctor, false),
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
            return AlertDialog(
              title: Text("Select Doctor(s)"),
              content: Container(
                width: double.minPositive,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: doctors.map((doc) {
                      return StatefulBuilder(
                        builder: (context, setStateDialog) {
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
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel")),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, tempSelected),
                    child: Text("OK")),
              ],
            );
          },
        );

        if (selected != null) {
          setState(() {
            selectedDoctors[day] = selected;
            for (var doc in selected) {
              doctorSpecializations[day] ??= {};
              doctorSpecializations[day]![doc] ??= [];

              opTimeIn[day] ??= {};
              opTimeIn[day]![doc] ??= null;

              opTimeOut[day] ??= {};
              opTimeOut[day]![doc] ??= null;
            }
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text("Doctor(s)",
          style:
              TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSpecializationSelector(String day, String doctor) {
    return ElevatedButton(
      onPressed: () async {
        final selected = await showDialog<List<String>>(
          context: context,
          builder: (context) {
            List<String> tempSelected =
                List.from(doctorSpecializations[day]?[doctor] ?? []);
            return AlertDialog(
              title: Text("Select Specialization(s) for $doctor"),
              content: SingleChildScrollView(
                child: Column(
                  children: specializations.map((spec) {
                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return CheckboxListTile(
                          value: tempSelected.contains(spec),
                          title: Text(spec),
                          onChanged: (checked) {
                            setStateDialog(() {
                              if (checked == true) {
                                tempSelected.add(spec);
                              } else {
                                tempSelected.remove(spec);
                              }
                            });
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel")),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, tempSelected),
                    child: Text("OK")),
              ],
            );
          },
        );

        if (selected != null) {
          setState(() {
            doctorSpecializations[day] ??= {};
            doctorSpecializations[day]![doctor] = selected;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child:
          Text("Specialization(s)", style: TextStyle(color: Colors.blue[900])),
    );
  }

  Widget _buildTimeInput(String day, String doctor, bool isTimeIn) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());
        if (time != null) {
          final formatted = time.format(context);
          setState(() {
            if (isTimeIn) {
              opTimeIn[day]?[doctor] = formatted;
            } else {
              opTimeOut[day]?[doctor] = formatted;
            }
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: 6),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isTimeIn
              ? (opTimeIn[day]?[doctor] ?? "--:--")
              : (opTimeOut[day]?[doctor] ?? "--:--"),
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
      ),
    );
  }
}
