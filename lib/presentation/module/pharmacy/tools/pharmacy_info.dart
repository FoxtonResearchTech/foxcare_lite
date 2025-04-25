import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import 'manage_pharmacy_info.dart';

class PharmacyInfo extends StatefulWidget {
  const PharmacyInfo({super.key});

  @override
  State<PharmacyInfo> createState() => _PharmacyInfo();
}

class _PharmacyInfo extends State<PharmacyInfo> {
  TextEditingController pharmacyName = TextEditingController();
  TextEditingController hospitalName = TextEditingController();
  TextEditingController dlNo1Controller = TextEditingController();
  TextEditingController expiryDate1Controller = TextEditingController();
  TextEditingController dlNo2Controller = TextEditingController();
  TextEditingController expiryDate2Controller = TextEditingController();
  TextEditingController gstNoController = TextEditingController();
  TextEditingController lane1 = TextEditingController();
  TextEditingController lane2 = TextEditingController();
  TextEditingController landMark = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController phoneNo1 = TextEditingController();
  TextEditingController phoneNO2 = TextEditingController();
  TextEditingController bankAccountNumber = TextEditingController();
  TextEditingController bankAccountName = TextEditingController();
  TextEditingController ifsc = TextEditingController();
  TextEditingController surfCode = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController branchName = TextEditingController();
  TextEditingController bankPhoneNo = TextEditingController();

  Future<void> _savePharmacyDetails() async {
    final fireStore = FirebaseFirestore.instance;
    Map<String, dynamic> data = {
      'pharmacyName': pharmacyName.text,
      'hospitalName': hospitalName.text,
      'dlNo1': dlNo1Controller.text,
      'expiryDate1': expiryDate1Controller.text,
      'dlNo2': dlNo2Controller.text,
      'expiryDate2': expiryDate2Controller.text,
      'gstNo': gstNoController.text,
      'lane1': lane1.text,
      'lane2': lane2.text,
      'landMark': landMark.text,
      'city': city.text,
      'state': state.text,
      'pinCode': pinCode.text,
      'emailId': emailId.text,
      'phoneNo1': phoneNo1.text,
      'phoneNO2': phoneNO2.text,
      'bankAccountNumber': bankAccountNumber.text,
      'bankAccountName': bankAccountName.text,
      'ifsc': ifsc.text,
      'surfCode': surfCode.text,
      'bankName': bankName.text,
      'branchName': branchName.text,
      'bankPhoneNo': bankPhoneNo.text,
    };

    try {
      if (pharmacyName.text.trim().isNotEmpty ||
          lane1.text.trim().isNotEmpty ||
          bankAccountNumber.text.trim().isNotEmpty) {
        await fireStore
            .collection('pharmacy')
            .doc('pharmacies')
            .collection('pharmacy')
            .doc()
            .set(data);
        CustomSnackBar(context,
            message: 'Pharmacy Added Successfully',
            backgroundColor: Colors.green);
        clearForm();
      } else {
        CustomSnackBar(context,
            message: 'Please fill all the required fields',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      CustomSnackBar(context,
          message: 'Unable To Add Pharmacy $e', backgroundColor: Colors.red);
    }
  }

  void clearForm() {
    pharmacyName.clear();
    hospitalName.clear();
    dlNo1Controller.clear();
    expiryDate1Controller.clear();
    dlNo2Controller.clear();
    expiryDate2Controller.clear();
    gstNoController.clear();
    lane1.clear();
    lane2.clear();
    landMark.clear();
    city.clear();
    state.clear();
    pinCode.clear();
    emailId.clear();
    phoneNo1.clear();
    phoneNO2.clear();
    bankAccountNumber.clear();
    bankAccountName.clear();
    ifsc.clear();
    surfCode.clear();
    bankName.clear();
    branchName.clear();
    bankPhoneNo.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
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
                          text: "Pharmacy Information",
                          size: screenWidth * 0.0275,
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    label: 'Download',
                    onPressed: () {},
                    width: screenWidth * 0.08,
                    height: screenHeight * 0.03,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    controller: pharmacyName,
                    hintText: 'Pharmacy Name',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    controller: hospitalName,
                    hintText: 'Hospital Name',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    controller: dlNo1Controller,
                    hintText: 'DL / No 1',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    controller: expiryDate1Controller,
                    hintText: 'Expiry date',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    controller: dlNo2Controller,
                    hintText: 'DL / No 2',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    controller: expiryDate2Controller,
                    hintText: 'Expiry date',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    controller: gstNoController,
                    hintText: 'GST NO',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Pharmacy Address'),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    controller: lane1,
                    hintText: 'Lane 1',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    controller: lane2,
                    hintText: 'Lane 2',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    controller: landMark,
                    hintText: 'Landmark',
                    width: screenWidth * 0.61,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    controller: city,
                    hintText: 'City',
                    width: screenWidth * 0.20,
                  ),
                  SizedBox(width: screenHeight * 0.1),
                  CustomTextField(
                    controller: state,
                    hintText: 'State',
                    width: screenWidth * 0.20,
                  ),
                  SizedBox(width: screenHeight * 0.1),
                  CustomTextField(
                    controller: pinCode,
                    hintText: 'Pin code',
                    width: screenWidth * 0.20,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    controller: emailId,
                    hintText: 'E-Mail ID',
                    width: screenWidth * 0.20,
                  ),
                  SizedBox(width: screenHeight * 0.1),
                  CustomTextField(
                    controller: phoneNo1,
                    hintText: 'Phone NO 1',
                    width: screenWidth * 0.20,
                  ),
                  SizedBox(width: screenHeight * 0.1),
                  CustomTextField(
                    controller: phoneNO2,
                    hintText: 'Phone Number 2',
                    width: screenWidth * 0.20,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Bank Details'),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    controller: bankAccountNumber,
                    hintText: 'Bank Account Number',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    controller: bankAccountName,
                    hintText: 'Bank Account Name',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    controller: ifsc,
                    hintText: 'IFSC',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    controller: surfCode,
                    hintText: 'Surf Code',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    controller: bankName,
                    hintText: 'Bank Name',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    controller: branchName,
                    hintText: 'Branch Name',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    controller: bankPhoneNo,
                    hintText: 'Bank Phone No',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    label: 'Create',
                    onPressed: () => _savePharmacyDetails(),
                    width: screenWidth * 0.08,
                    height: screenHeight * 0.05,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
