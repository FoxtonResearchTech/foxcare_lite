import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foxcare_lite/presentation/pages/patient_registration.dart';
import 'package:foxcare_lite/presentation/signup/employee_registration.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import '../../utilities/images.dart';
import '../../utilities/widgets/buttons/primary_button.dart';
import '../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../utilities/widgets/image/custom_image.dart';
import '../../utilities/widgets/textField/primary_textField.dart';

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
  String? positionSelectedValue;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> roles = [
    'Pharmacist',
    'Receptionist',
    'Doctor',
    'Lab Assistance',
    'X-Ray Technician'
  ];

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
          text: 'Enter your credentials and role to access your account',
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
        CustomDropdown(
          label: 'Position',
          items: roles,
          selectedItem: positionSelectedValue,
          onChanged: (value) {
            setState(() {
              positionSelectedValue = value!;
            });
          },
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
    if (positionSelectedValue == null) {
      showMessage('Please select a role to continue.');
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email and Password cannot be empty.');
      return;
    }

    try {
      // Authenticate the user
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user!.uid;
      print(userId);

      // Access the 'details' document inside the position-specific subcollection
      DocumentSnapshot detailsDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(positionSelectedValue) // Subcollection name for the position
          .collection('details') // Subcollection for details
          .doc(userId) // Match the document ID with the userId
          .get();

      if (!detailsDoc.exists) {
        showMessage('User data not found for the selected role.');
        return;
      }

      // Fetch the position value from the document
      String? position = detailsDoc.get('position');

      // Validate if the position matches the selected role
      if (position != positionSelectedValue) {
        showMessage('Role mismatch. Please select the correct role.');
        return;
      }

      // Navigate to the appropriate screen based on the role
      switch (positionSelectedValue) {
        case 'Pharmacist':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PatientRegistration()));
          break;
        case 'Receptionist':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PatientRegistration()));
          break;
        case 'Doctor':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EmployeeRegistration()));
          break;
        case 'Lab Assistance':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PatientRegistration()));
          break;
        case 'X-Ray Technician':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PatientRegistration()));
          break;
        default:
          showMessage('Invalid role selected.');
      }

      showMessage('Logged in as $positionSelectedValue');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showMessage('No user found for this email.');
      } else if (e.code == 'wrong-password') {
        showMessage('Wrong password provided.');
      } else {
        showMessage('Login failed: ${e.message}');
      }
    } catch (e) {
      showMessage('An error occurred: $e');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
