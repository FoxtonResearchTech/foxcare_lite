import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../tools/manage_pharmacy_info.dart';

class DistributorList extends StatefulWidget {
  const DistributorList({super.key});

  @override
  State<DistributorList> createState() => _DistributorList();
}

class _DistributorList extends State<DistributorList> {
  final List<String> headers = [
    'SL No',
    'Name',
    'Place',
    'Phone Number',
    'Representative',
    'Phone',
    'Action',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'SL No': '',
      'Name': '',
      'Place': '',
      'Phone Number': '',
      'Representative': '',
      'Phone': '',
      'Action': CustomButton(
        label: 'Open',
        onPressed: () {},
        width: 100,
        height: 25,
      ),
    },
    {
      'SL No': '',
      'Name': '',
      'Place': '',
      'Phone Number': '',
      'Representative': '',
      'Phone': '',
      'Action': CustomButton(
        label: 'Open',
        onPressed: () {},
        width: 100,
        height: 25,
      ),
    },
    {
      'SL No': '',
      'Name': '',
      'Place': '',
      'Phone Number': '',
      'Representative': '',
      'Phone': '',
      'Action': CustomButton(
        label: 'Open',
        onPressed: () {},
        width: 100,
        height: 25,
      ),
    },
  ];
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
              const Row(
                children: [
                  CustomText(text: 'Distributor List :'),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Distributor Name',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.1),
                  CustomButton(
                      height: screenHeight * 0.04,
                      label: 'Search',
                      onPressed: () {},
                      width: screenWidth * 0.08)
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Total Pending Payment List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
              Container(
                padding: EdgeInsets.only(right: screenWidth * 0.005),
                width: screenWidth,
                height: screenHeight * 0.025,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    CustomText(
                      text: 'Total : ',
                    )
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
