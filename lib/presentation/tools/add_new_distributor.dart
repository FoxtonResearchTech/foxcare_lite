import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/tools/manage_pharmacy_info.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

class AddNewDistributor extends StatefulWidget {
  const AddNewDistributor({super.key});

  @override
  State<AddNewDistributor> createState() => _AddNewDistributor();
}

class _AddNewDistributor extends State<AddNewDistributor> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AppColors.appBar,
        fieldNames: const [
          'Pharmacy Information',
          'Manage Pharmacy Information',
          'Distributor List',
          'Add / Delete Distributor',
          'Profile',
          'Logout',
        ],
        navigationMap: {
          'Pharmacy Information': {
            'Option 1': (context) => ManagePharmacyInfo(),
          }
        },
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Distributor details ',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Distributor Name',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'DL / No 1',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    hintText: 'Expiry date',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'DL / No 2',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    hintText: 'Expiry date',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'GST NO',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Pharmacy Address',
                    size: screenWidth * 0.012,
                  ),
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
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Bank Details',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Bank Account Number',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    hintText: 'Bank Account Name',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'IFSC',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    hintText: 'Surf Code',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Bank Name',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    hintText: 'Branch Name',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    label: 'Create',
                    onPressed: () {},
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
