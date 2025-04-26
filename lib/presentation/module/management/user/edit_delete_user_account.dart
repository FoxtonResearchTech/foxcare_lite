import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/user_information/user_information_drawer.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';

class EditDeleteUserAccount extends StatefulWidget {
  @override
  State<EditDeleteUserAccount> createState() => _EditDeleteUserAccount();
}

class _EditDeleteUserAccount extends State<EditDeleteUserAccount> {
  int selectedIndex = 1;
  String? positionSelectedValue;
  String? relationSelectedValue;
  String? selectedSpecialization;

  String? selectedSex;

  final TextEditingController empCodeSearch = TextEditingController();
  final TextEditingController phoneNumberSearch = TextEditingController();
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

  final List<String> headers = [
    'Name',
    'EMP Code',
    'Role',
    'Email',
    'Phone Number',
    'Gender',
    'City',
    'Action'
  ];
  List<Map<String, dynamic>> employeeData = [];

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

  Future<void> fetchData({String? empCode, String? phoneNumber}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('employees');

      if (empCode != null) {
        query = query.where('empCode', isEqualTo: empCode);
      } else if (phoneNumber != null) {
        query = query.where(Filter.or(
          Filter('phone1', isEqualTo: phoneNumber),
          Filter('phone2', isEqualTo: phoneNumber),
        ));
      }
      final QuerySnapshot snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        print("No records found");
        setState(() {
          employeeData = [];
        });
      }
      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        fetchedData.add({
          'Name': data['firstName'] + ' ' + data['lastName'] ?? 'N/A',
          'EMP Code': data['empCode'] ?? 'N/A',
          'Role': data['role'] ?? 'N/A',
          'Email': data['email'] ?? 'N/A',
          'Phone Number': data['phone1'] ?? 'N/A',
          'City': data['city'] ?? 'N/A',
          'Gender': data['gender'] ?? 'N/A',
          'Action': Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  bool isSameAsPermanent = true;
                  bool isPostgraduate = false;
                  bool isDoc = false;
                  void isDoctor(String value) {
                    setState(() {
                      isDoc = value == 'Doctor';
                    });
                  }

                  firstNameController.text = data['firstName'];
                  lastNameController.text = data['lastName'];
                  relationNameController.text = data['relationName'];
                  emailController.text = data['email'];
                  phone1Controller.text = data['phone1'];
                  phone2Controller.text = data['phone2'];
                  empCodeController.text = data['empCode'];
                  selectedSex = data['gender'];
                  relationSelectedValue = data['relationType'];
                  dobController.text = data['dob'];
                  positionSelectedValue = data['roles'];
                  selectedSpecialization = data['specialization'];
                  lane1Controller.text = data['address']['permanent']['lane1'];
                  lane2Controller.text = data['address']['permanent']['lane2'];
                  landmarkController.text =
                      data['address']['permanent']['landmark'];
                  cityController.text = data['address']['permanent']['city'];
                  stateController.text = data['address']['permanent']['state'];
                  pinCodeController.text =
                      data['address']['permanent']['pincode'];
                  if (positionSelectedValue == 'Doctor') {
                    isDoc = true;
                  }
                  if (data['address']['temporary'] != null) {
                    tempLane1Controller.text =
                        data['address']['temporary']['lane1'];
                    tempLane2Controller.text =
                        data['address']['temporary']['lane2'];
                    tempLandmarkController.text =
                        data['address']['temporary']['landmark'];
                    tempCityController.text =
                        data['address']['temporary']['city'];
                    tempStateController.text =
                        data['address']['temporary']['state'];
                  }
                  qualificationController.text =
                      data['qualification']['ug']['degree'];
                  registerNoController.text =
                      data['qualification']['ug']['registerNo'];
                  universityController.text =
                      data['qualification']['ug']['university'];
                  collegeController.text =
                      data['qualification']['ug']['college'];
                  if (data['qualification']['pg'] != null) {
                    isPostgraduate = true;
                    pgQualificationController.text =
                        data['qualification']['pg']['degree'];
                    pgRegisterNoController.text =
                        data['qualification']['pg']['registerNo'];
                    pgUniversityController.text =
                        data['qualification']['pg']['university'];
                    pgCollegeController.text =
                        data['qualification']['pg']['college'];
                  }
                  passwordController.text = data['password'];

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Edit Employee Details'),
                        content: StatefulBuilder(builder: (context, setState) {
                          return Container(
                            width: 800,
                            height: 1000,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CustomDropdown(
                                              label: 'Position',
                                              items: const [
                                                'Management',
                                                'Pharmacist',
                                                'Receptionist',
                                                'Doctor',
                                                'Manager',
                                                'Lab Assistance',
                                                'X-Ray Technician'
                                              ],
                                              selectedItem:
                                                  positionSelectedValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  positionSelectedValue =
                                                      value!;
                                                  isDoctor(
                                                      positionSelectedValue!);
                                                });
                                              },
                                            ),
                                            SizedBox(width: 100),
                                            CustomTextField(
                                              hintText: 'Emp Code',
                                              width: 300,
                                              controller: empCodeController,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
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
                                                selectedItem:
                                                    selectedSpecialization,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedSpecialization =
                                                        value!;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            CustomTextField(
                                              hintText: 'First Name',
                                              width: 300,
                                              controller: firstNameController,
                                            ),
                                            SizedBox(width: 100),
                                            CustomTextField(
                                              hintText: 'Last Name',
                                              width: 300,
                                              controller: lastNameController,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            CustomTextField(
                                              hintText:
                                                  "Father's Name / Mother's Name / Guardian's Name",
                                              width: 300,
                                              controller:
                                                  relationNameController,
                                            ),
                                            SizedBox(width: 100),
                                            CustomDropdown(
                                              label: 'Relation',
                                              items: const [
                                                'Father',
                                                'Mother',
                                                'Guardian'
                                              ],
                                              selectedItem:
                                                  relationSelectedValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  relationSelectedValue =
                                                      value!;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            CustomDropdown(
                                              label: 'Sex',
                                              items: const ['Male', 'Female'],
                                              selectedItem: selectedSex,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedSex = value!;
                                                });
                                              },
                                            ),
                                            SizedBox(width: 100),
                                            CustomTextField(
                                              controller: dobController,
                                              hintText: 'Date of Birth',
                                              width: 200,
                                              icon:
                                                  const Icon(Icons.date_range),
                                              onTap: () => _selectDate(context),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 40),
                                        const CustomText(
                                            text: 'Permanent Address'),
                                        SizedBox(height: 30),
                                        Row(
                                          children: [
                                            CustomTextField(
                                              hintText: 'Lane 1',
                                              width: 300,
                                              controller: lane1Controller,
                                            ),
                                            SizedBox(width: 100),
                                            CustomTextField(
                                              hintText: 'Lane 2',
                                              width: 300,
                                              controller: lane2Controller,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        CustomTextField(
                                          hintText: 'Landmark',
                                          width: 700,
                                          controller: landmarkController,
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            CustomTextField(
                                                hintText: 'City',
                                                width: 200,
                                                controller: cityController),
                                            SizedBox(width: 60),
                                            CustomTextField(
                                                hintText: 'State',
                                                width: 200,
                                                controller: stateController),
                                            SizedBox(width: 60),
                                            CustomTextField(
                                                hintText: 'Pin code',
                                                width: 200,
                                                controller: pinCodeController),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            CustomTextField(
                                                hintText: 'E-Mail ID',
                                                width: 200,
                                                controller: emailController),
                                            SizedBox(width: 60),
                                            CustomTextField(
                                                hintText: 'Phone No 1',
                                                width: 200,
                                                controller: phone1Controller),
                                            SizedBox(width: 60),
                                            CustomTextField(
                                                hintText: 'Phone No 2',
                                                width: 200,
                                                controller: phone2Controller),
                                          ],
                                        ),
                                        SizedBox(height: 20),
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
                                            SizedBox(width: 100),
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
                                        SizedBox(height: 20),
                                        const CustomText(
                                            text: 'Temporary Address'),
                                        SizedBox(height: 30),
                                        Row(
                                          children: [
                                            CustomTextField(
                                              hintText: 'Lane 1',
                                              width: 300,
                                              controller: tempLane1Controller,
                                            ),
                                            SizedBox(width: 100),
                                            CustomTextField(
                                              hintText: 'Lane 2',
                                              width: 300,
                                              controller: tempLane2Controller,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        CustomTextField(
                                          hintText: 'Landmark',
                                          width: 700,
                                          controller: tempLandmarkController,
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            CustomTextField(
                                                hintText: 'City',
                                                width: 200,
                                                controller: tempCityController),
                                            SizedBox(width: 60),
                                            CustomTextField(
                                                hintText: 'State',
                                                width: 200,
                                                controller:
                                                    tempStateController),
                                            SizedBox(width: 60),
                                            CustomTextField(
                                                hintText: 'Pin code',
                                                width: 200,
                                                controller:
                                                    tempPinCodeController),
                                          ],
                                        ),
                                        SizedBox(height: 40),
                                        const CustomText(
                                            text: 'Education Qualification'),
                                        SizedBox(height: 30),
                                        CustomTextField(
                                          hintText: 'Qualification',
                                          width: 300,
                                          controller: qualificationController,
                                        ),
                                        SizedBox(height: 20),
                                        CustomTextField(
                                          hintText: 'Register No',
                                          width: 300,
                                          controller: registerNoController,
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            CustomTextField(
                                              hintText: 'University',
                                              width: 300,
                                              controller: universityController,
                                            ),
                                            SizedBox(width: 60),
                                            CustomTextField(
                                              hintText: 'College',
                                              width: 300,
                                              controller: collegeController,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 40),
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
                                            const Text(
                                                'Postgraduate Qualification'),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        if (isPostgraduate) ...[
                                          CustomTextField(
                                            hintText: 'Qualification',
                                            width: 300,
                                            controller:
                                                pgQualificationController,
                                          ),
                                          SizedBox(height: 20),
                                          CustomTextField(
                                            hintText: 'Register No',
                                            width: 300,
                                            controller: pgRegisterNoController,
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            children: [
                                              CustomTextField(
                                                hintText: 'University',
                                                width: 300,
                                                controller:
                                                    pgUniversityController,
                                              ),
                                              SizedBox(width: 60),
                                              CustomTextField(
                                                hintText: 'College',
                                                width: 300,
                                                controller: pgCollegeController,
                                              ),
                                            ],
                                          ),
                                        ],
                                        SizedBox(height: 20),
                                        const CustomText(
                                            text: 'Password Details'),
                                        SizedBox(height: 30),
                                        CustomTextField(
                                          hintText: 'Password',
                                          width: 300,
                                          controller: passwordController,
                                        ),
                                        SizedBox(height: 40),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              try {
                                final firestore = FirebaseFirestore.instance;

                                if (data['docId'] != null) {
                                  await firestore
                                      .collection('employees')
                                      .doc(data['docId'])
                                      .update({
                                        'empCode': empCodeController.text,
                                        'firstName': firstNameController.text,
                                        'lastName': lastNameController.text,
                                        'relationName':
                                            relationNameController.text,
                                        'relationType': relationSelectedValue,
                                        'email': emailController.text,
                                        'password': passwordController.text,
                                        'phone1': phone1Controller.text,
                                        'phone2': phone2Controller.text,
                                        'gender': selectedSex,
                                        'dob': dobController.text,
                                        'roles': positionSelectedValue,
                                        'specialization':
                                            selectedSpecialization,
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
                                            'landmark':
                                                tempLandmarkController.text,
                                            'city': tempCityController.text,
                                            'state': tempStateController.text,
                                            'pincode':
                                                tempPinCodeController.text,
                                          },
                                        },
                                        'qualification': {
                                          'ug': {
                                            'degree':
                                                qualificationController.text,
                                            'registerNo':
                                                registerNoController.text,
                                            'university':
                                                universityController.text,
                                            'college': collegeController.text,
                                          },
                                          if (isPostgraduate) ...{
                                            'pg': {
                                              'degree':
                                                  pgQualificationController
                                                      .text,
                                              'registerNo':
                                                  pgRegisterNoController.text,
                                              'university':
                                                  pgUniversityController.text,
                                              'college':
                                                  pgCollegeController.text,
                                            }
                                          }
                                        },
                                        'updatedAt': FieldValue
                                            .serverTimestamp(), // <-- changed from createdAt
                                      })
                                      .then((value) => debugPrint(
                                          'Employee updated successfully'))
                                      .catchError((error) => debugPrint(
                                          'Failed to update employee: $error'));
                                }

                                CustomSnackBar(
                                  context,
                                  message: 'Employee updated successfully!',
                                  backgroundColor: Colors.green,
                                );
                                Navigator.of(context).pop();
                              } catch (e) {
                                CustomSnackBar(
                                  context,
                                  message: 'An error occurred: $e',
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                            child: CustomText(
                              text: 'Submit ',
                              color: AppColors.secondaryColor,
                              size: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: CustomText(
                              text: 'Cancel',
                              color: AppColors.secondaryColor,
                              size: 15,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const CustomText(text: 'Edit'),
              ),
              TextButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Deletion Conformation'),
                        content: Container(
                          width: 100,
                          height: 25,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomText(
                                  text: 'Are you sure you want to delete ?'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('employees')
                                      .doc(data['docId'])
                                      .delete();

                                  CustomSnackBar(context,
                                      message: 'Employee Details Deleted');
                                } catch (e) {
                                  print(
                                      'Error updating status for patient ${data['patientID']}: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Failed to update status')),
                                  );
                                }
                                Navigator.pop(context);
                              },
                              child: CustomText(text: 'Delete')),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: CustomText(text: 'Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const CustomText(text: 'Delete'),
              ),
            ],
          ),
        });
      }

      setState(() {
        employeeData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
            bottom: screenWidth * 0.25,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.03),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Employee Information",
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
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      image: const DecorationImage(
                        image: AssetImage('assets/foxcare_lite_logo.png'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    hintText: 'EMP Code',
                    width: screenWidth * 0.15,
                    controller: empCodeSearch,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(empCode: empCodeSearch.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  CustomTextField(
                    hintText: 'Phone Number',
                    width: screenWidth * 0.15,
                    controller: phoneNumberSearch,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(phoneNumber: phoneNumberSearch.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(headers: headers, tableData: employeeData),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
