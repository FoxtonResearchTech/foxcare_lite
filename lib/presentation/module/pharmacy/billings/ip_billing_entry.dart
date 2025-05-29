import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/constants.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/table/data_table.dart';

class IpBillingEntry extends StatefulWidget {
  final String? patientName;
  final String? ipTicket;
  final String? opNumber;
  final String? place;
  final String? phone;
  final String? doctorName;
  final String? specialization;
  final String? roomWard;
  final List<Map<String, dynamic>>? medications;

  const IpBillingEntry(
      {this.patientName,
      this.roomWard,
      this.ipTicket,
      this.opNumber,
      this.place,
      this.phone,
      this.doctorName,
      this.specialization,
      super.key,
      this.medications});

  @override
  State<IpBillingEntry> createState() => _IpBillingEntry();
}

class _IpBillingEntry extends State<IpBillingEntry> {
  TextEditingController discount = TextEditingController();
  DateTime dateTime = DateTime.now();

  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController collectedAmountController =
      TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();

  final TextEditingController _fromDate = TextEditingController();
  final TextEditingController _toDate = TextEditingController();

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

  final List<String> medicineHeaders = [
    'SL No',
    'Medicine Name',
    'Morning',
    'Afternoon',
    'Evening',
    'Night',
    'Duration',
  ];

  List<Map<String, dynamic>> medicineTableData = [];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, TextEditingController>> controllers = [];
  List<List<Map<String, dynamic>>> productSuggestions = [];

  String billNO = '';
  int newBillNo = 0;
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

      DocumentReference billRef = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billings')
          .collection('ipbilling')
          .doc();
      await billRef.set({
        'billDate': todayString,
        'billNo': billNO,
        'ipTicket': widget.ipTicket,
        'roomWard': widget.roomWard,
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
      await markAllTodayMedicinesAsGiven(
          patientId: widget.opNumber.toString(),
          ipTicket: widget.ipTicket.toString());
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

  Future<void> markMedicineAsGiven({
    required String patientId,
    required String ipTicket,
    required String docId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .collection('ipTickets')
          .doc(ipTicket)
          .collection('prescribedMedicines')
          .doc(docId)
          .update({'medicineGiven': true});

      print('Medicine marked as given for docId: $docId');
    } catch (e) {
      print('Error updating medicineGiven: $e');
    }
  }

  Future<void> markAllTodayMedicinesAsGiven({
    required String patientId,
    required String ipTicket,
  }) async {
    final docIds = medicineTableData.map((item) => item['docId']).toSet();
    for (var docId in docIds) {
      await markMedicineAsGiven(
        patientId: patientId,
        ipTicket: ipTicket,
        docId: docId,
      );
    }
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
                                    'Patient Name : ${widget.patientName}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'OP Number : ${widget.opNumber}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'IP Ticket : ${widget.ipTicket}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Phone No : ${widget.phone}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Doctor Name : ${widget.doctorName}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Specialization : ${widget.specialization}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Room Type/No : ${widget.roomWard}',
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
                      pw.SizedBox(height: 15),
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
                                '${_taxTotal().toStringAsFixed(2)}',
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
                                '${_allProductTotal().toStringAsFixed(2)}',
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
                                '${discountAmount.toStringAsFixed(2)}',
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
                await Printing.layoutPdf(
                  onLayout: (format) async => pdf.save(),
                );
                //
                // await Printing.sharePdf(
                //     bytes: await pdf.save(), filename: '${billNO}.pdf');
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

  Future<void> checkMedications({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final prescribedSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.opNumber)
          .collection('ipTickets')
          .doc(widget.ipTicket)
          .collection('prescribedMedicines')
          .get();

      List<Map<String, dynamic>> todayPrescribedMedicines = [];
      medicineTableData.clear();

      for (var doc in prescribedSnapshot.docs) {
        final data = doc.data();
        final docDateStr = data['date'];

        if (docDateStr != null &&
            docDateStr.compareTo(fromDate) >= 0 &&
            docDateStr.compareTo(toDate) <= 0 &&
            data.containsKey('items')) {
          todayPrescribedMedicines.add({
            'docId': doc.id,
            'items': data['items'],
            'medicineGiven': data['medicineGiven'] ?? false,
          });

          final items = data['items'];
          final medicineGiven = data['medicineGiven'] ?? false;
          if (items is List) {
            for (var item in items) {
              if (item is Map<String, dynamic>) {
                item['docId'] = doc.id;
                item['medicineGiven'] = medicineGiven;
                medicineTableData.add(item);
              }
            }
          }
        }
      }

      setState(() {});
    } catch (e) {
      print('Error fetching prescribed medicines: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getAndIncrementBillNo();
    productSuggestions = List.generate(allProducts.length, (_) => []);
    addNewRow();
    totalAmountController.addListener(_updateBalance);
    collectedAmountController.addListener(_updateBalance);
    for (var entry in widget.medications!) {
      final docId = entry['docId'];
      final items = entry['items'];
      final medicineGiven = entry['medicineGiven'];
      if (items is List) {
        for (var item in items) {
          if (item is Map<String, dynamic>) {
            item['docId'] = docId;
            item['medicineGiven'] = medicineGiven;
            medicineTableData.add(item);
          }
        }
      }
    }
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
              text: 'IP Billing',
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
              const TimeDateWidget(text: 'IP Billings'),
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
                            text: 'IP Ticket Number : ${widget.ipTicket}',
                            size: screenWidth * 0.015,
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.01),
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
                      SizedBox(width: screenWidth * 0.01),
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
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.045),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Room Ward : ${widget.roomWard}',
                      size: screenWidth * 0.015,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: '     Prescribed Medications',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                  PharmacyButton(
                      label: 'Check For Previous Medicine',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: CustomText(
                                    text: 'Check For Previous Medicine',
                                    size: screenWidth * 0.013,
                                  ),
                                  content: SizedBox(
                                    width: screenWidth * 0.25,
                                    height: screenHeight * 0.2,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: screenHeight * 0.1),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              PharmacyTextField(
                                                onTap: () => _selectDate(
                                                    context, _fromDate),
                                                hintText: 'From Date ',
                                                width: screenWidth * 0.1,
                                                controller: _fromDate,
                                                icon: const Icon(
                                                    Icons.date_range_outlined),
                                              ),
                                              PharmacyTextField(
                                                onTap: () => _selectDate(
                                                    context, _toDate),
                                                hintText: 'To Date ',
                                                width: screenWidth * 0.1,
                                                controller: _toDate,
                                                icon: const Icon(Icons
                                                    .access_time_filled_outlined),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        await checkMedications(
                                            fromDate: _fromDate.text,
                                            toDate: _toDate.text);
                                        Navigator.of(context).pop();
                                      },
                                      child: CustomText(
                                        text: 'OK',
                                        color: AppColors.blue,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _fromDate.clear();
                                        _toDate.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: CustomText(
                                        text: 'Cancel',
                                        color: AppColors.blue,
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      width: screenWidth * 0.14,
                      height: screenHeight * 0.035)
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              if (medicineTableData.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.only(left: screenWidth * 0.05),
                  width: double.infinity,
                  child: CustomDataTable(
                      headers: medicineHeaders,
                      tableData: medicineTableData,
                      rowColorResolver: (row) {
                        if (row['medicineGiven'] == true) {
                          return Colors.green.shade50;
                        }
                        return Colors.transparent;
                      }),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
              if (medicineTableData.isEmpty) ...[
                CustomText(
                  text: 'No Medicine Prescribed',
                  size: screenWidth * 0.012,
                ),
              ],
              Row(
                children: [
                  CustomText(
                    text: '     Products',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  )
                ],
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
                              final collectedAmountText =
                                  collectedAmountController.text.trim();

                              // Validate collected amount is not empty
                              if (collectedAmountText.isEmpty) {
                                CustomSnackBar(context,
                                    message:
                                        'Please enter the collected amount',
                                    backgroundColor: Colors.orange);

                                return;
                              }

                              // Parse and validate amount
                              final collectedAmount =
                                  double.tryParse(collectedAmountText);
                              if (collectedAmount == null ||
                                  collectedAmount < 0) {
                                CustomSnackBar(context,
                                    message:
                                        'Please enter a valid collected amount',
                                    backgroundColor: Colors.orange);

                                return;
                              }
                              submitBill();
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
