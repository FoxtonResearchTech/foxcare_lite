import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/login/fetch_user.dart';
import 'package:foxcare_lite/presentation/login/login.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/lab/dashboard.dart';

import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/manager/manager_dashboard.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/dashboard/pharmecy_dashboard.dart';
import 'package:foxcare_lite/presentation/module/reception/op_ticket.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/presentation/module/reception/reception_dashboard.dart';
import 'package:foxcare_lite/test/test.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await UserSession.initUser();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoxCare Lite',
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return LoginScreen();
        }

        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('employees').doc(uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("User document not found.")),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final role = data['roles'];

            if (UserSession.currentUser == null) {
              UserSession.currentUser = UserModel.fromMap(data);
            }

            switch (role) {
              case 'Management':
                return ManagementDashboard();
              case 'Pharmacist':
                return const SalesChartScreen();
              case 'Receptionist':
                return ReceptionDashboard();
              case 'Lab Assistance':
                return const LabDashboard();
              case 'X-Ray Technician':
                return PatientRegistration();
              case 'Doctor':
                return const DoctorDashboard();
              case 'Manager':
                return const ManagerDashboard();
              default:
                return Scaffold(
                  body: Center(child: Text("Unknown role: $role")),
                );
            }
          },
        );
      },
    );
  }
}
