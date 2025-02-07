import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/login/login.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/ip_patients_details.dart';
import 'package:foxcare_lite/presentation/module/lab/dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/manager/manager_dashboard.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/dashboard/pharmecy_dashboard.dart';
import 'package:foxcare_lite/presentation/module/reception/ip_admission.dart';
import 'package:foxcare_lite/presentation/module/reception/ip_patients_admission.dart';
import 'package:foxcare_lite/presentation/module/reception/reception_dashboard.dart';
import 'package:foxcare_lite/presentation/module/reception/total_room_update.dart';
import 'package:foxcare_lite/presentation/signup/employee_registration.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FoxCare Lite',
        home: ManagementDashboard());
  }
}
