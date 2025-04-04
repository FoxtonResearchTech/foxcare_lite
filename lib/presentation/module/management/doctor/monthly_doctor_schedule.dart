import 'package:flutter/material.dart';

class DoctorMonthlySchedule extends StatefulWidget {
  @override
  _DoctorMonthlyScheduleState createState() => _DoctorMonthlyScheduleState();
}

class _DoctorMonthlyScheduleState extends State<DoctorMonthlySchedule> {
  final List<String> doctors = ["Dr. John Doe", "Dr. Smith", "Dr. Emily", "Dr. Kevin"];
  final List<String> specializations = ["Cardiologist", "Dermatologist", "Neurologist", "Pediatrician"];

  Map<String, String?> selectedDoctor = {};
  Map<String, String?> selectedSpecialization = {};
  Map<String, String?> opTimeIn = {};
  Map<String, String?> opTimeOut = {};

  List<DateTime> selectedDates = [];

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
    );

    if (pickedDate != null && !selectedDates.contains(pickedDate)) {
      setState(() {
        selectedDates.add(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Doctor Monthly Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 8,
                shadowColor: Colors.blueAccent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Select Date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.5,
                ),
                itemCount: selectedDates.length,
                itemBuilder: (context, index) {
                  return _buildScheduleCard(selectedDates[index]);
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
              SnackBar(content: Text("Monthly Schedule Saved Successfully!")),
            );
          },
          backgroundColor: Colors.blue,
          label: Text(
            "Save",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          icon: Icon(Icons.save, size: 28, color: Colors.white),
          elevation: 10,
        ),
      ),
    );
  }

  Widget _buildScheduleCard(DateTime date) {
    String dateString = "${date.day}-${date.month}-${date.year}";

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.blue.withOpacity(0.3),
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              dateString,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            SizedBox(height: 8),

            // Doctor Dropdown
            _buildDropdown(dateString, "Doctor", doctors, selectedDoctor, (value) {
              setState(() {
                selectedDoctor[dateString] = value;
              });
            }),

            SizedBox(height: 6),

            // Specialization Dropdown
            _buildDropdown(dateString, "Specialization", specializations, selectedSpecialization, (value) {
              setState(() {
                selectedSpecialization[dateString] = value;
              });
            }),

            SizedBox(height: 8),

            // OP Time In & Out Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Time In", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    SizedBox(height: 4),
                    _buildTimeInput(dateString, true),
                  ],
                ),
                Column(
                  children: [
                    Text("Time Out", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    SizedBox(height: 4),
                    _buildTimeInput(dateString, false),
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
                    _buildTimeInput(dateString, true),
                  ],
                ),
                Column(
                  children: [
                    Text("Time Out", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    SizedBox(height: 4),
                    _buildTimeInput(dateString, false),
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

  Widget _buildDropdown(String dateString, String hint, List<String> items, Map<String, String?> selectedMap, ValueChanged<String?> onChanged) {
    return Container(
      width: 250,
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
          value: selectedMap[dateString],
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

  Widget _buildTimeInput(String dateString, bool isTimeIn) {
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
              opTimeIn[dateString] = formattedTime;
            } else {
              opTimeOut[dateString] = formattedTime;
            }
          });
        }
      },
      child: Container(
        width: 80,
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          isTimeIn ? (opTimeIn[dateString] ?? "--:--") : (opTimeOut[dateString] ?? "--:--"),
          style: TextStyle(fontSize: 14, color: Colors.blue[900], fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
