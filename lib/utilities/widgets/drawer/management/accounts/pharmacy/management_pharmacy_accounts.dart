import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_out_standing_bills.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_pending_sales_bills.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_purchase.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';

import 'package:foxcare_lite/presentation/module/reception/reception_dashboard.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../presentation/login/fetch_user.dart';
import '../../../../../../presentation/module/management/accountsInformation/new_patient_register_collection.dart';
import '../../../custom_drawer.dart';

class ManagementPharmacyAccounts extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const ManagementPharmacyAccounts({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _ManagementPharmacyAccounts createState() => _ManagementPharmacyAccounts();
}

class _ManagementPharmacyAccounts extends State<ManagementPharmacyAccounts> {
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
          title: 'Pharmacy Total Sales',
          icon: Iconsax.home,
          onTap: () {
            navigateWithTransition(context, PharmacyTotalSales());
          },
        ),
        DrawerMenuItem(
          title: 'Pharmacy Purchase',
          icon: Iconsax.receipt,
          onTap: () {
            navigateWithTransition(context, PharmacyPurchase());
          },
        ),
        DrawerMenuItem(
          title: 'Pending Sales Bills',
          icon: Iconsax.ticket,
          onTap: () {
            navigateWithTransition(context, PharmacyPendingSalesBills());
          },
        ),
        DrawerMenuItem(
          title: 'Purchase OutStanding Bills',
          icon: Iconsax.ticket,
          onTap: () {
            navigateWithTransition(context, PharmacyOutStandingBills());
          },
        ),
        DrawerMenuItem(
          title: 'Back To Management Accounts',
          icon: Iconsax.add_circle,
          onTap: () {
            navigateWithTransition(context, NewPatientRegisterCollection());
          },
        ),
      ],
    );
  }
}
