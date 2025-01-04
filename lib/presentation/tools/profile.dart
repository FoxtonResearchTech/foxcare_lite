import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import 'manage_pharmacy_info.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
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
                    child: CircleAvatar(),
                  ),
                  Column(
                    children: [
                      const CustomText(text: 'Pharmacist details '),
                      SizedBox(height: screenHeight * 0.05),
                      Row(
                        children: [
                          CustomTextField(
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
                            hintText: 'Qualification',
                            width: screenWidth * 0.25,
                            icon: Icon(Icons.arrow_drop_down_rounded),
                          ),
                          SizedBox(width: screenHeight * 0.2),
                          CustomTextField(
                            hintText: 'Gender',
                            width: screenWidth * 0.25,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          CustomTextField(
                            hintText: 'Place',
                            width: screenWidth * 0.25,
                          ),
                          SizedBox(width: screenHeight * 0.2),
                          CustomTextField(
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
                        hintText: 'Lane 1',
                        width: screenWidth * 0.25,
                      ),
                      SizedBox(width: screenHeight * 0.2),
                      CustomTextField(
                        hintText: 'Lane 2',
                        width: screenWidth * 0.25,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'Landmark',
                        width: screenWidth * 0.61,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'City',
                        width: screenWidth * 0.20,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'State',
                        width: screenWidth * 0.20,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'Pin code',
                        width: screenWidth * 0.20,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'E-Mail ID',
                        width: screenWidth * 0.20,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'Phone NO 1',
                        width: screenWidth * 0.20,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'Phone Number 2',
                        width: screenWidth * 0.20,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CustomTextField(
                        hintText: 'Parents/Guardian Name',
                        width: screenWidth * 0.20,
                      ),
                      SizedBox(width: screenHeight * 0.1),
                      CustomTextField(
                        hintText: 'Phone',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
