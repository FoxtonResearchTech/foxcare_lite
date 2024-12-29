import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

class BillSearch extends StatefulWidget {
  const BillSearch({super.key});

  @override
  State<BillSearch> createState() => _BillSearch();
}

class _BillSearch extends State<BillSearch> {
  final List<String> headers1 = [
    'Bill NO',
    'Name',
    'OP NO',
    'Doctor Name',
    'Bill Date',
    'Place',
    'Amount',
  ];
  final List<Map<String, dynamic>> tableData1 = [
    {
      'Bill NO': '',
      'Name': '',
      'OP NO': '',
      'Doctor Name': '',
      'Bill Date': '',
      'Place': '',
      'Amount': '',
    },
  ];
  final List<String> headers2 = [
    'Bill NO',
    'Name',
    'OP NO',
    'Doctor Name',
    'Bill Date',
    'Place',
    'Amount',
  ];
  final List<Map<String, dynamic>> tableData2 = [
    {
      'Bill NO': '',
      'Name': '',
      'OP NO': '',
      'Doctor Name': '',
      'Bill Date': '',
      'Place': '',
      'Amount': '',
    },
  ];
  final List<String> headers3 = [
    'Bill NO',
    'Name',
    'OP NO',
    'Doctor Name',
    'Bill Date',
    'Place',
    'Amount',
  ];
  final List<Map<String, dynamic>> tableData3 = [
    {
      'Bill NO': '',
      'Name': '',
      'OP NO': '',
      'Doctor Name': '',
      'Bill Date': '',
      'Place': '',
      'Amount': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(backgroundColor: AppColors.appBar, fieldNames: [
        'Home',
        'Billing',
        'Stock Management',
        'Reports',
        'Tools'
      ], fieldOptions: [
        ['Option 1', 'Option 2', 'Option 3'],
        [
          'Counter sale',
          'OP Billing',
          'Bill Cancelling ',
          'Medcine Return',
          'IP Billing'
        ],
        ['Option 1', 'Option 2', 'Option 3'],
        ['Option 1', 'Option 2', 'Option 3'],
        ['Option 1', 'Option 2', 'Option 3'],
      ]),
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
                  CustomTextField(
                    hintText: 'From ',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                tableData: tableData1,
                headers: headers1,
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'From',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                    hintText: 'To',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                tableData: tableData2,
                headers: headers2,
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Bill No',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                    hintText: 'Patient Name',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'OP No',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                    hintText: 'Phone Number',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                tableData: tableData3,
                headers: headers3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
