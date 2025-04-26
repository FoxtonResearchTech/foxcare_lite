import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../utilities/widgets/drawer/management/doctor/management_doctor_schedule.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/text/primary_text.dart';

class WeeklyScheduleEdit extends StatefulWidget {
  @override
  _WeeklyScheduleEdit createState() => _WeeklyScheduleEdit();
}

class _WeeklyScheduleEdit extends State<WeeklyScheduleEdit> {
  int selectedIndex = 4;

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
                        text: "Doctor Weekly Schedule Edit  ",
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
          ],
        ),
      ),
    );
  }
}
