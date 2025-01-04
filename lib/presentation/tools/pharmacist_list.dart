import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class PharmacistList extends StatefulWidget {
  const PharmacistList({super.key});

  @override
  State<PharmacistList> createState() => _PharmacistList();
}

class _PharmacistList extends State<PharmacistList> {
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
        label: 'Edit',
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
        label: 'Edit',
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
        label: 'Edit',
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
      appBar: const FoxCareLiteAppBar(),
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
                  CustomText(text: ' All Pharmacist List :'),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Pharmacist Name',
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
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
