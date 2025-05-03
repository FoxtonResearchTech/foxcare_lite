import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_room_availability_check.dart';
import 'package:foxcare_lite/presentation/module/doctor/patients_search.dart';
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
  final UserModel? currentUser = UserSession.currentUser;

  void navigateWithTransition(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 150), // Very fast
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.fastOutSlowIn;

          final scaleTween = Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: curve));
          final fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

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
        department: 'Doctor',
        menuItems: [
          DrawerMenuItem(
            title: 'Home',
            icon: Iconsax.home,
            onTap: () {
              navigateWithTransition(
                  context,
                  DoctorDashboard(
                    doctorName: currentUser!.name,
                  ));
            },
          ),
          DrawerMenuItem(
            title: 'OP Tickets',
            icon: Iconsax.receipt,
            onTap: () {
              navigateWithTransition(
                context,
                DoctorRxList(
                  doctorName: currentUser!.name,
                ),
              );
            },
          ),
          DrawerMenuItem(
            title: 'IP Tickets',
            icon: Iconsax.receipt,
            onTap: () {
              navigateWithTransition(
                  context,
                  IpPatientsDetails(
                    doctorName: currentUser!.name,
                  ));
            },
          ),
          DrawerMenuItem(
            title: 'Medications',
            icon: Iconsax.add_circle,
            onTap: () {
              navigateWithTransition(context, PharmacyStocks());
            },
          ),
          DrawerMenuItem(
            title: 'Room Availability',
            icon: Icons.room_preferences_outlined,
            onTap: () {
              navigateWithTransition(context, DoctorRoomAvailabilityCheck());
            },
          ),
          DrawerMenuItem(
            title: 'Patients Search',
            icon: Iconsax.search_favorite,
            onTap: () {
              navigateWithTransition(
                  context,
                  PatientsSearch(
                    doctorName: currentUser!.name,
                  ));
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
                    title: const Text('Logout Confirmation'),
                    content: const CustomText(
                        text: 'Are you sure you want to Logout?'),
                    actions: <Widget>[
                      TextButton(
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
                        child: const CustomText(
                          text: 'Sure',
                          color: Colors.red,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const CustomText(text: 'Close'),
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
