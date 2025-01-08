import 'package:flutter/material.dart';


import 'presentation/dashboard/pharmecy_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the window manager


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoxCare Lite',
      home: SalesChartScreen(),
    );
  }
}
