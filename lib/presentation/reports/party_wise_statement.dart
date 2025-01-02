import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../tools/manage_pharmacy_info.dart';

class PartyWiseStatement extends StatefulWidget {
  const PartyWiseStatement({super.key});

  @override
  State<PartyWiseStatement> createState() => _PartyWiseStatement();
}

class _PartyWiseStatement extends State<PartyWiseStatement> {
  final List<String> headers = [
    'Bill NO',
    'Bill Date',
    'Bill Value',
    'Return Value',
    'Payment Status',
    'Open Bill',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'Bill NO': '',
      'Bill Date': '',
      'Bill Value': '',
      'Return Value': '',
      'Payment Status': '',
      'Open Bill': CustomButton(
        label: 'Open',
        onPressed: () {},
        width: 100,
        height: 25,
      ),
    },
    {
      'Bill NO': '',
      'Bill Date': '',
      'Bill Value': '',
      'Return Value': '',
      'Payment Status': '',
      'Open Bill': CustomButton(
        label: 'Open',
        onPressed: () {},
        width: 100,
        height: 25,
      ),
    },
    {
      'Bill NO': '',
      'Bill Date': '',
      'Bill Value': '',
      'Return Value': '',
      'Payment Status': '',
      'Open Bill': CustomButton(
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
          'Stock Statement',
          'Party wise Statement',
          'Product wise Statement',
          'Non-Moving Statement',
          'Stock Return Statement',
          'Expiry Return Statement',
          'Damage/Broken Statement',
        ],
        navigationMap: {
          'Stock Statement': {
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
                  CustomText(text: 'Party Wise Statement :'),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Distributor Name',
                    width: screenWidth * 0.25,
                    icon: Icon(Icons.arrow_drop_down_outlined),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'From',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                    hintText: 'To',
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
                children: [CustomText(text: 'Available Party wise List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
              Container(
                padding: EdgeInsets.only(right: screenWidth * 0.42),
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
            ],
          ),
        ),
      ),
    );
  }
}
