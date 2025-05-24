import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';

class AddNewDistributor extends StatefulWidget {
  const AddNewDistributor({super.key});

  @override
  State<AddNewDistributor> createState() => _AddNewDistributor();
}

class _AddNewDistributor extends State<AddNewDistributor> {
  TextEditingController distributorNameController = TextEditingController();
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
  TextEditingController contactPerson = TextEditingController();
  TextEditingController contactPersonNumber = TextEditingController();

  TextEditingController bankName = TextEditingController();
  TextEditingController branchName = TextEditingController();
  TextEditingController bankPhoneNo = TextEditingController();

  Future<void> _saveDistributorData() async {
    final fireStore = FirebaseFirestore.instance;
    Map<String, dynamic> data = {
      'distributorName': distributorNameController.text,
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
      'contactPerson': contactPerson.text,
      'contactPersonNumber': contactPersonNumber.text,
      'bankName': bankName.text,
      'branchName': branchName.text,
      'bankPhoneNo': bankPhoneNo.text,
    };

    try {
      if (distributorNameController.text.trim().isNotEmpty ||
          lane1.text.trim().isNotEmpty ||
          bankAccountNumber.text.trim().isNotEmpty) {
        await fireStore
            .collection('pharmacy')
            .doc('distributors')
            .collection('distributor')
            .doc()
            .set(data);
        CustomSnackBar(context,
            message: 'Distributor Added Successfully',
            backgroundColor: Colors.green);
        clearForm();
      } else {
        CustomSnackBar(context,
            message: 'Please fill all the required fields',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      CustomSnackBar(context,
          message: 'Unable To Add Distributor $e', backgroundColor: Colors.red);
    }
  }

  void clearForm() {
    distributorNameController.clear();
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
    contactPerson.clear();
    contactPersonNumber.clear();
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
              TimeDateWidget(text: 'Add Distributor'),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Distributor Name',
                        size: screenWidth * 0.012,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      PharmacyTextField(
                        controller: distributorNameController,
                        hintText: '',
                        width: screenWidth * 0.3,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Address',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Lane 1',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: lane1,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Lane 2',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: lane2,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Landmark',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: landMark,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'City',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: city,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'State',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: state,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Pin Code',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: pinCode,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone 1',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: phoneNo1,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone 2',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: phoneNO2,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                      SizedBox(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Email-ID',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: emailId,
                            hintText: '',
                            width: screenWidth * 0.25,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Licence',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'DL NO 1',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: dlNo1Controller,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'DL NO 2',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: dlNo2Controller,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'GSTIN',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: gstNoController,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Bank Details',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Bank Account Number',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: bankAccountNumber,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Bank Account Name',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: bankAccountName,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'IFSC',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: ifsc,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Surf Code',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: surfCode,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Bank Name',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: bankName,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Branch Name',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: branchName,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone Number',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: bankPhoneNo,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Contact Person',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Contact Person',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: contactPerson,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone Number',
                            size: screenWidth * 0.012,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          PharmacyTextField(
                            controller: contactPersonNumber,
                            hintText: '',
                            width: screenWidth * 0.3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(height: screenHeight * 0.08),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PharmacyButton(
                    label: 'Cancel',
                    onPressed: () => (),
                    width: screenWidth * 0.08,
                    height: screenHeight * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  PharmacyButton(
                    label: 'Create',
                    onPressed: () => _saveDistributorData(),
                    width: screenWidth * 0.08,
                    height: screenHeight * 0.05,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
