import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/accounts/reception_accounts_new_patient_registration_collection.dart';
import 'package:foxcare_lite/presentation/module/reception/admission_status.dart';
import 'package:foxcare_lite/presentation/module/reception/book_appointments.dart';
import 'package:foxcare_lite/presentation/module/reception/doctor_schedule_view.dart';
import 'package:foxcare_lite/presentation/module/reception/ip_admission.dart';
import 'package:foxcare_lite/presentation/module/reception/op_ticket.dart';
import 'package:foxcare_lite/presentation/module/reception/reception_dashboard.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../presentation/login/fetch_user.dart';
import '../../../../presentation/login/login.dart';
import '../../../../presentation/module/reception/ip_patients_admission.dart';
import '../../../../presentation/module/reception/patient_registration.dart';
import '../../snackBar/snakbar.dart';
import '../../text/primary_text.dart';
import '../custom_drawer.dart';

class ReceptionDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const ReceptionDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _ReceptionDrawer createState() => _ReceptionDrawer();
}

class _ReceptionDrawer extends State<ReceptionDrawer> {
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
          title: 'Home',
          icon: Iconsax.home,
          onTap: () {
            navigateWithTransition(context, ReceptionDashboard());
          },
        ),
        DrawerMenuItem(
          title: 'New Patient Registration',
          icon: Iconsax.receipt,
          onTap: () {
            navigateWithTransition(context, PatientRegistration());
          },
        ),
        DrawerMenuItem(
          title: 'OP Ticket Generation',
          icon: Iconsax.ticket,
          onTap: () {
            navigateWithTransition(context, OpTicketPage());
          },
        ),
        DrawerMenuItem(
          title: 'IP Admission',
          icon: Iconsax.add_circle,
          onTap: () {
            navigateWithTransition(context, IpPatientsAdmission());
          },
        ),
        DrawerMenuItem(
          title: 'Admission Status',
          icon: Iconsax.check,
          onTap: () {
            navigateWithTransition(context, AdmissionStatus());
          },
        ),
        DrawerMenuItem(
          title: 'Doctor Visit Schedule',
          icon: Iconsax.add_circle,
          onTap: () {
            navigateWithTransition(context, DoctorScheduleView());
          },
        ),
        DrawerMenuItem(
          title: 'Appointments',
          icon: Icons.book_online_outlined,
          onTap: () {
            navigateWithTransition(context, BookAppointments());
          },
        ),
        DrawerMenuItem(
          title: 'Accounts',
          icon: Icons.account_balance_outlined,
          onTap: () {
            navigateWithTransition(
                context, ReceptionAccountsNewPatientRegistrationCollection());
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
