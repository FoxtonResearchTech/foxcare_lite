import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _Purchase();
}

class _Purchase extends State<Purchase> {
  final List<String> headers = [
    'Bill NO',
    'Bill Date',
    'Distributor Name',
    'Bill Amount',
    'Due Date',
    'Action',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'Bill NO': '',
      'Bill date': '',
      'Distributor Name': '',
      'Bill Amount': '',
      'Due Date': '',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomText(text: 'Bill Approve List '),
                  CustomButton(
                    label: 'Purchase Entry',
                    onPressed: () {},
                    width: screenWidth * 0.12,
                    height: screenHeight * 0.04,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Purchase Bill No',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                      label: 'Search',
                      onPressed: () {},
                      width: screenWidth * 0.08),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    hintText: 'Bill No',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                      label: 'Search',
                      onPressed: () {},
                      width: screenWidth * 0.08),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Add Product List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
