import 'package:flutter/material.dart';


class MonthlyDoctorSchedule extends StatefulWidget {
  const MonthlyDoctorSchedule({super.key});

  @override
  State<MonthlyDoctorSchedule> createState() => _MonthlyDoctorScheduleState();
}

class _MonthlyDoctorScheduleState extends State<MonthlyDoctorSchedule> {
  List<Map<String, dynamic>> schedules = [];

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
        'doctor': null,
        'fromTime': TimeOfDay.now(),
        'toTime': TimeOfDay.now(),
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Doctor Schedule"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _selectDate,
              icon: const Icon(Icons.date_range),
              label: const Text("Select Date to Add Doctor"),
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
                  childAspectRatio: isWide ? 1.4 : 0.95,
                ),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  final selectedDoctor = schedule['doctor'];
                  final specialization = selectedDoctor != null
                      ? doctorList.firstWhere((doc) => doc['name'] == selectedDoctor)['specialization']
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "📅 ${schedule['date'].toLocal().toString().split(' ')[0]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    schedules.removeAt(index);
                                  });
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: schedule['doctor'],
                            decoration: InputDecoration(
                              labelText: "Select Doctor",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: doctorList.map((doctor) {
                              return DropdownMenuItem<String>(
                                value: doctor['name'],
                                child: Text(doctor['name']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                schedules[index]['doctor'] = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Specialization",
                              hintText: specialization,
                              prefixIcon: const Icon(Icons.local_hospital),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // From Time Button
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(index, 'fromTime'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF90CAF9), Color(0xFF42A5F5)], // Light to medium blue
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
                                          "From: ${schedules[index]['fromTime'].format(context)}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // To Time Button
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(index, 'toTime'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)], // Medium to dark blue
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
                                        const Icon(Icons.access_time_filled, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          "To: ${schedules[index]['toTime'].format(context)}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // From Time Button
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(index, 'fromTime'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF90CAF9), Color(0xFF42A5F5)], // Light to medium blue
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
                                          "From: ${schedules[index]['fromTime'].format(context)}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // To Time Button
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(index, 'toTime'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)], // Medium to dark blue
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
                                        const Icon(Icons.access_time_filled, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          "To: ${schedules[index]['toTime'].format(context)}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            letterSpacing: 0.5,
                                          ),
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
