import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';
import 'counter_sales.dart';
import 'ip_billing.dart';
import 'medicine_return.dart';

class PrescriptionBilling extends StatefulWidget {
  const PrescriptionBilling({super.key});

  @override
  State<PrescriptionBilling> createState() => _PrescriptionBilling();
}

class _PrescriptionBilling extends State<PrescriptionBilling> {
  final List<String> headers = [
    'Product Name',
    'Type',
    'Batch',
    'EXP',
    'HSN',
    'MPS',
    'Discount',
    'Price',
    'Cast',
    'Amount',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'Product Name': 'Product 1',
      'Type': 'Type A',
      'Batch': 'Batch001',
      'EXP': '12/2025',
      'HSN': '1234',
      'MPS': '10',
      'Discount': '5%',
      'Price': '200',
      'Cast': '150',
      'Amount': '180',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
    },
    {
      'Product Name': 'Product 2',
      'Type': 'Type B',
      'Batch': 'Batch002',
      'EXP': '11/2024',
      'HSN': '5678',
      'MPS': '15',
      'Discount': '10%',
      'Price': '300',
      'Cast': '250',
      'Amount': '270',
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
                  CustomTextField(
                    hintText: 'Bill No',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                    hintText: 'Date',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                      hintText: 'Patient name', width: screenWidth * 0.25),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(hintText: 'Place', width: screenWidth * 0.25)
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(hintText: 'Place', width: screenWidth * 0.25),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                      hintText: 'OP Number', width: screenWidth * 0.20),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                      hintText: 'Gender', width: screenWidth * 0.20),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                      hintText: 'Phone Number', width: screenWidth * 0.20),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Doctor Name',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                    hintText: 'Spectating',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    CustomText(
                      text: 'Total : ',
                    )
                  ],
                ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    CustomText(text: '12% TAX : '),
                    CustomText(text: '10% GST : '),
                    CustomText(text: 'Total GST : '),
                    CustomText(text: 'Grand Total : '),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.08),
              Container(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.25,
                  right: screenWidth * 0.25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      label: 'Payment',
                      onPressed: () {},
                      width: screenWidth * 0.15,
                    ),
                    CustomButton(
                      label: 'Print',
                      onPressed: () {},
                      width: screenWidth * 0.15,
                    ),
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
