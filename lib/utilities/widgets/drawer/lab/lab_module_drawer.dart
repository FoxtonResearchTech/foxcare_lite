import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_room_availability_check.dart';
import 'package:foxcare_lite/presentation/module/doctor/patients_search.dart';
import 'package:foxcare_lite/presentation/module/lab/dashboard.dart';
import 'package:foxcare_lite/presentation/module/lab/ip_lab_accounts.dart';
import 'package:foxcare_lite/presentation/module/lab/ip_patients_lab_details.dart';
import 'package:foxcare_lite/presentation/module/lab/ip_report_search.dart';
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
import '../../snackBar/snakbar.dart';
import '../../text/primary_text.dart';
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
        transitionDuration: const Duration(milliseconds: 150), // Very fast
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.fastOutSlowIn;

          final scaleTween =
              Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: curve));
          final fadeTween =
              Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

          final scaleAnimation = animation.drive(scaleTween);
          final fadeAnimation = animation.drive(fadeTween);

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
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
            title: 'OP Lab Test',
            icon: Icons.check,
            onTap: () {
              navigateWithTransition(context, PatientsLabDetails());
            },
          ),
          DrawerMenuItem(
            title: 'IP Lab Test',
            icon: Icons.check,
            onTap: () {
              navigateWithTransition(context, IpPatientsLabDetails());
            },
          ),
          DrawerMenuItem(
            title: 'OP Ticket Accounts',
            icon: Iconsax.money,
            onTap: () {
              navigateWithTransition(context, LabAccounts());
            },
          ),
          DrawerMenuItem(
            title: 'OP Ticket Reports',
            icon: Iconsax.document,
            onTap: () {
              navigateWithTransition(context, ReportsSearch());
            },
          ),
          DrawerMenuItem(
            title: 'IP Ticket Accounts',
            icon: Iconsax.money,
            onTap: () {
              navigateWithTransition(context, IpLabAccounts());
            },
          ),
          DrawerMenuItem(
            title: 'IP Ticket Reports',
            icon: Iconsax.document,
            onTap: () {
              navigateWithTransition(context, IpReportSearch());
            },
          ),
          DrawerMenuItem(
            title: 'Logout',
            icon: Iconsax.logout,
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                    contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    title: Row(
                      children: [
                        const Icon(Iconsax.warning_2, color: Colors.red, size: 28),
                        const SizedBox(width: 10),
                        const Text(
                          'Logout Confirmation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    content: const CustomText(
                      text: 'Are you sure you want to logout?',
                      //textAlign: TextAlign.center,
                      //     fontSize: 16,
                    ),
                    actionsAlignment: MainAxisAlignment.end,
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          textStyle: const TextStyle(fontSize: 15),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            UserSession.clearUser();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                                  (route) => false,
                            );
                            CustomSnackBar(context,
                                message: 'Logout Successful',
                                backgroundColor: Colors.green);
                          } catch (e) {
                            CustomSnackBar(context,
                                message: 'Unable to Logout',
                                backgroundColor: Colors.red);
                          }
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ]);
  }
}
