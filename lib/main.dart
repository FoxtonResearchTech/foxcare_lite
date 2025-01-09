import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/pages/customerService/admin_chat_panel.dart';
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
      home: EmployeeRegistration(),
    );
  }
}
