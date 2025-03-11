import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  Map<String, dynamic> user = {};
  Future<void> fetchProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('employees')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            user = userDoc.data() as Map<String, dynamic>;
          });
        } else {
          print("User document not found!");
        }
      } else {
        print("No user is logged in!");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  @override
  void initState() {
    fetchProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: screenHeight * 0.03,
                right: screenWidth * 0.01,
                bottom: screenWidth * 0.01,
              ),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.25,
                    child: const CircleAvatar(
                      backgroundImage: AssetImage('assets/splash.png'),
                    ),
                  ),
                  Column(
                    children: [
                      const CustomText(text: 'Pharmacist Details'),
                      SizedBox(height: screenHeight * 0.05),
                      Row(
                        children: [
                          CustomTextField(
                            readOnly: true,
                            controller: TextEditingController(
                                text: user['firstName'].toString() +
                                        user['lastName'].toString() ??
                                    ''),
                            hintText: 'Name',
                            width: screenWidth * 0.25,
                          ),
                          SizedBox(width: screenHeight * 0.66),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          CustomTextField(
                            readOnly: true,
                            controller: TextEditingController(
                                text: user['qualification']?['ug']?['degree']
                                        .toString() ??
                                    ''),
                            hintText: 'Qualification',
                            width: screenWidth * 0.25,
                          ),
                          SizedBox(width: screenHeight * 0.2),
                          CustomTextField(
                            readOnly: true,
                            controller: TextEditingController(
                                text: user['gender'] ?? ''),
                            hintText: 'Gender',
                            width: screenWidth * 0.25,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          CustomTextField(
                            readOnly: true,
                            controller: TextEditingController(
                                text: user['address']?['permanent']?['city'] ??
                                    ''),
                            hintText: 'Place',
                            width: screenWidth * 0.25,
                          ),
                          SizedBox(width: screenHeight * 0.2),
                          CustomTextField(
                            readOnly: true,
                            controller:
                                TextEditingController(text: user['dob'] ?? ''),
                            hintText: 'Date of Birth',
                            width: screenWidth * 0.25,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.05,
                  left: screenWidth * 0.08,
                  right: screenWidth * 0.08,
                  bottom: screenWidth * 0.05,
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(text: 'Communication Address'),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Row(
                      children: [
                        CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: user['address']?['permanent']?['lane1'] ??
                                  ''),
                          hintText: 'Lane 1',
                          width: screenWidth * 0.25,
                        ),
                        SizedBox(width: screenHeight * 0.2),
                        CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: user['address']?['permanent']?['lane2'] ??
                                  ''),
                          hintText: 'Lane 2',
                          width: screenWidth * 0.25,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: user['address']?['permanent']
                                      ?['landmark'] ??
                                  ''),
                          hintText: 'Landmark',
                          width: screenWidth * 0.61,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text:
                                  user['address']?['permanent']?['city'] ?? ''),
                          hintText: 'City',
                          width: screenWidth * 0.20,
                        ),
                        SizedBox(width: screenHeight * 0.1),
                        CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: user['address']?['permanent']?['state'] ??
                                  ''),
                          hintText: 'State',
                          width: screenWidth * 0.20,
                        ),
                        SizedBox(width: screenHeight * 0.1),
                        CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: user['address']?['permanent']?['pincode'] ??
                                  ''),
                          hintText: 'Pin code',
                          width: screenWidth * 0.20,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        CustomTextField(
                          readOnly: true,
                          controller:
                              TextEditingController(text: user['email'] ?? ''),
                          hintText: 'E-Mail ID',
                          width: screenWidth * 0.20,
                        ),
                        SizedBox(width: screenHeight * 0.1),
                        CustomTextField(
                          readOnly: true,
                          controller:
                              TextEditingController(text: user['phone1'] ?? ''),
                          hintText: 'Phone Number 1',
                          width: screenWidth * 0.20,
                        ),
                        SizedBox(width: screenHeight * 0.1),
                        CustomTextField(
                          readOnly: true,
                          controller:
                              TextEditingController(text: user['phone2'] ?? ''),
                          hintText: 'Phone Number 2',
                          width: screenWidth * 0.20,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: user['relationName'] ?? ''),
                          hintText: 'Parents/Guardian Name',
                          width: screenWidth * 0.20,
                        ),
                        SizedBox(width: screenHeight * 0.1),
                        CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: user['relationType'] ?? ''),
                          hintText: 'RelationType',
                          width: screenWidth * 0.20,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          label: 'Create',
                          onPressed: () {},
                          width: screenWidth * 0.08,
                          height: screenHeight * 0.05,
                        )
                      ],
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
