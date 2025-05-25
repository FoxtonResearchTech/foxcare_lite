import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/new_patient_register_collection.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/doctor_view-schedule_manager.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/patientsInformation/management_register_patient.dart';
import 'package:foxcare_lite/presentation/module/management/user/user_account_creation.dart';
import 'package:foxcare_lite/presentation/module/management/wardRoomInformation/ward_rooms.dart';

import 'package:iconsax/iconsax.dart';
import '../../../../presentation/login/fetch_user.dart';
import '../../../../presentation/login/login.dart';

import '../../snackBar/snakbar.dart';
import '../../text/primary_text.dart';
import '../custom_drawer.dart';

class ManagementModuleDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const ManagementModuleDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _ManagementModuleDrawer createState() => _ManagementModuleDrawer();
}

class _ManagementModuleDrawer extends State<ManagementModuleDrawer> {
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
      department: 'Management',
      menuItems: [
        DrawerMenuItem(
          title: 'Home',
          icon: Iconsax.home,
          onTap: () {
            navigateWithTransition(context, ManagementDashboard());
          },
        ),
        DrawerMenuItem(
          title: 'Patient Information',
          icon: Iconsax.information,
          onTap: () {
            navigateWithTransition(context, ManagementRegisterPatient());
          },
        ),
        DrawerMenuItem(
          title: 'General Information',
          icon: Iconsax.ticket,
          onTap: () {
            navigateWithTransition(context, GeneralInformationOpTicket());
          },
        ),
        DrawerMenuItem(
          title: 'Doctor Schedule',
          icon: Icons.medical_information_outlined,
          onTap: () {
            navigateWithTransition(context, DoctorScheduleViewManager());
          },
        ),
        DrawerMenuItem(
          title: 'User Information',
          icon: Iconsax.user,
          onTap: () {
            navigateWithTransition(context, UserAccountCreation());
          },
        ),
        DrawerMenuItem(
          title: 'Accounts',
          icon: Iconsax.money,
          onTap: () {
            navigateWithTransition(context, NewPatientRegisterCollection());
          },
        ),
        DrawerMenuItem(
          title: 'Wars /Rooms',
          icon: Icons.hotel_outlined,
          onTap: () {
            navigateWithTransition(context, WardRooms());
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
      ],
    );
  }
}
