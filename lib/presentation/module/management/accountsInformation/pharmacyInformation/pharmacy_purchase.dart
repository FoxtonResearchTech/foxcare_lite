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
  TextEditingController date = TextEditingController();
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();

  int selectedIndex = 1;
  String? choosePartyName;

  double totalAmount = 0.0;

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

  final List<String> headers = [
    'Entry No',
    'Bill No',
    'Bill Date',
    'Distributor Name',
    'Bill Amount',
    'Bill Details'
  ];

  final List<String> headers2 = [
    'Product Name',
    'Batch',
    'Expiry',
    'Quantity',
    'Free',
    'MRP',
    'Price',
    'Tax',
    'Amount',
  ];
  List<Map<String, dynamic>> tableData2 = [];

  List<Map<String, dynamic>> tableData = [];
  Future<void> fetchData(
      {String? date, String? fromDate, String? toDate}) async {
    try {
      resetTotals();
      CollectionReference productsCollection = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('PurchaseEntry');

      Query query = productsCollection;
      if (date != null) {
        query = query.where('reportDate', isEqualTo: date);
      } else if (fromDate != null && toDate != null) {
        query = query
            .where('reportDate', isGreaterThanOrEqualTo: fromDate)
            .where('reportDate', isLessThanOrEqualTo: toDate);
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

        fetchedData.add({
          'Entry No': data['entryNo']?.toString() ?? 'N/A',
          'Bill No': data['billNo']?.toString() ?? 'N/A',
          'Bill Date': data['reportDate']?.toString() ?? 'N/A',
          'Distributor Name': '${data['distributor'] ?? 'N/A'}'.trim(),
          'Bill Amount': data['amount']?.toString() ?? 'N/A',
          'Bill Details': TextButton(
            onPressed: () {
              for (var product in data['entryProducts']) {
                tableData2.add({
                  'Product Name': product['Product Name'],
                  'Batch': product['Batch Number'],
                  'Expiry': product['Expiry'],
                  'Quantity': product['Quantity'],
                  'Free': product['Free'],
                  'MRP': product['MRP'],
                  'Price': product['Price'],
                  'Tax': product['GST'],
                  'Amount': product['Amount'],
                  'HSN Code': product['HSN Code'],
                  'Category': product['Category'],
                  'Company': product['Company'],
                });
              }
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('View Bill'),
                    content: Container(
                      width: 950,
                      height: 500,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                  child: Container(
                                    width: 950,
                                    height: 500,
                                    child: Column(
                                      children: [
                                        CustomDataTable(
                                            headerColor: Colors.white,
                                            headerBackgroundColor:
                                                AppColors.blue,
                                            headers: headers2,
                                            tableData: tableData2),
                                        SizedBox(height: 50),
                                      ],
                                    ),
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                          text: 'Ok ',
                          color: AppColors.secondaryColor,
                          size: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                          text: 'Cancel',
                          color: AppColors.secondaryColor,
                          size: 14,
                        ),
                      ),
                    ],
                  );
                },
              ).then((_) {
                tableData2.clear();
              });
            },
            child: const CustomText(text: 'Open'),
          ),
        });
      }
      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Entry No']) ?? 0;
        int tokenB = int.tryParse(b['Entry No']) ?? 0;
        return tokenA.compareTo(tokenB);
      });
      if (fetchedData.isEmpty) {
        setState(() {
          tableData = [];
          resetTotals();
        });
        return;
      }
      setState(() {
        tableData = fetchedData;
        calculateTotals();
      });
      print(tableData);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void calculateTotals() {
    totalAmount = tableData.fold(0.0, (sum, item) {
      double amount =
          double.tryParse(item['Bill Amount']?.toString() ?? '0') ?? 0;
      return sum + amount;
    });

    totalAmount = double.parse(totalAmount.toStringAsFixed(2));
  }

  void resetTotals() {
    totalAmount = 0.00;
  }

  @override
  void initState() {
    fetchData();

    super.initState();
  }

  @override
  void dispose() {
    date.dispose();
    fromDate.dispose();
    toDate.dispose();
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
                          text: "Pharmacy Total Sales",
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
                    controller: date,
                    onTap: () => _selectDate(context, date),
                    icon: Icon(Icons.date_range),
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(date: date.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomText(text: 'OR'),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, fromDate),
                    controller: fromDate,
                    icon: Icon(Icons.date_range),
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, toDate),
                    controller: toDate,
                    icon: Icon(Icons.date_range),
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(fromDate: fromDate.text, toDate: toDate.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
              ),
              Container(
                padding: EdgeInsets.only(right: screenWidth * 0.03),
                width: screenWidth,
                height: screenHeight * 0.030,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomText(
                      text: 'Total :        $totalAmount',
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
