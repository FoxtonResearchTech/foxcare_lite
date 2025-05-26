import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/new_patient_register_collection.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/patientsInformation/management_patient_history.dart';
import 'package:foxcare_lite/presentation/module/management/patientsInformation/management_patients_list.dart';
import 'package:foxcare_lite/presentation/module/management/patientsInformation/management_register_patient.dart';
import 'package:foxcare_lite/presentation/module/management/user/user_account_creation.dart';
import 'package:foxcare_lite/presentation/module/management/wardRoomInformation/ward_rooms.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../../presentation/login/fetch_user.dart';
import '../../custom_drawer.dart';

class ManagementPatientInformation extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const ManagementPatientInformation({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _ManagementPatientInformation createState() =>
      _ManagementPatientInformation();
}

class _ManagementPatientInformation
    extends State<ManagementPatientInformation> {
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
          title: 'Patient Registration',
          icon: Iconsax.home,
          onTap: () {
            navigateWithTransition(context, ManagementRegisterPatient());
          },
        ),
        DrawerMenuItem(
          title: 'Patient History',
          icon: Iconsax.information,
          onTap: () {
            navigateWithTransition(context, ManagementPatientHistory());
          },
        ),
        DrawerMenuItem(
          title: 'Patient List',
          icon: Iconsax.ticket,
          onTap: () {
            navigateWithTransition(context, ManagementPatientsList());
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
