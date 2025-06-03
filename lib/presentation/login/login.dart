// ... Your existing imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/manager/manager_dashboard.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:lottie/lottie.dart';
import '../../utilities/images.dart';
import '../../utilities/widgets/buttons/primary_button.dart';

import '../../utilities/widgets/textField/secondary_text_field.dart';
import '../module/doctor/doctor_dashboard.dart';
import '../module/lab/dashboard.dart';
import '../module/pharmacy/dashboard/pharmecy_dashboard.dart';
import '../module/reception/patient_registration.dart';
import '../module/reception/reception_dashboard.dart';
import 'fetch_user.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg_img.jpg',
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = MediaQuery.of(context).size.width;
              double screenHeight = MediaQuery.of(context).size.height;

              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.28),
                      child: Center(
                        child: Column(
                          children: [
                            Image.asset(
                              AppImages.logo,
                              width: screenWidth * 0.25,
                              height: screenHeight * 0.25,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.14),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/hospital_logo_demo.png',
                                    width: screenWidth * 0.1,
                                    height: screenHeight * 0.1,
                                  ),
                                  Container(width: 2.5, height: 50, color: Colors.grey),
                                  Image.asset(
                                    'assets/NIH_Logo.png',
                                    width: screenWidth * 0.1,
                                    height: screenHeight * 0.1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: LoginForm(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool showPassword = false;
  bool isLoading = false;

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
        CustomText(
          text: 'Welcome back !',
          size: screenWidth * 0.0225,
          color: AppColors.lightBlue,
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomText(
          text: 'User Email',
          size: screenWidth * 0.0125,
          color: AppColors.lightBlue,
        ),
        SecondaryTextField(
          controller: _emailController,
          hintText: '',
          suffixText: '@gmail.com',
          width: screenWidth * 0.25,
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomText(
          text: 'Password',
          size: screenWidth * 0.0125,
          color: AppColors.lightBlue,
        ),
        SecondaryTextField(
          controller: _passwordController,
          obscureText: !showPassword,
          hintText: '',
          width: screenWidth * 0.25,
        ),
        SizedBox(height: screenHeight * 0.03),
        Row(
          children: [
            Checkbox(
              checkColor: Colors.white,
              activeColor: AppColors.lightBlue,
              side: BorderSide(color: AppColors.lightBlue, width: 2),
              value: showPassword,
              onChanged: (value) {
                setState(() {
                  showPassword = value!;
                });
              },
            ),
            CustomText(
              text: "Show Password",
              color: AppColors.lightBlue,
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            SizedBox(width: screenWidth * 0.09),
            isLoading
                ? Lottie.asset('assets/login_lottie.json',height: 150,width: 150)
                : CustomButton(
              label: 'Login',
              onPressed: _login,
              width: screenWidth * 0.09,
              height: screenHeight * 0.05,
            ),
          ],
        )
      ],
    );
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (!email.endsWith('@gmail.com')) {
      email += '@gmail.com';
    }

    if (email.isEmpty || password.isEmpty) {
      CustomSnackBar(context,
          message: 'Email and Password cannot be empty.',
          backgroundColor: Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(userCredential.user!.uid)
          .get();

      if (!employeeDoc.exists) {
        CustomSnackBar(context,
            message: 'User not found in employees collection',
            backgroundColor: Colors.red);
        return;
      }

      Map<String, dynamic> employeeData =
      employeeDoc.data() as Map<String, dynamic>;
      String? position = employeeData['roles'];

      if (position == null || position.isEmpty) {
        CustomSnackBar(context,
            message: 'Position information is missing.',
            backgroundColor: Colors.red);
        return;
      }

      await UserSession.initUser();

      switch (position) {
        case 'Management':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ManagementDashboard()));
          break;
        case 'Pharmacist':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SalesChartScreen()));
          break;
        case 'Receptionist':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReceptionDashboard()));
          break;
        case 'Lab Assistance':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LabDashboard()));
          break;
        case 'X-Ray Technician':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PatientRegistration()));
          break;
        case 'Doctor':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DoctorDashboard()));
          break;
        case 'Manager':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ManagerDashboard()));
          break;
        default:
          CustomSnackBar(context,
              message: 'Invalid position information.',
              backgroundColor: Colors.red);
      }

      CustomSnackBar(context,
          message: 'Logged in as $position', backgroundColor: Colors.green);
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Authentication error: ${e.message}';
      }

      CustomSnackBar(context, message: message, backgroundColor: Colors.red);
    } catch (e) {
      CustomSnackBar(context,
          message: 'An unexpected error occurred: $e',
          backgroundColor: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
class SecondaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double width;
  final bool obscureText;
  final String? suffixText;
  final Color? fillColor;

  const SecondaryTextField({
    required this.controller,
    required this.hintText,
    required this.width,
    this.obscureText = false,
    this.suffixText,
    this.fillColor = const Color(0xFFF5F5F5), // Default light gray if not provided
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,

          // suffixText: suffixText,
          filled: true,
          fillColor: AppColors.blue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

