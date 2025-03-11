import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/login/login.dart';

import 'package:foxcare_lite/presentation/module/pharmacy/tools/distributor_list.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/tools/manage_pharmacy_info.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/tools/pharmacy_info.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/tools/profile.dart';
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
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FoxCare Lite',
        home: Profile());
  }
}
