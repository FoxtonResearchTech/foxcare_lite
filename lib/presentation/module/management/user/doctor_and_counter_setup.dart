import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';

import 'package:foxcare_lite/presentation/module/management/user/user_account_creation.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../generalInformation/general_information_admission_status.dart';
import 'edit_delete_user_account.dart';

class DoctorAndCounterSetup extends StatefulWidget {
  @override
  State<DoctorAndCounterSetup> createState() => _DoctorAndCounterSetup();
}

class _DoctorAndCounterSetup extends State<DoctorAndCounterSetup> {
  int selectedIndex = 2;
  List<Widget> addedCounterWidgets = [];
  List<TextEditingController> doctorNameMonthlyControllers = [];
  List<TextEditingController> dateMonthlyControllers = [];
  String? selectedDoctorName;
  String? selectedDepartment;
  String? selectedConsultingRoom;

  String? selectedCounter;

  List<TextEditingController> departmentMonthlyControllers = [];

  void _addMonthlyScheduleWidget() {
    setState(() {
      // Create new controllers for each field
      TextEditingController newTimeController1 = TextEditingController();
      TextEditingController newTimeController2 = TextEditingController();
      TextEditingController newDoctorNameController = TextEditingController();
      TextEditingController newDepartmentController = TextEditingController();
      TextEditingController dateController = TextEditingController();

      // Store them in lists

      doctorNameMonthlyControllers.add(newDoctorNameController);
      departmentMonthlyControllers.add(newDepartmentController);
      dateMonthlyControllers.add(newDepartmentController);

      int currentIndex = addedCounterWidgets.length;

      addedCounterWidgets.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 225,
                    child: CustomDropdown(
                      label: 'Counter',
                      items: ['Counter 1', 'Counter 2', 'Counter 3'],
                      onChanged: (value) {
                        setState(() {
                          selectedCounter = value!;
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
                      label: 'Consulting Room',
                      items: [
                        'Consulting Room 1',
                        'Consulting Room 2',
                        'Consulting Room 3'
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedDoctorName = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      _removeMonthlyScheduleWidget(currentIndex);
                    },
                  ),
                  SizedBox(width: 10),
                  CustomButton(
                    label: 'OK',
                    onPressed: () {},
                    width: 30,
                    height: 30,
                  )
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
      if (index >= 0 && index < addedCounterWidgets.length) {
        addedCounterWidgets.removeAt(index);
        dateMonthlyControllers.removeAt(index);

        doctorNameMonthlyControllers.removeAt(index);
        departmentMonthlyControllers.removeAt(index);
      }
    });
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
                text: 'User Information',
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
            'User Information',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'User Account Creation', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UserAccountCreation()));
        }, Iconsax.mask),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'Edit / Delete User', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EditDeleteUserAccount()));
        }, Iconsax.receipt),
        Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(
            2, "Doctor's & Counter Setup", () {}, Iconsax.add_circle),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'Back To Management Dashboard', () {
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
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.25,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CustomText(
                    text: 'Add Doctor Counters',
                    size: screenWidth * 0.018,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomText(
                    text: 'ADD',
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
                children: addedCounterWidgets,
              ),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
