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

class HospitalDirectPurchase extends StatefulWidget {
  @override
  State<HospitalDirectPurchase> createState() => _HospitalDirectPurchase();
}

class _HospitalDirectPurchase extends State<HospitalDirectPurchase> {
  int selectedIndex = 4;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();

  //ADD BILL
  TextEditingController purchaseDate = TextEditingController();
  TextEditingController billNo = TextEditingController();
  TextEditingController fromParty = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController collected = TextEditingController();
  TextEditingController balanceAmount = TextEditingController();

  TextEditingController payedDate = TextEditingController();
  TextEditingController chequeNo = TextEditingController();
  TextEditingController transactionId = TextEditingController();

  String? selectedPaymentMode;

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
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> addBill() async {
    try {
      Map<String, dynamic> data = {
        'purchaseDate': purchaseDate.text,
        'billNo': billNo.text,
        'fromParty': fromParty.text,
        'phone': phone.text,
        'city': city.text,
        'description': description.text,
        'amount': amount.text,
        'collected': collected.text,
        'balance': balanceAmount.text,
        'payedDate': payedDate.text,
        'paymentMode': selectedPaymentMode,
        'chequeNo': chequeNo.text,
        'transactionId': transactionId.text,
      };
      await FirebaseFirestore.instance
          .collection('hospital')
          .doc('purchase')
          .collection('directPurchase')
          .doc()
          .set(data);
      clear();
      CustomSnackBar(context,
          message: 'Bill Added Successfully', backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to Add Bill', backgroundColor: Colors.red);
    }
  }

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
        if (!data.containsKey('purchaseDate')) continue;

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
        });
      }

      setState(() {
        tableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _updateBalance() {
    double totalAmount = double.tryParse(amount.text) ?? 0.0;
    double paidAmount = double.tryParse(collected.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    balanceAmount.text = balance.toStringAsFixed(2);
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

  void clear() {
    purchaseDate.clear();
    billNo.clear();
    fromParty.clear();
    phone.clear();
    city.clear();
    description.clear();
    amount.clear();
    collected.clear();
    balanceAmount.clear();
    payedDate.clear();
    chequeNo.clear();
    transactionId.clear();
    selectedPaymentMode = '';
  }

  @override
  void initState() {
    fetchData();
    _totalAmountCollected();
    _totalCollected();
    _totalBalance();
    amount.addListener(_updateBalance);
    collected.addListener(_updateBalance);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _toDateController.dispose();
    _fromDateController.dispose();
    amount.dispose();
    collected.dispose();
    balanceAmount.dispose();
    payedDate.dispose();
    chequeNo.dispose();
    transactionId.dispose();
    purchaseDate.dispose();
    billNo.dispose();
    fromParty.dispose();
    phone.dispose();
    city.dispose();
    description.dispose();
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
                          text: "Hospital Direct Purchase ",
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
                  CustomButton(
                    label: 'New Bill Entry',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Add Product'),
                            content: Container(
                              width: screenWidth * 0.5,
                              height: screenHeight * 0.5,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenWidth * 0.5,
                                          height: screenHeight * 0.5,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomTextField(
                                                    onTap: () => _selectDate(
                                                        context, purchaseDate),
                                                    icon:
                                                        Icon(Icons.date_range),
                                                    controller: purchaseDate,
                                                    hintText: 'Purchase Date',
                                                    width: screenWidth * 0.15,
                                                  ),
                                                  CustomTextField(
                                                    onTap: () => _selectDate(
                                                        context, payedDate),
                                                    icon:
                                                        Icon(Icons.date_range),
                                                    controller: payedDate,
                                                    hintText: 'Payed Date',
                                                    width: screenWidth * 0.15,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomTextField(
                                                    controller: billNo,
                                                    hintText: 'Bill NO',
                                                    width: screenWidth * 0.2,
                                                  ),
                                                  CustomTextField(
                                                    controller: fromParty,
                                                    hintText: 'From Party',
                                                    width: screenWidth * 0.2,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth * 0.15,
                                                    child: CustomDropdown(
                                                      label: 'Payment Type',
                                                      items: const [
                                                        'UPI',
                                                        'Net Banking',
                                                        'Credit card',
                                                        'Debit Card',
                                                      ],
                                                      selectedItem:
                                                          selectedPaymentMode,
                                                      onChanged: (value) {
                                                        setState(
                                                          () {
                                                            selectedPaymentMode =
                                                                value;
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  CustomTextField(
                                                    controller: amount,
                                                    hintText: 'Total Amount',
                                                    width: screenWidth * 0.15,
                                                  ),
                                                  CustomTextField(
                                                    controller: collected,
                                                    hintText: 'Collected',
                                                    width: screenWidth * 0.15,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomTextField(
                                                    controller: city,
                                                    hintText: 'City',
                                                    width: screenWidth * 0.2,
                                                  ),
                                                  CustomTextField(
                                                    controller: phone,
                                                    hintText: 'Phone Number',
                                                    width: screenWidth * 0.2,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomTextField(
                                                    controller: chequeNo,
                                                    hintText: 'Cheque NO',
                                                    width: screenWidth * 0.2,
                                                  ),
                                                  CustomTextField(
                                                    controller: transactionId,
                                                    hintText: 'Transaction Id',
                                                    width: screenWidth * 0.2,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomTextField(
                                                    controller: description,
                                                    hintText: 'Description',
                                                    width: screenWidth * 0.25,
                                                  ),
                                                  CustomTextField(
                                                    controller: balanceAmount,
                                                    hintText: 'Balance',
                                                    width: screenWidth * 0.2,
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
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => addBill(),
                                child: CustomText(
                                  text: 'Submit ',
                                  color: AppColors.secondaryColor,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: CustomText(
                                  text: 'Cancel',
                                  color: AppColors.secondaryColor,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    width: screenWidth * 0.07,
                    height: screenHeight * 0.04,
                  )
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
