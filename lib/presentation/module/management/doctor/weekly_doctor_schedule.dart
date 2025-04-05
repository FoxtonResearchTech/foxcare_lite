import 'package:flutter/material.dart';

import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/text/primary_text.dart';

class DoctorWeeklySchedule extends StatefulWidget {
  @override
  _DoctorWeeklyScheduleState createState() => _DoctorWeeklyScheduleState();
}

class _DoctorWeeklyScheduleState extends State<DoctorWeeklySchedule> {
  int selectedIndex = 6;

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
    "Dr. Kevin"
  ];
  final List<String> specializations = [
    "Cardiologist",
    "Dermatologist",
    "Neurologist",
    "Pediatrician"
  ];

  Map<String, String?> selectedDoctor = {};
  Map<String, String?> selectedSpecialization = {};
  Map<String, String?> opTimeIn = {};
  Map<String, String?> opTimeOut = {};

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
                        text: "Weekly Doctor Schedule",
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
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
        width: 200, // Increased width
        height: 60, // Increased height
        child: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Schedule Saved Successfully!")),
            );
          },
          backgroundColor: Colors.blue,
          label: const Text(
            "Save",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white), // Larger font
          ),
          icon: const Icon(Icons.save,
              size: 28, color: Colors.white), // Larger icon
          elevation: 10, // Slightly raised for better effect
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
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900]),
            ),
            const SizedBox(height: 8),

            // Doctor Dropdown with Reduced Width
            _buildDropdown(day, "Doctor", doctors, selectedDoctor, (value) {
              setState(() {
                selectedDoctor[day] = value;
              });
            }, width: 250),

            const SizedBox(height: 6),

            // Specialization Dropdown with Reduced Width
            _buildDropdown(
                day, "Specialization", specializations, selectedSpecialization,
                (value) {
              setState(() {
                selectedSpecialization[day] = value;
              });
            }, width: 250),

            const SizedBox(height: 8),

            // OP Time In & Out Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Time In",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    const SizedBox(height: 4),
                    _buildTimeInput(day, true), // Time In Button
                  ],
                ),
                Column(
                  children: [
                    Text("Time Out",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    const SizedBox(height: 4),
                    _buildTimeInput(day, false), // Time Out Button
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Time In",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    const SizedBox(height: 4),
                    _buildTimeInput(day, true), // Time In Button
                  ],
                ),
                Column(
                  children: [
                    Text("Time Out",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    const SizedBox(height: 4),
                    _buildTimeInput(day, false), // Time Out Button
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String day, String hint, List<String> items,
      Map<String, String?> selectedMap, ValueChanged<String?> onChanged,
      {double width = 150}) {
    return Container(
      width: width, // Reduced dropdown width
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint,
              style: TextStyle(
                  color: Colors.blue[900], fontWeight: FontWeight.bold)),
          isExpanded: true,
          value: selectedMap[day],
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTimeInput(String day, bool isTimeIn) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            String formattedTime = pickedTime.format(context);
            if (isTimeIn) {
              opTimeIn[day] = formattedTime;
            } else {
              opTimeOut[day] = formattedTime;
            }
          });
        }
      },
      child: Container(
        width: 70, // Slightly increased for better tap area
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          isTimeIn ? (opTimeIn[day] ?? "--:--") : (opTimeOut[day] ?? "--:--"),
          style: TextStyle(
              fontSize: 14,
              color: Colors.blue[900],
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
