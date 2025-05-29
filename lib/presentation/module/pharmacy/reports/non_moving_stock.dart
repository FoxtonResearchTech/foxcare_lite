import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';

import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';

class NonMovingStock extends StatefulWidget {
  const NonMovingStock({super.key});

  @override
  State<NonMovingStock> createState() => _NonMovingStock();
}

class _NonMovingStock extends State<NonMovingStock> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  int i = 1;

  final List<String> headers = [
    'SL No',
    'Product Name',
    'Opening Stock',
    'Expiry Date',
    'Non-Moving Details',
  ];
  List<Map<String, dynamic>> tableData = [];
  bool singleDateSearch = false;
  bool fromToDateSearch = false;

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      const int batchSize = 15;
      QueryDocumentSnapshot<Map<String, dynamic>>? lastProductDoc;
      bool hasMoreProducts = true;

      List<Map<String, dynamic>> allFetchedData = [];
      int i = 1;

      setState(() {
        tableData = [];
      });

      while (hasMoreProducts) {
        Query<Map<String, dynamic>> productQuery = FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .limit(batchSize);

        if (lastProductDoc != null) {
          productQuery = productQuery.startAfterDocument(lastProductDoc);
        }

        final addedProductsSnapshot = await productQuery.get();

        if (addedProductsSnapshot.docs.isEmpty) {
          hasMoreProducts = false;
          break;
        }

        for (var productDoc in addedProductsSnapshot.docs) {
          final productData = productDoc.data();
          final docId = productDoc.id;

          final purchaseEntriesSnapshot = await FirebaseFirestore.instance
              .collection('stock')
              .doc('Products')
              .collection('AddedProducts')
              .doc(docId)
              .collection('purchaseEntry')
              .get();

          for (var purchaseDoc in purchaseEntriesSnapshot.docs) {
            final purchaseData = purchaseDoc.data();

            if (!purchaseData.containsKey('reportDate') ||
                !purchaseData.containsKey('fixedQuantity') ||
                !purchaseData.containsKey('quantity')) continue;

            String reportDateStr = purchaseData['reportDate'];
            DateTime reportDate =
                DateTime.tryParse(reportDateStr) ?? DateTime(1900);

            // Filter
            if (singleDate != null) {
              if (reportDateStr != singleDate) continue;
            } else if (fromDate != null && toDate != null) {
              DateTime from = DateTime.parse(fromDate);
              DateTime to = DateTime.parse(toDate);
              if (reportDate.isBefore(from) || reportDate.isAfter(to)) continue;
            }

            // Non-moving condition
            if (purchaseData['fixedQuantity'] == purchaseData['quantity']) {
              allFetchedData.add({
                'SL No': i++,
                'Product Name': productData['productName'],
                'Opening Stock': purchaseData['fixedQuantity'],
                'Remaining Stock': purchaseData['quantity'],
                'Expiry Date': purchaseData['expiry'],
                'Non-Moving Details': TextButton(
                  onPressed: () {
                    int daysDifference =
                        DateTime.now().difference(reportDate).inDays;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Non-Moving Stocks Details'),
                          content: Container(
                            width: 350,
                            height: 180,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                    text: 'Product Entry Date: $reportDateStr'),
                                CustomText(
                                    text:
                                        'Product Name: ${productData['productName']}'),
                                CustomText(
                                    text:
                                        'Opening Stock: ${purchaseData['fixedQuantity']}'),
                                CustomText(
                                    text:
                                        'Remaining Stock: ${purchaseData['quantity']}'),
                                CustomText(
                                    text:
                                        'Expiry Date: ${purchaseData['expiry']}'),
                                CustomText(
                                    text:
                                        'Days Since Entry: $daysDifference days'),
                              ],
                            ),
                          ),
                          actions: <Widget>[
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
                  child: CustomText(text: 'View Details'),
                ),
              });
            }
          }
        }

        // Add to table in batch
        setState(() {
          tableData.addAll(allFetchedData);
        });

        allFetchedData.clear();
        lastProductDoc = addedProductsSnapshot.docs.last;
        await Future.delayed(const Duration(milliseconds: 300));
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
              TimeDateWidget(text: 'Non-Moving Statement'),
              Row(
                children: [
                  PharmacyTextField(
                    onTap: () => _selectDate(context, _dateController),
                    icon: Icon(Icons.date_range),
                    controller: _dateController,
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  singleDateSearch
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
                            setState(() => singleDateSearch = true);
                            await fetchData(singleDate: _dateController.text);
                            setState(() => singleDateSearch = false);
                            i = 1;
                          },
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.025,
                        ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomText(text: 'OR'),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyTextField(
                    onTap: () => _selectDate(context, _fromDateController),
                    icon: Icon(Icons.date_range),
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyTextField(
                    onTap: () => _selectDate(context, _toDateController),
                    icon: Icon(Icons.date_range),
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  fromToDateSearch
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
                            setState(() => fromToDateSearch = true);
                            await fetchData(
                              fromDate: _fromDateController.text,
                              toDate: _toDateController.text,
                            );
                            setState(() => fromToDateSearch = false);
                            i = 1;
                          },
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.025,
                        ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Available Non-Moving Stock List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              LazyDataTable(
                tableData: tableData,
                headers: headers,
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
