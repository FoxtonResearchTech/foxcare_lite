import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductList();
}

class _ProductList extends State<ProductList> {
  final List<String> headers = [
    'Product Name',
    'HSN Code',
    'Category',
    'Company',
    'Composition',
    'Type',
    'Action',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'Product Name': '',
      'HSN Code': '',
      'Category': '',
      'Company': '',
      'Composition': '',
      'Type': CustomTextField(
        hintText: '',
        width: 250,
        icon: Icon(Icons.arrow_drop_down_sharp),
      ),
      'Action': CustomButton(
        label: 'Edit',
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
                    text: 'Product List',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Select Category',
                    width: screenWidth * 0.25,
                    icon: Icon(Icons.arrow_drop_down_sharp),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Product Name',
                    width: screenWidth * 0.20,
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'Company Name',
                    width: screenWidth * 0.20,
                  ),
                  SizedBox(width: screenHeight * 0.3),
                  CustomTextField(
                    hintText: 'HSN Code',
                    width: screenWidth * 0.10,
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomButton(
                      label: 'Search',
                      onPressed: () {},
                      width: screenWidth * 0.1)
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              CustomDataTable(headers: headers, tableData: tableData),
              SizedBox(height: screenHeight * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: screenWidth * 0.02,
                        bottom: screenWidth * 0.02,
                        left: screenWidth * 0.04,
                        right: screenWidth * 0.04),
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.5,
                    decoration: BoxDecoration(
                      color: AppColors.containerColor,
                      borderRadius: BorderRadius.circular(screenWidth * 0.005),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(text: 'Product Name'),
                        CustomTextField(
                          hintText: 'Composition',
                          width: screenWidth * 0.25,
                        ),
                        CustomTextField(
                          hintText: 'Category',
                          width: screenWidth * 0.25,
                        ),
                        CustomTextField(
                          hintText: 'HSN Code',
                          width: screenWidth * 0.25,
                        ),
                        CustomTextField(
                          hintText: 'Company Name',
                          width: screenWidth * 0.25,
                        ),
                        CustomTextField(
                          hintText: 'Additional Information',
                          width: screenWidth * 0.25,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: screenWidth * 0.02,
                        bottom: screenWidth * 0.02,
                        left: screenWidth * 0.02,
                        right: screenWidth * 0.02),
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.5,
                    decoration: BoxDecoration(
                      color: AppColors.containerColor,
                      borderRadius: BorderRadius.circular(screenWidth * 0.005),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Product Name'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextField(
                              hintText: 'Composition',
                              width: screenWidth * 0.25,
                            ),
                            CustomTextField(
                              hintText: 'Type',
                              width: screenWidth * 0.10,
                              icon: Icon(Icons.arrow_drop_down_sharp),
                            ),
                          ],
                        ),
                        CustomTextField(
                          hintText: 'Category',
                          width: screenWidth * 0.25,
                          icon: Icon(Icons.arrow_drop_down_sharp),
                        ),
                        CustomTextField(
                          hintText: 'HSN Code',
                          width: screenWidth * 0.25,
                        ),
                        CustomTextField(
                          hintText: 'Company Name',
                          width: screenWidth * 0.25,
                        ),
                        CustomTextField(
                          hintText: 'Additional Information',
                          width: screenWidth * 0.25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              label: 'Submit',
                              onPressed: () {},
                              width: 100,
                              height: 32,
                            ),
                          ],
                        ),
                      ],
                    ),
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
