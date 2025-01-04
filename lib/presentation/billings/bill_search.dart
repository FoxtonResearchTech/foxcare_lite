import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/billings/counter_sales.dart';
import 'package:foxcare_lite/presentation/billings/ip_billing.dart';
import 'package:foxcare_lite/presentation/billings/medicine_return.dart';
import 'package:foxcare_lite/presentation/login/login.dart';
import 'package:foxcare_lite/presentation/reports/broken_or_damaged_statement.dart';
import 'package:foxcare_lite/presentation/reports/expiry_return_statement.dart';
import 'package:foxcare_lite/presentation/reports/non_moving_stock.dart';
import 'package:foxcare_lite/presentation/reports/party_wise_statement.dart';
import 'package:foxcare_lite/presentation/reports/pending_payment_report.dart';
import 'package:foxcare_lite/presentation/reports/product_wise_statement.dart';
import 'package:foxcare_lite/presentation/reports/stock_return_statement.dart';
import 'package:foxcare_lite/presentation/stock_management/add_product.dart';
import 'package:foxcare_lite/presentation/stock_management/cancel_bill.dart';
import 'package:foxcare_lite/presentation/stock_management/damage_return.dart';
import 'package:foxcare_lite/presentation/stock_management/delete_product.dart';
import 'package:foxcare_lite/presentation/stock_management/expiry_return.dart';
import 'package:foxcare_lite/presentation/stock_management/product_list.dart';
import 'package:foxcare_lite/presentation/stock_management/purchase.dart';
import 'package:foxcare_lite/presentation/stock_management/purchase_order.dart';
import 'package:foxcare_lite/presentation/stock_management/stock_return.dart';
import 'package:foxcare_lite/presentation/tools/add_new_distributor.dart';
import 'package:foxcare_lite/presentation/tools/distributor_list.dart';
import 'package:foxcare_lite/presentation/tools/pharmacy_info.dart';
import 'package:foxcare_lite/presentation/tools/profile.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../tools/manage_pharmacy_info.dart';

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
