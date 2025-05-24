import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_out_standing_bills.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_pending_sales_bills.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utilities/colors.dart';
import '../../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../../utilities/widgets/drawer/management/accounts/pharmacy/management_pharmacy_accounts.dart';
import '../../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../../utilities/widgets/table/data_table.dart';
import '../../../../../utilities/widgets/text/primary_text.dart';
import '../../../../../utilities/widgets/textField/primary_textField.dart';
import '../new_patient_register_collection.dart';

class PharmacyPurchase extends StatefulWidget {
  @override
  State<PharmacyPurchase> createState() => _PharmacyPurchase();
}

class _PharmacyPurchase extends State<PharmacyPurchase> {
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();

  int selectedIndex = 1;
  TextEditingController _distributor = TextEditingController();
  TextEditingController _billNo = TextEditingController();

  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController collectedAmountController =
      TextEditingController();
  final TextEditingController currentlyPayingAmount = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();
  String? selectedPaymentMode;

  List<String> distributorsNames = [];
  String? selectedDistributor;
  double _originalCollected = 0.0;

  final List<String> headers = [
    'Bill NO',
    'Bill Date',
    'Ref No',
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

  Future<void> fetchData({String? fromDate, String? toDate}) async {
    try {
      CollectionReference productsCollection = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry');

      Query query = productsCollection;

      if (fromDate != null && toDate != null) {
        query = query
            .where('billDate', isGreaterThanOrEqualTo: fromDate)
            .where('billDate', isLessThanOrEqualTo: toDate);
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
            'Bill Date': data['billDate']?.toString() ?? 'N/A',
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
                                        CustomTextField(
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
                                        CustomTextField(
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
                                        CustomTextField(
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
                                        CustomTextField(
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
                                          child: CustomDropdown(
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
                                        CustomTextField(
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

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _distributor.dispose();
    _billNo.dispose();
    currentlyPayingAmount.removeListener(_payingAmountListener);

    super.dispose();
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
                text: 'Pharmacy Accounts Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ManagementPharmacyAccounts(
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
              child: ManagementPharmacyAccounts(
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
              padding: const EdgeInsets.all(16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
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
                          text: "Pharmacy Purchase",
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
                  SizedBox(width: screenWidth * 0.02),
                  CustomTextField(
                    controller: fromDate,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                    verticalSize: screenHeight * 0.015,
                    icon: Icon(Icons.date_range),
                    onTap: () => _selectDate(context, fromDate),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  CustomTextField(
                    controller: toDate,
                    hintText: 'To Date ',
                    width: screenWidth * 0.15,
                    verticalSize: screenHeight * 0.015,
                    icon: Icon(Icons.date_range),
                    onTap: () => _selectDate(context, toDate),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(fromDate: fromDate.text, toDate: toDate.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenHeight * 0.05,
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
                  7: FixedColumnWidth(screenWidth * 0.15),
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
