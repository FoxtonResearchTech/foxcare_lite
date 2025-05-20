import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/billings/op_billing.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/dashboard/pharmecy_dashboard.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';

import '../../../presentation/login/fetch_user.dart';
import '../../../presentation/login/login.dart';
import '../../../presentation/module/pharmacy/billings/cancel_bill.dart';
import '../../../presentation/module/pharmacy/billings/counter_sales.dart';
import '../../../presentation/module/pharmacy/billings/ip_billing.dart';
import '../../../presentation/module/pharmacy/billings/medicine_return.dart';
import '../../../presentation/module/pharmacy/reports/broken_or_damaged_statement.dart';
import '../../../presentation/module/pharmacy/reports/expiry_return_statement.dart';
import '../../../presentation/module/pharmacy/reports/non_moving_stock.dart';
import '../../../presentation/module/pharmacy/reports/party_wise_statement.dart';
import '../../../presentation/module/pharmacy/reports/pending_payment_report.dart';
import '../../../presentation/module/pharmacy/reports/sales_wise_statement.dart';
import '../../../presentation/module/pharmacy/reports/stock_return_statement.dart';
import '../../../presentation/module/pharmacy/stock_management/add_product.dart';
import '../../../presentation/module/pharmacy/stock_management/damage_return.dart';
import '../../../presentation/module/pharmacy/stock_management/delete_product.dart';
import '../../../presentation/module/pharmacy/stock_management/expiry_return.dart';
import '../../../presentation/module/pharmacy/stock_management/product_list.dart';
import '../../../presentation/module/pharmacy/stock_management/purchase.dart';
import '../../../presentation/module/pharmacy/stock_management/purchase_order.dart';
import '../../../presentation/module/pharmacy/stock_management/stock_return.dart';
import '../../../presentation/module/pharmacy/tools/add_new_distributor.dart';
import '../../../presentation/module/pharmacy/tools/distributor_list.dart';
import '../../../presentation/module/pharmacy/tools/manage_pharmacy_info.dart';
import '../../../presentation/module/pharmacy/tools/pharmacy_info.dart';
import '../../../presentation/module/pharmacy/tools/profile.dart';
import '../../colors.dart';
import '../../constants.dart';
import '../state/app_bar_selection_state.dart';

class FoxCareLiteAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, Map<String, WidgetBuilder>>? navigationMap;

  const FoxCareLiteAppBar({
    super.key,
    this.navigationMap,
  });

  @override
  State<FoxCareLiteAppBar> createState() => _FoxCareLiteAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(150.0);
}

class _FoxCareLiteAppBarState extends State<FoxCareLiteAppBar> {
  final UserModel? currentUser = UserSession.currentUser;

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    AppBarSelectionState.selectedField = null;
    AppBarSelectionState.selectedOptionsMap.clear();
    UserSession.clearUser();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  String? selectedField;
  Map<String, String> selectedOptionsMap = {};

  @override
  void initState() {
    super.initState();
    selectedField = AppBarSelectionState.selectedField;
    selectedOptionsMap =
        Map<String, String>.from(AppBarSelectionState.selectedOptionsMap);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: AppColors.blueOpacity,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: screenHeight * 0.06,
                              left: screenWidth * 0.02,
                              right: screenWidth * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: Constants.pharmacyName,
                                color: Colors.white,
                                size: screenWidth * 0.018,
                              ),
                              Column(
                                children: [
                                  CustomText(
                                    text: 'Mr. ${currentUser!.name}',
                                    color: Colors.white,
                                    size: screenWidth * 0.014,
                                  ),
                                  CustomText(
                                    text: 'Pharmacist',
                                    color: Colors.white,
                                    size: screenWidth * 0.008,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
          ),
        ),
        Positioned(
          top: 60,
          left: 80,
          right: 80,
          child: CustomAppBar(
            backgroundColor: AppColors.appBar,
            fields: [
              FieldConfig(name: 'Dashboard', icon: Icons.home),
              FieldConfig(name: 'Billing', icon: Icons.receipt),
              FieldConfig(name: 'Stock Management', icon: Icons.store),
              FieldConfig(name: 'Reports', icon: Icons.bar_chart),
              FieldConfig(name: 'Tools', icon: Icons.build),
            ],
            selectedField: selectedField,
            selectedOptionsMap: selectedOptionsMap,
            onFieldSelected: (fieldName) {
              setState(() {
                AppBarSelectionState.selectedField = fieldName;
                selectedField = fieldName;

                if (fieldName == 'Home') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SalesChartScreen()),
                  );
                }
              });
            },
            onOptionSelected: (fieldName, option) async {
              if (option == 'Logout') {
                await _logout(context);
                return;
              }

              setState(() {
                AppBarSelectionState.selectedOptionsMap.clear();
                AppBarSelectionState.selectedOptionsMap[fieldName] = option;
                selectedOptionsMap = AppBarSelectionState.selectedOptionsMap;
              });

              final navigationTarget =
                  widget.navigationMap?[fieldName]?[option];
              if (navigationTarget != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => navigationTarget(context)),
                );
              }
            },
            navigationMap: widget.navigationMap ??
                {
                  'Dashboard': {'Home': (context) => SalesChartScreen()},
                  'Billing': {
                    'Counter Sales': (context) => const CounterSales(),
                    'OP Billings': (context) => const OpBilling(),
                    'Bill Canceling': (context) => const CancelBill(),
                    'Medicine Return': (context) => const MedicineReturn(),
                    'IP Billing': (context) => const IpBilling(),
                  },
                  'Stock Management': {
                    'Purchase': (context) => const Purchase(),
                    'Stock Return': (context) => const StockReturn(),
                    'Product List': (context) => const ProductList(),
                    'Add Product': (context) => const AddProduct(),
                    'Delete Product': (context) => const DeleteProduct(),
                    'Damage / Broken Return': (context) => const DamageReturn(),
                    'Expiry Return': (context) => const ExpiryReturn(),
                  },
                  'Reports': {
                    'Stock Return Statement': (context) =>
                        const StockReturnStatement(),
                    'Expiry Return Statement': (context) =>
                        const ExpiryReturnStatement(),
                    'Damage / Broken Statement': (context) =>
                        const BrokenOrDamagedStatement(),
                    'Party Wise Statement': (context) =>
                        const PartyWiseStatement(),
                    'Sales Wise Statement': (context) =>
                        const SalesWiseStatement(),
                    'Non Moving Statement': (context) => const NonMovingStock(),
                    'Pending Return Statement': (context) =>
                        const PendingPaymentReport(),
                  },
                  'Tools': {
                    'Pharmacy Information': (context) => const PharmacyInfo(),
                    'Manage Pharmacy Information': (context) =>
                        const ManagePharmacyInfo(),
                    'Distributor List': (context) => const DistributorList(),
                    'Add Distributor': (context) => const AddNewDistributor(),
                    'Profile': (context) => const Profile(),
                    'Logout': (context) => const SizedBox.shrink(),
                  }
                },
          ),
        ),
      ],
    );
  }
}
