import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/table/purchase_entry_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/stock_return_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

import '../../../../utilities/constants.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';

class DamageReturnEntry extends StatefulWidget {
  const DamageReturnEntry({super.key});

  @override
  State<DamageReturnEntry> createState() => _DamageReturnEntry();
}

class _DamageReturnEntry extends State<DamageReturnEntry> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController mail = TextEditingController();
  TextEditingController dlNo1 = TextEditingController();
  TextEditingController dlNo2 = TextEditingController();
  TextEditingController gstIn = TextEditingController();
  TextEditingController discount = TextEditingController();

  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController collectedAmountController =
      TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();
  String? selectedPaymentMode;

  double totalAmount = 0.0;
  double discountAmount = 0.0;
  DateTime dateTime = DateTime.now();

  bool isAdding = false;
  bool isSubmitting = false;
  final List<String> headers = [
    'Product Name',
    'HSN',
    'Batch',
    'Expiry',
    'Quantity',
    'Free',
    'MRP',
    'Rate',
    'Tax',
    'SGST',
    'CGST',
    'Tax Total',
    'Product Total',
    'Delete',
  ];

  final List<String> editableColumns = ['Product Name', 'Quantity', 'Free'];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, TextEditingController>> controllers = [];
  List<List<Map<String, dynamic>>> productSuggestions = [];

  String? selectedDistributor;
  List<String> distributorsNames = [];
  String rfNo = '';
  int newRfNo = 0;

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

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
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

  Future<void> getDistributorDetails({required String distributorName}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> distributorsSnapshot =
          await FirebaseFirestore.instance
              .collection('pharmacy')
              .doc('distributors')
              .collection('distributor')
              .where('distributorName', isEqualTo: distributorName)
              .get();
      setState(() {
        address.text = distributorsSnapshot.docs[0]['lane1'].toString();
        phone.text = distributorsSnapshot.docs[0]['phoneNo1'].toString();
        mail.text = distributorsSnapshot.docs[0]['emailId'].toString();
        dlNo1.text = distributorsSnapshot.docs[0]['dlNo1'].toString();
        dlNo2.text = distributorsSnapshot.docs[0]['dlNo2'].toString();
        gstIn.text = distributorsSnapshot.docs[0]['gstNo'].toString();
      });
    } catch (e) {
      print('Error fetching distributors: $e');
    }
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
          int entryFree =
              int.tryParse(purchaseEntryData?['free']?.toString() ?? '0') ?? 0;
          int mainQty =
              int.tryParse(mainProductData?['quantity']?.toString() ?? '0') ??
                  0;

          // Returned quantities
          int returnQty =
              int.tryParse(controllers[i]['Quantity']?.text ?? '0') ?? 0;
          int returnFree =
              int.tryParse(controllers[i]['Free']?.text ?? '0') ?? 0;

          // Updated values
          int newEntryQty = entryQty - returnQty - returnFree;
          int newEntryFree = entryFree - returnFree;
          if (newEntryQty < 0) newEntryQty = 0;
          if (newEntryFree < 0) newEntryFree = 0;

          int newMainQty = mainQty - returnQty - returnFree;
          if (newMainQty < 0) newMainQty = 0;

          // Update purchase entry document
          await purchaseEntrySnapshot.reference.update({
            'quantity': newEntryQty.toString(),
            'free': newEntryFree.toString(),
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

      DocumentReference billRef = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('DamageReturn')
          .doc();

      await billRef.set({
        'returnDate': _dateController.text,
        'rfNo': rfNo,
        'entryProducts': allProducts,
        'distributor': selectedDistributor,
        'discountPercentage': discount.text,
        'discountAmount': discountAmount.toStringAsFixed(2),
        'taxTotal': _taxTotal().toStringAsFixed(2),
        'totalBeforeDiscount': _allProductTotal().toStringAsFixed(2),
        'netTotalAmount': totalAmount.toStringAsFixed(2),
        'address': address.text,
        'phone': phone.text,
        'mail': mail.text,
        'dlNo1': dlNo1.text,
        'dlNo2': dlNo2.text,
        'gstIn': gstIn.text,
        'totalAmount': totalAmountController.text,
        'collectedAmount': collectedAmountController.text,
        'balance': balanceController.text,
      });

      await billRef.collection('payments').add({
        'collected': totalAmount.toStringAsFixed(2),
        'balance': balanceController.text,
        'paymentMode': selectedPaymentMode,
        'paymentDetails': paymentDetails.text,
        'payedDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'payedTime': dateTime.hour.toString() +
            ':' +
            dateTime.minute.toString().padLeft(2, '0'),
      });

      await updateBillNo(newRfNo);

      setState(() {
        isSubmitting = false;
      });

      CustomSnackBar(
        context,
        message: 'Products updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      print('Error updating products: $e');
      CustomSnackBar(
        context,
        message: 'Failed to update products',
        backgroundColor: Colors.red,
      );
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<String?> getAndIncrementBillNo() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('billNo').doc('pharmacyRfNo');

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        int currentBillNo = data?['rfno'] ?? 0;
        int newBillNo = currentBillNo + 1;

        setState(() {
          rfNo = 'RfNo${newBillNo}';
          newRfNo = newBillNo;
        });

        return rfNo;
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
        FirebaseFirestore.instance.collection('billNo').doc('pharmacyRfNo');

    await docRef.set({'rfno': newBillNo});
  }

  @override
  void initState() {
    super.initState();
    fetchDistributors();
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
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        title: Center(
          child: CustomText(
              text: 'Damage Return Entry',
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
              const TimeDateWidget(text: 'Damage Return Entry'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Return Date ',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      PharmacyTextField(
                        hintText: '',
                        width: screenWidth * 0.2,
                        controller: _dateController,
                        icon: const Icon(Icons.date_range),
                        onTap: () => _selectDate(context),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Reference No',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      PharmacyTextField(
                        readOnly: true,
                        hintText: '',
                        width: screenWidth * 0.2,
                        controller:
                            TextEditingController(text: rfNo.toString()),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Distributor Name',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Row(
                        children: [
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
                          SizedBox(width: screenWidth * 0.01),
                          PharmacyButton(
                            label: 'Select',
                            onPressed: () {
                              getDistributorDetails(
                                  distributorName:
                                      selectedDistributor.toString());
                            },
                            width: screenWidth * 0.1,
                            height: screenHeight * 0.05,
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Distributor Name : ${selectedDistributor}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'Address : ${address.text}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'Phone : ${phone.text}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'Mail : ${mail.text}',
                        size: screenWidth * 0.012,
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'DL NO 1 : ${dlNo1.text}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'DL NO 2 : ${dlNo2.text}',
                        size: screenWidth * 0.012,
                      ),
                      CustomText(
                        text: 'GSTIN : ${gstIn.text}',
                        size: screenWidth * 0.012,
                      ),
                    ],
                  ),
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
                          child: StockReturnDataTable(
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
                                  text: 'Total Amount ',
                                  size: screenWidth * 0.013,
                                ),
                                SizedBox(height: 7),
                                PharmacyTextField(
                                  hintText: '',
                                  controller: totalAmountController,
                                  width: screenWidth * 0.15,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Collected ',
                                  size: screenWidth * 0.013,
                                ),
                                SizedBox(height: 7),
                                PharmacyTextField(
                                  hintText: '',
                                  controller: collectedAmountController,
                                  width: screenWidth * 0.2,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Balance ',
                                  size: screenWidth * 0.013,
                                ),
                                SizedBox(height: 7),
                                PharmacyTextField(
                                  hintText: '',
                                  controller: balanceController,
                                  width: screenWidth * 0.2,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Payment Mode ',
                                  size: screenWidth * 0.013,
                                ),
                                SizedBox(height: 7),
                                SizedBox(
                                  width: screenWidth * 0.2,
                                  child: PharmacyDropDown(
                                    width: screenWidth * 0.05,
                                    label: '',
                                    items: Constants.paymentMode,
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
                                  size: screenWidth * 0.013,
                                ),
                                SizedBox(height: 7),
                                PharmacyTextField(
                                  hintText: '',
                                  controller: paymentDetails,
                                  width: screenWidth * 0.2,
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
                        onPressed: () {},
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
                                await submitBill();
                              }
                            },
                            width: screenWidth * 0.1),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
