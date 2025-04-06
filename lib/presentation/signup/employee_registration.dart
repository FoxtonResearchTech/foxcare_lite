import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/login/login.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:intl/intl.dart';

import '../../utilities/colors.dart';
import '../../utilities/widgets/buttons/primary_button.dart';
import '../../utilities/widgets/text/primary_text.dart';
import '../../utilities/widgets/textField/primary_textField.dart';

class EmployeeRegistration extends StatefulWidget {
  const EmployeeRegistration({super.key});

  @override
  State<EmployeeRegistration> createState() => _EmployeeRegistrationState();
}

class _EmployeeRegistrationState extends State<EmployeeRegistration> {
  String? positionSelectedValue;
  String? relationSelectedValue;
  String? selectedSpecialization;

  String? selectedSex;

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

  Future<void> registerEmployee() async {
    try {
      // Authenticate user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final firestore = FirebaseFirestore.instance;

      if (positionSelectedValue != null) {
        String docId = userCredential.user!.uid;

        // Create the employee document
        await firestore
            .collection('employees')
            .doc(docId)
            .set({
              'docId': docId, // Store the document ID
              'empCode': empCodeController.text,
              'firstName': firstNameController.text,
              'lastName': lastNameController.text,
              'relationName': relationNameController.text,
              'relationType': relationSelectedValue,
              'email': emailController.text,
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
            })
            .then((value) => debugPrint('Employee added successfully'))
            .catchError(
                (error) => debugPrint('Failed to add employee: $error'));
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      CustomSnackBar(context,
          message: 'Employee registered successfully!',
          backgroundColor: Colors.green);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showMessage('Email already in use.');
      } else if (e.code == 'weak-password') {
        showMessage('The password is too weak.');
      } else {
        showMessage('Registration failed: ${e.message}');
      }
    } catch (e) {
      showMessage('An error occurred: $e');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: CustomText(
            text: 'Employee Registration',
            size: screenWidth * 0.015,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: screenHeight * 0.05,
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                bottom: screenWidth * 0.05,
              ),
              child: Column(
                children: [
                  const CustomText(text: 'Pharmacist Details'),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    children: [
                      CustomDropdown(
                        label: 'Position',
                        items: const [
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
                      SizedBox(width: screenHeight * 0.2),
                      CustomTextField(
                        hintText: 'Emp Code',
                        width: screenWidth * 0.25,
                        controller: empCodeController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  if (isDoc)
                    Row(
                      children: [
                        CustomDropdown(
                          label: 'Specialization',
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
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'First Name',
                        width: screenWidth * 0.25,
                        controller: firstNameController,
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      CustomTextField(
                        hintText: 'Last Name',
                        width: screenWidth * 0.25,
                        controller: lastNameController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText:
                            "Father's Name / Mother's Name / Guardian's Name",
                        width: screenWidth * 0.25,
                        controller: relationNameController,
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      CustomDropdown(
                        label: 'Relation',
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
                  SizedBox(height: screenHeight * 0.02),

                  Row(
                    children: [
                      CustomDropdown(
                        label: 'Sex',
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
                      SizedBox(width: screenHeight * 0.2),
                      CustomTextField(
                        controller: dobController,
                        hintText: 'Date of Birth',
                        width: screenWidth * 0.15,
                        icon: const Icon(Icons.date_range),
                        onTap: () => _selectDate(context),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  const CustomText(text: 'Permanent Address'),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'Lane 1',
                        width: screenWidth * 0.25,
                        controller: lane1Controller,
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      CustomTextField(
                        hintText: 'Lane 2',
                        width: screenWidth * 0.25,
                        controller: lane2Controller,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'Landmark',
                        width: screenWidth * 0.595,
                        controller: landmarkController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'City',
                        width: screenWidth * 0.20,
                        controller: cityController,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'State',
                        width: screenWidth * 0.20,
                        controller: stateController,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'Pin code',
                        width: screenWidth * 0.20,
                        controller: pinCodeController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'E-Mail ID',
                        width: screenWidth * 0.20,
                        controller: emailController,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'Phone No 1',
                        width: screenWidth * 0.20,
                        controller: phone1Controller,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'Phone No 2',
                        width: screenWidth * 0.20,
                        controller: phone2Controller,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Checkboxes for Temporary Address
                  Row(
                    children: [
                      Checkbox(
                        value: isSameAsPermanent,
                        onChanged: (value) {
                          setState(() {
                            isSameAsPermanent = value!;
                            if (isSameAsPermanent) {
                              populateTemporaryAddress();
                            } else {
                              clearTemporaryAddress();
                            }
                          });
                        },
                      ),
                      const Text('Same as Above'),
                      SizedBox(width: screenWidth * 0.1),
                      Checkbox(
                        value: !isSameAsPermanent,
                        onChanged: (value) {
                          setState(() {
                            isSameAsPermanent = !value!;
                            if (isSameAsPermanent) {
                              populateTemporaryAddress();
                            } else {
                              clearTemporaryAddress();
                            }
                          });
                        },
                      ),
                      const Text('Different'),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Temporary Address Fields
                  const CustomText(text: 'Temporary Address'),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'Lane 1',
                        width: screenWidth * 0.25,
                        controller: tempLane1Controller,
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      CustomTextField(
                        hintText: 'Lane 2',
                        width: screenWidth * 0.25,
                        controller: tempLane2Controller,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'Landmark',
                        width: screenWidth * 0.595,
                        controller: tempLandmarkController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'City',
                        width: screenWidth * 0.20,
                        controller: tempCityController,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'State',
                        width: screenWidth * 0.20,
                        controller: tempStateController,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'Pin code',
                        width: screenWidth * 0.20,
                        controller: tempPinCodeController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  const CustomText(text: 'Education Qualification'),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'Qualification',
                        width: screenWidth * 0.25,
                        controller: qualificationController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'Register No',
                        width: screenWidth * 0.25,
                        controller: registerNoController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'University',
                        width: screenWidth * 0.25,
                        controller: universityController,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'University',
                        width: screenWidth * 0.25,
                        controller: collegeController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    children: [
                      Checkbox(
                        value: isPostgraduate,
                        onChanged: (value) {
                          setState(() {
                            isPostgraduate = value!;
                          });
                        },
                      ),
                      const Text('Postgraduate Qualification'),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (isPostgraduate) ...[
                    Row(
                      children: [
                        CustomTextField(
                          hintText: 'Qualification',
                          width: screenWidth * 0.25,
                          controller: pgQualificationController,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        CustomTextField(
                          hintText: 'Register No',
                          width: screenWidth * 0.25,
                          controller: pgRegisterNoController,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        CustomTextField(
                          hintText: 'University',
                          width: screenWidth * 0.25,
                          controller: pgUniversityController,
                        ),
                        SizedBox(width: screenHeight * 0.1),
                        CustomTextField(
                          hintText: 'University',
                          width: screenWidth * 0.25,
                          controller: pgCollegeController,
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: screenHeight * 0.02),
                  const CustomText(text: 'Password Details'),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'Password',
                        width: screenWidth * 0.25,
                        controller: passwordController,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        label: 'Create',
                        onPressed: () {
                          registerEmployee();
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
