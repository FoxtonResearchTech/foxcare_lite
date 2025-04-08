import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase_still_pending.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admission_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit_list.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/lab_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/new_patient_register_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/op_ticket_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/other_expense.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:iconsax/iconsax.dart';

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
            title: 'Lab Collection',
            icon: Iconsax.add_circle,
            onTap: () {
              navigateWithTransition(context, LabCollection());
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
