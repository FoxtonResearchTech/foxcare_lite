import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/lab/patients_lab_details.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../utilities/constants.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/lab/lab_module_drawer.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'dashboard.dart';
import 'lab_accounts.dart';
import 'lab_testqueue.dart';

class ReportsSearch extends StatefulWidget {
  const ReportsSearch({super.key});

  @override
  State<ReportsSearch> createState() => _ReportsSearch();
}

class ReportRow {
  final String slNo;
  final String opNumber;
  final String name;
  final String age;
  final String testType;
  final String dateOfReport;
  final String amountCollected;
  final String paymentStatus;

  ReportRow(
    this.slNo,
    this.opNumber,
    this.name,
    this.age,
    this.testType,
    this.dateOfReport,
    this.amountCollected,
    this.paymentStatus,
  );
}

class _ReportsSearch extends State<ReportsSearch> {
  int selectedIndex = 4;

  TextEditingController _reportNumber = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();

  final List<String> labTestHeader = [
    'Test Descriptions',
    'Values',
    'Unit',
    'Reference Range',
  ];
  List<Map<String, dynamic>> labTestData = [];
  final List<String> headers = [
    'Report Date',
    'Report No',
    'Name',
    'OP Ticket',
    'OP Number',
    'Report'
  ];
  List<Map<String, dynamic>> tableData = [];
  Future<void> printData({
    required String name,
    required String bloodGroup,
    required String opTicket,
    required String opNumber,
    required String specialization,
    required String phoneNo,
    required String city,
    required String age,
    required String labTechName,
    required String labQual,
    required String doctorName,
    required String sampleDate,
    required String address,
    required String sampleCollectedDate,
    required String reportDate,
    required String reportNo,
  }) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Print'),
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
                  const lightBlue = PdfColor.fromInt(0xFF21b0d1);

                  final font = await rootBundle
                      .load('Fonts/Poppins/Poppins-Regular.ttf');
                  final ttf = pw.Font.ttf(font);

                  final topImage = pw.MemoryImage(
                    (await rootBundle.load('assets/opAssets/OP_Bill_Top.png'))
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
                        headerDecoration: pw.BoxDecoration(color: headerColor),
                        cellStyle: pw.TextStyle(font: ttf, fontSize: 7),
                        cellHeight: rowHeight > 12 ? rowHeight - 10 : rowHeight,
                        border: pw.TableBorder.all(color: headerColor),
                      ),
                      pw.SizedBox(height: 6),
                    ];
                  }

                  final List<List<String>> dataRows = labTestData.map((data) {
                    return labTestHeader
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
                                fit: pw.BoxFit.cover, height: 225, width: 500),
                          ),
                          // Footer Content
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(
                                left: 8, right: 8, bottom: 8, top: 20),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                                      padding: pw.EdgeInsets.only(top: 20),
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
                          padding: const pw.EdgeInsets.only(left: 8, right: 0),
                          child: pw.Container(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  '${Constants.labName}',
                                  style: pw.TextStyle(
                                    fontSize: 30,
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                    color: lightBlue,
                                  ),
                                ),
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
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
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
                                      ],
                                    ),
                                    pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
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
                                          'Mail : ${Constants.mail}',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Web : ${Constants.website}',
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
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 8, right: 8),
                          child: pw.Container(
                            child: pw.Column(
                              children: [
                                pw.Divider(color: blue, thickness: 1),
                                pw.SizedBox(height: 10),
                                pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          'OP Ticket No : ${opTicket}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          'Doctor : ${doctorName}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Specialization : ${specialization}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          'Name : ${name}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'OP Number : ${opNumber}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          'Age : ${age}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Blood Group : ${bloodGroup}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Place : ${city}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Phone : ${phoneNo}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
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
                                          'Address : ${address}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          'Sample Collected Date : ${sampleCollectedDate}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Sample Date : ${sampleDate}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.SizedBox(height: 6),
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          'Report Date : ${reportDate}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Report No : ${reportNo}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 6),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        ...buildPaginatedTable(
                          headers: labTestHeader,
                          data: labTestData,
                          ttf: ttf,
                          headerColor: lightBlue,
                          rowHeight: 15,
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              '***** END OF THE REPORT *****',
                              style: pw.TextStyle(
                                fontSize: 10,
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 20),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${labTechName}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.Text(
                              '[${labQual}]',
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
                  );
                  //
                  // await Printing.layoutPdf(
                  //   onLayout: (format) async => pdf.save(),
                  // );

                  await Printing.sharePdf(
                      bytes: await pdf.save(), filename: '${opTicket}.pdf');
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
        });
  }

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
    String? reportNo,
  }) async {
    try {
      final QuerySnapshot patientSnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var patientDoc in patientSnapshot.docs) {
        final patientData = patientDoc.data() as Map<String, dynamic>;
        final patientId = patientDoc.id;

        final opTicketsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .collection('opTickets')
            .get();

        for (var ticketDoc in opTicketsSnapshot.docs) {
          final ticketData = ticketDoc.data();

          if (!ticketData.containsKey('reportNo') ||
              !ticketData.containsKey('reportDate')) continue;

          bool matches = false;

          if (singleDate != null) {
            matches = ticketData['reportDate'] == singleDate;
          } else if (fromDate != null && toDate != null) {
            final date = ticketData['reportDate'];
            matches =
                date.compareTo(fromDate) >= 0 && date.compareTo(toDate) <= 0;
          } else if (reportNo != null) {
            matches = ticketData['reportNo'].toString() == reportNo;
          } else {
            matches = true;
          }

          if (matches) {
            fetchedData.add({
              'Report Date': ticketData['reportDate']?.toString() ?? 'N/A',
              'Report No': ticketData['reportNo']?.toString() ?? 'N/A',
              'Name':
                  '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                      .trim(),
              'OP Ticket': ticketData['opTicket']?.toString() ?? 'N/A',
              'OP Number': patientData['opNumber']?.toString() ?? 'N/A',
              'Report': TextButton(
                onPressed: () async {
                  setState(() {
                    labTestData = (ticketData['tests'] as List)
                        .whereType<Map<String, dynamic>>()
                        .toList();
                  });

                  await printData(
                    labTechName: ticketData['labTechnician'] ?? 'N/A',
                    labQual: ticketData['labTechnicianDegree'] ?? 'N/A',
                    name:
                        '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                            .trim(),
                    opTicket: ticketData['opTicket']?.toString() ?? 'N/A',
                    opNumber: patientData['opNumber']?.toString() ?? 'N/A',
                    address: patientData['address']?.toString() ?? 'N/A',
                    age: patientData['age']?.toString() ?? 'N/A',
                    bloodGroup: patientData['bloodGroup']?.toString() ?? 'N/A',
                    city: patientData['city']?.toString() ?? 'N/A',
                    phoneNo: patientData['phone1']?.toString() ?? 'N/A',
                    sampleCollectedDate:
                        ticketData['sampleCollectedDate']?.toString() ?? 'N/A',
                    sampleDate: ticketData['sampleDate']?.toString() ?? 'N/A',
                    reportNo: ticketData['reportNo']?.toString() ?? 'N/A',
                    doctorName: ticketData['doctorName']?.toString() ?? 'N/A',
                    specialization:
                        ticketData['specialization']?.toString() ?? 'N/A',
                    reportDate: ticketData['reportDate']?.toString() ?? 'N/A',
                  );
                },
                child: CustomText(text: 'Print'),
              ),
            });
          }
        }
      }

      fetchedData.sort((a, b) {
        int aNo = int.tryParse(a['Report No'].toString()) ?? 0;
        int bNo = int.tryParse(b['Report No'].toString()) ?? 0;
        return aNo.compareTo(bNo);
      });

      setState(() {
        tableData = fetchedData;
      });
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
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _toDateController.dispose();
    _fromDateController.dispose();
    _reportNumber.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Laboratory Dashboard'),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: LabModuleDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300,
              color: Colors.blue.shade100,
              child: LabModuleDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
            bottom: screenWidth * 0.01,
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
                          text: " OP Ticket Reports",
                          size: screenWidth * 0.03,
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
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Report Number',
                    width: screenWidth * 0.15,
                    controller: _reportNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(reportNo: _reportNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                    icon: Icon(Icons.date_range),
                    controller: _dateController,
                    onTap: () => _selectDate(context, _dateController),
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(singleDate: _dateController.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomText(text: 'OR'),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                    icon: Icon(Icons.date_range),
                    onTap: () => _selectDate(context, _fromDateController),
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                    icon: Icon(Icons.date_range),
                    onTap: () => _selectDate(context, _toDateController),
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(
                        fromDate: _fromDateController.text,
                        toDate: _toDateController.text,
                      );
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData,
                headers: headers,
              ),
              SizedBox(height: screenHeight * 0.05)
            ],
          ),
        ),
      ),
    );
  }
}
