import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:async';

import '../../../../utilities/colors.dart';
import '../../../../utilities/constants.dart';
import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/buttons/pharmacy_button.dart';
import '../../../../utilities/widgets/date_time.dart';
import '../../../../utilities/widgets/dropDown/pharmacy_drop_down.dart';
import '../../../../utilities/widgets/table/billing_data_table.dart';
import '../../../../utilities/widgets/textField/pharmacy_text_field.dart';

class CounterSales extends StatefulWidget {
  const CounterSales({super.key});

  @override
  State<CounterSales> createState() => _CounterSales();
}

class _CounterSales extends State<CounterSales> {
  TextEditingController patientName = TextEditingController();
  TextEditingController opNumber = TextEditingController();
  TextEditingController place = TextEditingController();
  TextEditingController doctorName = TextEditingController();
  TextEditingController hospitalName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

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

  final List<String> editableColumns = ['Product Name', 'Quantity'];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, TextEditingController>> controllers = [];
  List<List<Map<String, dynamic>>> productSuggestions = [];

  String billNO = '';
  int newBillNo = 0;

  void clearAll() {
    setState(() {
      patientName.clear();
      opNumber.clear();
      place.clear();
      doctorName.clear();
      hospitalName.clear();
      phoneNumber.clear();
      discount.clear();
      totalAmountController.clear();
      collectedAmountController.clear();
      balanceController.clear();
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
      controllers.clear();
      productSuggestions.clear();
      billNO = '';
      newBillNo = 0;
    });
  }

  void printInvoice() {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invoice'),
          content: Container(
            width: 125,
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomText(text: 'Do you want to print ?'),
                const SizedBox(height: 8),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final pdf = pw.Document();
                const blue = PdfColor.fromInt(0xFF106ac2);
                const lightBlue = PdfColor.fromInt(0xFF21b0d1); // 0xAARRGGBB

                final font =
                    await rootBundle.load('Fonts/Poppins/Poppins-Regular.ttf');
                final ttf = pw.Font.ttf(font);

                final topImage = pw.MemoryImage(
                  (await rootBundle.load('assets/opAssets/OP_Ticket_Top.png'))
                      .buffer
                      .asUint8List(),
                );

                final bottomImage = pw.MemoryImage(
                  (await rootBundle
                          .load('assets/opAssets/OP_Card_back_original.png'))
                      .buffer
                      .asUint8List(),
                );
                List<pw.Widget> buildPaginatedTable({
                  required List<String> headers,
                  required List<Map<String, dynamic>> data,
                  required pw.Font ttf,
                  required PdfColor headerColor,
                  required double rowHeight,
                }) {
                  final List<List<String>> tableData = [
                    headers,
                    ...data.map((row) =>
                        headers.map((h) => row[h]?.toString() ?? '').toList()),
                  ];

                  return [
                    pw.TableHelper.fromTextArray(
                      headers: headers,
                      data: data
                          .map((row) => headers
                              .map((h) => row[h]?.toString() ?? '')
                              .toList())
                          .toList(),
                      headerStyle: pw.TextStyle(
                        font: ttf,
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      headerDecoration: pw.BoxDecoration(color: headerColor),
                      cellStyle: pw.TextStyle(font: ttf, fontSize: 7),
                      cellHeight: rowHeight - 10,
                      border: pw.TableBorder.all(color: headerColor),
                    ),
                  ];
                }

                pdf.addPage(
                  pw.MultiPage(
                    pageFormat: PdfPageFormat.a4,
                    header: (context) => pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Invoice',
                              style: pw.TextStyle(
                                fontSize: 40,
                                font: ttf,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Invoice No : $billNO',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    font: ttf,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.Text(
                                  'Date : $todayString',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    font: ttf,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        pw.Divider(color: blue, thickness: 2),
                      ],
                    ),
                    footer: (context) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Divider(color: blue, thickness: 2),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  '${Constants.hospitalName}',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: blue,
                                  ),
                                ),
                                pw.Text(
                                  '${Constants.hospitalAddress}',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.Text(
                                  '${Constants.state + ' - ' + Constants.pincode}',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.Text(
                                  'Phone - ${Constants.landLine + ', ' + Constants.billNo}',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ],
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'For Surya Pharmacy',
                                  style: pw.TextStyle(
                                    fontSize: 24,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                    build: (context) => [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                'Surya Pharmacy',
                                style: pw.TextStyle(
                                  fontSize: 24,
                                  font: ttf,
                                  color: blue,
                                ),
                              ),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    '${Constants.hospitalAddress}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    '${Constants.state + ' - ' + Constants.pincode}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Phone - ${Constants.landLine + ', ' + Constants.billNo}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'DL : ',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'GSTIN : ',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Patient Name : ${patientName.text}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  if (opNumber.text.isNotEmpty)
                                    pw.Text(
                                      'OP Number : ${opNumber.text}',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  if (phoneNumber.text.isNotEmpty)
                                    pw.Text(
                                      'Phone No : ${phoneNumber.text}',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  pw.Text(
                                    'Doctor Name : ${doctorName.text}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  if (hospitalName.text.isNotEmpty)
                                    pw.Text(
                                      'Hospital Name : ${hospitalName.text}',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      ...buildPaginatedTable(
                        headers: pdfHeaders,
                        data: allProducts,
                        ttf: ttf,
                        headerColor: blue,
                        rowHeight: 15,
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 231),
                        child: pw.Container(
                          padding: pw.EdgeInsets.only(left: 1),
                          width: 270,
                          height: 20,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: blue,
                              width: 1,
                            ),
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text(
                                'Tax Total : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                '${_taxTotal().toString()}',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.SizedBox(width: 20),
                              pw.Text(
                                'Total : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                '${_allProductTotal().toString()}',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.SizedBox(width: 15),
                            ],
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 340),
                        child: pw.Container(
                          padding: pw.EdgeInsets.only(left: 5),
                          width: 150,
                          height: 20,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: blue,
                              width: 1,
                            ),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text(
                                'Discount ${discount.text}% : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                '${discountAmount.toString()}',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.SizedBox(width: 5),
                            ],
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.only(left: 340),
                        child: pw.Container(
                          padding: pw.EdgeInsets.only(left: 5),
                          width: 150,
                          height: 20,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: blue,
                              width: 1,
                            ),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text(
                                'Net Total : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                '${totalAmountController.text}',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.SizedBox(width: 5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                //
                // await Printing.layoutPdf(
                //   onLayout: (format) async => pdf.save(),
                // );

                await Printing.sharePdf(
                    bytes: await pdf.save(), filename: '${billNO}.pdf');
              },
              child: const Text('Print'),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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

  void validateForm() {
    setState(() {
      if (patientName.text.trim().isEmpty) {
        patientNameError = 'This field can\'t cannot be empty';
      } else {
        patientNameError = null;
      }
      if (doctorName.text.trim().isEmpty) {
        doctorNameError = 'This field can\'t cannot be empty';
      } else {
        doctorNameError = null;
      }
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
      });
    }
  }

  Future<void> submitBill() async {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    setState(() {
      validateForm();
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
          .collection('countersales')
          .doc()
          .set({
        'billDate': todayString,
        'billNo': billNO,
        'opNumber': opNumber.text,
        'patientName': patientName.text,
        'place': place.text,
        'phone': phoneNumber.text,
        'doctorName': doctorName.text,
        'hospitalName': hospitalName.text,
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
        isPrinting = true;
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
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              const TimeDateWidget(text: 'Counter Sales'),
              SizedBox(height: screenHeight * 0.02),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.078),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Bill No : $billNO',
                          size: screenWidth * 0.015,
                        ),
                        SizedBox(width: screenWidth * 0.21),
                        CustomText(
                          text: 'Date : $todayString',
                          size: screenWidth * 0.015,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Patient Name',
                            size: screenHeight * 0.03,
                          ),
                          SizedBox(height: screenHeight * 0.001),
                          Row(
                            children: [
                              PharmacyTextField(
                                controller: patientName,
                                hintText: '',
                                width: screenWidth * 0.2,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: screenHeight * 0.02),
                                child: CustomText(
                                  text: ' *',
                                  size: screenHeight * 0.03,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          if (patientNameError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: CustomText(
                                text: patientNameError!,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone Number',
                            size: screenHeight * 0.03,
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          PharmacyTextField(
                            controller: phoneNumber,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Place',
                            size: screenHeight * 0.03,
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          PharmacyTextField(
                            controller: place,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Doctor Name',
                            size: screenHeight * 0.03,
                          ),
                          SizedBox(height: screenHeight * 0.001),
                          Row(
                            children: [
                              PharmacyTextField(
                                controller: doctorName,
                                hintText: '',
                                width: screenWidth * 0.2,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: screenHeight * 0.02),
                                child: CustomText(
                                  text: ' *',
                                  size: screenHeight * 0.03,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          if (doctorNameError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: CustomText(
                                text: doctorNameError!,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'OP Number',
                            size: screenHeight * 0.03,
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          PharmacyTextField(
                            controller: opNumber,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Hospital Name',
                            size: screenHeight * 0.03,
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          PharmacyTextField(
                            controller: hospitalName,
                            hintText: '',
                            width: screenWidth * 0.2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.04),
                child: Row(
                  children: [
                    CustomText(
                      text: '     Products',
                      size: screenWidth * 0.02,
                      color: AppColors.blue,
                    )
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
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
              SizedBox(height: screenHeight * 0.02),
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
                    isPrinting
                        ? PharmacyButton(
                            color: AppColors.blue,
                            label: 'Print',
                            onPressed: () {
                              printInvoice();
                            },
                            width: screenWidth * 0.1)
                        : SizedBox(),
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
