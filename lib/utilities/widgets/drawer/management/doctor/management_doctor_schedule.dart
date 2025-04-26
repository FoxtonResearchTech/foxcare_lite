import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/add_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/doctor_view-schedule_manager.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/monthly_doctor_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/monthly_schedule_edit.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/weekly_doctor_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/weekly_schedule_edit.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../../presentation/login/fetch_user.dart';
import '../../custom_drawer.dart';

class ManagementDoctorSchedule extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const ManagementDoctorSchedule({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _ManagementDoctorSchedule createState() => _ManagementDoctorSchedule();
}

class _ManagementDoctorSchedule extends State<ManagementDoctorSchedule> {
  final UserModel? currentUser = UserSession.currentUser;

  void navigateWithTransition(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;
    if (user == null) {
      return Drawer(child: Center(child: CircularProgressIndicator()));
    }
    return CustomDrawer(
      selectedIndex: widget.selectedIndex,
      onItemSelected: widget.onItemSelected,
      name: currentUser!.name,
      degree: currentUser!.degree,
      department: 'Management',
      menuItems: [
        DrawerMenuItem(
          title: 'Doctor Schedule View Manager',
          icon: Iconsax.add_circle,
          onTap: () {
            navigateWithTransition(context, DoctorScheduleViewManager());
          },
        ),
        DrawerMenuItem(
          title: 'Doctor Daily Schedule',
          icon: Iconsax.hospital,
          onTap: () {
            navigateWithTransition(context, AddDoctorSchedule());
          },
        ),
        DrawerMenuItem(
          title: 'Doctor Weekly Schedule',
          icon: Icons.analytics_outlined,
          onTap: () {
            navigateWithTransition(context, DoctorWeeklySchedule());
          },
        ),
        DrawerMenuItem(
          title: 'Doctor Monthly Schedule',
          icon: Iconsax.hospital,
          onTap: () {
            navigateWithTransition(context, MonthlyDoctorSchedule());
          },
        ),
        DrawerMenuItem(
          title: 'Weekly Schedule Edit',
          icon: Iconsax.edit,
          onTap: () {
            navigateWithTransition(context, WeeklyScheduleEdit());
          },
        ),
        DrawerMenuItem(
          title: 'Monthly Schedule Edit',
          icon: Iconsax.edit,
          onTap: () {
            navigateWithTransition(context, MonthlyScheduleEdit());
          },
        ),
        DrawerMenuItem(
          title: 'Back to Management Dashboard',
          icon: Iconsax.back_square,
          onTap: () {
            navigateWithTransition(context, ManagementDashboard());
          },
        ),
      ],
    );
  }
}
