import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
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
                top: screenHeight * 0.02,
                right: screenWidth * 0.01,
                bottom: screenWidth * 0.01,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.08, right: screenWidth * 0.08),
                    child: TimeDateWidget(text: 'Profile'),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Section
                      Container(
                        width: screenWidth * 0.25,
                        height: screenHeight * 0.25,
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/splash.png'),
                          radius: 80,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),

                      // Details Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Pharmacist Details',
                              size: screenWidth * 0.018,
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Name Row
                            Row(
                              children: [
                                CustomText(
                                  text: 'Name : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text:
                                      '${user['firstName'] ?? 'N/A'} ${user['lastName'] ?? 'N/A'}',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Qualification and Gender Row
                            Row(
                              children: [
                                // Qualification
                                CustomText(
                                  text: 'Qualification : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['qualification']?['ug']?['degree']
                                          ?.toString() ??
                                      'N/A',
                                  size: screenWidth * 0.012,
                                ),
                                SizedBox(width: screenWidth * 0.1),

                                // Gender
                                CustomText(
                                  text: 'Gender : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['gender']?.toString() ?? 'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Address and DOB Row
                            Row(
                              children: [
                                // Qualification
                                CustomText(
                                  text: 'Place : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['address']?['permanent']
                                          ?['city'] ??
                                      'N/A',
                                  size: screenWidth * 0.012,
                                ),
                                SizedBox(width: screenWidth * 0.1),

                                // Gender
                                CustomText(
                                  text: 'DOB : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['dob']?.toString() ?? 'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: screenHeight * 0.05,
                left: screenWidth * 0.1,
                right: screenWidth * 0.08,
                bottom: screenHeight * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Communication Address',
                    size: screenWidth * 0.018,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomText(
                                  text: 'Lane 1 : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['address']?['permanent']
                                          ?['lane1'] ??
                                      'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                CustomText(
                                  text: 'Lane 2 : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['address']?['permanent']
                                          ?['lane2'] ??
                                      'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                CustomText(
                                  text: 'Landmark : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['address']?['permanent']
                                          ?['landmark'] ??
                                      'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                CustomText(
                                  text: 'City : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['address']?['permanent']
                                          ?['city'] ??
                                      'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                CustomText(
                                  text: 'E-Mail ID : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['email'] ?? 'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                CustomText(
                                  text: 'Relation Type : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['relationType'] ?? 'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.05),

                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomText(
                                  text: 'State : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['address']?['permanent']
                                          ?['state'] ??
                                      'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                CustomText(
                                  text: 'Pincode : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['address']?['permanent']
                                          ?['pincode'] ??
                                      'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                CustomText(
                                  text: 'Phone Number 1 : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['phone1'] ?? 'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                CustomText(
                                  text: 'Phone Number 2 : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['phone2'] ?? 'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                CustomText(
                                  text: 'Guardian Name : ',
                                  size: screenWidth * 0.012,
                                ),
                                CustomText(
                                  text: user['relationName'] ?? 'N/A',
                                  size: screenWidth * 0.012,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
