import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_appointment.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_billing.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_dashboard.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_opTickets.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_patient_registration.dart';
import 'package:foxcare_lite/presentation/module/dental/dental_pending_bills.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_edit_doctor_visit_schedule.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/manager/manager_dashboard.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/dashboard/pharmecy_dashboard.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/add_product.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/product_list.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/tools/add_new_distributor.dart';
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
        home: DentalPendingBills());
  }
}
