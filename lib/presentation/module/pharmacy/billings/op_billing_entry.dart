import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/table/billing_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/stock_return_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

import '../../../../utilities/widgets/snackBar/snakbar.dart';

class OpBillingEntry extends StatefulWidget {
  final String? patientName;
  final String? opTicket;
  final String? opNumber;
  final String? place;
  final String? phone;
  final String? doctorName;
  final String? specialization;

  const OpBillingEntry(
      {this.patientName,
      this.opTicket,
      this.opNumber,
      this.place,
      this.phone,
      this.doctorName,
      this.specialization,
      super.key});

  @override
  State<OpBillingEntry> createState() => _OpBillingEntry();
}

class _OpBillingEntry extends State<OpBillingEntry> {
  TextEditingController discount = TextEditingController();
  DateTime dateTime = DateTime.now();

  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController collectedAmountController =
      TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();
  String? selectedPaymentMode;

  double totalAmount = 0.0;
  double discountAmount = 0.0;
  bool isPrinting = false;

  bool isAdding = false;
  bool isSubmitting = false;
  final List<String> headers = [
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
    'Delete',
  ];

  final List<String> editableColumns = ['Product Name', 'Quantity'];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, TextEditingController>> controllers = [];
  List<List<Map<String, dynamic>>> productSuggestions = [];

  String billNO = '';
  int newBillNo = 0;

  void clearAll() {
    setState(() {
      discount.clear();
      totalAmountController.clear();
      collectedAmountController.clear();
      balanceController.clear();
      paymentDetails.clear();
      selectedPaymentMode = null;
      totalAmount = 0.0;
      discountAmount = 0.0;
      isAdding = false;
      isSubmitting = false;
      isPrinting = false;

      allProducts = [];
      controllers.clear();
      productSuggestions.clear();
      billNO = '';
      newBillNo = 0;
    });
  }

  void _updateBalance() {
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    double paidAmount = double.tryParse(collectedAmountController.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    balanceController.text = balance.toStringAsFixed(2);
  }

  void addNewRow() {
    setState(() {
      allProducts.add({
        for (var header in headers) header: '',
      });
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

  void initializeControllers() {
    controllers.clear();
    for (int index = 0; index < allProducts.length; index++) {
      final product = allProducts[index];
      controllers.add({
        'Quantity': TextEditingController(text: product['Quantity'] ?? ''),
        'Free': TextEditingController(text: product['Free'] ?? ''),
      });
    }
  }

  Future<void> submitBill() async {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    setState(() {
      isSubmitting = true;
      initializeControllers();
    });

    try {
      for (int i = 0; i < controllers.length; i++) {
        var ctrl = controllers[i];
        for (var key in ctrl.keys) {
          if (ctrl[key]?.text.trim().isEmpty ?? true) {
            CustomSnackBar(
              context,
              message: "Product ${i + 1} field '$key' is empty.",
              backgroundColor: Colors.red,
            );
            setState(() {
              isSubmitting = false;
            });
            return;
          }
        }
      }

      for (int i = 0; i < allProducts.length; i++) {
        String docId = allProducts[i]['productDocId'];
        String purchaseEntryDocId = allProducts[i]['purchaseEntryDocId'];

        DocumentReference productRef = FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .doc(docId);

        DocumentSnapshot mainProductSnapshot = await productRef.get();
        final mainProductData =
            mainProductSnapshot.data() as Map<String, dynamic>?;

        // Fetch purchase entry doc
        DocumentSnapshot purchaseEntrySnapshot = await productRef
            .collection('purchaseEntry')
            .doc(purchaseEntryDocId)
            .get();
        final purchaseEntryData =
            purchaseEntrySnapshot.data() as Map<String, dynamic>?;

        if (mainProductSnapshot.exists && purchaseEntrySnapshot.exists) {
          // Quantities before return
          int entryQty =
              int.tryParse(purchaseEntryData?['quantity']?.toString() ?? '0') ??
                  0;

          int mainQty =
              int.tryParse(mainProductData?['quantity']?.toString() ?? '0') ??
                  0;

          // Returned quantities
          int returnQty =
              int.tryParse(controllers[i]['Quantity']?.text ?? '0') ?? 0;

          // Updated values
          int newEntryQty = entryQty - returnQty;
          if (newEntryQty < 0) newEntryQty = 0;

          int newMainQty = mainQty - returnQty;
          if (newMainQty < 0) newMainQty = 0;

          // Update purchase entry document
          await purchaseEntrySnapshot.reference.update({
            'quantity': newEntryQty.toString(),
          });

          // Update main product document
          await productRef.update({
            'quantity': newMainQty.toString(),
          });

          // Log updated quantity
          await productRef.collection('currentQty').doc().set({
            'quantity': newMainQty.toString(),
            'date':
                "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
            'time': dateTime.hour.toString() +
                ':' +
                dateTime.minute.toString().padLeft(2, '0'),
          });
        }
      }

      // Save stock return document
      await FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billings')
          .collection('opbilling')
          .doc()
          .set({
        'billDate': todayString,
        'billNo': billNO,
        'opTicket': widget.opTicket,
        'opNumber': widget.opNumber,
        'patientName': widget.patientName,
        'place': widget.place,
        'phone': widget.phone,
        'doctorName': widget.doctorName,
        'specialization': widget.specialization,
        'entryProducts': allProducts,
        'discountPercentage': discount.text,
        'discountAmount': discountAmount.toStringAsFixed(2),
        'taxTotal': _taxTotal().toStringAsFixed(2),
        'totalBeforeDiscount': _allProductTotal().toStringAsFixed(2),
        'netTotalAmount': totalAmount.toStringAsFixed(2),
        'paymentDetails': paymentDetails.text,
        'paymentMode': selectedPaymentMode,
        'totalAmount': totalAmountController.text,
        'collectedAmount': collectedAmountController.text,
        'balance': balanceController.text,
      });

      await updateBillNo(newBillNo);

      setState(() {
        isSubmitting = false;
      });

      CustomSnackBar(
        context,
        message: 'Bill Submitted and Product updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      print('Error updating products: $e');
      CustomSnackBar(
        context,
        message: 'Failed to submit Bill update products',
        backgroundColor: Colors.red,
      );
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<String?> getAndIncrementBillNo() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('billNo')
          .doc('pharmacyBillings');

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        int currentBillNo = data?['billNo'] ?? 0;
        int currentNewBillNo = currentBillNo + 1;

        setState(() {
          billNO = '${currentNewBillNo}';
          newBillNo = currentNewBillNo;
        });

        return billNO;
      } else {
        print('Document does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching or incrementing billNo: $e');
      return null;
    }
  }

  Future<void> updateBillNo(int newBillNo) async {
    final docRef =
        FirebaseFirestore.instance.collection('billNo').doc('pharmacyBillings');

    await docRef.set({'billNo': newBillNo});
  }

  @override
  void initState() {
    super.initState();
    getAndIncrementBillNo();
    productSuggestions = List.generate(allProducts.length, (_) => []);
    addNewRow();
    totalAmountController.addListener(_updateBalance);
    collectedAmountController.addListener(_updateBalance);
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
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        title: Center(
          child: CustomText(
              text: 'OP Billing',
              size: screenWidth * 0.012,
              color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06, vertical: screenHeight * 0.04),
          child: Column(
            children: [
              const TimeDateWidget(text: 'OP Billings'),
              SizedBox(height: screenHeight * 0.02),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: screenWidth * 0.005),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Bill No : $billNO',
                            size: screenWidth * 0.015,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          CustomText(
                            text: 'Date : $todayString',
                            size: screenWidth * 0.015,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          CustomText(
                            text: 'OP Ticket Number : ${widget.opTicket}',
                            size: screenWidth * 0.015,
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Patient Name : ${widget.patientName}',
                            size: screenWidth * 0.015,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          CustomText(
                            text: 'OP Number : ${widget.opNumber}',
                            size: screenWidth * 0.015,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          CustomText(
                            text: 'Place: ${widget.place}',
                            size: screenWidth * 0.015,
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone : ${widget.phone}',
                            size: screenWidth * 0.015,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          CustomText(
                            text: 'Doctor Name : ${widget.doctorName}',
                            size: screenWidth * 0.015,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          CustomText(
                            text: 'Specialization : ${widget.specialization}',
                            size: screenWidth * 0.015,
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.005),
                    ],
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomText(
                    text: '     Products',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              isAdding
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              isAdding = true;
                            });
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            setState(() {
                              addNewRow();
                              isAdding = false;
                            });
                          },
                          icon: Icon(
                            Icons.add,
                            color: AppColors.blue,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.85,
                          child: BillingDataTable(
                            headers: headers,
                            tableData: allProducts,
                            editableColumns: editableColumns,
                            onValueChanged: (rowIndex, header, value) {
                              setState(() {
                                allProducts[rowIndex][header] = value;

                                if (header == 'Quantity') {
                                  final tax = double.tryParse(
                                          allProducts[rowIndex]['Tax'] ??
                                              '0') ??
                                      0;
                                  final quantity = double.tryParse(
                                          allProducts[rowIndex]['Quantity'] ??
                                              '0') ??
                                      0;
                                  final price = double.tryParse(
                                      allProducts[rowIndex]['Rate'] ?? '0');
                                  final totalQuantity = quantity;

                                  if (price != null) {
                                    final totalWithoutTax =
                                        totalQuantity * price;
                                    final taxAmount =
                                        totalWithoutTax * (tax / 100);
                                    final totalWithTax =
                                        totalWithoutTax + taxAmount;

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
                        ),
                      ],
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
                      SizedBox(width: screenWidth * 0.05),
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
                        text: 'Discount ',
                      ),
                      PharmacyTextField(
                        controller: discount,
                        hintText: '',
                        width: screenWidth * 0.05,
                        onChanged: onDiscountChanged,
                      ),
                      CustomText(
                        text: '  % :  ',
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
              SizedBox(height: screenHeight * 0.04),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.05),
                child: Row(
                  children: [
                    CustomText(
                      text: 'Payment',
                      size: screenWidth * 0.02,
                      color: AppColors.blue,
                    )
                  ],
                ),
              ),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Collected ',
                                  size: screenWidth * 0.011,
                                ),
                                SizedBox(height: 7),
                                PharmacyTextField(
                                  hintText: '',
                                  controller: collectedAmountController,
                                  width: screenWidth * 0.15,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Balance ',
                                  size: screenWidth * 0.011,
                                ),
                                SizedBox(height: 7),
                                PharmacyTextField(
                                  hintText: '',
                                  controller: balanceController,
                                  width: screenWidth * 0.15,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Payment Mode ',
                                  size: screenWidth * 0.011,
                                ),
                                SizedBox(height: 7),
                                SizedBox(
                                  height: screenHeight * 0.04,
                                  width: screenWidth * 0.15,
                                  child: PharmacyDropDown(
                                    width: screenWidth * 0.04,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Payment Details ',
                                  size: screenWidth * 0.011,
                                ),
                                SizedBox(height: 7),
                                PharmacyTextField(
                                  hintText: '',
                                  controller: paymentDetails,
                                  width: screenWidth * 0.15,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                    PharmacyButton(
                        color: AppColors.blue,
                        label: 'Print',
                        onPressed: () {},
                        width: screenWidth * 0.1),
                    isSubmitting
                        ? Lottie.asset('assets/button_loading.json',
                            height: 150, width: 150)
                        : PharmacyButton(
                            color: AppColors.blue,
                            label: 'Submit',
                            onPressed: () {
                              submitBill();
                            },
                            width: screenWidth * 0.1),
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
