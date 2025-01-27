import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/login/login.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_rx_list.dart';
import 'package:foxcare_lite/presentation/module/doctor/patient_view.dart';
import 'package:foxcare_lite/presentation/pages/customerService/admin_chat_panel.dart';
import 'package:foxcare_lite/presentation/pages/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/pages/doctor/rx_prescription.dart';
import 'package:foxcare_lite/presentation/pages/lab/dashboard.dart';
import 'package:foxcare_lite/presentation/pages/lab/lab_accounts.dart';
import 'package:foxcare_lite/presentation/pages/lab/patient_report.dart';
import 'package:foxcare_lite/presentation/pages/lab/patients_lab_details.dart';
import 'package:foxcare_lite/presentation/pages/lab/reports_search.dart';
import 'package:foxcare_lite/presentation/pages/op_ticket.dart';
import 'package:foxcare_lite/presentation/pages/patient_registration.dart';
import 'package:foxcare_lite/presentation/pages/reception_dashboard.dart';
import 'package:foxcare_lite/presentation/signup/employee_registration.dart';
import 'package:foxcare_lite/presentation/signup/role_selection_page.dart';
import 'firebase_options.dart';

import 'presentation/dashboard/pharmecy_dashboard.dart';

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoxCare Lite',
      home: RxPrescription(
          patientID: '',
          name: '',
          age: '',
          place: '',
          primaryInfo: '',
          address: '',
          pincode: '',
          temperature: '',
          bloodPressure: '',
          sugarLevel: ''),
    );
  }
}
