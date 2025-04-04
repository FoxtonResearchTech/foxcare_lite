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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => NewPatientRegisterCollection()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'OP Ticket Collection',
            icon: Iconsax.receipt,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => OpTicketCollection()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'IP Admission Collection',
            icon: Iconsax.receipt,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => IpAdmissionCollection()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Pharmacy Collection',
            icon: Iconsax.add_circle,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PharmacyTotalSales()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Hospital Direct Purchase',
            icon: Iconsax.hospital,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HospitalDirectPurchase()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Hospital Direct Purchase Still Pending',
            icon: Iconsax.hospital,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => HospitalDirectPurchaseStillPending()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Other Expense',
            icon: Icons.analytics_outlined,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => OtherExpense()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Lab Collection',
            icon: Iconsax.add_circle,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LabCollection()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'IP Admit',
            icon: Iconsax.add_circle,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => IpAdmit()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'IP Admit List',
            icon: Iconsax.add_circle,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => IpAdmitList()),
              );
            },
          ),
          DrawerMenuItem(
            title: 'Back To Management Dashboard',
            icon: Iconsax.back_square,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ManagementDashboard()),
              );
            },
          ),
        ]);
  }
}
