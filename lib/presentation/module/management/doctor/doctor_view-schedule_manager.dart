import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/add_schedule.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
class DoctorScheduleViewManager extends StatelessWidget {
  final List<Map<String, String>> doctorSchedules = [
    {'doctor': 'Dr. Smith', 'specification': 'Cardiologist', 'counter': '1', 'opTime': '09:00 AM', 'outTime': '01:00 PM'},
    {'doctor': 'Dr. John', 'specification': 'Dentist', 'counter': '2', 'opTime': '10:00 AM', 'outTime': '02:00 PM'},
    {'doctor': 'Dr. Rose', 'specification': 'Neurologist', 'counter': '3', 'opTime': '11:00 AM', 'outTime': '03:00 PM'},
  ];
  final List<Map<String, String>> doctors = [
    {
      'name': 'Dr. John Doe',
      'designation': 'Cardiologist',
      'time': '10:00 AM - 4:00 PM'
    },
    {
      'name': 'Dr. Emily Smith',
      'designation': 'Dentist',
      'time': '11:00 AM - 5:00 PM'
    },
    {
      'name': 'Dr. Rahul Sharma',
      'designation': 'Neurologist',
      'time': '9:00 AM - 3:00 PM'
    },
    {
      'name': 'Dr. Sarah Lee',
      'designation': 'Pediatrician',
      'time': '1:00 PM - 7:00 PM'
    },
  ];

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Schedules'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Doctor Schedule",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding:
              EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today,
                      color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "26 May, 2025",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth < 600
                    ? 1
                    : (constraints.maxWidth < 900 ? 2 : 4);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: doctors.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent,
                              Colors.lightBlueAccent
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                child: Text(
                                  "5",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              Text(
                                doctor['name']!,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                doctor['designation']!,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  doctor['time']!,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  doctor['time']!,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: Icon(Icons.calendar_today, color: Colors.white),
            backgroundColor: Colors.green,
            label: 'Daily Schedule',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddDoctorSchedule()));
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.calendar_view_week, color: Colors.white),
            backgroundColor: Colors.orange,
            label: 'Weekly Schedule',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Weekly Schedule Selected')));
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.calendar_month, color: Colors.white),
            backgroundColor: Colors.purple,
            label: 'Monthly Schedule',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Monthly Schedule Selected')));
            },
          ),
        ],
      ),
    );
  }
}

