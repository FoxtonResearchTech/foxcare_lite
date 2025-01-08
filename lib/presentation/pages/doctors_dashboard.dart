import 'package:flutter/material.dart';

class DoctorsDashboard extends StatelessWidget {
  const DoctorsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Doctors Dashboard",
          style: TextStyle(fontFamily: 'SanFrancisco'),
        ),
      ),
    );
  }
}
