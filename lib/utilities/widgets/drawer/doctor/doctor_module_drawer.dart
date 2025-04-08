import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../presentation/module/doctor/doctor_rx_list.dart';
import '../../../../presentation/module/doctor/ip_patients_details.dart';
import '../../../../presentation/module/doctor/pharmacy_stocks.dart';
import '../custom_drawer.dart';

class DoctorModuleDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const DoctorModuleDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _DoctorModuleDrawer createState() => _DoctorModuleDrawer();
}

class _DoctorModuleDrawer extends State<DoctorModuleDrawer> {
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
            title: 'Home',
            icon: Iconsax.home,
            onTap: () {
              navigateWithTransition(context, DoctorDashboard());
            },
          ),
          DrawerMenuItem(
            title: 'OP Patient',
            icon: Iconsax.receipt,
            onTap: () {
              navigateWithTransition(context, DoctorRxList());
            },
          ),
          DrawerMenuItem(
            title: 'IP Patients',
            icon: Iconsax.receipt,
            onTap: () {
              navigateWithTransition(context, IpPatientsDetails());
            },
          ),
          DrawerMenuItem(
            title: 'Pharmacy Stocks',
            icon: Iconsax.add_circle,
            onTap: () {
              navigateWithTransition(context, PharmacyStocks());
            },
          ),
          DrawerMenuItem(
            title: 'Logout',
            icon: Iconsax.logout,
            onTap: () {},
          ),
        ]);
  }
}
