import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foxcare_lite/presentation/module/manager/manager_dashboard.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import '../../utilities/images.dart';
import '../../utilities/widgets/buttons/primary_button.dart';
import '../../utilities/widgets/image/custom_image.dart';
import '../../utilities/widgets/textField/primary_textField.dart';
import '../module/doctor/doctor_dashboard.dart';
import '../module/lab/dashboard.dart';
import '../module/pharmacy/dashboard/pharmecy_dashboard.dart';
import '../module/reception/patient_registration.dart';
import '../module/reception/reception_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        if (constraints.maxWidth > 600) {
          // Web or large screen: horizontal split
          return Row(
            children: [
              // Left side: Login form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(150, 0, 0, 0),
                  child: LoginForm(),
                ),
              ),
              Expanded(
                child: Center(
                  child: CustomImage(
                    path: AppImages.logo,
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.35,
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile: vertical split
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top half: Logo
              const Expanded(
                child: Center(
                  child: CustomImage(path: AppImages.logo),
                ),
              ),
              // Bottom half: Login form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: LoginForm(),
                ),
              ),
            ],
          );
        }
      },
    ));
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: 'Welcome back!',
        ),
        const CustomText(
          text: 'Enter your credentials to access your account',
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          controller: _emailController,
          hintText: 'Enter your email',
          width: screenWidth * 0.4,
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          hintText: 'Enter Password',
          obscureText: true,
          controller: _passwordController,
          width: screenWidth * 0.4,
        ),
        SizedBox(height: screenHeight * 0.03),
        Center(
          child: CustomButton(
            label: "Login",
            onPressed: _login,
            width: screenWidth * 0.1,
          ),
        )
      ],
    );
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email and Password cannot be empty.');
      return;
    }

    try {
      // Step 1: Authenticate user with FirebaseAuth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      QuerySnapshot roleSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(userCredential.user!.uid)
          .collection('roles')
          .get();

      if (roleSnapshot.docs.isEmpty) {
        showMessage('Role not found for the user.');
        return;
      }

      // Assuming only one role is assigned per user
      Map<String, dynamic> roleData =
          roleSnapshot.docs.first.data() as Map<String, dynamic>;
      String? position = roleData['position'];

      if (position == null || position.isEmpty) {
        showMessage('Position information is missing.');
        return;
      }

      // Step 3: Navigate based on position
      switch (position) {
        case 'Pharmacist':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SalesChartScreen()),
          );
          break;
        case 'Receptionist':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReceptionDashboard()),
          );
          break;
        case 'Lab Assistance':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LabDashboard()),
          );
          break;
        case 'X-Ray Technician':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PatientRegistration()),
          );
          break;
        case 'Doctor':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorDashboard()),
          );
          break;
        case 'Manager':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManagerDashboard()),
          );
          break;
        default:
          showMessage('Invalid position information.');
      }

      showMessage('Logged in as $position');
    } catch (e) {
      showMessage('An error occurred: $e');
      print('Error: $e');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
