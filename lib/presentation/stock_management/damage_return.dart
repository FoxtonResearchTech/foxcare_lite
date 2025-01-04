import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class DamageReturn extends StatefulWidget {
  const DamageReturn({super.key});

  @override
  State<DamageReturn> createState() => _DamageReturn();
}

class _DamageReturn extends State<DamageReturn> {
  final List<String> headers = [
    'Product Name',
    'Batch',
    'Expiry',
    'Quantity',
    'Free',
    'MRP',
    'Price',
    'Tax',
    'Amount',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'Product Name': '',
      'Batch': '',
      'Expiry': '',
      'Quantity': '',
      'Free': '',
      'MRP': '',
      'Price': '',
      'Tax': '',
      'Amount': '',
    },
  ];
  final List<String> headers2 = [
    'GST 12%',
    'GST 18%',
    'Total',
    'No Of Items',
    'CGST',
    '',
  ];
  final List<Map<String, dynamic>> tableData2 = [
    {
      'GST 12%': 'GR Amount :',
      'GST 18%': '',
      'Total': '',
      'No Of Items': '',
      'CGST': 'SGST',
      '': '',
    },
    {
      'GST 12%': 'Tax Amount :',
      'GST 18%': '',
      'Total': '',
      'No Of Items': '',
      'CGST': 'ISGT',
      '': '',
    },
    {
      'GST 12%': 'Total :',
      'GST 18%': '',
      'Total': '',
      'No Of Items': '',
      'CGST': '',
      '': '',
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
                    text: 'Damage Return ',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Distributor Name',
                    width: screenWidth * 0.233,
                  ),
                  SizedBox(width: screenHeight * 0.726),
                  CustomTextField(
                    hintText: 'Return Number',
                    width: screenWidth * 0.15,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'DL No',
                    width: screenWidth * 0.10,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Exp',
                    width: screenWidth * 0.10,
                  ),
                  SizedBox(width: screenHeight * 0.726),
                  CustomTextField(
                    hintText: 'Return Date',
                    width: screenWidth * 0.15,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'DL No',
                    width: screenWidth * 0.10,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Exp',
                    width: screenWidth * 0.10,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Address Lane 1',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Address Lane 2',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Phone 1',
                    width: screenWidth * 0.15,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Customer Number',
                    width: screenWidth * 0.234,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Address Lane 3',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Pin code',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Phone 2',
                    width: screenWidth * 0.15,
                  ),
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
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData2,
                headers: headers2,
              ),
              Container(
                width: screenWidth,
                height: screenHeight * 0.025,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: screenWidth * 0.19),
                    CustomText(
                      text: 'Bill Due Date : ',
                    ),
                    SizedBox(width: screenWidth * 0.36),
                    CustomText(
                      text: 'Total : ',
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      label: 'Submit',
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
