import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'dart:io';

import '../../../utilities/colors.dart';
import '../../../utilities/constants.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class OpTicketPage extends StatefulWidget {
  @override
  State<OpTicketPage> createState() => _OpTicketPageState();
}

class _OpTicketPageState extends State<OpTicketPage> {
  final dateTime = DateTime.timestamp();
  int selectedIndex = 2;
  final TextEditingController tokenDate = TextEditingController();
  final TextEditingController doctorName = TextEditingController();
  final TextEditingController specialization = TextEditingController();
  final TextEditingController degree = TextEditingController();

  final TextEditingController bloodSugarLevel = TextEditingController();
  final TextEditingController temperature = TextEditingController();
  final TextEditingController bloodPressure = TextEditingController();
  final TextEditingController otherComments = TextEditingController();
  final TextEditingController bloodGroup = TextEditingController();

  final TextEditingController opTicketTotalAmount = TextEditingController();
  final TextEditingController opTicketCollectedAmount = TextEditingController();

  final TextEditingController searchOpNumber = TextEditingController();
  final TextEditingController searchPhoneNumber = TextEditingController();

  bool isSearchPerformed = false;
  List<Map<String, String>> searchResults = [];
  Map<String, String>? selectedPatient;
  String? selectedCounter;
  bool isGeneratingToken = false;

  int tokenNumber = 0;
  String lastSavedDate = '';

  @override
  void initState() {
    super.initState();
  }

  Future<String> generateUniqueOpTicketId(String selectedPatientId) async {
    const chars = '0123456789';
    Random random = Random.secure();
    String opTicketId = '';

    bool exists = true;
    while (exists) {
      String randomString =
          List.generate(6, (index) => chars[random.nextInt(chars.length)])
              .join();
      opTicketId = 'OP$randomString';

      var docSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(selectedPatientId)
          .collection('opTickets')
          .doc(opTicketId)
          .get();

      exists = docSnapshot.exists;
    }

    return opTicketId;
  }

  Future<void> initializeOpTicketID(String selectedPatientId) async {
    opTicketId = await generateUniqueOpTicketId(selectedPatientId);
    setState(() {});
  }

  String opTicketId = '';

  Future<void> fetchDoctorAndSpecialization() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      QuerySnapshot<Map<String, dynamic>> doctorsSnapshot =
          await FirebaseFirestore.instance
              .collection('doctorSchedulesDaily')
              .where('date', isEqualTo: today)
              .where('counter', isEqualTo: selectedCounter)
              .get();

      if (doctorsSnapshot.docs.isNotEmpty) {
        final firstDoc = doctorsSnapshot.docs.first.data();

        setState(() {
          doctorName.text = firstDoc['doctor'] ?? '';
          specialization.text = firstDoc['specialization'] ?? '';
          degree.text = firstDoc['degree'] ?? '';
        });
      } else {
        setState(() {
          doctorName.text = '';
          specialization.text = '';
          degree.text = '';
        });
      }
    } catch (e) {
      print('Error fetching doctors: $e');
    }
  }

  Future<void> _generateToken(String selectedPatientId) async {
    setState(() {
      tokenNumber++;
      isGeneratingToken = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      DocumentSnapshot documentSnapshot =
          await firestore.collection('counters').doc('counterDoc').get();

      var storedTokenValue = documentSnapshot['value'] + 1;

      print('Fetched Token Value from counter collection : $storedTokenValue');

      await firestore
          .collection('patients')
          .doc(selectedPatientId)
          .collection('tokens')
          .doc('currentToken')
          .set({
        'tokenNumber': storedTokenValue,
        'date': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
      });
      await firestore
          .collection('patients')
          .doc(selectedPatientId)
          .collection('opTickets')
          .doc(opTicketId)
          .set({
        'opTicket': opTicketId,
        'tokenNumber': storedTokenValue,
        'tokenDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'status': 'waiting',
        'counter': selectedCounter,
        'doctorName': doctorName.text,
        'specialization': specialization.text,
        'bloodPressure': bloodPressure.text,
        'bloodSugarLevel': bloodSugarLevel.text,
        'temperature': temperature.text,
        'opTicketTotalAmount': opTicketTotalAmount.text,
        'opTicketCollectedAmount': opTicketCollectedAmount.text,
        'otherComments': otherComments.text,
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Token Detail'),
            content: Container(
              width: 125,
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(text: 'OP Ticket Number : $opTicketId'),
                  const SizedBox(height: 8),
                  CustomText(
                      text: 'Generated Token Number : $storedTokenValue'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  final pdf = pw.Document();
                  const blue = PdfColor.fromInt(0xFF106ac2);
                  const lightBlue = PdfColor.fromInt(0xFF21b0d1); // 0xAARRGGBB

                  final font = await rootBundle
                      .load('Fonts/Poppins/Poppins-Regular.ttf');
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

                  pdf.addPage(
                    pw.Page(
                      // pageFormat: PdfPageFormat.a4,
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
                                              'Dr. ${doctorName.text}',
                                              style: pw.TextStyle(
                                                fontSize: 28,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              '${degree.text}[General Medicine]',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              '${specialization.text}',
                                              style: pw.TextStyle(
                                                fontSize: 12,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
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
                                                  '0${selectedCounter}',
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
                                                  '$storedTokenValue',
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
                                    pw.Divider(thickness: 2, color: lightBlue),
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
                                              'OP Ticket No : ${opTicketId}',
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
                                              'Name : ${selectedPatient!['name']}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              'OP Number : ${selectedPatient!['opNumber']}',
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
                                              'Age : ${selectedPatient!['age']}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              'Blood Group : ${selectedPatient!['bloodGroup']}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              'Place : ${selectedPatient!['city']}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              'Phone : ${selectedPatient!['phone']}',
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
                                              'Basic Diagnosis',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              'BP : ${bloodPressure.text}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              'Temp : ${temperature.text}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              'Blood Sugar : ${bloodSugarLevel.text}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
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
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              'Place : ${Constants.hospitalCity}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        pw.Column(
                                          children: [
                                            pw.Text(
                                              'Dr. ${doctorName.text}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              '${degree.text}[General Medicine]',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              '${specialization.text}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
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
                child: const Text('Print'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    clearFields();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      setState(() {
        isGeneratingToken = false;
      });
      CustomSnackBar(context,
          message: 'Token saved: $storedTokenValue',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to save token: $e', backgroundColor: Colors.red);
    }
  }

  void clearFields() {
    searchOpNumber.clear();
    searchPhoneNumber.clear();
    isSearchPerformed = false;
    searchResults = [];
    selectedPatient = null;
    tokenDate.clear();
    doctorName.clear();
    specialization.clear();
    bloodSugarLevel.clear();
    temperature.clear();
    bloodPressure.clear();
    otherComments.clear();
    opTicketTotalAmount.clear();
    opTicketCollectedAmount.clear();
  }

  Future<void> incrementCounter() async {
    final docRef =
        FirebaseFirestore.instance.collection('counters').doc('counterDoc');

    try {
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        int currentValue = snapshot.get('value') as int;
        Timestamp lastResetTimestamp = snapshot.get('lastReset') as Timestamp;
        DateTime lastReset = lastResetTimestamp.toDate();

        print("Last reset time: $lastReset");

        if (_shouldResetCounter(lastReset)) {
          print("Resetting the counter...");
          await docRef.update({
            'value': 0,
            'lastReset': FieldValue.serverTimestamp(),
          });
        } else {
          print("Incrementing the counter...");
          await docRef.update({'value': currentValue + 1});
        }
      } else {
        print("Initializing counter...");
        await docRef.set({
          'value': 0,
          'lastReset': FieldValue.serverTimestamp(),
        });
      }
    } catch (e, stackTrace) {
      print("Error in incrementCounter: $e");
      print(stackTrace);
      showMessage("Failed to update counter: $e");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<List<Map<String, String>>> searchPatients(
      String opNumber, String phoneNumber) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Map<String, String>> patientsList = [];
    List<QueryDocumentSnapshot> docs = [];

    if (opNumber.isNotEmpty) {
      final QuerySnapshot snapshot =
          await firestore.collection('patients').get();
      docs.addAll(snapshot.docs.where((doc) {
        final docOp = (doc['opNumber'] ?? '').toString();
        return docOp.toLowerCase() == opNumber.toLowerCase();
      }));
    }

    // Phone1 exact match
    if (phoneNumber.isNotEmpty) {
      final QuerySnapshot snapshotPhone1 = await firestore
          .collection('patients')
          .where('phone1', isEqualTo: phoneNumber)
          .get();
      docs.addAll(snapshotPhone1.docs);

      // Phone2 exact match
      final QuerySnapshot snapshotPhone2 = await firestore
          .collection('patients')
          .where('phone2', isEqualTo: phoneNumber)
          .get();
      docs.addAll(snapshotPhone2.docs);
    }

    // Remove duplicates by document ID
    final uniqueDocs = {
      for (var doc in docs) doc.id: doc,
    }.values;

    for (var doc in uniqueDocs) {
      patientsList.add({
        'opNumber': doc['opNumber'] ?? 'N/A',
        'name':
            ((doc['firstName'] ?? '') + ' ' + (doc['lastName'] ?? '') ?? 'N/A')
                .trim(),
        'age': doc['age'] ?? 'N/A',
        'phone': doc['phone1'] ?? 'N/A',
        'address': doc['address1'] ?? 'N/A',
        'city': doc['city'] ?? 'N/A',
        'bloodGroup': doc['bloodGroup'] ?? 'N/A',
      });
    }

    return patientsList;
  }

  final String documentId = "counterDoc";

  bool _shouldResetCounter(DateTime lastReset) {
    final now = DateTime.now();
    return now.year != lastReset.year ||
        now.month != lastReset.month ||
        now.day != lastReset.day;
  }

  @override
  void dispose() {
    super.dispose();
    searchOpNumber.dispose();
    searchPhoneNumber.dispose();
    tokenDate.dispose();
    doctorName.dispose();
    bloodSugarLevel.dispose();
    temperature.dispose();
    bloodPressure.dispose();
    otherComments.dispose();
    opTicketTotalAmount.dispose();
    opTicketCollectedAmount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text(
                'OP Ticket Dashboard',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            )
          : null,
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
          : null, // No AppBar for web view
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Sidebar width for larger screens
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(0.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return buildThreeColumnForm(); // Web view
                  } else {
                    return buildSingleColumnForm(); // Mobile view
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildThreeColumnForm() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: screenHeight * 1.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenWidth * 0.01),
                  child: Column(
                    children: [
                      CustomText(
                        text: "Search Patient",
                        size: screenWidth * 0.025,
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
            Container(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.08, right: screenWidth * 0.08),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const CustomText(
                        text: 'Enter OP Number            :',
                        size: 18,
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      SizedBox(
                        width: 250,
                        child: CustomTextField(
                          hintText: '',
                          controller: searchOpNumber,
                          width: null,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const CustomText(
                        text: 'Enter Phone Number      : ',
                        size: 18,
                      ),
                      const SizedBox(width: 25),
                      SizedBox(
                        width: 250,
                        child: CustomTextField(
                          controller: searchPhoneNumber,
                          hintText: '',
                          width: null,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 200),
                      CustomButton(
                        width: 125,
                        height: 35,
                        label: 'Search',
                        onPressed: () async {
                          final searchResultsFetched = await searchPatients(
                            searchOpNumber.text,
                            searchPhoneNumber.text,
                          );
                          setState(() {
                            searchResults =
                                searchResultsFetched; // Update searchResults
                            isSearchPerformed =
                                true; // Show the table after search
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (isSearchPerformed) ...[
              const Text('Search Results: ',
                  style: TextStyle(
                      fontFamily: 'SanFrancisco',
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Center(
                child: DataTable(
                  columnSpacing: 180,
                  columns: [
                    const DataColumn(label: Text('OP Number')),
                    const DataColumn(label: Text('Name')),
                    const DataColumn(label: Text('Age')),
                    const DataColumn(label: Text('Phone')),
                    const DataColumn(label: Text('Address')),
                  ],
                  rows: searchResults.map((result) {
                    return DataRow(
                      selected: selectedPatient == result,
                      onSelectChanged: (isSelected) {
                        setState(() {
                          selectedPatient = result;
                        });
                      },
                      cells: [
                        DataCell(Text(result['opNumber']!)),
                        DataCell(Text(result['name']!)),
                        DataCell(Text(result['age']!)),
                        DataCell(Text(result['phone']!)),
                        DataCell(Text(result['address']!)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              if (selectedPatient != null) buildPatientDetailsForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildPatientDetailsForm() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OP Ticket Generation :',
            style: TextStyle(
                fontFamily: 'SanFrancisco',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        'OP Number : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomText(
                        text: "${selectedPatient?['opNumber']}",
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const SizedBox(
                      width: 80,
                      child: Text(
                        'Name : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomText(text: "${selectedPatient?['name']}"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        'AGE : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomText(text: "${selectedPatient?['age']}"),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const SizedBox(
                      width: 80,
                      child: Text(
                        'Phone : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomText(text: "${selectedPatient?['phone']}"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        'Address : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomText(text: "${selectedPatient?['address']}"),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const SizedBox(
                      width: 80,
                      child: Text(
                        'Last OP Date : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child:
                          CustomText(text: "${selectedPatient?['lastOpDate']}"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            width: 1200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Token Infomation',
                  size: 24,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomText(
                        text: 'Date : ',
                        size: 16,
                      ),
                      CustomTextField(
                        hintText: '',
                        controller: TextEditingController(
                            text: dateTime.year.toString() +
                                '-' +
                                dateTime.month.toString().padLeft(2, '0') +
                                '-' +
                                dateTime.day.toString().padLeft(2, '0')),
                        width: 150,
                      ),
                      const CustomText(
                        text: 'Counter : ',
                        size: 16,
                      ),
                      CustomDropdown(
                        width: 0.05,
                        label: '',
                        items: const ['1', '2', '3', '4', '5'],
                        onChanged: (value) {
                          setState(
                            () {
                              selectedCounter = value;
                              fetchDoctorAndSpecialization();
                            },
                          );
                        },
                      ),
                      const CustomText(
                        text: 'Doctor : ',
                        size: 16,
                      ),
                      CustomTextField(
                        hintText: '',
                        width: 200,
                        controller: doctorName,
                      ),
                      const CustomText(
                        text: 'Specialization : ',
                        size: 16,
                      ),
                      CustomTextField(
                        hintText: '',
                        width: 180,
                        controller: specialization,
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 150),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomText(
                        text: 'OP Ticket Amount : ',
                        size: 16,
                      ),
                      CustomTextField(
                        hintText: '',
                        controller: opTicketTotalAmount,
                        width: 250,
                      ),
                      const CustomText(
                        text: 'Collected : ',
                        size: 16,
                      ),
                      CustomTextField(
                        hintText: '',
                        controller: opTicketCollectedAmount,
                        width: 250,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 75,
          ),
          Container(
            height: 200,
            width: 1100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'General Information',
                  size: 24,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomText(
                        text: 'Temperature : ',
                        size: 16,
                      ),
                      CustomTextField(
                        hintText: '',
                        controller: temperature,
                        width: 175,
                      ),
                      const CustomText(
                        text: 'Blood Pressure : ',
                        size: 16,
                      ),
                      CustomTextField(
                        hintText: '',
                        controller: bloodPressure,
                        width: 175,
                      ),
                      const CustomText(
                        text: 'Blood Sugar : ',
                        size: 16,
                      ),
                      CustomTextField(
                        hintText: '',
                        controller: bloodSugarLevel,
                        width: 175,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(text: 'Other Comments : '),
                      const SizedBox(
                        width: 5,
                      ),
                      CustomTextField(
                        controller: otherComments,
                        hintText: '',
                        width: 800,
                        verticalSize: 30,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 75,
          ),
          Row(
            children: [
              const SizedBox(width: 425),
              isGeneratingToken
                  ? Lottie.asset('assets/button_loading.json',
                      height: 150, width: 150)
                  : CustomButton(
                      label: 'Generate',
                      onPressed: () async {
                        String? selectedPatientId =
                            selectedPatient?['opNumber'];
                        await initializeOpTicketID(selectedPatientId!);
                        print(selectedPatientId);
                        await incrementCounter();
                        await _generateToken(selectedPatientId!);
                      },
                      width: 200,
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSingleColumnForm() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Patient Search: ',
                style: TextStyle(
                    fontFamily: 'SanFrancisco',
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Enter OP Number: ',
                    style: TextStyle(fontFamily: 'SanFrancisco', fontSize: 22)),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    hintText: 'OP Number',
                    width: null,
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Enter Phone Number: ',
                    style: TextStyle(fontFamily: 'SanFrancisco', fontSize: 22)),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    hintText: 'Phone Number',
                    width: null,
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 250,
                  child: CustomButton(
                    label: 'Search',
                    onPressed: () {
                      setState(() {
                        isSearchPerformed = true; // Show the table after search
                      });
                    },
                    width: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (isSearchPerformed) ...[
              const Text('Search Results: ',
                  style: TextStyle(
                      fontFamily: 'SanFrancisco',
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('OP Number')),
                    const DataColumn(label: Text('Name')),
                    const DataColumn(label: Text('Age')),
                    const DataColumn(label: Text('Phone')),
                    const DataColumn(label: Text('Address')),
                  ],
                  rows: searchResults.map((result) {
                    return DataRow(
                      selected: selectedPatient == result,
                      onSelectChanged: (isSelected) {
                        setState(() {
                          selectedPatient = result;
                        });
                      },
                      cells: [
                        DataCell(Text(result['opNumber']!)),
                        DataCell(Text(result['name']!)),
                        DataCell(Text(result['age']!)),
                        DataCell(Text(result['phone']!)),
                        DataCell(Text(result['address']!)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              if (selectedPatient != null) buildPatientDetailsForm(),
            ],
          ],
        ),
      ),
    );
  }
}
