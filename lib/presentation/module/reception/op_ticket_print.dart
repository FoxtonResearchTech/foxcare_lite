import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/reception/reception_drawer.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../../../utilities/constants.dart';

class OpTicketPrint extends StatefulWidget {
  @override
  State<OpTicketPrint> createState() => _OpTicketPrint();
}

class _OpTicketPrint extends State<OpTicketPrint> {
  final dateTime = DateTime.timestamp();

  int selectedIndex = 9;
  TextEditingController _patientID = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  bool isPhoneLoading = false;
  bool isOpLoading = false;
  final List<String> headers = [
    'Token NO',
    'OP Ticket',
    'OP NO',
    'Name',
    'Age',
    'Place',
    'Primary Info',
    'Action',
  ];
  List<Map<String, dynamic>> tableData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchData({
    String? opNumber,
    String? phoneNumber,
    int pageSize = 1,
    Duration delayBetweenPages = const Duration(milliseconds: 100),
  }) async {
    print('Fetching data with OP Number: $opNumber');

    try {
      List<Map<String, dynamic>> fetchedData = [];

      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final firestore = FirebaseFirestore.instance;
      DocumentSnapshot? lastPatientDoc;

      while (true) {
        Query patientQuery = firestore.collection('patients').limit(pageSize);
        if (lastPatientDoc != null) {
          patientQuery = patientQuery.startAfterDocument(lastPatientDoc);
        }

        final patientSnapshot = await patientQuery.get();

        if (patientSnapshot.docs.isEmpty) break;

        for (var patientDoc in patientSnapshot.docs) {
          final patientId = patientDoc.id;
          final patientData = patientDoc.data() as Map<String, dynamic>;

          final opTicketsSnapshot = await firestore
              .collection('patients')
              .doc(patientId)
              .collection('opTickets')
              .get();

          for (var opTicketDoc in opTicketsSnapshot.docs) {
            final opTicketData = opTicketDoc.data();

            bool matches = false;

            if (patientData['isIP'] == false) {
              if (opNumber != null &&
                  opTicketData['opTicket'] != null &&
                  opTicketData['opTicket'].toString().toLowerCase() == opNumber.toLowerCase()) {
                matches = true;
              } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
                if (patientData['phone1'] == phoneNumber ||
                    patientData['phone2'] == phoneNumber) {
                  matches = true;
                }
              } else if (opNumber == null &&
                  (phoneNumber == null || phoneNumber.isEmpty)) {
                matches = true;
              }
            }

            if (matches) {
              String tokenNo = '';
              String tokenDate = '';

              try {
                final tokenSnapshot = await firestore
                    .collection('patients')
                    .doc(patientId)
                    .collection('tokens')
                    .doc('currentToken')
                    .get();

                if (tokenSnapshot.exists) {
                  final tokenData = tokenSnapshot.data();
                  if (tokenData != null && tokenData['tokenNumber'] != null) {
                    tokenNo = tokenData['tokenNumber'].toString();
                  }
                  if (tokenData != null && tokenData['date'] != null) {
                    tokenDate = tokenData['date'];
                  }
                }
              } catch (e) {
                print('Error fetching tokenNo for patient $patientId: $e');
              }

              if (tokenDate == todayString) {
                fetchedData.add({
                  'Token NO': tokenNo,
                  'OP NO': patientData['opNumber'] ?? 'N/A',
                  'OP Ticket': opTicketData['opTicket'] ?? 'N/A',
                  'Name':
                      '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                          .trim(),
                  'Age': patientData['age'] ?? 'N/A',
                  'Place': patientData['city'] ?? 'N/A',
                  'Address': patientData['address1'] ?? 'N/A',
                  'PinCode': patientData['pincode'] ?? 'N/A',
                  'Status': opTicketData['status'] ?? 'N/A',
                  'Primary Info': opTicketData['otherComments'] ?? 'N/A',
                  'Action': TextButton(
                    onPressed: () async {
                      final pdf = pw.Document();
                      const blue = PdfColor.fromInt(0xFF106ac2);
                      const lightBlue =
                          PdfColor.fromInt(0xFF21b0d1); // 0xAARRGGBB

                      final font = await rootBundle
                          .load('Fonts/Poppins/Poppins-Regular.ttf');
                      final ttf = pw.Font.ttf(font);

                      final topImage = pw.MemoryImage(
                        (await rootBundle.load(
                                'assets/opAssets/OP_Ticket_Top_original.png'))
                            .buffer
                            .asUint8List(),
                      );

                      final bottomImage = pw.MemoryImage(
                        (await rootBundle.load(
                                'assets/opAssets/OP_Card_back_original.png'))
                            .buffer
                            .asUint8List(),
                      );

                      pdf.addPage(
                        pw.Page(
                          // pageFormat: PdfPageFormat.a4,
                          build: (pw.Context context) {
                            return pw.Stack(
                              children: [
                                pw.Positioned.fill(
                                  child:
                                      pw.Image(topImage, fit: pw.BoxFit.cover),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'ABC Hospital',
                                            style: pw.TextStyle(
                                              fontSize: 30,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pw.SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                      top: 75, left: 8, right: 8),
                                  child: pw.Container(
                                    child: pw.Column(
                                      children: [
                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Column(
                                              mainAxisAlignment:
                                                  pw.MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text(
                                                  'Dr. ${opTicketData['doctorName']}',
                                                  style: pw.TextStyle(
                                                    fontSize: 28,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  '${opTicketData['degree']}[General Medicine]',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  '${opTicketData['specialization']}',
                                                  style: pw.TextStyle(
                                                    fontSize: 12,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            pw.Row(
                                              children: [
                                                pw.Column(
                                                  children: [
                                                    pw.Text(
                                                      '0${opTicketData['counter']}',
                                                      style: pw.TextStyle(
                                                        fontSize: 36,
                                                        font: ttf,
                                                        fontWeight:
                                                            pw.FontWeight.bold,
                                                        color: PdfColors.black,
                                                      ),
                                                    ),
                                                    pw.Text(
                                                      'Counter Number',
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
                                                pw.SizedBox(width: 10),
                                                pw.Column(
                                                  children: [
                                                    pw.Text(
                                                      '${opTicketData['tokenNumber']}',
                                                      style: pw.TextStyle(
                                                        fontSize: 36,
                                                        font: ttf,
                                                        fontWeight:
                                                            pw.FontWeight.bold,
                                                        color: PdfColors.black,
                                                      ),
                                                    ),
                                                    pw.Text(
                                                      'Token Number',
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
                                        pw.Divider(
                                            thickness: 2, color: lightBlue),
                                        pw.Column(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Row(
                                              mainAxisAlignment:
                                                  pw.MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text(
                                                  'OP Ticket No : ${opTicketData['opTicket']}',
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
                                                  .MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                pw.Text(
                                                  'Name : ${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'OP Number : ${patientData['opNumber']}',
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
                                                  .MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                pw.Text(
                                                  'Age : ${patientData['age']}',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'Blood Group : ${patientData['bloodGroup']}',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'Place : ${patientData['city']}',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'Phone : ${patientData['phone1']}',
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
                                                  .MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                pw.Text(
                                                  'Basic Diagnosis',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'BP : ${opTicketData['bloodPressure']}',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'Temp : ${opTicketData['temperature']}',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'Blood Sugar : ${opTicketData['bloodSugarLevel']}',
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
                                pw.Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: pw.Image(
                                    bottomImage,
                                    fit: pw.BoxFit.cover,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                      left: 8, right: 8, bottom: 10),
                                  child: pw.Column(
                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        child: pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Column(
                                              children: [
                                                pw.Text(
                                                  'Date : ${dateTime.year.toString() + '/' + dateTime.month.toString().padLeft(2, '0') + '/' + dateTime.day.toString().padLeft(2, '0')}',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  'Place : ${Constants.hospitalCity}',
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
                                            pw.Column(
                                              children: [
                                                pw.Text(
                                                  'Dr. ${opTicketData['doctorName']}',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  '${opTicketData['degree']}[General Medicine]',
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                    font: ttf,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    color: PdfColors.black,
                                                  ),
                                                ),
                                                pw.Text(
                                                  '${opTicketData['specialization']}',
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
                                      ),
                                      pw.SizedBox(height: 50),
                                      pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                'Emergency No: ${Constants.emergencyNo}',
                                                style: pw.TextStyle(
                                                    fontSize: 8,
                                                    font: ttf,
                                                    color: PdfColors.white),
                                              ),
                                              pw.Text(
                                                'Appointments: ${Constants.appointmentNo}',
                                                style: pw.TextStyle(
                                                    fontSize: 8,
                                                    font: ttf,
                                                    color: PdfColors.white),
                                              ),
                                            ],
                                          ),
                                          pw.Row(
                                            mainAxisAlignment:
                                                pw.MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.center,
                                            children: [
                                              pw.Column(
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.end,
                                                children: [
                                                  pw.Text(
                                                    'Mail : ${Constants.mail}',
                                                    style: pw.TextStyle(
                                                        fontSize: 8,
                                                        font: ttf,
                                                        color: PdfColors.white),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          pw.Row(
                                            mainAxisAlignment:
                                                pw.MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.center,
                                            children: [
                                              pw.Column(
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.end,
                                                children: [
                                                  pw.Text(
                                                    'For more info visit : ${Constants.website}',
                                                    style: pw.TextStyle(
                                                        fontSize: 8,
                                                        font: ttf,
                                                        color: PdfColors.white),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                      //
                      await Printing.layoutPdf(
                        onLayout: (format) async => pdf.save(),
                      );

                      // await Printing.sharePdf(
                      //     bytes: await pdf.save(), filename: '${opTicketId}.pdf');
                    },
                    child: CustomText(text: 'Print'),
                  ),
                });

                break;
              }
            }
          }
        }

        lastPatientDoc = patientSnapshot.docs.last;
        fetchedData.sort((a, b) {
          int tokenA = int.tryParse(a['Token NO']) ?? 0;
          int tokenB = int.tryParse(b['Token NO']) ?? 0;
          return tokenA.compareTo(tokenB);
        });

        setState(() {
          tableData = fetchedData;
        });
        await Future.delayed(delayBetweenPages);
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
                text: 'General Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: dashboard(),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double buttonWidth = screenWidth * 0.08;
    final double buttonHeight = screenHeight * 0.040;
    bool isMobile = screenWidth < 600;

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
                          text: "OP Ticket Print ",
                          size: screenWidth * .03,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.11,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        image: const DecorationImage(
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: 'OP Number'),
                      SizedBox(height: 5,),
                      CustomTextField(
                        hintText: '',
                        width: screenWidth * 0.18,
                        controller: _patientID,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 28,),
                      isOpLoading
                          ? SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: Lottie.asset(
                          'assets/button_loading.json', // Ensure this path is correct
                          fit: BoxFit.contain,
                        ),
                      )
                          : CustomButton(
                        label: 'Search',
                        onPressed: () async {
                          setState(() => isOpLoading = true);
                          await fetchData(opNumber: _patientID.text);
                          setState(() => isOpLoading = false);
                        },
                        width: buttonWidth,
                        height: buttonHeight,
                      ),
                    ],
                  ),

                  SizedBox(width: screenHeight * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: 'Phone Number'),
                      CustomTextField(
                        hintText: '',
                        width: screenWidth * 0.18,
                        controller: _phoneNumber,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    children: [
                      SizedBox(height: 28,),
                      isPhoneLoading
                          ? SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: Lottie.asset(
                          'assets/button_loading.json', // Update the path to your Lottie file
                          fit: BoxFit.contain,
                        ),
                      )
                          : CustomButton(
                        label: 'Search',
                        onPressed: () async {
                          setState(() => isPhoneLoading = true);
                          await fetchData(phoneNumber: _phoneNumber.text);
                          setState(() => isPhoneLoading = false);
                        },
                        width: buttonWidth,
                        height: buttonHeight,
                      ),
                    ],
                  ),

                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              LazyDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData,
                headers: headers,
                rowColorResolver: (row) {
                  return row['Status'] == 'aborted'
                      ? Colors.red.shade200
                      : Colors.transparent;
                },
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
