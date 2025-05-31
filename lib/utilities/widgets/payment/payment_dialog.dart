import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../colors.dart';
import '../../constants.dart';
import '../snackBar/snakbar.dart';
import '../text/primary_text.dart';
import '../textField/primary_textField.dart';
import 'package:pdf/widgets.dart' as pw;

class PaymentDialog extends StatefulWidget {
  final String? billNo;
  final String? ipTicket;
  final String? roomNo;
  final String? roomType;
  final String? ipAdmitDate;
  final String? doctorName;
  final String? specialization;
  final String? address;
  final String? age;
  final String? bloodGroup;
  final String? phoneNo;
  final String? partyName;
  final String? patientID;
  final String? firstName;
  final String? lastName;
  final String? city;
  final String? balance;
  final String? totalBilledAmount;
  final String? totalCollectedAmount;
  final String? totalBalanceAmount;

  final String? totalAmount;
  final String? docId;
  final bool? timeLine;
  final bool? initialPayment;
  final String? initialBalance;
  final Future<void> Function()? fetchData;
  PaymentDialog({
    this.patientID = '',
    this.firstName,
    this.lastName,
    this.balance,
    this.city,
    this.billNo,
    this.partyName,
    super.key,
    this.docId,
    this.timeLine = false,
    this.totalAmount,
    this.fetchData,
    this.initialPayment = false,
    this.initialBalance,
    this.ipTicket,
    this.roomNo,
    this.roomType,
    this.ipAdmitDate,
    this.doctorName,
    this.specialization,
    this.address,
    this.age,
    this.bloodGroup,
    this.phoneNo,
    this.totalCollectedAmount,
    this.totalBalanceAmount,
    this.totalBilledAmount,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  TextEditingController collected = TextEditingController();
  TextEditingController balance = TextEditingController();
  ScrollController _scrollController1 = ScrollController();

  TextEditingController currentCollected = TextEditingController();
  TextEditingController currentBalance = TextEditingController();

  String _selectedPaymentMethod = '';
  bool isNotPatient = false;
  int billNo = 0;

  final List<String> ipAdditionalAmountHeader = [
    'SL No',
    'Description',
    'Rate',
    'Quantity',
    'Amount'
  ];
  List<Map<String, dynamic>> ipAdditionalAmountData = [];
  Future<int?> getAndIncrementIpAdmitBillNo() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('billNo').doc('ipAdmitBill');

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        int currentBillNo = data?['billNo'] ?? 0;
        int newBillNo = currentBillNo + 1;

        setState(() {
          billNo = newBillNo;
        });

        return newBillNo;
      } else {
        print('Document /billNo/ipAdmitBill does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching or incrementing billNo: $e');
      return null;
    }
  }

  Future<void> updateIpAdmitBillNo(int newBillNo) async {
    final docRef =
        FirebaseFirestore.instance.collection('billNo').doc('ipAdmitBill');

    await docRef.set({'billNo': newBillNo});
  }

  Future<void> fetchIpAdditionalAmountData(
      String docID, String ipTicket) async {
    try {
      final List<Map<String, dynamic>> fetchedData = [];

      final additionalAmountCollection = FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments$ipTicket')
          .collection('additionalAmount');

      final snapshot = await additionalAmountCollection.get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final List<dynamic>? detailsList = data['details'];

        if (detailsList != null) {
          for (var entry in detailsList) {
            if (entry is Map<String, dynamic>) {
              fetchedData.add(entry);
            }
          }
        }
      }

      setState(() {
        ipAdditionalAmountData = fetchedData;
      });

      print("Fetched data: $ipAdditionalAmountData");
    } catch (e) {
      print("Error fetching additional amount data: $e");
    }
  }

  void checkPayer() {
    setState(() {
      if (widget.patientID == '') {
        isNotPatient = true;
      }
    });
  }

  final dateTime = DateTime.now();
  List<Map<String, dynamic>> payments = [];

  IconData getPaymentIcon(String method) {
    switch (method) {
      case "UPI":
        return Icons.qr_code;
      case "Credit Card":
        return Icons.credit_card;
      case "Debit Card":
        return Icons.credit_card_sharp;
      case "Net Banking":
        return Icons.account_balance;
      case "Cash":
        return Icons.money;
      case "Cheque":
        return Icons.local_post_office_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> addPaymentAmount(String docID) async {
    try {
      Map<String, dynamic> data = {
        'payedAmount': balance.text,
        'payedBy': widget.ipTicket.toString(),
        'payedDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'paymentMode': _selectedPaymentMethod,
        'payedTime': dateTime.hour.toString() +
            ':' +
            dateTime.minute.toString().padLeft(2, '0'),
      };
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc()
          .set(data);
      CustomSnackBar(context,
          message: 'Payment Added Successfully', backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to Add Payment', backgroundColor: Colors.red);
    }
  }

  Future<void> updateBalance(String docID, double amountPaid) async {
    if (docID.isEmpty) return;

    try {
      DocumentReference patientDoc = FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments${widget.ipTicket.toString()}');

      DocumentSnapshot snapshot = await patientDoc.get();

      if (!snapshot.exists) {
        print("Payment document does not exist");
        return;
      }

      double currentBalance = double.tryParse(widget.balance ?? '0.00') ?? 0.0;
      double newBalance = currentBalance - amountPaid;

      double currentCollected = double.tryParse(
              snapshot["ipAdmissionCollected"]?.toString() ?? '0.00') ??
          0.0;
      double newCollected = currentCollected + amountPaid;

      await patientDoc.update({
        "ipAdmissionBalance": newBalance.toStringAsFixed(2),
        "ipAdmissionCollected": newCollected.toStringAsFixed(2),
      });

      setState(() {
        balance.text = '₹ ${newBalance.toStringAsFixed(2)}';
      });

      print("Balance and Collected amount updated successfully");
    } catch (e) {
      print("Error updating balance and collected amount: $e");
    }
  }

  Future<void> fetchPayments() async {
    if (widget.docId == null || widget.docId!.isEmpty) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.docId)
          .collection('ipAdmissionPayments')
          .get();

      List<Map<String, dynamic>> tempPayments = [];
      for (var doc in querySnapshot.docs) {
        if (doc.id == "payments${widget.ipTicket.toString()}") {
          print("Skipping document: ${doc.id}");
          continue;
        }

        final data = doc.data() as Map<String, dynamic>;
        if (data["payedBy"] != widget.ipTicket.toString()) {
          print("Skipping document not matching payedBy: ${doc.id}");
          continue;
        }

        print("Fetched document: ${doc.id}");

        tempPayments.add({
          "time": data["payedTime"] ?? "00:00",
          "date": data["payedDate"] ?? "No Date",
          "method": data["paymentMode"] ?? "Unknown",
          "paidAmount": data["payedAmount"] ?? "₹0",
        });
      }

      tempPayments.sort((a, b) {
        DateTime dateTimeA =
            DateTime.tryParse("${a["date"]} ${a["time"]}") ?? DateTime(1970);
        DateTime dateTimeB =
            DateTime.tryParse("${b["date"]} ${b["time"]}") ?? DateTime(1970);
        return dateTimeB.compareTo(dateTimeA);
      });

      setState(() {
        payments = tempPayments;
      });

      print("Final payment list: $payments");
    } catch (error) {
      print("Error fetching payments: $error");
    }
  }

  void _update() {
    print('--- _update() called ---');
    print('Raw balance input: ${balance.text}');
    print('widget.totalCollectedAmount: ${widget.totalCollectedAmount}');
    print('widget.totalBalanceAmount: ${widget.totalBalanceAmount}');

    setState(() {
      double totalPaidAmount =
          double.tryParse(widget.totalCollectedAmount ?? '0') ?? 0.0;
      double totalBalance =
          double.tryParse(widget.totalBalanceAmount ?? '0') ?? 0.0;
      double enteredAmount = double.tryParse(balance.text) ?? 0.0;

      print('Parsed enteredAmount: $enteredAmount');
      print('Parsed totalPaidAmount: $totalPaidAmount');
      print('Parsed totalBalance: $totalBalance');

      double newCollectedAmount = totalPaidAmount + enteredAmount;
      double newBalance = totalBalance - enteredAmount;

      print('Calculated newCollectedAmount: $newCollectedAmount');
      print('Calculated newBalance: $newBalance');

      currentCollected.text = newCollectedAmount.toStringAsFixed(2);
      currentBalance.text = newBalance.toStringAsFixed(2);
    });
  }

  @override
  void initState() {
    super.initState();
    checkPayer();
    fetchIpAdditionalAmountData(
        widget.patientID.toString(), widget.ipTicket.toString());
    balance.text = widget.balance ?? '0.00';
    fetchPayments();
    getAndIncrementIpAdmitBillNo();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      title: Center(
        child: CustomText(
          text: 'Payment Details',
          size: screenWidth * 0.017,
        ),
      ),
      content: Container(
        width: screenWidth * 0.3,
        height: screenHeight * 0.5,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: isNotPatient
                    ? 'Bill No: ${widget.billNo ?? 'N/A'}'
                    : 'OP Number: ${widget.patientID ?? 'N/A'}',
                size: screenWidth * 0.011,
              ),
              CustomText(
                  text: isNotPatient
                      ? 'Party Name: ${widget.partyName ?? 'N/A'}'
                      : 'Name: ${widget.firstName ?? 'N/A'} ${widget.lastName ?? 'N/A'}',
                  size: screenWidth * 0.011),
              CustomText(
                  text: 'City: ${widget.city ?? 'N/A'}',
                  size: screenWidth * 0.011),
              CustomText(
                  text: widget.initialPayment == true
                      ? 'Balance: ${widget.initialBalance ?? '0.00'}'
                      : 'Balance: ${widget.balance ?? '0.00'}',
                  size: screenWidth * 0.011),
              SizedBox(height: screenHeight * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Payable Amount:   ',
                    size: screenWidth * 0.012,
                    color: Colors.red,
                  ),
                  CustomTextField(
                    controller: balance,
                    hintText: '',
                    width: screenWidth * 0.08,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              if (widget.timeLine == true)
                Center(
                  child: SizedBox(
                    height: screenHeight * 0.12,
                    width: screenWidth * 0.75,
                    child: Scrollbar(
                      controller: _scrollController1,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController1,
                        child: _buildPaymentTimeline(),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: screenHeight * 0.015),
              CustomText(
                text: 'Select Payment Method:',
                size: screenWidth * 0.012,
                color: Colors.black87,
              ),
              Column(
                children: [
                  RadioListTile(
                    activeColor: AppColors.blue,
                    title: CustomText(text: 'UPI', size: screenWidth * 0.010),
                    value: 'UPI',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: AppColors.blue,
                    title: CustomText(
                        text: 'Net Banking', size: screenWidth * 0.010),
                    value: 'Net Banking',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: AppColors.blue,
                    title: CustomText(
                        text: 'Credit Card', size: screenWidth * 0.010),
                    value: 'Credit Card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: AppColors.blue,
                    title: CustomText(
                        text: 'Debit Card', size: screenWidth * 0.010),
                    value: 'Debit Card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: AppColors.blue,
                    title:
                        CustomText(text: 'Cheque', size: screenWidth * 0.010),
                    value: 'Cheque',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: AppColors.blue,
                    title: CustomText(text: 'Cash', size: screenWidth * 0.010),
                    value: 'Cash',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: const [
                      Icon(Icons.description_outlined,
                          color: Colors.teal, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Invoice',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.print_rounded, color: Colors.teal, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Do you want to print this bill?',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  actionsPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        _update();
                        final pdf = pw.Document();
                        const blue = PdfColor.fromInt(0xFF106ac2);
                        const lightBlue = PdfColor.fromInt(0xFF21b0d1);

                        final font = await rootBundle
                            .load('Fonts/Poppins/Poppins-Regular.ttf');
                        final ttf = pw.Font.ttf(font);

                        final topImage = pw.MemoryImage(
                          (await rootBundle
                                  .load('assets/opAssets/OP_Bill_Top.png'))
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
                                .map((h) => row[h]?.toString() ?? '')
                                .toList()),
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
                              headerDecoration:
                                  pw.BoxDecoration(color: headerColor),
                              cellStyle: pw.TextStyle(font: ttf, fontSize: 7),
                              cellHeight:
                                  rowHeight > 12 ? rowHeight - 10 : rowHeight,
                              border: pw.TableBorder.all(color: headerColor),
                            ),
                            pw.SizedBox(height: 6),
                          ];
                        }

                        final List<List<String>> dataRows =
                            ipAdditionalAmountData.map((data) {
                          return ipAdditionalAmountHeader
                              .map((header) => data[header]?.toString() ?? '')
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
                                      left: 8, right: 8, bottom: 8, top: 20),
                                  child: pw.Column(
                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          // Left Column
                                          pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                'Emergency No: ${Constants.emergencyNo}',
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: ttf,
                                                  color: PdfColors.white,
                                                ),
                                              ),
                                              pw.Text(
                                                'Appointments: ${Constants.appointmentNo}',
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: ttf,
                                                  color: PdfColors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          pw.Padding(
                                            padding:
                                                pw.EdgeInsets.only(top: 20),
                                            child: pw.Row(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.end,
                                              children: [
                                                pw.Text(
                                                  'Mail: ${Constants.mail}',
                                                  style: pw.TextStyle(
                                                    fontSize: 8,
                                                    font: ttf,
                                                    color: PdfColors.white,
                                                  ),
                                                ),
                                                pw.SizedBox(width: 15),
                                                pw.Text(
                                                  'For more info visit: ${Constants.website}',
                                                  style: pw.TextStyle(
                                                    fontSize: 8,
                                                    font: ttf,
                                                    color: PdfColors.white,
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
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black,
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
                                padding:
                                    const pw.EdgeInsets.only(left: 8, right: 0),
                                child: pw.Container(
                                  child: pw.Column(
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                '${Constants.hospitalName}',
                                                style: pw.TextStyle(
                                                  fontSize: 16,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: blue,
                                                ),
                                              ),
                                              pw.Text(
                                                '${Constants.hospitalAddress}',
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                '${Constants.state + ' - ' + Constants.pincode}',
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Phone - ${Constants.landLine + ', ' + Constants.billNo}',
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Mail : ${Constants.mail}',
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Web : ${Constants.website}',
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                'Bill No : $billNo',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Bill Date : ${dateTime.year.toString() + '-' + dateTime.month.toString().padLeft(2, '0') + '-' + dateTime.day.toString().padLeft(2, '0')}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
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
                                padding:
                                    const pw.EdgeInsets.only(left: 8, right: 8),
                                child: pw.Container(
                                  child: pw.Column(
                                    children: [
                                      pw.SizedBox(height: 10),
                                      pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Row(
                                            mainAxisAlignment: pw
                                                .MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Text(
                                                'IP Ticket No : ${widget.ipTicket}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Room / Ward No : ${widget.roomNo} ${widget.roomType}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Admission Date : ${widget.ipAdmitDate}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.Row(
                                            mainAxisAlignment: pw
                                                .MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Text(
                                                'Doctor : ${widget.doctorName}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Specialization : ${widget.specialization}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.Row(
                                            mainAxisAlignment: pw
                                                .MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Text(
                                                'Name : ${widget.firstName} ${widget.lastName}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'OP Number : ${widget.patientID}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.Row(
                                            mainAxisAlignment: pw
                                                .MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Text(
                                                'Age : ${widget.age}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Blood Group : ${widget.bloodGroup}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Place : ${widget.city}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                              pw.Text(
                                                'Phone : ${widget.phoneNo}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.Row(
                                            mainAxisAlignment:
                                                pw.MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                'Address : ${widget.address}',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  font: ttf,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.black,
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
                                headers: ipAdditionalAmountHeader,
                                data: ipAdditionalAmountData,
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
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            'Total Amount : ${widget.totalBilledAmount}',
                                            style: pw.TextStyle(
                                              fontSize: 8,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                          pw.Text(
                                            'Patient Paid Amount : ${currentCollected.text}',
                                            style: pw.TextStyle(
                                              fontSize: 8,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                          pw.Text(
                                            'Balance : ${currentBalance.text}',
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
                            bytes: await pdf.save(),
                            filename: '${widget.ipTicket}.pdf');
                        await updateIpAdmitBillNo(billNo);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.teal,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Print'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        setState(() {});
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
          child: CustomText(
            text: 'Print',
            size: screenWidth * 0.012,
            color: AppColors.secondaryColor,
          ),
        ),
        TextButton(
          onPressed: () async {
            if (widget.timeLine == true) {
              if (balance.text.isNotEmpty || balance.text == '') {
                CustomSnackBar(context,
                    message: 'Enter Payment Amount',
                    backgroundColor: Colors.orange);
                return;
              }
              await addPaymentAmount(widget.docId.toString());
              await updateBalance(widget.docId.toString(),
                  double.parse(balance.text.replaceAll('₹ ', '')));
              widget.fetchData!();
            }
          },
          child: CustomText(
            text: 'Pay',
            size: screenWidth * 0.012,
            color: AppColors.secondaryColor,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: CustomText(
            text: 'Close',
            size: screenWidth * 0.012,
            color: AppColors.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTimeline() {
    return payments.isEmpty
        ? const Center(child: CustomText(text: "No Payments Found"))
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: payments.map((payment) {
                return Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            getPaymentIcon(payment["method"]),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomText(text: payment["date"]),
                        CustomText(
                          text: payment["paidAmount"],
                        ),
                      ],
                    ),
                    if (payment != payments.last)
                      Container(
                        width: 40,
                        height: 5,
                        color: Colors.grey,
                      ),
                  ],
                );
              }).toList(),
            ),
          );
  }
}
