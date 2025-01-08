import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/billings/bill_search.dart';
import 'package:foxcare_lite/presentation/billings/counter_sales.dart';
import 'package:foxcare_lite/presentation/billings/ip_billing.dart';
import 'package:foxcare_lite/presentation/billings/medicine_return.dart';
import 'package:foxcare_lite/presentation/billings/prescription_billing.dart';
import 'package:foxcare_lite/presentation/login/login.dart';
import 'package:foxcare_lite/presentation/pages/doctor/rx_prescription.dart';
import 'package:foxcare_lite/presentation/pages/ip_admission.dart';
import 'package:foxcare_lite/presentation/reports/broken_or_damaged_statement.dart';
import 'package:foxcare_lite/presentation/reports/collection_report.dart';
import 'package:foxcare_lite/presentation/reports/expiry_return_statement.dart';
import 'package:foxcare_lite/presentation/reports/non_moving_stock.dart';
import 'package:foxcare_lite/presentation/reports/party_wise_statement.dart';
import 'package:foxcare_lite/presentation/reports/pending_payment_report.dart';
import 'package:foxcare_lite/presentation/reports/product_wise_statement.dart';
import 'package:foxcare_lite/presentation/reports/stock_management.dart';
import 'package:foxcare_lite/presentation/reports/stock_return_statement.dart';
import 'package:foxcare_lite/presentation/stock_management/add_product.dart';
import 'package:foxcare_lite/presentation/stock_management/cancel_bill.dart';
import 'package:foxcare_lite/presentation/stock_management/damage_return.dart';
import 'package:foxcare_lite/presentation/stock_management/delete_product.dart';
import 'package:foxcare_lite/presentation/stock_management/expiry_return.dart';
import 'package:foxcare_lite/presentation/stock_management/product_list.dart';
import 'package:foxcare_lite/presentation/stock_management/purchase.dart';
import 'package:foxcare_lite/presentation/stock_management/purchase_entry.dart';
import 'package:foxcare_lite/presentation/stock_management/purchase_order.dart';
import 'package:foxcare_lite/presentation/stock_management/stock_return.dart';
import 'package:foxcare_lite/presentation/tools/add_new_distributor.dart';
import 'package:foxcare_lite/presentation/tools/distributor_list.dart';
import 'package:foxcare_lite/presentation/tools/distributor_update.dart';
import 'package:foxcare_lite/presentation/tools/manage_pharmacy_info.dart';
import 'package:foxcare_lite/presentation/tools/pharmacist_list.dart';
import 'package:foxcare_lite/presentation/tools/pharmacy_info.dart';
import 'package:foxcare_lite/presentation/tools/profile.dart';
import 'package:window_manager/window_manager.dart';

import 'presentation/dashboard/pharmecy_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoxCare Lite',
      home: RxPrescription(),
    );
  }
}
