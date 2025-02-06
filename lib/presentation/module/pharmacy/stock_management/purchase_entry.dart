import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class PurchaseEntry extends StatefulWidget {
  const PurchaseEntry({super.key});

  @override
  State<PurchaseEntry> createState() => _PurchaseEntry();
}

class _PurchaseEntry extends State<PurchaseEntry> {
  final List<String> headers = [
    'Product Name',
    'HSN Code',
    'Batch Number',
    'Expiry',
    'Quantity',
    'Free',
    'MRP',
    'Price',
    'GST',
    'Amount',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'Product Name': '',
      'HSN Code': '',
      'Batch Number': '',
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
      'CGST': 'Less CR Note',
      '': ''
    },
    {
      'GST 12%': '',
      'GST 18%': '',
      'Total': '',
      'No Of Items': '',
      'CGST': 'Add DR Note',
      '': ''
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
                    text: 'Purchase Entry ',
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
                    icon: Icon(Icons.arrow_drop_down_sharp),
                  ),
                  SizedBox(width: screenHeight * 0.726),
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
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Bill NO',
                    width: screenWidth * 0.10,
                  ),
                  SizedBox(width: screenHeight * 0.06),
                  CustomTextField(
                    hintText: 'Bill Date',
                    width: screenWidth * 0.10,
                  ),
                  SizedBox(width: screenHeight * 0.726),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
              Container(
                padding: EdgeInsets.only(right: screenWidth * 0.08),
                width: screenWidth,
                height: screenHeight * 0.025,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: 'Total : ',
                    )
                  ],
                ),
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
                      label: 'Update',
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
