import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../utilities/constants.dart';
import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';
import 'counter_sales.dart';
import 'medicine_return.dart';

class OpBilling extends StatefulWidget {
  const OpBilling({super.key});

  @override
  State<OpBilling> createState() => _OpBilling();
}

class _OpBilling extends State<OpBilling> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _opTicket = TextEditingController();
  TextEditingController patientName = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController place = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController billNo = TextEditingController();
  TextEditingController doctorName = TextEditingController();
  TextEditingController specialization = TextEditingController();
  TextEditingController opNumber = TextEditingController();
  TextEditingController bloodGroup = TextEditingController();
  TextEditingController address = TextEditingController();

  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  double totalAmount = 0.0;
  double taxPercentage = 12;
  double gstPercentage = 10;
  double taxAmount = 0.00;
  double gstAmount = 0.00;
  double totalGst = 0.00;
  double grandTotal = 0.00;

  final List<String> headers = [
    'Product Name',
    'Type',
    'Batch',
    'EXP',
    'HSN',
    'Quantity',
    'MPS',
    'Price',
    'Gst',
    'Amount',
  ];

  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({String? opTicket}) async {
    try {
      final patientsSnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      if (patientsSnapshot.docs.isEmpty) {
        setState(() {
          tableData = [];
          resetTotals();
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];
      bool found = false;

      for (var patientDoc in patientsSnapshot.docs) {
        final patientData = patientDoc.data();

        final opTicketsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientDoc.id)
            .collection('opTickets')
            .get();

        for (var ticketDoc in opTicketsSnapshot.docs) {
          final ticketData = ticketDoc.data();

          if ((ticketData['opTicket'] ?? '') == opTicket) {
            found = true;

            // Set patient fields
            setState(() {
              gender.text = patientData['sex'] ?? 'N/A';
              patientName.text = (patientData['firstName'] ?? '') +
                  ' ' +
                  (patientData['lastName'] ?? 'N/A');
              age.text = patientData['age'] ?? 'N/A';
              place.text = patientData['city'] ?? 'N/A';
              phoneNumber.text = patientData['phone1'] ?? 'N/A';
              doctorName.text = ticketData['doctorName'] ?? 'N/A';
              specialization.text = ticketData['specialization'] ?? 'N/A';
              opNumber.text = patientData['opNumber'] ?? 'N/A';
              bloodGroup.text = patientData['bloodGroup'] ?? 'N/A';
              address.text = patientData['address1'] ?? 'N/A';
            });

            List<dynamic> medicines = ticketData['Medication'] ?? [];

            for (String medicineName in medicines) {
              QuerySnapshot medicineSnapshot = await FirebaseFirestore.instance
                  .collection('stock')
                  .doc('Products')
                  .collection('AddedProducts')
                  .where('productName', isEqualTo: medicineName)
                  .get();

              for (var medicineDoc in medicineSnapshot.docs) {
                var medicineData = medicineDoc.data() as Map<String, dynamic>;

                fetchedData.add({
                  'Product Name': medicineData['productName'] ?? 'N/A',
                  'Type': medicineData['type'] ?? 'N/A',
                  'Batch': medicineData['batchNumber'] ?? 'N/A',
                  'EXP': medicineData['expiry'] ?? 'N/A',
                  'HSN': medicineData['hsnCode'] ?? 'N/A',
                  'Quantity': '',
                  'MPS': medicineData['mrp'] ?? 'N/A',
                  'Price': medicineData['price'] ?? 'N/A',
                  'Gst': (medicineData['gst'] ?? 0).toString() + '%',
                  'Amount': medicineData['amount'] ?? 'N/A',
                });
              }
            }

            break; // Stop after finding the first matching opTicket
          }
        }

        if (found) break;
      }

      setState(() {
        tableData = fetchedData;
        if (found) {
          calculateTotals();
        } else {
          resetTotals();
        }
      });

      print(tableData);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void calculateTotals() {
    totalAmount = tableData.fold(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item['Amount']?.toString() ?? '0') ?? 0),
    );

    taxAmount = (totalAmount * taxPercentage) / 100;
    gstAmount = (totalAmount * gstPercentage) / 100;
    totalGst = taxAmount + gstAmount;
    grandTotal = totalAmount + totalGst;

    totalAmount = double.parse(totalAmount.toStringAsFixed(2));
    taxAmount = double.parse(taxAmount.toStringAsFixed(2));
    gstAmount = double.parse(gstAmount.toStringAsFixed(2));
    totalGst = double.parse(totalGst.toStringAsFixed(2));
    grandTotal = double.parse(grandTotal.toStringAsFixed(2));
    totalAmountController.text = grandTotal.toString();
  }

  void resetTotals() {
    totalAmount = 0.00;
    taxAmount = 0.00;
    gstAmount = 0.00;
    totalGst = 0.00;
    grandTotal = 0.00;

    patientName.clear();
    age.clear();
    place.clear();
    gender.clear();
    phoneNumber.clear();
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

  Future<void> submitBillingData() async {
    try {
      DocumentReference billingRef = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billing')
          .collection('opbilling')
          .doc();
      List<Map<String, dynamic>> updatedTableData = tableData.map((item) {
        return {
          'Product Name': item['Product Name'] ?? 'N/A',
          'Type': item['Type'] ?? 'N/A',
          'Batch': item['Batch'] ?? 'N/A',
          'EXP': item['EXP'] ?? 'N/A',
          'HSN': item['HSN'] ?? 'N/A',
          'Quantity': item['Quantity'] ?? '0',
          'MPS': item['MPS'] ?? 'N/A',
          'Price': item['Price'] ?? 'N/A',
          'Gst': item['Gst'] ?? '0%',
          'Amount': item['Amount'] ?? '0.00',
        };
      }).toList();
      Map<String, dynamic> billingData = {
        'billNo': billNo.text,
        'opTicket': _opTicket.text,
        'billDate': _dateController.text,
        'patientName': patientName.text,
        'age': age.text,
        'place': place.text,
        'gender': gender.text,
        'phoneNumber': phoneNumber.text,
        'totalAmount': totalAmount,
        'taxAmount': taxAmount,
        'gstAmount': gstAmount,
        'totalGst': totalGst,
        'grandTotal': grandTotal,
        'collectedAmount': paidController.text,
        'balance': balanceController.text,
        'items': updatedTableData,
      };

      await billingRef.set(billingData);
      for (var product in tableData) {
        String productName = product['Product Name'];
        String batch = product['Batch'];
        String hsn = product['HSN'];

        double Quantity = double.tryParse(product['Quantity'].toString()) ?? 0;

        print('Return Quantity: $Quantity');

        if (Quantity > 0) {
          QuerySnapshot<Map<String, dynamic>> productSnapshot =
              await FirebaseFirestore.instance
                  .collection('stock')
                  .doc('Products')
                  .collection('AddedProducts')
                  .where('productName', isEqualTo: productName)
                  .where('batchNumber', isEqualTo: batch)
                  .where('hsnCode', isEqualTo: hsn)
                  .get();

          if (productSnapshot.docs.isEmpty) {
            print(
                'No matching product found for $productName, Batch: $batch, HSN: $hsn');
          } else {
            print('Found ${productSnapshot.docs.length} matching products.');

            for (var doc in productSnapshot.docs) {
              double currentQuantity =
                  double.tryParse(doc['quantity'].toString()) ?? 0;

              double rawUpdatedQuantity =
                  (currentQuantity - Quantity).clamp(0, double.infinity);
              int updatedQuantity = rawUpdatedQuantity.floor();
              print(
                  'Current Quantity: $currentQuantity, Updated Quantity: $updatedQuantity');

              await FirebaseFirestore.instance
                  .collection('stock')
                  .doc('Products')
                  .collection('AddedProducts')
                  .doc(doc.id)
                  .update({
                'quantity': updatedQuantity.toString(),
              });
            }
          }
        }
      }

      CustomSnackBar(context,
          message: 'Billing data submitted successfully',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to submit billing data',
          backgroundColor: Colors.red);

      print('Error submitting billing data: $e');
    }
  }

  void _updateBalance() {
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    double paidAmount = double.tryParse(paidController.text) ?? 0.0;

    if (totalAmount == 0.0 || paidAmount == 0.0) {
      balanceController.text = '0.00';
    } else {
      double balance = totalAmount - paidAmount;
      balanceController.text = balance.toStringAsFixed(2);
    }
  }

  @override
  void initState() {
    super.initState();
    totalAmountController.addListener(_updateBalance);
    paidController.addListener(_updateBalance);
  }

  @override
  void dispose() {
    totalAmountController.removeListener(_updateBalance);
    paidController.removeListener(_updateBalance);
    _dateController.dispose();
    totalAmountController.dispose();
    paidController.dispose();
    _opTicket.dispose();
    patientName.dispose();
    age.dispose();
    place.dispose();
    gender.dispose();
    phoneNumber.dispose();
    billNo.dispose();
    doctorName.dispose();
    specialization.dispose();

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
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.03),
                    child: Column(
                      children: [
                        CustomText(
                          text: "OP Billing",
                          size: screenWidth * 0.0275,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      image: const DecorationImage(
                        image: AssetImage('assets/foxcare_lite_logo.png'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomTextField(
                    controller: billNo,
                    hintText: 'Bill No',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                    controller: _opTicket,
                    hintText: 'OP Ticket',
                    width: screenWidth * 0.25,
                    onChanged: (value) {
                      fetchData(opTicket: value);
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                      controller: patientName,
                      hintText: 'Patient Name',
                      width: screenWidth * 0.25),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                      controller: age,
                      hintText: 'Age',
                      width: screenWidth * 0.25)
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                      controller: place,
                      hintText: 'Place',
                      width: screenWidth * 0.25),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                    controller: _dateController,
                    hintText: 'Bill Date',
                    width: screenWidth * 0.15,
                    icon: const Icon(Icons.date_range),
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                      controller: gender,
                      hintText: 'Gender',
                      width: screenWidth * 0.20),
                  SizedBox(width: screenHeight * 0.2),
                  CustomTextField(
                      controller: phoneNumber,
                      hintText: 'Phone Number',
                      width: screenWidth * 0.20),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              if (tableData.isNotEmpty) ...[
                CustomDataTable(
                    tableData: tableData,
                    headers: headers,
                    editableColumns: ['Quantity'],
                    onValueChanged: (rowIndex, header, value) async {
                      if (header == 'Quantity') {
                        if (rowIndex >= 0 && rowIndex < tableData.length) {
                          setState(() {
                            tableData[rowIndex]['Quantity'] = value;

                            double quantity =
                                double.tryParse(value.toString()) ?? 0;
                            double amountPerUnit = double.tryParse(
                                    tableData[rowIndex]['Amount']?.toString() ??
                                        '0') ??
                                0;
                            double gstRate = double.tryParse(tableData[rowIndex]
                                            ['Gst']
                                        ?.replaceAll('%', '') ??
                                    '0') ??
                                0;

                            double totalAmountForItem =
                                quantity * amountPerUnit;
                            double itemGst =
                                (totalAmountForItem * gstRate) / 100;

                            tableData[rowIndex]['Amount'] =
                                totalAmountForItem.toStringAsFixed(2);
                            calculateTotals();
                          });
                        } else {
                          print("Error: rowIndex $rowIndex is out of range.");
                        }
                      }
                    }),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        text: 'Total : $totalAmount',
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: screenWidth * 0.08),
                  width: screenWidth,
                  height: screenHeight * 0.025,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(text: '12% TAX :$taxAmount '),
                      CustomText(text: '10% GST : $gstAmount'),
                      CustomText(text: 'Total GST :$totalGst '),
                      CustomText(text: 'Grand Total :$grandTotal '),
                    ],
                  ),
                ),
              ],
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                      controller: totalAmountController,
                      hintText: 'Total Amount',
                      width: screenWidth * 0.2),
                  SizedBox(width: screenWidth * 0.03),
                  CustomTextField(
                      controller: paidController,
                      hintText: 'Paid',
                      width: screenWidth * 0.2),
                  SizedBox(width: screenWidth * 0.03),
                  CustomText(
                    text: 'Balance : ',
                    size: screenWidth * 0.012,
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  CustomTextField(
                      controller: balanceController,
                      hintText: '',
                      width: screenWidth * 0.2),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Container(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.15,
                  right: screenWidth * 0.15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      label: 'Payment',
                      onPressed: () {},
                      width: screenWidth * 0.10,
                    ),
                    CustomButton(
                      label: 'Print',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Rx Prescription'),
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
                                    const lightBlue =
                                        PdfColor.fromInt(0xFF21b0d1);

                                    final font = await rootBundle.load(
                                        'Fonts/Poppins/Poppins-Regular.ttf');
                                    final ttf = pw.Font.ttf(font);

                                    final topImage = pw.MemoryImage(
                                      (await rootBundle.load(
                                              'assets/opAssets/OP_Bill_Top.png'))
                                          .buffer
                                          .asUint8List(),
                                    );

                                    final bottomImage = pw.MemoryImage(
                                      (await rootBundle.load(
                                              'assets/opAssets/OP_Card_back_original.png'))
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
                                        ...data.map((row) => headers
                                            .map(
                                                (h) => row[h]?.toString() ?? '')
                                            .toList()),
                                      ];

                                      return [
                                        pw.TableHelper.fromTextArray(
                                          headers: headers,
                                          data: data
                                              .map((row) => headers
                                                  .map((h) =>
                                                      row[h]?.toString() ?? '')
                                                  .toList())
                                              .toList(),
                                          headerStyle: pw.TextStyle(
                                            font: ttf,
                                            fontSize: 7,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.white,
                                          ),
                                          headerDecoration: pw.BoxDecoration(
                                              color: headerColor),
                                          cellStyle: pw.TextStyle(
                                              font: ttf, fontSize: 7),
                                          cellHeight: rowHeight > 12
                                              ? rowHeight - 10
                                              : rowHeight,
                                          border: pw.TableBorder.all(
                                              color: headerColor),
                                        ),
                                        pw.SizedBox(height: 6),
                                      ];
                                    }

                                    final List<List<String>> dataRows =
                                        tableData.map((data) {
                                      return headers
                                          .map((header) =>
                                              data[header]?.toString() ?? '')
                                          .toList();
                                    }).toList();

                                    pdf.addPage(
                                      pw.MultiPage(
                                        pageFormat: PdfPageFormat.a4,
                                        header: (context) => pw.Stack(
                                          children: [
                                            pw.Image(
                                              topImage,
                                              fit: pw.BoxFit.cover,
                                            ),
                                          ],
                                        ),
                                        footer: (context) => pw.Stack(
                                          children: [
                                            // Background Image
                                            pw.Positioned.fill(
                                              child: pw.Image(bottomImage,
                                                  fit: pw.BoxFit.cover,
                                                  height: 225,
                                                  width: 500),
                                            ),
                                            // Footer Content
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.only(
                                                  left: 8,
                                                  right: 8,
                                                  bottom: 8,
                                                  top: 20),
                                              child: pw.Column(
                                                mainAxisAlignment:
                                                    pw.MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Row(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment
                                                        .spaceBetween,
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      // Left Column
                                                      pw.Column(
                                                        crossAxisAlignment: pw
                                                            .CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          pw.Text(
                                                            'Emergency No: ${Constants.emergencyNo}',
                                                            style: pw.TextStyle(
                                                              fontSize: 8,
                                                              font: ttf,
                                                              color: PdfColors
                                                                  .white,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'Appointments: ${Constants.appointmentNo}',
                                                            style: pw.TextStyle(
                                                              fontSize: 8,
                                                              font: ttf,
                                                              color: PdfColors
                                                                  .white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      pw.Padding(
                                                        padding:
                                                            pw.EdgeInsets.only(
                                                                top: 20),
                                                        child: pw.Row(
                                                          crossAxisAlignment: pw
                                                              .CrossAxisAlignment
                                                              .end,
                                                          children: [
                                                            pw.Text(
                                                              'Mail: ${Constants.mail}',
                                                              style:
                                                                  pw.TextStyle(
                                                                fontSize: 8,
                                                                font: ttf,
                                                                color: PdfColors
                                                                    .white,
                                                              ),
                                                            ),
                                                            pw.SizedBox(
                                                                width: 15),
                                                            pw.Text(
                                                              'For more info visit: ${Constants.website}',
                                                              style:
                                                                  pw.TextStyle(
                                                                fontSize: 8,
                                                                font: ttf,
                                                                color: PdfColors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        build: (context) => [
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(
                                                left: 190, right: 0),
                                            child: pw.Container(
                                              child: pw.Column(
                                                children: [
                                                  pw.Column(
                                                    children: [
                                                      pw.Text(
                                                        'Bill Receipt',
                                                        style: pw.TextStyle(
                                                          fontSize: 20,
                                                          font: ttf,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color:
                                                              PdfColors.black,
                                                        ),
                                                      ),
                                                      pw.SizedBox(
                                                        width: 100,
                                                        child: pw.Divider(
                                                          color: blue,
                                                          thickness: 2,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(
                                                left: 8, right: 0),
                                            child: pw.Container(
                                              child: pw.Column(
                                                children: [
                                                  pw.Row(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      pw.Column(
                                                        crossAxisAlignment: pw
                                                            .CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          pw.Text(
                                                            '${Constants.hospitalName}',
                                                            style: pw.TextStyle(
                                                              fontSize: 16,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: blue,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            '${Constants.hospitalAddress}',
                                                            style: pw.TextStyle(
                                                              fontSize: 8,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            '${Constants.state + ' - ' + Constants.pincode}',
                                                            style: pw.TextStyle(
                                                              fontSize: 8,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'Phone - ${Constants.landLine + ', ' + Constants.billNo}',
                                                            style: pw.TextStyle(
                                                              fontSize: 8,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'Mail : ${Constants.mail}',
                                                            style: pw.TextStyle(
                                                              fontSize: 8,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'Web : ${Constants.website}',
                                                            style: pw.TextStyle(
                                                              fontSize: 8,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      pw.Column(
                                                        crossAxisAlignment: pw
                                                            .CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          pw.Text(
                                                            'Bill No : ${billNo.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'Bill Date : ${_dateController.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      pw.SizedBox(width: 40),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(
                                                left: 8, right: 8),
                                            child: pw.Container(
                                              child: pw.Column(
                                                children: [
                                                  pw.SizedBox(height: 10),
                                                  pw.Column(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      pw.Row(
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .start,
                                                        crossAxisAlignment: pw
                                                            .CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          pw.Text(
                                                            'OP Ticket No : ${_opTicket.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      pw.SizedBox(height: 6),
                                                      pw.Row(
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          pw.Text(
                                                            'Doctor : ${doctorName.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'Specialization : ${specialization.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      pw.SizedBox(height: 6),
                                                      pw.Row(
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          pw.Text(
                                                            'Name : ${patientName.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'OP Number : ${opNumber.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      pw.SizedBox(height: 6),
                                                      pw.Row(
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          pw.Text(
                                                            'Age : ${age.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'Blood Group : ${bloodGroup.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'Place : ${place.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                          pw.Text(
                                                            'Phone : ${phoneNumber.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      pw.SizedBox(height: 6),
                                                      pw.Row(
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .start,
                                                        crossAxisAlignment: pw
                                                            .CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          pw.Text(
                                                            'Address : ${address.text}',
                                                            style: pw.TextStyle(
                                                              fontSize: 10,
                                                              font: ttf,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              color: PdfColors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          pw.SizedBox(height: 10),
                                          ...buildPaginatedTable(
                                            headers: headers,
                                            data: tableData,
                                            ttf: ttf,
                                            headerColor: lightBlue,
                                            rowHeight: 15,
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(
                                                left: 350, right: 8),
                                            child: pw.Container(
                                              child: pw.Column(
                                                children: [
                                                  pw.SizedBox(height: 10),
                                                  pw.Column(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment
                                                        .start,
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      pw.Text(
                                                        'Total Amount : ${grandTotal}',
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          font: ttf,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color:
                                                              PdfColors.black,
                                                        ),
                                                      ),
                                                      pw.Text(
                                                        'Patient Paid Amount : ${paidController.text}',
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          font: ttf,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color:
                                                              PdfColors.black,
                                                        ),
                                                      ),
                                                      pw.Text(
                                                        'Balance : ${balanceController.text}',
                                                        style: pw.TextStyle(
                                                          fontSize: 8,
                                                          font: ttf,
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          color:
                                                              PdfColors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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

                                    // await Printing.sharePdf(
                                    //     bytes: await pdf.save(),
                                    //     filename: '${_opTicket.text}.pdf');
                                  },
                                  child: const Text('Print'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      width: screenWidth * 0.10,
                    ),
                    CustomButton(
                      label: 'Submit',
                      onPressed: () => submitBillingData(),
                      width: screenWidth * 0.10,
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
