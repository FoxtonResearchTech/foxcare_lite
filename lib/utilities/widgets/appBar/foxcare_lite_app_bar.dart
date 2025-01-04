import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';

import '../../../presentation/billings/counter_sales.dart';
import '../../../presentation/billings/ip_billing.dart';
import '../../../presentation/billings/medicine_return.dart';
import '../../../presentation/login/login.dart';
import '../../../presentation/reports/broken_or_damaged_statement.dart';
import '../../../presentation/reports/expiry_return_statement.dart';
import '../../../presentation/reports/non_moving_stock.dart';
import '../../../presentation/reports/party_wise_statement.dart';
import '../../../presentation/reports/pending_payment_report.dart';
import '../../../presentation/reports/product_wise_statement.dart';
import '../../../presentation/reports/stock_return_statement.dart';
import '../../../presentation/stock_management/add_product.dart';
import '../../../presentation/stock_management/cancel_bill.dart';
import '../../../presentation/stock_management/damage_return.dart';
import '../../../presentation/stock_management/delete_product.dart';
import '../../../presentation/stock_management/expiry_return.dart';
import '../../../presentation/stock_management/product_list.dart';
import '../../../presentation/stock_management/purchase.dart';
import '../../../presentation/stock_management/purchase_order.dart';
import '../../../presentation/stock_management/stock_return.dart';
import '../../../presentation/tools/add_new_distributor.dart';
import '../../../presentation/tools/distributor_list.dart';
import '../../../presentation/tools/manage_pharmacy_info.dart';
import '../../../presentation/tools/pharmacy_info.dart';
import '../../../presentation/tools/profile.dart';
import '../../colors.dart';

class FoxCareLiteAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FoxCareLiteAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      backgroundColor: AppColors.appBar,
      fieldNames: ['Home', 'Billing', 'Stock Management', 'Reports', 'Tools'],
      navigationMap: {
        'Billing': {
          'Counter Sales': (context) => const CounterSales(),
          'OP Billings': (context) => const CounterSales(),
          'Bill Canceling': (context) => const CancelBill(),
          'Medicine Return': (context) => const MedicineReturn(),
          'IP Billing': (context) => const IPBilling(),
        },
        'Stock Management': {
          'Purchase': (context) => const Purchase(),
          'Purchase Order': (context) => const PurchaseOrder(),
          'Stock Return': (context) => const StockReturn(),
          'Product List': (context) => const ProductList(),
          'Add Product': (context) => const AddProduct(),
          'Delete Product': (context) => const DeleteProduct(),
          'Damage / Broken Return': (context) => const DamageReturn(),
          'Expiry Return': (context) => const ExpiryReturn(),
        },
        'Reports': {
          'Stock Statement': (context) => const StockReturnStatement(),
          'Party Wise Statement': (context) => const PartyWiseStatement(),
          'Product Wise Statement': (context) => const ProductWiseStatement(),
          'Non Moving Statement': (context) => const NonMovingStock(),
          'Stock Return Statement': (context) => const StockReturnStatement(),
          'Expiry Return Statement': (context) => const ExpiryReturnStatement(),
          'Damage / Broken Statement': (context) =>
              const BrokenOrDamagedStatement(),
          'Pending Return Statement': (context) => const PendingPaymentReport(),
        },
        'Tools': {
          'Pharmacy Information': (context) => const PharmacyInfo(),
          'Manage Pharmacy Information': (context) =>
              const ManagePharmacyInfo(),
          'Distributor List': (context) => const DistributorList(),
          'Add / Delete Distributor': (context) => const AddNewDistributor(),
          'Profile': (context) => const Profile(),
          'Logout': (context) => LoginScreen(),
        }
      },
    );
  }
}
