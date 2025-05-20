import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/damage_return_entry.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/purchase_entry.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/stock_management/stock_return%20_entry.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class DamageReturn extends StatefulWidget {
  const DamageReturn({super.key});

  @override
  State<DamageReturn> createState() => _DamageReturn();
}

class _DamageReturn extends State<DamageReturn> {
  TextEditingController _distributor = TextEditingController();
  TextEditingController _refNo = TextEditingController();
  List<String> distributorsNames = [];
  String? selectedDistributor;
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController collectedAmountController =
      TextEditingController();
  final TextEditingController currentlyPayingAmount = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();
  String? selectedPaymentMode;
  double _originalCollected = 0.0;

  final List<String> headers = [
    'Ref No',
    'Return Date',
    'Distributor',
    'Amount',
    'Paid',
    'Balance',
    'Action'
  ];
  List<Map<String, dynamic>> tableData = [];

  void _payingAmountListener() {
    double paying = double.tryParse(currentlyPayingAmount.text) ?? 0.0;
    double total = double.tryParse(totalAmountController.text) ?? 0.0;

    double newCollected = _originalCollected + paying;
    double newBalance = total - newCollected;

    collectedAmountController.text = newCollected.toStringAsFixed(2);
    balanceController.text = newBalance.toStringAsFixed(2);
  }

  Future<void> fetchData({String? distributor, String? refNo}) async {
    try {
      CollectionReference productsCollection = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('DamageReturn');

      Query query = productsCollection;
      if (distributor != null) {
        query = query.where('distributor', isEqualTo: distributor);
      } else if (refNo != null) {
        query = query.where('refNo', isEqualTo: refNo);
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

        fetchedData.add(
          {
            'Bill NO': data['billNo']?.toString() ?? 'N/A',
            'Return Date': data['returnDate']?.toString() ?? 'N/A',
            'Ref No': data['rfNo']?.toString() ?? 'N/A',
            'Distributor': '${data['distributor'] ?? 'N/A'}'.trim(),
            'Amount': data['netTotalAmount']?.toString() ?? 'N/A',
            'Paid': data['collectedAmount']?.toString() ?? 'N/A',
            'Balance': data['balance']?.toString() ?? 'N/A',
            'Action': Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    double originalCollected = double.tryParse(
                            data['collectedAmount']?.toString() ?? '0') ??
                        0.0;
                    double total = double.tryParse(
                            data['netTotalAmount']?.toString() ?? '0') ??
                        0.0;

                    setState(() {
                      _originalCollected = originalCollected;
                      totalAmountController.text = total.toStringAsFixed(2);
                      collectedAmountController.text =
                          originalCollected.toStringAsFixed(2);
                      balanceController.text =
                          (total - originalCollected).toStringAsFixed(2);
                      currentlyPayingAmount.text = '';
                    });

                    currentlyPayingAmount.removeListener(_payingAmountListener);
                    currentlyPayingAmount.addListener(_payingAmountListener);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const CustomText(
                            text: 'Payment Details Details',
                            size: 26,
                          ),
                          content: Container(
                            width: 750,
                            height: 275,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CustomText(
                                          text: 'Total Amount',
                                          size: 20,
                                        ),
                                        const SizedBox(height: 5),
                                        PharmacyTextField(
                                            readOnly: true,
                                            controller: totalAmountController,
                                            hintText: '',
                                            width: 175),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CustomText(
                                          text: 'Collected',
                                          size: 20,
                                        ),
                                        const SizedBox(height: 5),
                                        PharmacyTextField(
                                            readOnly: true,
                                            controller:
                                                collectedAmountController,
                                            hintText: '',
                                            width: 175),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CustomText(
                                          text: 'Balance',
                                          size: 20,
                                        ),
                                        const SizedBox(height: 5),
                                        PharmacyTextField(
                                            readOnly: true,
                                            controller: balanceController,
                                            hintText: '',
                                            width: 175),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 50),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: 'Paying Amount ',
                                          size: 20,
                                        ),
                                        SizedBox(height: 7),
                                        PharmacyTextField(
                                          hintText: '',
                                          controller: currentlyPayingAmount,
                                          width: 175,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: 'Payment Mode ',
                                          size: 20,
                                        ),
                                        SizedBox(height: 7),
                                        SizedBox(
                                          width: 175,
                                          child: PharmacyDropDown(
                                            label: '',
                                            items: const [
                                              'UPI',
                                              'Credit Card',
                                              'Debit Card',
                                              'Net Banking',
                                              'Cash'
                                            ],
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  selectedPaymentMode = value;
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: 'Payment Details ',
                                          size: 20,
                                        ),
                                        SizedBox(height: 7),
                                        PharmacyTextField(
                                          hintText: '',
                                          controller: paymentDetails,
                                          width: 175,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {},
                              child: CustomText(
                                text: 'Pay',
                                color: AppColors.secondaryColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: CustomText(
                                text: 'Close',
                                color: AppColors.secondaryColor,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: CustomText(
                    text: 'Pay',
                    color: AppColors.blue,
                    size: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: CustomText(
                    text: 'Open',
                    color: AppColors.blue,
                    size: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: CustomText(
                    text: 'Abscond',
                    color: AppColors.blue,
                    size: 14,
                  ),
                ),
              ],
            ),
          },
        );
      }

      setState(() {
        tableData = fetchedData;
      });
      print(tableData);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchDistributors() async {
    try {
      QuerySnapshot<Map<String, dynamic>> distributorsSnapshot =
          await FirebaseFirestore.instance
              .collection('pharmacy')
              .doc('distributors')
              .collection('distributor')
              .get();
      setState(() {
        distributorsNames = distributorsSnapshot.docs
            .map((doc) => doc['distributorName'].toString())
            .toList();
      });
    } catch (e) {
      print('Error fetching distributors: $e');
    }
  }

  @override
  void initState() {
    fetchData();
    fetchDistributors();
    super.initState();
  }

  @override
  void dispose() {
    _distributor.dispose();
    _refNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              TimeDateWidget(text: 'Damage / Broken Return'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PharmacyButton(
                    label: 'Damage Return Entry',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DamageReturnEntry()));
                    },
                    width: screenWidth * 0.12,
                    height: screenHeight * 0.04,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  PharmacyTextField(
                    controller: _refNo,
                    hintText: 'Ref No',
                    width: screenWidth * 0.25,
                    verticalSize: screenHeight * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyButton(
                      label: 'Search',
                      onPressed: () {
                        fetchData(refNo: _refNo.text);
                      },
                      width: screenWidth * 0.08),
                  SizedBox(width: screenHeight * 0.2),
                  SizedBox(
                    width: screenWidth * 0.15,
                    child: PharmacyDropDown(
                      label: '',
                      items: distributorsNames,
                      selectedItem: selectedDistributor,
                      onChanged: (value) {
                        setState(() {
                          selectedDistributor = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(distributor: selectedDistributor);
                    },
                    width: screenWidth * 0.08,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Bill List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                columnWidths: {
                  6: FixedColumnWidth(screenWidth * 0.18),
                },
                tableData: tableData,
                headers: headers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
