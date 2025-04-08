import 'package:flutter/material.dart';
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => GeneralInformationOpTicket()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'IP Admission',
            icon: Iconsax.receipt,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => GeneralInformationIpAdmission()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Admission Status',
            icon: Iconsax.receipt,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => GeneralInformationAdmissionStatus()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Doctor Schedule View Manager',
            icon: Iconsax.add_circle,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DoctorScheduleViewManager()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Doctor Daily Schedule',
            icon: Iconsax.hospital,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AddDoctorSchedule()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Doctor Weekly Schedule',
            icon: Icons.analytics_outlined,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DoctorWeeklySchedule()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Doctor Monthly Schedule',
            icon: Iconsax.hospital,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MonthlyDoctorSchedule()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Back To Management Dashboard',
            icon: Iconsax.back_square,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ManagementDashboard()),
              );
            },
          ),
        ]);
  }
}
