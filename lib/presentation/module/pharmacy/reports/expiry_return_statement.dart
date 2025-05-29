import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/buttons/pharmacy_button.dart';
import '../../../../utilities/widgets/date_time.dart';
import '../../../../utilities/widgets/textField/pharmacy_text_field.dart';
import '../tools/manage_pharmacy_info.dart';

class ExpiryReturnStatement extends StatefulWidget {
  const ExpiryReturnStatement({super.key});

  @override
  State<ExpiryReturnStatement> createState() => _ExpiryReturnStatement();
}

class _ExpiryReturnStatement extends State<ExpiryReturnStatement> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  TextEditingController distributorNameController = TextEditingController();
  TextEditingController dlNo1Controller = TextEditingController();
  TextEditingController dlNo2Controller = TextEditingController();
  TextEditingController gstNoController = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController refNo = TextEditingController();
  bool searching = false;

  TextEditingController emailId = TextEditingController();
  TextEditingController phoneNo1 = TextEditingController();
  TextEditingController returnDate = TextEditingController();
  TextEditingController totalReturnAmount = TextEditingController();
  double totalAmount = 0.0;
  final List<String> headers = [
    'Ref No',
    'Bill date',
    'Distributor Name',
    'Total Amount',
    'Collected',
    'Balance',
    'Bill details',
  ];
  List<Map<String, dynamic>> tableData = [];
  final List<String> headers2 = [
    'Product Name',
    'Batch',
    'Expiry',
    'Return Quantity',
    'Free',
    'MRP',
    'Rate',
    'Tax',
    'CGST',
    'SGST',
    'Total Tax',
    'Product Total',
  ];
  List<Map<String, dynamic>> tableData2 = [];

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      const int batchSize = 20;
      List<Map<String, dynamic>> allFetchedData = [];

      Query<Map<String, dynamic>> baseQuery = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('ExpiryReturn')
          .orderBy('returnDate'); // Required for pagination

      // Apply date filters
      if (singleDate != null) {
        baseQuery = baseQuery.where('returnDate', isEqualTo: singleDate);
      } else if (fromDate != null && toDate != null) {
        baseQuery = baseQuery
            .where('returnDate', isGreaterThanOrEqualTo: fromDate)
            .where('returnDate', isLessThanOrEqualTo: toDate);
      }

      QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;
      bool hasMore = true;

      // Clear table before adding new data
      setState(() {
        tableData = [];
      });

      while (hasMore) {
        Query<Map<String, dynamic>> paginatedQuery = baseQuery.limit(batchSize);

        if (lastDoc != null) {
          paginatedQuery = paginatedQuery.startAfterDocument(lastDoc);
        }

        final snapshot = await paginatedQuery.get();

        if (snapshot.docs.isEmpty) {
          hasMore = false;
          break;
        }

        List<Map<String, dynamic>> batchData = [];

        for (var doc in snapshot.docs) {
          final data = doc.data();

          batchData.add({
            'Ref No': data['rfNo']?.toString() ?? 'N/A',
            'Bill date': data['returnDate']?.toString() ?? 'N/A',
            'Distributor Name': data['distributor']?.toString() ?? 'N/A',
            'Total Amount': data['netTotalAmount']?.toString() ?? 'N/A',
            'Collected': data['collectedAmount']?.toString() ?? 'N/A',
            'Balance': data['balance']?.toString() ?? 'N/A',
            'Bill details': TextButton(
              onPressed: () {
                distributorNameController.text =
                    data['distributor']?.toString() ?? 'N/A';
                dlNo1Controller.text = data['dlNo1']?.toString() ?? 'N/A';

                dlNo2Controller.text = data['dlNo1']?.toString() ?? 'N/A';

                address.text = data['address']?.toString() ?? 'N/A';

                emailId.text = data['mail']?.toString() ?? 'N/A';
                phoneNo1.text = data['phone']?.toString() ?? 'N/A';
                refNo.text = data['rfNo']?.toString() ?? 'N/A';
                returnDate.text = data['returnDate']?.toString() ?? 'N/A';
                totalReturnAmount.text =
                    data['netTotalAmount']?.toString() ?? 'N/A';
                print(totalReturnAmount);

                for (var product in data['entryProducts']) {
                  tableData2.add({
                    'Product Name': product['Product Name'],
                    'Batch': product['Batch'],
                    'Expiry': product['Expiry'],
                    'Free': product['Free'],
                    'MRP': product['MRP'],
                    'Rate': product['Rate'],
                    'Tax': product['Tax'],
                    'CGST': product['CGST'],
                    'SGST': product['SGST'],
                    'Total Tax': product['Tax Total'],
                    'Return Quantity': product['Quantity'],
                    'Product Total': product['Product Total'],
                    'HSN Code': product['HSN Code'],
                    'Category': product['Category'],
                    'Company': product['Company'],
                    'Distributor': product['Distributor'],
                  });
                }
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const CustomText(
                        text: 'View Bill',
                        size: 26,
                      ),
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
                                      height: 750,
                                      child: Column(
                                        children: [
                                          const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText(
                                                text: 'Distributor details ',
                                                size: 20, // Adjusted size
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text:
                                                        'Distributor Name :${distributorNameController.text}',
                                                    size: 16,
                                                  ),
                                                  CustomText(
                                                    text:
                                                        'DL / No 1 :${dlNo1Controller.text}',
                                                    size: 16,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 175),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text:
                                                        'Return Date :${returnDate.text}',
                                                    size: 16,
                                                  ),
                                                  CustomText(
                                                    text:
                                                        'DL / No 2 :${dlNo2Controller.text}',
                                                    size: 16,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText(
                                                text: 'Stock Return Address',
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text:
                                                        'Return Number : ${refNo.text}',
                                                    size: 16,
                                                  ),
                                                  CustomText(
                                                    text:
                                                        'E-Mail ID : ${emailId.text}',
                                                    size: 16,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 175),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text:
                                                        'Address : ${address.text}',
                                                    size: 16,
                                                  ),
                                                  CustomText(
                                                    text:
                                                        'Phone : ${phoneNo1.text}',
                                                    size: 16,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          CustomDataTable(
                                              headers: headers2,
                                              tableData: tableData2),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                left: 650),
                                            width: 1000,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                CustomText(
                                                  text:
                                                      'Total : ${totalReturnAmount.text}',
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 50),
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

        // Update table data in UI incrementally
        setState(() {
          tableData.addAll(batchData);
          calculateTotals();
        });

        lastDoc = snapshot.docs.last;
        await Future.delayed(const Duration(milliseconds: 100));
      }
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

  void calculateTotals() {
    totalAmount = tableData.fold(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item['Total Amount']?.toString() ?? '0') ?? 0),
    );
  }

  @override
  void initState() {
    fetchData();
    super.initState();
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
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              TimeDateWidget(text: 'Expiry Return Statement'),
              Row(
                children: [
                  PharmacyTextField(
                    onTap: () => _selectDate(context, _fromDateController),
                    icon: const Icon(Icons.date_range),
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyTextField(
                    onTap: () => _selectDate(context, _toDateController),
                    icon: const Icon(Icons.date_range),
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  searching
                      ? SizedBox(
                          width: screenWidth * 0.1,
                          height: screenHeight * 0.045,
                          child: Center(
                            child: Lottie.asset(
                              'assets/button_loading.json',
                            ),
                          ),
                        )
                      : PharmacyButton(
                          label: 'Search',
                          onPressed: () async {
                            setState(() => searching = true);
                            await fetchData(
                              fromDate: _fromDateController.text,
                              toDate: _toDateController.text,
                            );
                            setState(() => searching = false);
                            calculateTotals();
                          },
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.025,
                        ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Available Stock Return List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              LazyDataTable(
                tableData: tableData,
                headers: headers,
              ),
              Container(
                padding: EdgeInsets.only(left: screenWidth * 0.01),
                width: screenWidth,
                height: screenHeight * 0.030,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    CustomText(
                      text: 'Total : ${totalAmount.toStringAsFixed(2)} ',
                    )
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PharmacyButton(
                      label: 'Print',
                      onPressed: () {},
                      width: screenWidth * 0.1)
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
