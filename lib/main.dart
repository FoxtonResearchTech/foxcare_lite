import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_rx_list.dart';
import 'package:foxcare_lite/presentation/module/lab/dashboard.dart';
import 'package:foxcare_lite/presentation/module/lab/lab_accounts.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/manager/manager_dashboard.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/dashboard/pharmecy_dashboard.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/reports/non_moving_stock.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/reports/party_wise_statement.dart';
import 'package:foxcare_lite/presentation/module/reception/op_ticket.dart';
import 'package:foxcare_lite/presentation/module/reception/reception_dashboard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: DoctorRxList(),
    );
  }
}
