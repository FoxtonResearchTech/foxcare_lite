import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class CancelBill extends StatefulWidget {
  const CancelBill({super.key});

  @override
  State<CancelBill> createState() => _CancelBill();
}

class _CancelBill extends State<CancelBill> {
  final List<String> headers = [
    'Bill No',
    'Name',
    'OP No',
    'Doctor Name',
    'Action',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'Bill No': '',
      'Name': '',
      'OP No': '',
      'Doctor Name': '',
      'Action': CustomButton(
        label: 'Cancel',
        onPressed: () {},
        width: 100,
        height: 32,
      ),
    },
  ];
  final List<String> headers2 = [
    'Bill No',
    'Name',
    'OP No',
    'Doctor Name',
    'Action',
  ];
  final List<Map<String, dynamic>> tableData2 = [
    {
      'Bill No': '',
      'Name': '',
      'OP No': '',
      'Doctor Name': '',
      'Action': CustomButton(
        label: 'Cancel',
        onPressed: () {},
        width: 100,
        height: 32,
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
              Row(
                children: [
                  CustomText(
                    text: 'Today Billing Status',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  CustomText(
                    text: 'Nov-12-2024',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomDataTable(headers: headers, tableData: tableData),
              SizedBox(height: screenHeight * 0.05),
              Row(
                children: [
                  CustomText(
                    text: 'IP Billing Que',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  CustomText(
                    text: 'Nov-12-2024',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomDataTable(headers: headers2, tableData: tableData2),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
