import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/hospital_direct_purchase_still_pending.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admission_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/ip_admit_list.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/lab_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/op_ticket_collection.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/other_expense.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/surgery_ot_icu_collection.dart';
import 'package:foxcare_lite/utilities/widgets/payment/payment_dialog.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../management_dashboard.dart';
import 'new_patient_register_collection.dart';

class HospitalDirectPurchaseStillPending extends StatefulWidget {
  @override
  State<HospitalDirectPurchaseStillPending> createState() =>
      _HospitalDirectPurchaseStillPending();
}

class _HospitalDirectPurchaseStillPending
    extends State<HospitalDirectPurchaseStillPending> {
  int selectedIndex = 5;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();

  DateTime now = DateTime.now();
  final List<String> headers = [
    'Purchase Date',
    'Bill NO',
    'From Party',
    'Phone',
    'City',
    'Description',
    'Amount',
    'Collected',
    'Balance',
    'Payed Date',
    'Payment Mode',
    'Cheque NO',
    'Transaction ID',
    'Pay',
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('hospital')
          .doc('purchase')
          .collection('directPurchase');

      if (singleDate != null) {
        query = query.where('purchaseDate', isEqualTo: singleDate);
      } else if (fromDate != null && toDate != null) {
        query = query
            .where('purchaseDate', isGreaterThanOrEqualTo: fromDate)
            .where('purchaseDate', isLessThanOrEqualTo: toDate);
      }
      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No records found");
        setState(() {
          tableData = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('billNo')) continue;
        if (data['balance'] == '0.00') break;

        double opAmount =
            double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
        double opAmountCollected =
            double.tryParse(data['collected']?.toString() ?? '0') ?? 0;
        double balance = opAmount - opAmountCollected;

        fetchedData.add({
          'Purchase Date': data['purchaseDate'],
          'Bill NO': data['billNo'],
          'From Party': data['fromParty'],
          'Phone': data['phone'],
          'City': data['city'],
          'Description': data['description'],
          'Amount': opAmount,
          'Collected': opAmountCollected,
          'Balance': balance,
          'Payed Date': data['payedDate'],
          'Payment Mode': data['paymentMode'],
          'Cheque NO': data['chequeNo'],
          'Transaction ID': data['transactionId'],
          'Pay': TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PaymentDialog(
                        billNo: data['billNo'],
                        partyName: data['fromParty'],
                        city: data['city'],
                        balance: data['balance'],
                      );
                    });
              },
              child: CustomText(text: 'Pay'))
        });
      }
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Balance'].toString()) ?? 0;
        int tokenB = int.tryParse(b['Balance'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  int _totalAmountCollected() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        final value = entry['Amount'];
        final intValue = (value is num)
            ? value.toInt()
            : int.tryParse(value.toString()) ?? 0;
        return sum + intValue;
      },
    );
  }

  int _totalCollected() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        final value = entry['Collected'];
        final intValue = (value is num)
            ? value.toInt()
            : int.tryParse(value.toString()) ?? 0;
        return sum + intValue;
      },
    );
  }

  int _totalBalance() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        final value = entry['Balance'];
        final intValue = (value is num)
            ? value.toInt()
            : int.tryParse(value.toString()) ?? 0;
        return sum + intValue;
      },
    );
  }

  @override
  void initState() {
    fetchData();
    _totalAmountCollected();
    _totalCollected();
    _totalBalance();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _toDateController.dispose();
    _fromDateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
                text: 'Accounts Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ManagementAccountsDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ManagementAccountsDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.07),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Hospital Direct Purchase Pending ",
                          size: screenWidth * .015,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        image: const DecorationImage(
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomTextField(
                    onTap: () => _selectDate(context, _dateController),
                    icon: Icon(Icons.date_range),
                    controller: _dateController,
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(singleDate: _dateController.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomText(text: 'OR'),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _fromDateController),
                    icon: Icon(Icons.date_range),
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _toDateController),
                    icon: Icon(Icons.date_range),
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(
                        fromDate: _fromDateController.text,
                        toDate: _toDateController.text,
                      );
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomText(text: 'Collection Report Of Date'),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData,
                headers: headers,
              ),
              Container(
                width: screenWidth,
                height: screenHeight * 0.030,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: screenWidth * 0.38),
                    CustomText(
                      text: 'Total : ',
                    ),
                    SizedBox(width: screenWidth * 0.086),
                    CustomText(
                      text: '${_totalAmountCollected()}',
                    ),
                    SizedBox(width: screenWidth * 0.08),
                    CustomText(
                      text: '${_totalCollected()}',
                    ),
                    SizedBox(width: screenWidth * 0.083),
                    CustomText(
                      text: '${_totalBalance()}',
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
