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

class MedicineReturn extends StatefulWidget {
  const MedicineReturn({super.key});

  @override
  State<MedicineReturn> createState() => _MedicineReturn();
}

class _MedicineReturn extends State<MedicineReturn> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _opNumber = TextEditingController();
  TextEditingController patientName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController billNo = TextEditingController();

  final List<String> headers1 = [
    'Bill NO',
    'Patient Name',
    'OP NO',
    'Doctor Name',
    'Bill Date',
    'Action',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  final List<String> headers2 = [
    'Product Name',
    'Type',
    'Batch',
    'EXP',
    'HSN',
    'MRP',
    'Price',
    'GST',
    'Returning Qut',
    'Returning Cost'
  ];
  List<Map<String, dynamic>> tableData2 = [];
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
                      hintText: 'Patient Name', width: screenWidth * 0.25),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                    hintText: 'OP Number',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                      hintText: 'Phone Number', width: screenWidth * 0.25),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                tableData: tableData1,
                headers: headers1,
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                tableData: tableData2,
                headers: headers2,
              ),
              Container(
                padding: EdgeInsets.only(right: screenWidth * 0.08),
                width: screenWidth,
                height: screenHeight * 0.028,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: 'Total : ',
                      size: screenWidth * 0.0085,
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: '12% TAX : '),
                    CustomText(text: '10% GST : '),
                    CustomText(text: 'Total GST : '),
                    CustomText(text: 'Grand Total : '),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.08),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
