import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_room_availability_check.dart';
import 'package:foxcare_lite/presentation/module/doctor/patients_search.dart';
import 'package:foxcare_lite/presentation/module/lab/dashboard.dart';
import 'package:foxcare_lite/presentation/module/lab/lab_accounts.dart';
import 'package:foxcare_lite/presentation/module/lab/patients_lab_details.dart';
import 'package:foxcare_lite/presentation/module/lab/reports_search.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../presentation/login/fetch_user.dart';
import '../../../../presentation/login/login.dart';
import '../../../../presentation/module/doctor/doctor_rx_list.dart';
import '../../../../presentation/module/doctor/ip_patients_details.dart';
import '../../../../presentation/module/doctor/pharmacy_stocks.dart';
import '../custom_drawer.dart';

class LabModuleDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const LabModuleDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _LabModuleDrawer createState() => _LabModuleDrawer();
}

class _LabModuleDrawer extends State<LabModuleDrawer> {
  final UserModel? currentUser = UserSession.currentUser;

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
    final user = UserSession.currentUser;
    if (user == null) {
      return Drawer(child: Center(child: CircularProgressIndicator()));
    }
    return CustomDrawer(
        selectedIndex: widget.selectedIndex,
        onItemSelected: widget.onItemSelected,
        name: currentUser!.name,
        degree: currentUser!.degree,
        department: 'Lab Assistance',
        menuItems: [
          DrawerMenuItem(
            title: 'Home',
            icon: Iconsax.home,
            onTap: () {
              navigateWithTransition(context, LabDashboard());
            },
          ),
          DrawerMenuItem(
            title: 'Lab Test',
            icon: Icons.check,
            onTap: () {
              navigateWithTransition(context, PatientsLabDetails());
            },
          ),
          DrawerMenuItem(
            title: 'Accounts',
            icon: Iconsax.money,
            onTap: () {
              navigateWithTransition(context, LabAccounts());
            },
          ),
          DrawerMenuItem(
            title: 'Reports',
            icon: Iconsax.document,
            onTap: () {
              navigateWithTransition(context, ReportsSearch());
            },
          ),
          DrawerMenuItem(
            title: 'Logout',
            icon: Iconsax.logout,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              UserSession.clearUser();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ]);
  }
}
