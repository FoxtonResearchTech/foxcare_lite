import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../utilities/widgets/text/primary_text.dart';

class DoctorScheduleView extends StatefulWidget {
  const DoctorScheduleView({super.key});

  @override
  State<DoctorScheduleView> createState() => _DoctorScheduleViewState();
}

class _DoctorScheduleViewState extends State<DoctorScheduleView> {
  Map<String, List<Map<String, dynamic>>> groupedSchedules = {};
  List<String> sortedDates = [];

  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  int selectedIndex = 5;
  List<Map<String, dynamic>> Dailydoctors = [];

  final String formattedDate = DateFormat('d MMMM, y').format(DateTime.now());
  Future<List<List<Map<String, dynamic>>>> getGroupedMonthlySchedule() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('doctorSchedules').get();

    // Create a list for 31 days (for days 1–31)
    List<List<Map<String, dynamic>>> monthlySchedule =
        List.generate(31, (_) => []);

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateString = data['date'];
      final date = DateTime.tryParse(dateString);

      if (date != null && date.month == 4 && date.year == 2025) {
        int day = date.day;
        monthlySchedule[day - 1].add(data);
      }
    }

    return monthlySchedule;
  }

  List<List<Map<String, dynamic>>> monthlyDoctorSchedule =
      List.generate(31, (_) => []);
  bool isLoading = true;
  Future<void> loadMonthlySchedule() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctorSchedulesMonthly')
        .get();

    List<List<Map<String, dynamic>>> grouped = List.generate(31, (_) => []);

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateString = data['date'];

      if (dateString != null) {
        final date = DateTime.tryParse(dateString);
        if (date != null && date.month == 4 && date.year == 2025) {
          grouped[date.day - 1].add(data); // Group by day (1-indexed)
        }
      }
    }

    setState(() {
      monthlyDoctorSchedule = grouped;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDoctorSchedules();
    loadSchedule();
    fetchWeeklyDoctorSchedule();
    fetchSchedulesFromFirestore();
  }

  Future<void> loadSchedule() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctorSchedulesMonthly')
          .get();

      List<List<Map<String, dynamic>>> grouped = List.generate(31, (_) => []);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dateStr = data['date'];

        DateTime? date;

        // Handle both String and Timestamp
        if (dateStr is String) {
          date = DateTime.tryParse(dateStr);
        } else if (dateStr is Timestamp) {
          date = dateStr.toDate();
        }

        if (date != null && date.month == 4 && date.year == 2025) {
          final int dayIndex = date.day - 1;
          if (dayIndex >= 0 && dayIndex < 31) {
            grouped[dayIndex].add(data);
          }
        }
      }

      setState(() {
        monthlyDoctorSchedule = grouped;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading doctor schedules: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDoctorSchedules() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('doctorSchedulesDaily')
          .get();

      final List<Map<String, dynamic>> fetchedDoctors =
          snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'doctor': data['doctor'] ?? 'Unknown',
          'counter': data['counter'] ?? '0',
          'specialization': data['specialization'] ?? 'Unknown',
          'morningOpIn': data['morningOpIn'] ?? 'N/A',
          'morningOpOut': data['morningOpOut'] ?? 'N/A',
          'eveningOpIn': data['eveningOpIn'] ?? 'N/A',
          'eveningOpOut': data['eveningOpOut'] ?? 'N/A',
          'date': data['date'] ?? 'N/A',
        };
      }).toList();

      setState(() {
        Dailydoctors = fetchedDoctors;
      });
    } catch (e) {
      print('Error fetching doctor schedules: $e');
    }
  }

  List<List<Map<String, String>>> weeklyDoctorSchedule =
      List.generate(7, (_) => []);

  Future<void> fetchWeeklyDoctorSchedule() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctor_weekly_schedule')
        .get();

    // Clear the previous schedule
    weeklyDoctorSchedule = List.generate(7, (_) => []);

    for (var doc in snapshot.docs) {
      final String day = doc['day'];
      final List schedules = doc['schedules'] ?? [];

      int index = days.indexOf(day);
      if (index != -1) {
        weeklyDoctorSchedule[index] =
            schedules.map<Map<String, String>>((sched) {
          final String timeString =
              'Morning: ${sched['morning_in']} - ${sched['morning_out']}\n'
              'Evening: ${sched['evening_in']} - ${sched['evening_out']}';

          return {
            'name': sched['doctor'],
            'designation': sched['specialization'],
            'time': timeString,
          };
        }).toList();
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text(
                'Reception Dashboard',
                style: TextStyle(fontFamily: 'SanFrancisco'),
              ),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: ReceptionDrawer(
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
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.01),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Doctor Schedule View",
                          size: screenWidth * 0.025,
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
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 4;
            final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

// Filter doctors for today
            final todayDoctors = Dailydoctors.where((doctor) {
              final dateStr = doctor['date'];
              if (dateStr == null) return false;

              try {
                final doctorDate =
                    DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr));
                return doctorDate == today;
              } catch (e) {
                return false;
              }
            }).toList();

// Show message if no data
            if (todayDoctors.isEmpty) {
              return Center(
                child: Lottie.asset("assets/no_data.json",
                    height: 500, width: 500),
              );
            }
            return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: Dailydoctors.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.6,
                ),
                itemBuilder: (context, index) {
                  final doctor = Dailydoctors[index];

                  return Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlueAccent],
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
                                doctor['counter'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            Text(
                              doctor['doctor'],
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              doctor['specialization'],
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      doctor['morningOpIn'],
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      doctor['morningOpOut'],
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      doctor['eveningOpIn'],
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      doctor['eveningOpOut'],
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
        const SizedBox(height: 16.0),
        const Text(
          "Doctor Visit Schedule",
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 300,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: days.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 320,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(4, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${days[index]} - ${index + 1} May, 2025',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: weeklyDoctorSchedule[index].isEmpty
                              ? const Center(
                                  child: Text("No doctors available"))
                              : SingleChildScrollView(
                                  child: Column(
                                    children: List.generate(
                                        weeklyDoctorSchedule[index].length,
                                        (docIndex) {
                                      final doctor =
                                          weeklyDoctorSchedule[index][docIndex];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.blueAccent
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const CircleAvatar(
                                                backgroundColor:
                                                    Colors.blueAccent,
                                                child: Icon(Icons.person,
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(doctor['name']!,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(doctor['designation']!,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .black54)),
                                                    Text(doctor['time']!,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .blueAccent)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        const Text(
          "Monthly Visit Doctor Schedule",
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16.0),
        groupedSchedules.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                height: 500,
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // ⬅️ From 7 to 5 for more space per card
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.65, // ⬅️ Lower ratio = taller card
                  ),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final dateStr = sortedDates[index];
                    final schedules = groupedSchedules[dateStr] ?? [];
                    final date = DateTime.parse(dateStr);
                    final dayLabel = "${date.day} ${_monthName(date.month)}";

                    if (schedules.isEmpty) {
                      return _noScheduleCard(dayLabel);
                    }

                    return _scheduleCard(dayLabel, schedules);
                  },
                ),
              ),
      ],
    );
  }

  Widget _scheduleCard(String dayLabel, List<Map<String, dynamic>> schedules) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      dayLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3.0,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                        color: Colors.white24, thickness: 1, height: 20),
                    ...schedules.map((doctor) {
                      return Column(
                        children: [
                          Text(
                            doctor['doctorName'] ?? 'Unknown',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor['specialization'] ?? 'Specialist',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Morning: ${doctor['fromTimeMorning']} - ${doctor['toTimeMorning']}\n'
                              'Evening: ${doctor['fromTimeEvening']} - ${doctor['toTimeEvening']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _noScheduleCard(String dayLabel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dayLabel,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Icon(Icons.event_busy, color: Colors.redAccent, size: 32),
          const SizedBox(height: 8),
          const Text("No Schedule", style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Future<void> fetchSchedulesFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctorSchedulesMonthly')
        .get();

    final allSchedules = snapshot.docs.map((doc) => doc.data()).toList();

    final Map<String, List<Map<String, dynamic>>> tempGrouped = {};

    for (var schedule in allSchedules) {
      final date = schedule['date'];
      if (!tempGrouped.containsKey(date)) {
        tempGrouped[date] = [];
      }
      tempGrouped[date]!.add(schedule);
    }

    final tempSortedDates = tempGrouped.keys.toList()
      ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    setState(() {
      groupedSchedules = tempGrouped;
      sortedDates = tempSortedDates;
    });
  }

  String _monthName(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month];
  }
}
