import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/manager/manager_dashboard.dart';
import 'package:foxcare_lite/utilities/colors.dart';
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.28),
                      child: Center(
                        child: Container(
                          child: Column(
                            children: [
                              Image.asset(
                                AppImages.logo,
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.25,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.14),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/hospital_logo_demo.png',
                                        width: screenWidth * 0.1,
                                        height: screenHeight * 0.1,
                                      ),
                                      Container(
                                          width: 2.5,
                                          height: 50,
                                          color: Colors.grey),
                                      Image.asset(
                                        'assets/NIH_Logo.png',
                                        width: screenWidth * 0.1,
                                        height: screenHeight * 0.1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
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
        SizedBox(
          width: screenWidth * 0.25,
          child: TextField(
            controller: _emailController,
            obscureText: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              isDense: true,
              hintStyle: TextStyle(
                color: AppColors.lightBlue,
                fontFamily: 'Poppins',
              ),
              labelStyle: TextStyle(
                color: AppColors.lightBlue,
                fontFamily: 'Poppins',
              ),
              floatingLabelStyle:
                  TextStyle(fontFamily: 'Poppins', color: AppColors.lightBlue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              fillColor: AppColors.blue,
              focusColor: AppColors.blue,
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightBlue, width: 2.0),
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.lightBlue, width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomText(
          text: 'Password',
          size: screenWidth * 0.0125,
          color: AppColors.lightBlue,
        ),
        SizedBox(
          width: screenWidth * 0.25,
          child: TextField(
            controller: _passwordController,
            obscureText: !showPassword,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              isDense: true,
              hintStyle: TextStyle(
                color: AppColors.lightBlue,
                fontFamily: 'Poppins',
              ),
              labelStyle: TextStyle(
                color: AppColors.lightBlue,
                fontFamily: 'Poppins',
              ),
              floatingLabelStyle:
                  TextStyle(fontFamily: 'Poppins', color: AppColors.lightBlue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              fillColor: AppColors.blue,
              focusColor: AppColors.blue,
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightBlue, width: 2.0),
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.lightBlue, width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
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
            ), // Optional label
          ],
        ),
        SizedBox(height: screenHeight * 0.03),
        Row(
          children: [
            SizedBox(width: screenWidth * 0.09),
            SizedBox(
              height: screenHeight * 0.05,
              width: screenWidth * 0.08,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.all(0), // Keep padding minimal
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20), // Set borderRadius to 12
                  ),
                ),
                onPressed: _login,
                child: Text(
                  'Login',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
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
        showMessage('User not found in employees collection.');
        return;
      }

      Map<String, dynamic> employeeData =
          employeeDoc.data() as Map<String, dynamic>;
      String? position = employeeData['roles'];

      if (position == null || position.isEmpty) {
        showMessage('Position information is missing.');
        return;
      }

      switch (position) {
        case 'Management':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManagementDashboard()),
          );
          break;
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
