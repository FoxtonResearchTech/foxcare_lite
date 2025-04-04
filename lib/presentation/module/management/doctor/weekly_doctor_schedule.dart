import 'package:flutter/material.dart';

class DoctorWeeklySchedule extends StatefulWidget {
  @override
  _DoctorWeeklyScheduleState createState() => _DoctorWeeklyScheduleState();
}

class _DoctorWeeklyScheduleState extends State<DoctorWeeklySchedule> {
  final List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  final List<String> doctors = ["Dr. John Doe", "Dr. Smith", "Dr. Emily", "Dr. Kevin"];
  final List<String> specializations = ["Cardiologist", "Dermatologist", "Neurologist", "Pediatrician"];

  Map<String, String?> selectedDoctor = {};
  Map<String, String?> selectedSpecialization = {};
  Map<String, String?> opTimeIn = {};
  Map<String, String?> opTimeOut = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Doctor Weekly Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
      floatingActionButton: Container(
        width: 200, // Increased width
        height: 60, // Increased height
        child: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Schedule Saved Successfully!")),
            );
          },
          backgroundColor: Colors.blue,
          label: Text(
            "Save",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Larger font
          ),
          icon: Icon(Icons.save, size: 28, color: Colors.white), // Larger icon
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
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            SizedBox(height: 8),

            // Doctor Dropdown with Reduced Width
            _buildDropdown(day, "Doctor", doctors, selectedDoctor, (value) {
              setState(() {
                selectedDoctor[day] = value;
              });
            }, width: 250),

            SizedBox(height: 6),

            // Specialization Dropdown with Reduced Width
            _buildDropdown(day, "Specialization", specializations, selectedSpecialization, (value) {
              setState(() {
                selectedSpecialization[day] = value;
              });
            }, width: 250),

            SizedBox(height: 8),

            // OP Time In & Out Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Time In", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    SizedBox(height: 4),
                    _buildTimeInput(day, true), // Time In Button
                  ],
                ),
                Column(
                  children: [
                    Text("Time Out", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    SizedBox(height: 4),
                    _buildTimeInput(day, false), // Time Out Button
                  ],
                ),
              ],
            ),

            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Time In", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    SizedBox(height: 4),
                    _buildTimeInput(day, true), // Time In Button
                  ],
                ),
                Column(
                  children: [
                    Text("Time Out", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    SizedBox(height: 4),
                    _buildTimeInput(day, false), // Time Out Button
                  ],
                ),
              ],
            ),

            SizedBox(height: 8),

          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String day, String hint, List<String> items, Map<String, String?> selectedMap, ValueChanged<String?> onChanged, {double width = 150}) {
    return Container(
      width: width, // Reduced dropdown width
      padding: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
          isExpanded: true,
          value: selectedMap[day],
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 14, color: Colors.blue[900], fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          isTimeIn ? (opTimeIn[day] ?? "--:--") : (opTimeOut[day] ?? "--:--"),
          style: TextStyle(fontSize: 14, color: Colors.blue[900], fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}
