import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:lottie/lottie.dart';
import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/buttons/pharmacy_button.dart';
import '../../../../utilities/widgets/date_time.dart';
import '../../../../utilities/widgets/dropDown/pharmacy_drop_down.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/textField/pharmacy_text_field.dart';
import '../tools/manage_pharmacy_info.dart';
import 'counter_sales.dart';
import 'ip_billing.dart';

class MedicineReturn extends StatefulWidget {
  const MedicineReturn({super.key});

  @override
  State<MedicineReturn> createState() => _MedicineReturn();
}

class _MedicineReturn extends State<MedicineReturn> {
  TextEditingController _date = TextEditingController();
  TextEditingController _billNo = TextEditingController();
  TextEditingController _billId = TextEditingController();

  TextEditingController discount = TextEditingController();
  DateTime dateTime = DateTime.now();
  bool billSearch = false;
  final TextEditingController totalAmountController = TextEditingController();

  final TextEditingController paymentDetails = TextEditingController();
  String? selectedPaymentMode;
  String? billingTypeFound;

  double totalAmount = 0.0;
  double discountAmount = 0.0;

  String? patientNameError;
  String? doctorNameError;
  bool isPrinting = false;
  bool isAdding = false;
  bool isSubmitting = false;
  final List<String> headers = [
    'Product Name',
    'HSN',
    'Batch',
    'Expiry',
    'Quantity',
    'Return Qty',
    'MRP',
    'Rate',
    'Tax',
    'SGST',
    'CGST',
    'Tax Total',
    'Product Total',
    'Delete',
  ];
  final List<String> pdfHeaders = [
    'Product Name',
    'HSN',
    'Batch',
    'Expiry',
    'Quantity',
    'MRP',
    'Rate',
    'Tax',
    'SGST',
    'CGST',
    'Tax Total',
    'Product Total',
  ];

  final List<String> editableColumns = ['Return Qty'];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, TextEditingController>> controllers = [];
  List<List<Map<String, dynamic>>> productSuggestions = [];

  void clearAll() {
    setState(() {
      discount.clear();
      totalAmountController.clear();

      paymentDetails.clear();
      selectedPaymentMode = null;
      totalAmount = 0.0;
      discountAmount = 0.0;
      patientNameError = null;
      doctorNameError = null;
      isAdding = false;
      isSubmitting = false;
      isPrinting = false;
      allProducts = [];
    });
  }

  void onDiscountChanged(String value) {
    setState(() {
      double discountValue = double.tryParse(value) ?? 0.0;
      double totalWithoutDiscount = _allProductTotal().toDouble();

      double discountAmt = totalWithoutDiscount * (discountValue / 100);

      double netTotal = totalWithoutDiscount - discountAmt;

      discountAmount = discountAmt;
      totalAmount = netTotal;
      totalAmountController.text = totalAmount.toStringAsFixed(2);
    });
  }

  Future<void> searchBill(String billNo) async {
    final fireStore = FirebaseFirestore.instance;
    final billingsDocRef = fireStore.collection('pharmacy').doc('billings');

    final List<String> billingTypes = [
      'opbilling',
      'ipbilling',
      'countersales',
    ];

    const int batchSize = 1; // Number of docs to fetch per batch
    List<Map<String, dynamic>> tempProducts = [];

    try {
      for (final type in billingTypes) {
        DocumentSnapshot? lastDoc;
        bool hasMore = true;

        while (hasMore) {
          Query query = billingsDocRef
              .collection(type)
              .where('billNo', isEqualTo: billNo)
              .limit(batchSize);

          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          }

          final querySnapshot = await query.get();

          if (querySnapshot.docs.isEmpty) {
            hasMore = false;
            break;
          }

          // Process docs batch
          for (final doc in querySnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;

            tempProducts.add({
              'docId': doc.id,
              'billNo': data['billNo'],
              'billDate': data['billDate'],
              'discountPercentage': data['discountPercentage'],
              'totalAmount': data['totalAmount'],
              'paymentDetails': data['paymentDetails'],
              'paymentMode': data['paymentMode'],
              'discountAmount': data['discountAmount'],
              'netTotalAmount': data['netTotalAmount'],
              'entryProducts': data['entryProducts'],
            });
          }

          // Update lastDoc for next batch
          lastDoc = querySnapshot.docs.last;

          // Artificial delay to avoid hammering Firestore (optional)
          await Future.delayed(const Duration(milliseconds: 200));

          // If less than batch size, no more docs
          if (querySnapshot.docs.length < batchSize) {
            hasMore = false;
          }
        }

        if (tempProducts.isNotEmpty) {
          // Just pick first matching bill for UI as original code does
          final firstData = tempProducts.first;

          setState(() {
            billingTypeFound = type;
            _billId.text = firstData['docId'];
            _date = TextEditingController(text: firstData['billDate']);
            discount.text = firstData['discountPercentage'].toString();
            totalAmountController.text = firstData['totalAmount'].toString();

            paymentDetails.text = firstData['paymentDetails'].toString();
            selectedPaymentMode = firstData['paymentMode'].toString();
            discountAmount =
                double.parse(firstData['discountAmount'].toString());
            totalAmount = double.parse(firstData['netTotalAmount'].toString());

            allProducts =
                List<Map<String, dynamic>>.from(firstData['entryProducts'])
                    .asMap()
                    .entries
                    .map((entry) {
              final index = entry.key;
              final product = Map<String, dynamic>.from(entry.value);

              product['Delete'] = IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    allProducts.removeAt(index);
                  });
                },
              );

              return product;
            }).toList();
          });

          break; // Stop searching other billing types once found
        }
      }

      if (billNo.isEmpty) {
        setState(() {
          allProducts = [];
        });
      }
    } catch (e) {
      print('Error searching bill: $e');
    }
  }

  Future<void> returnBill(
    String billId,
    List<Map<String, dynamic>> returnedItems,
    String billingType,
  ) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      double updatedTotalBeforeTax = 0.0;
      double updatedTaxTotal = 0.0;
      double updatedNetTotal = 0.0;
      double updatedDiscountAmount = 0.0;

      // Get bill reference
      DocumentReference billRef = firestore
          .collection('pharmacy')
          .doc('billings')
          .collection(billingType)
          .doc(billId);

      DocumentSnapshot billSnapshot = await billRef.get();
      if (!billSnapshot.exists) {
        throw Exception("Bill not found");
      }

      List<Map<String, dynamic>> originalEntryProducts =
          List<Map<String, dynamic>>.from(billSnapshot['entryProducts']);
      List<Map<String, dynamic>> updatedEntryProducts = [];

      // Loop through each item in original bill
      for (var originalItem in originalEntryProducts) {
        String productDocId = originalItem['productDocId'];
        String purchaseEntryDocId = originalItem['purchaseEntryDocId'];
        int originalQty =
            int.tryParse(originalItem['Quantity'].toString()) ?? 0;

        // Check if this product is returned
        Map<String, dynamic>? returnedItem = returnedItems.firstWhere(
          (item) => item['productDocId'] == productDocId,
          orElse: () => {},
        );

        int returnQty = returnedItem.isNotEmpty
            ? int.tryParse(returnedItem['Return Qty'].toString()) ?? 0
            : 0;

        if (returnQty > originalQty) returnQty = originalQty;
        int newQty = originalQty - returnQty;

        // Stock and purchaseEntry update only if there's a return
        if (returnQty > 0) {
          DocumentReference productRef = firestore
              .collection('stock')
              .doc('Products')
              .collection('AddedProducts')
              .doc(productDocId);

          DocumentSnapshot productSnapshot = await productRef.get();
          if (!productSnapshot.exists) continue;

          int currentQty =
              int.tryParse(productSnapshot['quantity'].toString()) ?? 0;
          int newMainQty = currentQty + returnQty;

          batch.update(productRef, {
            'quantity': newMainQty.toString(),
          });

          DocumentReference purchaseEntryRef =
              productRef.collection('purchaseEntry').doc(purchaseEntryDocId);

          DocumentSnapshot purchaseSnapshot = await purchaseEntryRef.get();
          if (purchaseSnapshot.exists) {
            int purchaseQty =
                int.tryParse(purchaseSnapshot['quantity'].toString()) ?? 0;
            int newPurchaseQty = purchaseQty + returnQty;

            batch.update(purchaseEntryRef, {
              'quantity': newPurchaseQty.toString(),
            });
          }

          DateTime now = DateTime.now();
          await productRef.collection('currentQty').doc().set({
            'quantity': newMainQty.toString(),
            'date':
                "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
            'time':
                "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
          });
        }

        // Recalculate item totals if new quantity > 0
        if (newQty > 0) {
          double rate = double.tryParse(originalItem['Rate'].toString()) ?? 0;
          double tax = double.tryParse(originalItem['Tax'].toString()) ?? 0;

          double itemTotalBeforeTax = newQty * rate;
          double taxAmt = itemTotalBeforeTax * (tax / 100);
          double totalWithTax = itemTotalBeforeTax + taxAmt;

          updatedTotalBeforeTax += totalWithTax;
          updatedTaxTotal += taxAmt;
          updatedNetTotal += totalWithTax;

          originalItem['Quantity'] = newQty.toString();
          originalItem['Tax Total'] = taxAmt.toStringAsFixed(2);
          originalItem['Product Total'] = totalWithTax.toStringAsFixed(2);

          updatedEntryProducts.add(originalItem);
        }
      }

      // Discount
      double discountPercentage = double.tryParse(discount.text) ?? 0;
      updatedDiscountAmount = updatedNetTotal * (discountPercentage / 100);
      double finalTotal = updatedNetTotal - updatedDiscountAmount;

      batch.update(billRef, {
        'entryProducts': updatedEntryProducts,
        'totalBeforeDiscount': updatedTotalBeforeTax.toStringAsFixed(2),
        'taxTotal': updatedTaxTotal.toStringAsFixed(2),
        'totalAmount': finalTotal.toStringAsFixed(2),
        'netTotalAmount': finalTotal.toStringAsFixed(2),
        'discountAmount': updatedDiscountAmount.toStringAsFixed(2),
      });

      await batch.commit();

      CustomSnackBar(
        context,
        message: 'Return processed successfully and bill updated.',
        backgroundColor: Colors.green,
      );

      clearAll();
    } catch (e) {
      CustomSnackBar(
        context,
        message: 'Failed to process return.',
        backgroundColor: Colors.red,
      );
      print('Return Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    ;
  }

  double _taxTotal() {
    double sum = allProducts.fold<double>(
      0.0,
      (sum, entry) {
        var value = entry['Tax Total'];
        if (value == null) return sum;

        if (value is String) {
          return sum + (double.tryParse(value) ?? 0.0);
        } else if (value is num) {
          return sum + value.toDouble();
        }

        return sum;
      },
    );

    return double.parse(sum.toStringAsFixed(2));
  }

  double _allProductTotal() {
    double sum = allProducts.fold<double>(
      0.0,
      (sum, entry) {
        var value = entry['Product Total'];
        if (value == null) return sum;

        if (value is String) {
          return sum + (double.tryParse(value) ?? 0.0);
        } else if (value is num) {
          return sum + value.toDouble();
        }

        return sum;
      },
    );

    return double.parse(sum.toStringAsFixed(2));
  }

  @override
  void dispose() {
    for (var rowControllers in controllers) {
      for (var controller in rowControllers.values) {
        controller.dispose();
      }
    }
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
            left: screenWidth * 0.06,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              const TimeDateWidget(text: 'Medicine Return'),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Bill No ',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      PharmacyTextField(
                        hintText: '',
                        width: screenWidth * 0.2,
                        controller: _billNo,
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.02),
                    child: billSearch
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
                              setState(() {
                                billSearch = true;
                                allProducts.clear();
                              });
                              await searchBill(_billNo.text);
                              setState(() => billSearch = false);
                            },
                            width: screenWidth * 0.1,
                            height: screenHeight * 0.042,
                          ),
                  ),
                  SizedBox(width: screenWidth * 0.08),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: ' Bill Date ',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      PharmacyTextField(
                        readOnly: true,
                        hintText: '',
                        width: screenWidth * 0.2,
                        controller: _date,
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              if (allProducts.isNotEmpty) ...[
                Row(
                  children: [
                    CustomText(
                      text: 'Purchased Medicines',
                      size: screenWidth * 0.02,
                      color: AppColors.blue,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                CustomDataTable(
                  editableColumns: editableColumns,
                  headers: headers,
                  tableData: allProducts,
                  onValueChanged: (rowIndex, header, value) {
                    setState(() {
                      allProducts[rowIndex][header] = value;

                      if (header == 'Return Qty') {
                        final tax = double.tryParse(
                                allProducts[rowIndex]['Tax'] ?? '0') ??
                            0;
                        final quantity = double.tryParse(
                                allProducts[rowIndex]['Return Qty'] ?? '0') ??
                            0;
                        final price = double.tryParse(
                            allProducts[rowIndex]['Rate'] ?? '0');
                        final totalQuantity = quantity;

                        if (price != null) {
                          final totalWithoutTax = totalQuantity * price;
                          final taxAmount = totalWithoutTax * (tax / 100);
                          final totalWithTax = totalWithoutTax + taxAmount;

                          allProducts[rowIndex]['Tax Total'] =
                              taxAmount.toStringAsFixed(2);
                          allProducts[rowIndex]['Product Total'] =
                              totalWithTax.toStringAsFixed(2);
                        }
                      }
                      _taxTotal();
                      _allProductTotal();
                      onDiscountChanged(discount.text);
                    });
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.395),
                  child: Container(
                    padding: EdgeInsets.only(left: screenWidth * 0.02),
                    width: screenWidth * 0.7,
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
                          text: 'Tax Total  : ',
                        ),
                        CustomText(
                          text: " ${_taxTotal()}",
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        CustomText(
                          text: 'Total  : ',
                        ),
                        CustomText(
                          text: " ${_allProductTotal()}",
                        ),
                        SizedBox(width: screenWidth * 0.08),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.6),
                  child: Container(
                    padding: EdgeInsets.only(left: screenWidth * 0.02),
                    width: screenWidth * 0.7,
                    height: screenHeight * 0.04,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomText(
                          text: 'Discount  ${discount.text} % : ',
                        ),
                        CustomText(
                          text: '${discountAmount.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.6),
                  child: Container(
                    padding: EdgeInsets.only(left: screenWidth * 0.02),
                    width: screenWidth * 0.7,
                    height: screenHeight * 0.04,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomText(
                          text: 'Net Total : ${totalAmount.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.05, right: screenWidth * 0.05),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text:
                                        'Net Total : ${totalAmountController.text}',
                                    size: screenWidth * 0.0125,
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.05),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.09, right: screenWidth * 0.09),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PharmacyButton(
                          color: AppColors.blue,
                          label: 'Cancel',
                          onPressed: () {
                            clearAll();
                          },
                          width: screenWidth * 0.1),
                      isSubmitting
                          ? Lottie.asset('assets/button_loading.json',
                              height: 150, width: 150)
                          : PharmacyButton(
                              color: AppColors.blue,
                              label: 'Submit',
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Row(
                                      children: const [
                                        Icon(Icons.warning_amber_rounded,
                                            color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Text('Confirm Bill Submission'),
                                      ],
                                    ),
                                    content: const Text(
                                      'Are you sure you want to submit the bill?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text(
                                          'Confirm',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await returnBill(_billId.text, allProducts,
                                      billingTypeFound.toString());
                                }
                              },
                              width: screenWidth * 0.1),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
