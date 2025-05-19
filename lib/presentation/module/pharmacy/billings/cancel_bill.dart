import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../../../../utilities/constants.dart';
import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/date_time.dart';
import '../tools/manage_pharmacy_info.dart';

class CancelBill extends StatefulWidget {
  const CancelBill({super.key});

  @override
  State<CancelBill> createState() => _CancelBill();
}

class _CancelBill extends State<CancelBill> {
  final dateTime = DateTime.now();
  final TextEditingController _opBillNo = TextEditingController();
  final TextEditingController _ipBillNo = TextEditingController();
  final TextEditingController _csBillNo = TextEditingController();
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
  String? selectedValue;
  final List<String> opHeaders = [
    'Bill No',
    'Bill Date',
    'Patient Name',
    'OP Ticket',
    'OP No',
    'Doctor Name',
    'Action',
  ];
  List<Map<String, dynamic>> opTableData = [];
  final List<String> ipHeaders = [
    'Bill No',
    'Bill Date',
    'Patient Name',
    'IP Ticket',
    'OP No',
    'Doctor Name',
    'Action',
  ];
  List<Map<String, dynamic>> ipTableData = [];
  final List<String> counterSalesHeaders = [
    'Bill No',
    'Bill Date',
    'Patient Name',
    'Doctor Name',
    'Action',
  ];
  List<Map<String, dynamic>> counterSalesTableData = [];
  String formatDate(DateTime dateTime) {
    return dateTime.day.toString().padLeft(2, '0') +
        getDaySuffix(dateTime.day) +
        ' ' +
        DateFormat('MMM').format(dateTime) +
        ' ' +
        dateTime.year.toString();
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> fetchOpBills({String? billNO}) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billings')
          .collection('opbilling');

      if (billNO != null) {
        query = query.where('billNo', isEqualTo: billNO);
      }

      final QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> fetchedData = [];

      for (var bills in snapshot.docs) {
        final data = bills.data() as Map<String, dynamic>;

        if (data.isNotEmpty) {
          fetchedData.add({
            'Bill No': data['billNo'] ?? 'N/A',
            'Patient Name': data['patientName'] ?? 'N/A',
            'OP No': data['opNumber'] ?? 'N/A',
            'Bill Date': data['billDate'] ?? 'N/A',
            'OP Ticket': data['opTicket'] ?? 'N/A',
            'Doctor Name': data['doctorName'] ?? 'N/A',
            'Action': Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    final List<Map<String, dynamic>> productLists =
                        (data['entryProducts'] as List)
                            .map((e) => Map<String, dynamic>.from(e as Map))
                            .toList();
                    printOpInvoice(
                      data['billNo'],
                      data['billDate'],
                      data['patientName'],
                      data['doctorName'],
                      data['opNumber'],
                      data['phone'],
                      data['place'],
                      data['opTicket'],
                      data['specialization'],
                      productLists,
                      data['discountPercentage'],
                      data['discountAmount'],
                      data['taxTotal'],
                      data['totalBeforeDiscount'],
                      data['netTotalAmount'],
                    );
                  },
                  child: const CustomText(text: 'View'),
                ),
                TextButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Confirmation'),
                          content: Container(
                            width: 200,
                            height: 35,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(text: 'Are you sure ?'),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                await cancelOpBill(
                                    bills.id, data['entryProducts']);
                              },
                              child: const CustomText(
                                text: 'Sure',
                                color: Colors.red,
                              ),
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
                  },
                  child: const CustomText(text: 'Cancel'),
                ),
              ],
            )
          });
        }
      }

      setState(() {
        opTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void printOpInvoice(
    String billNo,
    String billDate,
    String patientName,
    String doctorName,
    String opTicket,
    String specialization,
    String opNo,
    String phoneNo,
    String hospitalName,
    List<Map<String, dynamic>> products,
    String discountPercentage,
    String discountAmount,
    String taxTotal,
    String total,
    String netTotalAmount,
  ) {
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
                                  'Invoice No : $billNo',
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
                                    'Patient Name : ${patientName}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'OP Number : ${opNo}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'OP Ticket : ${opTicket}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Phone No : ${phoneNo}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Doctor Name : ${doctorName}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Specialization : ${specialization}',
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
                        data: products,
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
                                '${taxTotal}',
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
                                '${total}',
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
                                'Discount ${discountPercentage}% : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                '${discountAmount}',
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
                                '${netTotalAmount}',
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
                    bytes: await pdf.save(), filename: '${billNo}.pdf');
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

  Future<void> cancelOpBill(String billId, List<dynamic> items) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      for (var item in items) {
        String productDocId = item['productDocId'];
        String purchaseEntryDocId = item['purchaseEntryDocId'];
        int quantityToAdd = int.tryParse(item['Quantity'].toString()) ?? 0;

        // Reference to the product document
        DocumentReference productRef = firestore
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .doc(productDocId);

        // Get current quantity from product document
        DocumentSnapshot productSnapshot = await productRef.get();
        if (!productSnapshot.exists) continue;

        int currentQty =
            int.tryParse((productSnapshot['quantity'] ?? '0').toString()) ?? 0;
        int newMainQty = currentQty + quantityToAdd;

        // 1. Update product quantity (outside purchaseEntry)
        batch.update(productRef, {
          'quantity': newMainQty.toString(),
        });

        // 2. Update purchaseEntry's qtyWithoutFree
        DocumentReference purchaseEntryRef =
            productRef.collection('purchaseEntry').doc(purchaseEntryDocId);

        DocumentSnapshot purchaseSnapshot = await purchaseEntryRef.get();
        if (purchaseSnapshot.exists) {
          int purchaseQty =
              int.tryParse((purchaseSnapshot['quantity'] ?? '0').toString()) ??
                  0;
          int newPurchaseQty = purchaseQty + quantityToAdd;

          batch.update(purchaseEntryRef, {
            'quantity': newPurchaseQty.toString(),
          });
        }

        // 3. Add entry to currentQty subcollection
        DateTime dateTime = DateTime.now();
        await productRef.collection('currentQty').doc().set({
          'quantity': newMainQty.toString(),
          'date':
              "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
          'time': dateTime.hour.toString().padLeft(2, '0') +
              ':' +
              dateTime.minute.toString().padLeft(2, '0'),
        });
      }

      // Delete the bill document
      DocumentReference billRef = firestore
          .collection('pharmacy')
          .doc('billings')
          .collection('opbilling')
          .doc(billId);

      batch.delete(billRef);

      await batch.commit();

      CustomSnackBar(
        context,
        message: 'Bill canceled, and product quantities updated successfully',
        backgroundColor: Colors.green,
      );

      print('Bill canceled, and product quantities updated successfully');
      Navigator.of(context).pop();
      fetchOpBills(); // Refresh the bill list if needed
    } catch (e) {
      CustomSnackBar(
        context,
        message: 'Failed to cancel bill and update product quantities',
        backgroundColor: Colors.red,
      );

      print('Error canceling bill: $e');
    }
  }

  Future<void> fetchIpBills({String? billNO}) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billings')
          .collection('ipbilling');

      if (billNO != null) {
        query = query.where('billNo', isEqualTo: billNO);
      }

      final QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> fetchedData = [];

      for (var bills in snapshot.docs) {
        final data = bills.data() as Map<String, dynamic>;

        if (data.isNotEmpty) {
          fetchedData.add({
            'Bill No': data['billNo'] ?? 'N/A',
            'Patient Name': data['patientName'] ?? 'N/A',
            'OP No': data['opNumber'] ?? 'N/A',
            'IP Ticket': data['ipTicket'] ?? 'N/A',
            'Bill Date': data['billDate'] ?? 'N/A',
            'Doctor Name': data['doctorName'] ?? 'N/A',
            'Action': Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    final List<Map<String, dynamic>> productLists =
                        (data['entryProducts'] as List)
                            .map((e) => Map<String, dynamic>.from(e as Map))
                            .toList();
                    printIpInvoice(
                      data['billNo'],
                      data['billDate'],
                      data['patientName'],
                      data['doctorName'],
                      data['opNumber'],
                      data['phone'],
                      data['place'],
                      data['ipTicket'],
                      data['roomWard'],
                      data['specialization'],
                      productLists,
                      data['discountPercentage'],
                      data['discountAmount'],
                      data['taxTotal'],
                      data['totalBeforeDiscount'],
                      data['netTotalAmount'],
                    );
                  },
                  child: const CustomText(text: 'View'),
                ),
                TextButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Confirmation'),
                          content: Container(
                            width: 200,
                            height: 35,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(text: 'Are you sure ?'),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                await cancelIpBill(
                                    bills.id, data['entryProducts']);
                              },
                              child: const CustomText(
                                text: 'Sure',
                                color: Colors.red,
                              ),
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
                  },
                  child: const CustomText(text: 'Cancel'),
                ),
              ],
            )
          });
        }
      }

      setState(() {
        ipTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void printIpInvoice(
    String billNo,
    String billDate,
    String patientName,
    String doctorName,
    String ipTicket,
    String specialization,
    String roomWard,
    String opNo,
    String phoneNo,
    String hospitalName,
    List<Map<String, dynamic>> products,
    String discountPercentage,
    String discountAmount,
    String taxTotal,
    String total,
    String netTotalAmount,
  ) {
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
                                  'Invoice No : $billNo',
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
                                    'Patient Name : ${patientName}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'OP Number : ${opNo}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'IP Ticket : ${ipTicket}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Phone No : ${phoneNo}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Doctor Name : ${doctorName}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Specialization : ${specialization}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Room Type/No : ${roomWard}',
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
                        data: products,
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
                                '${taxTotal}',
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
                                '${total}',
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
                                'Discount ${discountPercentage}% : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                '${discountAmount}',
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
                                '${netTotalAmount}',
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
                    bytes: await pdf.save(), filename: '${billNo}.pdf');
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

  Future<void> cancelIpBill(String billId, List<dynamic> items) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      for (var item in items) {
        String productDocId = item['productDocId'];
        String purchaseEntryDocId = item['purchaseEntryDocId'];
        int quantityToAdd = int.tryParse(item['Quantity'].toString()) ?? 0;

        // Reference to the product document
        DocumentReference productRef = firestore
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .doc(productDocId);

        // Get current quantity from product document
        DocumentSnapshot productSnapshot = await productRef.get();
        if (!productSnapshot.exists) continue;

        int currentQty =
            int.tryParse((productSnapshot['quantity'] ?? '0').toString()) ?? 0;
        int newMainQty = currentQty + quantityToAdd;

        // 1. Update product quantity (outside purchaseEntry)
        batch.update(productRef, {
          'quantity': newMainQty.toString(),
        });

        // 2. Update purchaseEntry's qtyWithoutFree
        DocumentReference purchaseEntryRef =
            productRef.collection('purchaseEntry').doc(purchaseEntryDocId);

        DocumentSnapshot purchaseSnapshot = await purchaseEntryRef.get();
        if (purchaseSnapshot.exists) {
          int purchaseQty =
              int.tryParse((purchaseSnapshot['quantity'] ?? '0').toString()) ??
                  0;
          int newPurchaseQty = purchaseQty + quantityToAdd;

          batch.update(purchaseEntryRef, {
            'quantity': newPurchaseQty.toString(),
          });
        }

        // 3. Add entry to currentQty subcollection
        DateTime dateTime = DateTime.now();
        await productRef.collection('currentQty').doc().set({
          'quantity': newMainQty.toString(),
          'date':
              "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
          'time': dateTime.hour.toString().padLeft(2, '0') +
              ':' +
              dateTime.minute.toString().padLeft(2, '0'),
        });
      }

      // Delete the bill document
      DocumentReference billRef = firestore
          .collection('pharmacy')
          .doc('billings')
          .collection('ipbilling')
          .doc(billId);

      batch.delete(billRef);

      await batch.commit();

      CustomSnackBar(
        context,
        message: 'Bill canceled, and product quantities updated successfully',
        backgroundColor: Colors.green,
      );

      print('Bill canceled, and product quantities updated successfully');
      Navigator.of(context).pop();

      fetchIpBills(); // Refresh the bill list if needed
    } catch (e) {
      CustomSnackBar(
        context,
        message: 'Failed to cancel bill and update product quantities',
        backgroundColor: Colors.red,
      );

      print('Error canceling bill: $e');
    }
  }

  Future<void> fetchCounterSalesBills({String? billNO}) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billings')
          .collection('countersales');

      if (billNO != null) {
        query = query.where('billNo', isEqualTo: billNO);
      }

      final QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> fetchedData = [];

      for (var bills in snapshot.docs) {
        final data = bills.data() as Map<String, dynamic>;

        if (data.isNotEmpty) {
          fetchedData.add({
            'Bill No': data['billNo'] ?? 'N/A',
            'Patient Name': data['patientName'] ?? 'N/A',
            'OP No': data['opNumber'] ?? 'N/A',
            'Bill Date': data['billDate'] ?? 'N/A',
            'Doctor Name': data['doctorName'] ?? 'N/A',
            'Action': Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    final List<Map<String, dynamic>> productLists =
                        (data['entryProducts'] as List)
                            .map((e) => Map<String, dynamic>.from(e as Map))
                            .toList();
                    printCounterInvoice(
                      data['billNo'],
                      data['billDate'],
                      data['patientName'],
                      data['doctorName'],
                      data['opNumber'],
                      data['phone'],
                      data['place'],
                      productLists,
                      data['discountPercentage'],
                      data['discountAmount'],
                      data['taxTotal'],
                      data['totalBeforeDiscount'],
                      data['netTotalAmount'],
                    );
                  },
                  child: const CustomText(text: 'View'),
                ),
                TextButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Confirmation'),
                          content: Container(
                            width: 200,
                            height: 35,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(text: 'Are you sure ?'),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                await cancelCounterSalesBill(
                                    bills.id, data['entryProducts']);
                              },
                              child: const CustomText(
                                text: 'Sure',
                                color: Colors.red,
                              ),
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
                  },
                  child: const CustomText(text: 'Cancel'),
                ),
              ],
            )
          });
        }
      }

      setState(() {
        counterSalesTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void printCounterInvoice(
    String billNo,
    String billDate,
    String patientName,
    String doctorName,
    String opNo,
    String phoneNo,
    String hospitalName,
    List<Map<String, dynamic>> products,
    String discountPercentage,
    String discountAmount,
    String taxTotal,
    String total,
    String netTotalAmount,
  ) {
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
                                  'Invoice No : $billNo',
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
                                    'Patient Name : ${patientName}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  if (opNo.isNotEmpty)
                                    pw.Text(
                                      'OP Number : ${opNo}',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  if (phoneNo.isNotEmpty)
                                    pw.Text(
                                      'Phone No : ${phoneNo}',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  pw.Text(
                                    'Doctor Name : ${doctorName}',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  if (hospitalName.isNotEmpty)
                                    pw.Text(
                                      'Hospital Name : ${hospitalName}',
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
                        data: products,
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
                                '${taxTotal}',
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
                                '${total}',
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
                                'Discount ${discountPercentage}% : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: ttf,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                '${discountAmount}',
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
                                '${netTotalAmount}',
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
                    bytes: await pdf.save(), filename: '${billNo}.pdf');
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

  Future<void> cancelCounterSalesBill(
      String billId, List<dynamic> items) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      for (var item in items) {
        String productDocId = item['productDocId'];
        String purchaseEntryDocId = item['purchaseEntryDocId'];
        int quantityToAdd = int.tryParse(item['Quantity'].toString()) ?? 0;

        // Reference to the product document
        DocumentReference productRef = firestore
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .doc(productDocId);

        // Get current quantity from product document
        DocumentSnapshot productSnapshot = await productRef.get();
        if (!productSnapshot.exists) continue;

        int currentQty =
            int.tryParse((productSnapshot['quantity'] ?? '0').toString()) ?? 0;
        int newMainQty = currentQty + quantityToAdd;

        // 1. Update product quantity (outside purchaseEntry)
        batch.update(productRef, {
          'quantity': newMainQty.toString(),
        });

        // 2. Update purchaseEntry's qtyWithoutFree
        DocumentReference purchaseEntryRef =
            productRef.collection('purchaseEntry').doc(purchaseEntryDocId);

        DocumentSnapshot purchaseSnapshot = await purchaseEntryRef.get();
        if (purchaseSnapshot.exists) {
          int purchaseQty =
              int.tryParse((purchaseSnapshot['quantity'] ?? '0').toString()) ??
                  0;
          int newPurchaseQty = purchaseQty + quantityToAdd;

          batch.update(purchaseEntryRef, {
            'quantity': newPurchaseQty.toString(),
          });
        }

        // 3. Add entry to currentQty subcollection
        DateTime dateTime = DateTime.now();
        await productRef.collection('currentQty').doc().set({
          'quantity': newMainQty.toString(),
          'date':
              "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
          'time': dateTime.hour.toString().padLeft(2, '0') +
              ':' +
              dateTime.minute.toString().padLeft(2, '0'),
        });
      }

      // Delete the bill document
      DocumentReference billRef = firestore
          .collection('pharmacy')
          .doc('billings')
          .collection('countersales')
          .doc(billId);

      batch.delete(billRef);

      await batch.commit();

      CustomSnackBar(
        context,
        message: 'Bill canceled, and product quantities updated successfully',
        backgroundColor: Colors.green,
      );

      print('Bill canceled, and product quantities updated successfully');
      Navigator.of(context).pop();

      fetchCounterSalesBills(); // Refresh the bill list if needed
    } catch (e) {
      CustomSnackBar(
        context,
        message: 'Failed to cancel bill and update product quantities',
        backgroundColor: Colors.red,
      );

      print('Error canceling bill: $e');
    }
  }

  @override
  void initState() {
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
              const TimeDateWidget(
                text: 'Billing Canceling',
              ),
              PharmacyDropDown(
                label: 'Choose Billing',
                items: ['OP Billing', 'IP Billing', 'Counter Sales'],
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                    if (value == 'OP Billing') {
                      fetchOpBills();
                    } else if (value == 'IP Billing') {
                      fetchIpBills();
                    } else if (value == 'Counter Sales') {
                      fetchCounterSalesBills();
                    } else {
                      value == null;
                    }
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.05),
              if (selectedValue == 'OP Billing') ...[
                Row(
                  children: [
                    CustomText(
                      text: 'OP Bills',
                      size: screenWidth * 0.02,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.025),
                Row(
                  children: [
                    CustomText(
                      text: 'Bill No : ',
                      size: screenWidth * 0.015,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    PharmacyTextField(
                      controller: _opBillNo,
                      hintText: '',
                      width: screenWidth * 0.2,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    PharmacyButton(
                      label: 'Search',
                      onPressed: () {
                        fetchOpBills(billNO: _opBillNo.text);
                      },
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.042,
                    )
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                CustomDataTable(
                  headers: opHeaders,
                  tableData: opTableData,
                ),
              ],
              if (selectedValue == 'IP Billing') ...[
                Row(
                  children: [
                    CustomText(
                      text: 'IP Bills',
                      size: screenWidth * 0.02,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.025),
                Row(
                  children: [
                    CustomText(
                      text: 'Bill No : ',
                      size: screenWidth * 0.015,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    PharmacyTextField(
                      controller: _ipBillNo,
                      hintText: '',
                      width: screenWidth * 0.2,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    PharmacyButton(
                      label: 'Search',
                      onPressed: () {
                        fetchIpBills(billNO: _ipBillNo.text);
                      },
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.042,
                    )
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                CustomDataTable(
                  headers: ipHeaders,
                  tableData: ipTableData,
                ),
              ],
              if (selectedValue == 'Counter Sales') ...[
                Row(
                  children: [
                    CustomText(
                      text: 'Counter Sales Bills',
                      size: screenWidth * 0.02,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.025),
                Row(
                  children: [
                    CustomText(
                      text: 'Bill No : ',
                      size: screenWidth * 0.015,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    PharmacyTextField(
                      controller: _csBillNo,
                      hintText: '',
                      width: screenWidth * 0.2,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    PharmacyButton(
                      label: 'Search',
                      onPressed: () {
                        fetchCounterSalesBills(billNO: _csBillNo.text);
                      },
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.042,
                    )
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                CustomDataTable(
                  headers: counterSalesHeaders,
                  tableData: counterSalesTableData,
                ),
              ],
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
