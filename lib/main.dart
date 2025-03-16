import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/login/login.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_rx_list.dart';
import 'package:foxcare_lite/presentation/module/doctor/patient_view.dart';
import 'package:foxcare_lite/presentation/module/lab/patients_lab_details.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/billings/cancel_bill.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/billings/counter_sales.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/billings/ip_billing.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/billings/medicine_return.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/billings/op_billing.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/reports/stock_return_statement.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/purchase.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/purchase_entry.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/stock_return.dart';

import 'package:foxcare_lite/presentation/module/pharmacy/tools/distributor_list.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/tools/manage_pharmacy_info.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/tools/pharmacy_info.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/tools/profile.dart';
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
        home: StockReturn());
  }
}
