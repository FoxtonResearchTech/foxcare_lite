import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase_still_pending.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admission_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit_list.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/lab_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/new_patient_register_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/op_ticket_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/other_expense.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/add_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/doctor_view-schedule_manager.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/monthly_doctor_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/weekly_doctor_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_admission_status.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:iconsax/iconsax.dart';

import '../../custom_drawer.dart';

class ManagementGeneralInformationDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const ManagementGeneralInformationDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _ManagementGeneralInformationDrawer createState() =>
      _ManagementGeneralInformationDrawer();
}

class _ManagementGeneralInformationDrawer
    extends State<ManagementGeneralInformationDrawer> {
  void navigateWithTransition(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide from right
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
    return CustomDrawer(
        selectedIndex: widget.selectedIndex,
        onItemSelected: widget.onItemSelected,
        doctorName: "Dr. Ramesh",
        degree: "MBBS, MD (General Medicine)",
        department: "General Medicine",
        menuItems: [
          DrawerMenuItem(
            title: 'OP Ticket Generation',
            icon: Iconsax.home,
            onTap: () {
              navigateWithTransition(context, GeneralInformationOpTicket());
            },
          ),
          DrawerMenuItem(
            title: 'IP Admission',
            icon: Iconsax.receipt,
            onTap: () {
              navigateWithTransition(context, GeneralInformationIpAdmission());
            },
          ),
          DrawerMenuItem(
            title: 'Admission Status',
            icon: Iconsax.receipt,
            onTap: () {
              navigateWithTransition(
                  context, GeneralInformationAdmissionStatus());
            },
          ),
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
            title: 'Back To Management Dashboard',
            icon: Iconsax.back_square,
            onTap: () {
              navigateWithTransition(context, ManagementDashboard());
            },
          ),
        ]);
  }
}
