import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/add_product.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/purchase.dart';
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
        home: AddProduct());
  }
}
