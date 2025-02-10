import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_admission_status.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import 'general_information_doctor_visit_schedule.dart';
import 'general_information_ip_admission.dart';

class GeneralInformationEditDoctorVisitSchedule extends StatefulWidget {
  @override
  State<GeneralInformationEditDoctorVisitSchedule> createState() =>
      _GeneralInformationEditDoctorVisitSchedule();
}

class _GeneralInformationEditDoctorVisitSchedule
    extends State<GeneralInformationEditDoctorVisitSchedule> {
  List<Widget> addedWidgets = [];
  List<TextEditingController> consultingTimeControllers1 = [];
  List<TextEditingController> consultingTimeControllers2 = [];
  List<TextEditingController> doctorNameControllers = [];
  List<TextEditingController> departmentControllers = [];

  List<Widget> addedMonthlyWidgets = [];
  List<TextEditingController> consultingTimeMonthlyControllers1 = [];
  List<TextEditingController> consultingTimeMonthlyControllers2 = [];
  List<TextEditingController> doctorNameMonthlyControllers = [];
  List<TextEditingController> dateMonthlyControllers = [];

  List<TextEditingController> departmentMonthlyControllers = [];
  int selectedIndex = 4;
  final String day = '';
  String? selectedDoctorName;
  String? selectedDepartment;
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Map to store schedule entries for each day
  Map<String, List<Map<String, dynamic>>> scheduleMap = {};

  @override
  void initState() {
    super.initState();
    // Initialize map with empty lists for each day
    for (var day in daysOfWeek) {
      scheduleMap[day] = [];
    }
  }

  // Function to add a schedule row for a specific day
  void _addScheduleWidget(String day) {
    setState(() {
      scheduleMap[day]!.add({
        'startTimeController': TextEditingController(),
        'endTimeController': TextEditingController(),
        'selectedDoctor': null,
        'selectedDepartment': null,
      });
    });
  }

  // Function to remove a specific row from a specific day
  void _removeScheduleWidget(String day, int index) {
    setState(() {
      scheduleMap[day]![index]['startTimeController'].dispose();
      scheduleMap[day]![index]['endTimeController'].dispose();
      scheduleMap[day]!.removeAt(index);
    });
  }

  Widget _buildDaySchedule(String day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                      text: day,
                      size: MediaQuery.of(context).size.width * 0.012),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  color: AppColors.secondaryColor,
                  onPressed: () => _addScheduleWidget(day),
                ),
              ],
            )
          ],
        ),
        Column(
          children: scheduleMap[day]!.asMap().entries.map((entry) {
            int index = entry.key;
            var schedule = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: CustomDropdown(
                      label: 'Dr.Name',
                      items: ['Doctor 1', 'Doctor 2', 'Doctor 3'],
                      onChanged: (value) {
                        setState(() {
                          scheduleMap[day]![index]['selectedDoctor'] = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 250,
                    child: CustomDropdown(
                      label: 'Department',
                      items: ['Department 1', 'Department 2', 'Department 3'],
                      onChanged: (value) {
                        setState(() {
                          scheduleMap[day]![index]['selectedDepartment'] =
                              value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  CustomTextField(
                    controller: schedule['startTimeController'],
                    hintText: 'Start Time',
                    width: 175,
                    icon: Icon(Icons.access_time),
                    onTap: () =>
                        _selectTime(context, schedule['startTimeController']),
                  ),
                  SizedBox(width: 10),
                  CustomTextField(
                    controller: schedule['endTimeController'],
                    hintText: 'End Time',
                    width: 175,
                    icon: Icon(Icons.access_time),
                    onTap: () =>
                        _selectTime(context, schedule['endTimeController']),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _removeScheduleWidget(day, index),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addMonthlyScheduleWidget() {
    setState(() {
      // Create new controllers for each field
      TextEditingController newTimeController1 = TextEditingController();
      TextEditingController newTimeController2 = TextEditingController();
      TextEditingController newDoctorNameController = TextEditingController();
      TextEditingController newDepartmentController = TextEditingController();
      TextEditingController dateController = TextEditingController();

      // Store them in lists
      consultingTimeMonthlyControllers1.add(newTimeController1);
      consultingTimeMonthlyControllers2.add(newTimeController2);
      doctorNameMonthlyControllers.add(newDoctorNameController);
      departmentMonthlyControllers.add(newDepartmentController);
      dateMonthlyControllers.add(newDepartmentController);

      int currentIndex = addedMonthlyWidgets.length;

      addedMonthlyWidgets.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 225,
                    child: CustomDropdown(
                      label: 'Dr.Name',
                      items: ['Doctor 1', 'Doctor 2', 'Doctor 3'],
                      onChanged: (value) {
                        setState(() {
                          selectedDoctorName = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 225,
                    child: CustomDropdown(
                      label: 'Department',
                      items: ['Department 1', 'Department 2', 'Department 3'],
                      onChanged: (value) {
                        setState(() {
                          selectedDepartment = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  CustomTextField(
                    controller: dateController,
                    hintText: 'Date',
                    width: 165,
                    icon: Icon(Icons.date_range),
                    onTap: () => _selectDate(context, dateController),
                  ),
                  SizedBox(width: 10),
                  CustomTextField(
                    controller: newTimeController1,
                    hintText: 'Start Time',
                    width: 155,
                    icon: Icon(Icons.access_time),
                    onTap: () => _selectTime(context, newTimeController1),
                  ),
                  SizedBox(width: 10),
                  CustomTextField(
                    controller: newTimeController2,
                    hintText: 'End Time',
                    width: 140,
                    icon: Icon(Icons.access_time),
                    onTap: () => _selectTime(context, newTimeController2),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      _removeMonthlyScheduleWidget(currentIndex);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _removeMonthlyScheduleWidget(int index) {
    setState(() {
      if (index >= 0 && index < addedMonthlyWidgets.length) {
        addedMonthlyWidgets.removeAt(index);
        consultingTimeMonthlyControllers1.removeAt(index);
        consultingTimeMonthlyControllers2.removeAt(index);
        dateMonthlyControllers.removeAt(index);

        doctorNameMonthlyControllers.removeAt(index);
        departmentMonthlyControllers.removeAt(index);
      }
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      String formattedTime = pickedTime.format(context);
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
                text: 'General Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: buildDrawerContent(), // Drawer minimized for mobile
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: buildDrawerContent(), // Sidebar always open for web view
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

  // Drawer content reused for both web and mobile
  Widget buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'General Information',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'OP Ticket Generation', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeneralInformationOpTicket()));
        }, Iconsax.mask),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'IP Admission', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeneralInformationIpAdmission()));
        }, Iconsax.receipt),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(2, 'Admission Status', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeneralInformationAdmissionStatus()));
        }, Iconsax.add_circle),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'Doctor Visit  Schedule', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      GeneralInformationDoctorVisitSchedule()));
        }, Iconsax.add_circle),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(
            4, 'Doctor Visit  Schedule Edit ', () {}, Iconsax.add_circle),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(5, 'Back To Management Dashboard', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ManagementDashboard()));
        }, Iconsax.backward),
      ],
    );
  }

  // Helper method to build drawer items with the ability to highlight the selected item
  Widget buildDrawerItem(
      int index, String title, VoidCallback onTap, IconData icon) {
    return ListTile(
      selected: selectedIndex == index,
      selectedTileColor:
          Colors.blueAccent.shade100, // Highlight color for the selected item
      leading: Icon(
        icon, // Replace with actual icons
        color: selectedIndex == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
            fontFamily: 'SanFrancisco',
            color: selectedIndex == index ? Colors.blue : Colors.black54,
            fontWeight: FontWeight.w700),
      ),
      onTap: () {
        setState(() {
          selectedIndex = index; // Update the selected index
        });
        onTap();
      },
    );
  }

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.03,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CustomText(
                    text: 'Doctor Visit Schedule Edit',
                    size: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Container(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.03,
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  bottom: screenWidth * 0.01,
                ),
                child: Column(
                  children: [
                    CustomText(
                        text: 'Weekly Schedule Edit',
                        size: screenWidth * 0.0125),
                    SizedBox(height: screenHeight * 0.025),
                    Column(
                      children: daysOfWeek
                          .map((day) => _buildDaySchedule(day))
                          .toList(),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    CustomText(
                        text: 'Monthly Schedule Edit',
                        size: screenWidth * 0.0125),
                    SizedBox(height: screenHeight * 0.025),
                    Row(
                      children: [
                        CustomText(
                          text: 'Monthly',
                          size: screenWidth * 0.012,
                        ),
                        SizedBox(
                          width: screenWidth * 0.039,
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          color: AppColors.secondaryColor,
                          onPressed: _addMonthlyScheduleWidget,
                        ),
                      ],
                    ),
                    Column(
                      children: addedMonthlyWidgets,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
