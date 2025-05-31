import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/presentation/module/management/user/doctor_and_counter_setup.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/user_information/user_information_drawer.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../../../login/login.dart';
import '../generalInformation/general_information_admission_status.dart';
import 'edit_delete_user_account.dart';

class UserAccountCreation extends StatefulWidget {
  @override
  State<UserAccountCreation> createState() => _UserAccountCreation();
}

class _UserAccountCreation extends State<UserAccountCreation> {
  int selectedIndex = 0;

  String? positionSelectedValue;
  String? relationSelectedValue;
  String? selectedSpecialization;

  String? selectedSex;
  bool isLoading = false;

  // Controllers for employee details
  final TextEditingController empCodeController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController relationNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phone1Controller = TextEditingController();
  final TextEditingController phone2Controller = TextEditingController();

  // Controllers for permanent address
  final TextEditingController lane1Controller = TextEditingController();
  final TextEditingController lane2Controller = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // Controllers for temporary address
  final TextEditingController tempLane1Controller = TextEditingController();
  final TextEditingController tempLane2Controller = TextEditingController();
  final TextEditingController tempLandmarkController = TextEditingController();
  final TextEditingController tempCityController = TextEditingController();
  final TextEditingController tempStateController = TextEditingController();
  final TextEditingController tempPinCodeController = TextEditingController();

  // Controllers for Qualification details
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController registerNoController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();

  // Controllers for PG Qualification details
  final TextEditingController pgQualificationController =
      TextEditingController();
  final TextEditingController pgRegisterNoController = TextEditingController();
  final TextEditingController pgUniversityController = TextEditingController();
  final TextEditingController pgCollegeController = TextEditingController();

  // Controllers for password
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController dobController = TextEditingController();

  bool isSameAsPermanent = true;
  bool isPostgraduate = false;

  void populateTemporaryAddress() {
    tempLane1Controller.text = lane1Controller.text;
    tempLane2Controller.text = lane2Controller.text;
    tempLandmarkController.text = landmarkController.text;
    tempCityController.text = cityController.text;
    tempStateController.text = stateController.text;
    tempPinCodeController.text = pinCodeController.text;
  }

  void clearTemporaryAddress() {
    tempLane1Controller.clear();
    tempLane2Controller.clear();
    tempLandmarkController.clear();
    tempCityController.clear();
    tempStateController.clear();
    tempPinCodeController.clear();
  }

  bool isDoc = false;

  void isDoctor(String value) {
    setState(() {
      isDoc = value == 'Doctor';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<String?> askAdminPassword(BuildContext context) async {
    final TextEditingController adminPasswordController =
        TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const CustomText(
            text: 'Confirm Management Password',
            size: 20,
          ),
          content: Container(
              width: 350,
              height: 200,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  SizedBox(
                    width: 75,
                    height: 100,
                    child: Center(
                      child: Lottie.asset(
                        'assets/button_loading.json',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Management Password',
                        size: 15,
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                          controller: adminPasswordController,
                          hintText: '',
                          width: 250),
                    ],
                  ),
                ],
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: CustomText(
                text: 'Cancel',
                color: AppColors.blue,
              ),
            ),
            TextButton(
              onPressed: () {
                final password = adminPasswordController.text.trim();
                if (password.isNotEmpty) {
                  Navigator.pop(context, password); // Return password
                }
              },
              child: CustomText(
                text: 'Confirm',
                color: AppColors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> registerEmployee() async {
    setState(() {
      isLoading = true;
    });

    // Step 1: Save current admin credentials
    final currentUser = FirebaseAuth.instance.currentUser;
    final adminEmail = currentUser?.email;
    final adminPassword = await askAdminPassword(context);
    if (adminPassword == null || adminPassword.isEmpty) {
      CustomSnackBar(context,
          message: 'Registration cancelled', backgroundColor: Colors.red);
      setState(() => isLoading = false);
      return;
    }

    try {
      String email = emailController.text.trim();
      if (!email.endsWith('@gmail.com')) {
        email += '@gmail.com';
      }

      // Step 2: Create new employee (this signs you in as them)
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: passwordController.text.trim(),
      );

      // Step 3: Write employee data to Firestore
      final firestore = FirebaseFirestore.instance;
      if (positionSelectedValue != null) {
        String docId = userCredential.user!.uid;

        await firestore.collection('employees').doc(docId).set({
          'docId': docId,
          'empCode': emailController.text.endsWith('@gmail.com')
              ? emailController.text
              : '${emailController.text}@gmail.com',
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'relationName': relationNameController.text,
          'relationType': relationSelectedValue,
          'email': empCodeController.text,
          'password': passwordController.text,
          'phone1': phone1Controller.text,
          'phone2': phone2Controller.text,
          'gender': selectedSex,
          'dob': dobController.text,
          'roles': positionSelectedValue,
          'specialization': selectedSpecialization,
          'address': {
            'permanent': {
              'lane1': lane1Controller.text,
              'lane2': lane2Controller.text,
              'landmark': landmarkController.text,
              'city': cityController.text,
              'state': stateController.text,
              'pincode': pinCodeController.text,
            },
            'temporary': {
              'lane1': tempLane1Controller.text,
              'lane2': tempLane2Controller.text,
              'landmark': tempLandmarkController.text,
              'city': tempCityController.text,
              'state': tempStateController.text,
              'pincode': tempPinCodeController.text,
            },
          },
          'qualification': {
            'ug': {
              'degree': qualificationController.text,
              'registerNo': registerNoController.text,
              'university': universityController.text,
              'college': collegeController.text,
            },
            if (isPostgraduate) ...{
              'pg': {
                'degree': pgQualificationController.text,
                'registerNo': pgRegisterNoController.text,
                'university': pgUniversityController.text,
                'college': pgCollegeController.text,
              }
            }
          },
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Step 4: Sign out the employee
      await FirebaseAuth.instance.signOut();

      // Step 5: Re-login the admin
      if (adminEmail != null && adminPassword.isNotEmpty) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        )
            .then((_) {
          debugPrint('Admin re-logged in successfully');
        });
      }

      CustomSnackBar(context,
          message: 'Employee registered successfully!',
          backgroundColor: Colors.green);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        CustomSnackBar(context,
            message: 'Email Already In Use', backgroundColor: Colors.orange);
      } else if (e.code == 'weak-password') {
        CustomSnackBar(context,
            message: 'The password is too weak',
            backgroundColor: Colors.orange);
      } else {
        CustomSnackBar(context,
            message: 'Registration failed', backgroundColor: Colors.red);
      }
    } catch (e) {
      CustomSnackBar(
        context,
        message: 'An error occurred: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
                text: 'User Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: UserInformationDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: UserInformationDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: screenWidth * 0.02,
                right: screenWidth * 0.02,
                bottom: screenWidth * 0.05,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenWidth * 0.01),
                        child: Column(
                          children: [
                            CustomText(
                              text: "Employee Creation",
                              size: screenWidth * 0.03,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                          image: const DecorationImage(
                            image: AssetImage('assets/foxcare_lite_logo.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Position',
                            size: screenWidth * 0.015,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomDropdown(
                            label: '',
                            items: const [
                              'Management',
                              'Pharmacist',
                              'Receptionist',
                              'Doctor',
                              'Manager',
                              'Lab Assistance',
                              'X-Ray Technician'
                            ],
                            selectedItem: positionSelectedValue,
                            onChanged: (value) {
                              setState(() {
                                positionSelectedValue = value!;
                                isDoctor(positionSelectedValue!);
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Emp Code',
                            size: screenWidth * 0.015,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: emailController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  if (isDoc)
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Specialization',
                              size: screenWidth * 0.012,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            CustomDropdown(
                              label: '',
                              items: const [
                                'General Physician',
                                'Pediatrician',
                                'Cardiologist',
                                'Dermatologist',
                                'Neurologist',
                                'Orthopedic Surgeon',
                                'ENT Specialist',
                                'Gynecologist',
                                'Ophthalmologist',
                                'Psychiatrist',
                              ],
                              selectedItem: selectedSpecialization,
                              onChanged: (value) {
                                setState(() {
                                  selectedSpecialization = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'First Name',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: firstNameController,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Last Name',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: lastNameController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Father's /Mother's /Guardian's Name",
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: "",
                            width: screenWidth * 0.25,
                            controller: relationNameController,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Relation',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomDropdown(
                            label: '',
                            items: const ['Father', 'Mother', 'Guardian'],
                            selectedItem: relationSelectedValue,
                            onChanged: (value) {
                              setState(() {
                                relationSelectedValue = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Sex',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomDropdown(
                            label: '',
                            items: const [
                              'Male',
                              'Female',
                            ],
                            selectedItem: selectedSex,
                            onChanged: (value) {
                              setState(() {
                                selectedSex = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Date Of Birth',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            controller: dobController,
                            hintText: '',
                            width: screenWidth * 0.15,
                            icon: const Icon(Icons.date_range),
                            onTap: () => _selectDate(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      CustomText(
                        text: 'Permanent Address',
                        size: screenWidth * 0.02,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Lane 1',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: lane1Controller,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Lane 2',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: lane2Controller,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Landmark',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.612,
                            controller: landmarkController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'City',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.20,
                            controller: cityController,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'State',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.20,
                            controller: stateController,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Pin code',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.20,
                            controller: pinCodeController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'E-Mail ID',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.20,
                            controller: empCodeController,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone No 1',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.20,
                            controller: phone1Controller,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone No 2',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.20,
                            controller: phone2Controller,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Checkboxes for Temporary Address
                  Row(
                    children: [
                      Radio<bool>(
                        activeColor: AppColors.blue,
                        value: false,
                        groupValue: isSameAsPermanent,
                        onChanged: (value) {
                          setState(() {
                            isSameAsPermanent = value!;
                            populateTemporaryAddress();
                          });
                        },
                      ),
                      const CustomText(text: 'Same as Above'),
                      SizedBox(width: screenWidth * 0.08),
                      Radio<bool>(
                        activeColor: AppColors.blue,
                        value: true,
                        groupValue: isSameAsPermanent,
                        onChanged: (value) {
                          setState(() {
                            isSameAsPermanent = value!;
                            clearTemporaryAddress();
                          });
                        },
                      ),
                      const CustomText(text: 'Different'),
                    ],
                  ),

                  // Temporary Address Fields
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      CustomText(
                        text: 'Temporary Address',
                        size: screenWidth * 0.02,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Lane 1',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: tempLane1Controller,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Lane 2',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: tempLane2Controller,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Landmark',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.612,
                            controller: tempLandmarkController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'City',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.20,
                            controller: tempCityController,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'State',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.20,
                            controller: tempStateController,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Pin code',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.20,
                            controller: tempPinCodeController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      CustomText(
                        text: 'Education Qualification',
                        size: screenWidth * 0.02,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Qualification',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: qualificationController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Register No',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: registerNoController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'University',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: universityController,
                          ),
                        ],
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'College',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: collegeController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: AppColors.blue,
                        value: isPostgraduate,
                        onChanged: (value) {
                          setState(() {
                            isPostgraduate = value!;
                          });
                        },
                      ),
                      const CustomText(text: 'Postgraduate Qualification'),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (isPostgraduate) ...[
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Qualification',
                              size: screenWidth * 0.012,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            CustomTextField(
                              hintText: '',
                              width: screenWidth * 0.25,
                              controller: pgQualificationController,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Register No',
                              size: screenWidth * 0.012,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            CustomTextField(
                              hintText: '',
                              width: screenWidth * 0.25,
                              controller: pgRegisterNoController,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'University',
                              size: screenWidth * 0.012,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            CustomTextField(
                              hintText: '',
                              width: screenWidth * 0.25,
                              controller: pgUniversityController,
                            ),
                          ],
                        ),
                        SizedBox(width: screenHeight * 0.1),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'College',
                              size: screenWidth * 0.012,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            CustomTextField(
                              hintText: '',
                              width: screenWidth * 0.25,
                              controller: pgCollegeController,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      CustomText(
                        text: 'Password',
                        size: screenWidth * 0.02,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Password',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          CustomTextField(
                            hintText: '',
                            width: screenWidth * 0.25,
                            controller: passwordController,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isLoading
                          ? SizedBox(
                              width: screenWidth * 0.2,
                              height: screenHeight * 0.05,
                              child: Lottie.asset(
                                'assets/button_loading.json', // Ensure the file path is correct
                                fit: BoxFit.contain,
                              ),
                            )
                          : CustomButton(
                              label: 'Create',
                              onPressed: () async {
                                if (emailController.text.isEmpty &&
                                    passwordController.text.isEmpty) {
                                  CustomSnackBar(context,
                                      message:
                                          'Make Sure You Have Entered Email & Password',
                                      backgroundColor: Colors.orange);
                                  return;
                                }
                                await registerEmployee();
                              },
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.05,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
