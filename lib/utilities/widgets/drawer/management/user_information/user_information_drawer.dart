import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/add_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/doctor_view-schedule_manager.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/monthly_doctor_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/doctor/weekly_doctor_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_admission_status.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/user/edit_delete_user_account.dart';
import 'package:foxcare_lite/presentation/module/management/user/user_account_creation.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../presentation/login/fetch_user.dart';
import '../../custom_drawer.dart';

class UserInformationDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const UserInformationDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _UserInformationDrawer createState() => _UserInformationDrawer();
}

class _UserInformationDrawer extends State<UserInformationDrawer> {
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
        department: 'Management',
        menuItems: [
          DrawerMenuItem(
            title: 'User Account Creation',
            icon: Iconsax.user,
            onTap: () {
              navigateWithTransition(context, UserAccountCreation());
            },
          ),
          DrawerMenuItem(
            title: 'Edit Delete User',
            icon: Icons.change_circle_outlined,
            onTap: () {
              navigateWithTransition(context, EditDeleteUserAccount());
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
