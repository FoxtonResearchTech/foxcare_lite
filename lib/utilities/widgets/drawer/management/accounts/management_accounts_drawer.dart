import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase_still_pending.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admission_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit_list.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_lab_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/lab_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/new_patient_register_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/op_ticket_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/other_expense.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../presentation/login/fetch_user.dart';
import '../../custom_drawer.dart';

class ManagementAccountsDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const ManagementAccountsDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _ManagementAccountsDrawer createState() => _ManagementAccountsDrawer();
}

class _ManagementAccountsDrawer extends State<ManagementAccountsDrawer> {
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
        department: "Management",
        menuItems: [
          DrawerMenuItem(
            title: 'New Patients Register Collection',
            icon: Iconsax.home,
            onTap: () {
              navigateWithTransition(context, NewPatientRegisterCollection());
            },
          ),
          DrawerMenuItem(
            title: 'OP Ticket Collection',
            icon: Iconsax.receipt,
            onTap: () {
              navigateWithTransition(context, OpTicketCollection());
            },
          ),
          DrawerMenuItem(
            title: 'IP Admission Collection',
            icon: Iconsax.receipt,
            onTap: () {
              navigateWithTransition(context, IpAdmissionCollection());
            },
          ),
          DrawerMenuItem(
            title: 'Pharmacy Collection',
            icon: Iconsax.add_circle,
            onTap: () {
              navigateWithTransition(context, PharmacyTotalSales());
            },
          ),
          DrawerMenuItem(
            title: 'Hospital Direct Purchase',
            icon: Iconsax.hospital,
            onTap: () {
              navigateWithTransition(context, HospitalDirectPurchase());
            },
          ),
          DrawerMenuItem(
            title: 'Hospital Direct Purchase Still Pending',
            icon: Iconsax.hospital,
            onTap: () {
              navigateWithTransition(
                  context, HospitalDirectPurchaseStillPending());
            },
          ),
          DrawerMenuItem(
            title: 'Other Expense',
            icon: Icons.analytics_outlined,
            onTap: () {
              navigateWithTransition(context, OtherExpense());
            },
          ),
          DrawerMenuItem(
            title: 'OP Lab Collection',
            icon: Iconsax.add_circle,
            onTap: () {
              navigateWithTransition(context, LabCollection());
            },
          ),
          DrawerMenuItem(
            title: 'IP Lab Collection',
            icon: Iconsax.add_circle,
            onTap: () {
              navigateWithTransition(context, IpLabCollection());
            },
          ),
          DrawerMenuItem(
            title: 'IP Admit',
            icon: Iconsax.add_circle,
            onTap: () {
              navigateWithTransition(context, IpAdmit());
            },
          ),
          DrawerMenuItem(
            title: 'IP Admit List',
            icon: Iconsax.add_circle,
            onTap: () {
              navigateWithTransition(context, IpAdmitList());
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
