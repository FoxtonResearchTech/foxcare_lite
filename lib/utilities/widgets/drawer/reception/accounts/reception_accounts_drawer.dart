import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/accounts/reception_accounts_ip_admission_collection.dart';
import 'package:foxcare_lite/presentation/module/reception/accounts/reception_accounts_op_ticket_collection.dart';

import 'package:foxcare_lite/presentation/module/reception/reception_dashboard.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../presentation/login/fetch_user.dart';
import '../../../../../presentation/module/reception/accounts/reception_accounts_new_patient_registration_collection.dart';
import '../../custom_drawer.dart';

class ReceptionAccountsDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const ReceptionAccountsDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _ReceptionAccountsDrawer createState() => _ReceptionAccountsDrawer();
}

class _ReceptionAccountsDrawer extends State<ReceptionAccountsDrawer> {
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
      department: 'Receptionist',
      menuItems: [
        DrawerMenuItem(
          title: 'New Patient Registration Collection',
          icon: Iconsax.home,
          onTap: () {
            navigateWithTransition(
                context, ReceptionAccountsNewPatientRegistrationCollection());
          },
        ),
        DrawerMenuItem(
          title: 'OP Ticket Collection',
          icon: Iconsax.receipt,
          onTap: () {
            navigateWithTransition(
                context, ReceptionAccountsOpTicketCollection());
          },
        ),
        DrawerMenuItem(
          title: 'IP Admission Collection',
          icon: Iconsax.ticket,
          onTap: () {
            navigateWithTransition(
                context, ReceptionAccountsIpAdmissionCollection());
          },
        ),
        DrawerMenuItem(
          title: 'Back To Reception Dashboard',
          icon: Iconsax.add_circle,
          onTap: () {
            navigateWithTransition(context, ReceptionDashboard());
          },
        ),
      ],
    );
  }
}
