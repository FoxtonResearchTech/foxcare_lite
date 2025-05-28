import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/reception/reception_drawer.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../../../utilities/constants.dart';

class OpCardPrint extends StatefulWidget {
  @override
  State<OpCardPrint> createState() => _OpCardPrint();
}

class _OpCardPrint extends State<OpCardPrint> {
  int selectedIndex = 8;
  TextEditingController _patientID = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  final List<String> headers = [
    'OP No',
    'Date',
    'Name',
    'City',
    'Phone Number',
    'Action'
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
    int pageSize = 20,
    Duration delayBetweenPages = const Duration(milliseconds: 100),
  }) async {
    try {
      List<Map<String, dynamic>> fetchedData = [];
      final firestore = FirebaseFirestore.instance;

      Query query = firestore.collection('patients');

      if (opNumber != null) {
        query = query.where('opNumber', isEqualTo: opNumber);
      } else if (phoneNumber != null) {
        query = query.where(Filter.or(
          Filter('phone1', isEqualTo: phoneNumber),
          Filter('phone2', isEqualTo: phoneNumber),
        ));
      }

      DocumentSnapshot? lastDoc;

      while (true) {
        Query paginatedQuery = query.limit(pageSize);
        if (lastDoc != null) {
          paginatedQuery = paginatedQuery.startAfterDocument(lastDoc);
        }

        final snapshot = await paginatedQuery.get();

        if (snapshot.docs.isEmpty) break;

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (!data.containsKey('opNumber') ||
              !data.containsKey('opAdmissionDate')) {
            continue;
          }

          double opAmount =
              double.tryParse(data['opAmount']?.toString() ?? '0') ?? 0;
          double opAmountCollected =
              double.tryParse(data['opAmountCollected']?.toString() ?? '0') ??
                  0;
          double balance = opAmount - opAmountCollected;

          fetchedData.add({
            'OP No': data['opNumber']?.toString() ?? 'N/A',
            'Date': data['opAdmissionDate'] ?? 'N/A',
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'City': data['city']?.toString() ?? 'N/A',
            'Phone Number': data['phone1'] ?? 'N/A',
            'Action': TextButton(
              onPressed: () async {
                final pdf = pw.Document();
                final myColor = PdfColor.fromInt(0xFF106ac2); // 0xAARRGGBB

                final font =
                    await rootBundle.load('Fonts/Poppins/Poppins-Regular.ttf');
                final ttf = pw.Font.ttf(font);

                final topImage = pw.MemoryImage(
                  (await rootBundle.load('assets/opAssets/OP_Card_top.png'))
                      .buffer
                      .asUint8List(),
                );

                final bottomImage = pw.MemoryImage(
                  (await rootBundle.load('assets/opAssets/OP_Card_back.png'))
                      .buffer
                      .asUint8List(),
                );
                final loc = pw.MemoryImage(
                  (await rootBundle.load('assets/location_Icon.png'))
                      .buffer
                      .asUint8List(),
                );

                pdf.addPage(
                  pw.Page(
                    pageFormat: const PdfPageFormat(
                        8 * PdfPageFormat.cm, 5 * PdfPageFormat.cm),
                    margin: pw.EdgeInsets.zero,
                    build: (pw.Context context) {
                      return pw.Stack(
                        children: [
                          pw.Positioned.fill(
                            child: pw.Image(topImage, fit: pw.BoxFit.cover),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      'ABC Hospital',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        font: ttf,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  'OP Number: ${data['opNumber']}',
                                  style: pw.TextStyle(
                                      fontSize: 10, font: ttf, color: myColor),
                                ),
                                pw.Text(
                                  'Name: ${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}',
                                  style: pw.TextStyle(
                                      fontSize: 10, font: ttf, color: myColor),
                                ),
                                pw.Text(
                                  'Phone Number: ${data['phone1']}',
                                  style: pw.TextStyle(
                                      fontSize: 10, font: ttf, color: myColor),
                                ),
                              ],
                            ),
                          ),
                          // Full-width background image at the bottom
                          pw.Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: pw.Image(
                              bottomImage,
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                          // Text content above the bottom image
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(
                                left: 8, right: 8, top: 6),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Emergency and appointment info (left side)
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

                                    // City + District + Location Icon (right side)
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
                                              '${Constants.hospitalCity}',
                                              style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: ttf,
                                                  color: PdfColors.white),
                                            ),
                                            pw.Text(
                                              '${Constants.hospitalDistrict}',
                                              style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: ttf,
                                                  color: PdfColors.white),
                                            ),
                                          ],
                                        ),
                                        pw.SizedBox(width: 4),
                                        pw.Image(loc,
                                            height: 20,
                                            width: 10), // Icon on the right
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
                // await Printing.layoutPdf(
                //   onLayout: (PdfPageFormat format) async {
                //     return pdf.save();
                //   },
                //   format: const PdfPageFormat(
                //       8 * PdfPageFormat.cm, 5 * PdfPageFormat.cm),
                // );

                await Printing.sharePdf(
                    bytes: await pdf.save(),
                    filename: '${data['opNumber']}.pdf');
              },
              child: const CustomText(text: 'Print'),
            )
          });
        }

        lastDoc = snapshot.docs.last;
        fetchedData.sort((a, b) {
          int tokenA = int.tryParse(a['OP No'].toString()) ?? 0;
          int tokenB = int.tryParse(b['OP No'].toString()) ?? 0;
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
                          text: "OP Card Print ",
                          size: screenWidth * .03,
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
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    hintText: 'OP Number',
                    width: screenWidth * 0.15,
                    controller: _patientID,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(opNumber: _patientID.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  CustomTextField(
                    hintText: 'Phone Number',
                    width: screenWidth * 0.15,
                    controller: _phoneNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(phoneNumber: _phoneNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              LazyDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData,
                headers: headers,
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
