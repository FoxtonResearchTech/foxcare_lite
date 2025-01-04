import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class StockReturnStatement extends StatefulWidget {
  const StockReturnStatement({super.key});

  @override
  State<StockReturnStatement> createState() => _StockReturnStatement();
}

class _StockReturnStatement extends State<StockReturnStatement> {
  final List<String> headers = [
    'Bill NO',
    'Bill date',
    'Distributor Name',
    'Return value',
    'Bill details',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'Bill NO': '',
      'Bill date': '',
      'Distributor Name': '',
      'Return value': '',
      'Bill details': CustomButton(
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
                  CustomText(text: 'Stock Return Statement :'),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'From Date',
                    width: screenWidth * 0.25,
                    icon: Icon(Icons.arrow_drop_down_outlined),
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    hintText: 'To Date',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.1),
                  CustomButton(
                      label: 'Generate',
                      onPressed: () {},
                      width: screenWidth * 0.08)
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Available Stock Return List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
              Container(
                width: screenWidth,
                height: screenHeight * 0.030,
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
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      label: 'Print',
                      onPressed: () {},
                      width: screenWidth * 0.1)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
