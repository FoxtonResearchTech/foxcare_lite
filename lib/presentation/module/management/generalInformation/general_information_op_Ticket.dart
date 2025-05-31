import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../utilities/constants.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import 'general_information_admission_status.dart';
import 'general_information_doctor_visit_schedule.dart';
import 'general_information_edit_doctor_visit_schedule.dart';

class GeneralInformationOpTicket extends StatefulWidget {
  @override
  State<GeneralInformationOpTicket> createState() =>
      _GeneralInformationOpTicket();
}

class _GeneralInformationOpTicket extends State<GeneralInformationOpTicket> {
  final dateTime = DateTime.now();
  int selectedIndex = 0;
  bool isSearching = false;
  bool isSearching2 = false;
  final TextEditingController tokenDate = TextEditingController();
  final TextEditingController doctorName = TextEditingController();
  final TextEditingController degree = TextEditingController();
  final TextEditingController specialization = TextEditingController();
  final TextEditingController bloodSugarLevel = TextEditingController();
  final TextEditingController temperature = TextEditingController();
  final TextEditingController bloodPressure = TextEditingController();
  final TextEditingController otherComments = TextEditingController();

  final TextEditingController opTicketTotalAmount = TextEditingController();
  final TextEditingController opTicketCollectedAmount = TextEditingController();
  final TextEditingController opTicketBalance = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();

  final TextEditingController searchOpNumber = TextEditingController();
  final TextEditingController searchPhoneNumber = TextEditingController();

  bool isSearchPerformed = false;
  List<Map<String, String>> searchResults = [];
  Map<String, String>? selectedPatient;
  String? selectedCounter;
  String? selectedPaymentMode;

  int tokenNumber = 0;
  String lastSavedDate = '';
  int lastToken = 0;
  bool isGeneratingToken = false;

  @override
  void initState() {
    super.initState();
    opTicketTotalAmount.addListener(_updateBalance);
    opTicketCollectedAmount.addListener(_updateBalance);
  }

  String refreshNO = '';
  int newRefreshNo = 0;

  Future<String?> getAndIncrementRefreshNo() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('refresh')
          .doc('opTicketRefresh');

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        int currentBillNo = data?['number'] ?? 0;
        int currentNewBillNo = currentBillNo + 1;

        setState(() {
          refreshNO = '${currentNewBillNo}';
          newRefreshNo = currentNewBillNo;
        });

        return refreshNO;
      } else {
        print('Document does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching or incrementing billNo: $e');
      return null;
    }
  }

  Future<void> updateRefreshNo(int newRefreshNo) async {
    final docRef =
        FirebaseFirestore.instance.collection('refresh').doc('opTicketRefresh');

    await docRef.set({'number': newRefreshNo});
  }

  void _updateBalance() {
    double totalAmount = double.tryParse(opTicketTotalAmount.text) ?? 0.0;
    double paidAmount = double.tryParse(opTicketCollectedAmount.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    opTicketBalance.text = balance.toStringAsFixed(0);
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

  final String documentId = "counterDoc";

  bool _shouldResetCounter(DateTime lastReset) {
    final now = DateTime.now();
    return now.year != lastReset.year ||
        now.month != lastReset.month ||
        now.day != lastReset.day;
  }

  Future<int> fetchCounterValue() async {
    final docRef =
        FirebaseFirestore.instance.collection('counters').doc('counterDoc');
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw Exception('counterDoc does not exist');
    }

    final data = snapshot.data()!;
    final Timestamp lastResetTimestamp = data['lastReset'];
    final int value = data['value'];

    DateTime lastResetDate = lastResetTimestamp.toDate().toLocal();
    DateTime now = DateTime.now();

    bool isSameDay = lastResetDate.year == now.year &&
        lastResetDate.month == now.month &&
        lastResetDate.day == now.day;

    return isSameDay ? value : 0;
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
        'degree': degree.text,
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
        'opTicketBalance': opTicketBalance.text,
        'otherComments': otherComments.text,
      });
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(selectedPatientId)
          .collection('opTickets')
          .doc(opTicketId)
          .collection('opTicketPayments')
          .doc()
          .set({
        'collected': opTicketCollectedAmount.text,
        'balance': opTicketBalance.text,
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
                    (await rootBundle
                            .load('assets/opAssets/OP_Ticket_Top_original.png'))
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
                                        Constants.hospitalName,
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
                  // await Printing.layoutPdf(
                  //   onLayout: (format) async => pdf.save(),
                  // );

                  await Printing.sharePdf(
                      bytes: await pdf.save(), filename: '${opTicketId}.pdf');
                },
                child: const Text('Print'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    clearFields();
                  });
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => GeneralInformationOpTicket()));
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      await updateRefreshNo(newRefreshNo);
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
    Map<String, QueryDocumentSnapshot> docMap = {};
    const int pageSize = 20;

    // 1. Handle OP Number (case-insensitive, client-side filter)
    if (opNumber.isNotEmpty) {
      DocumentSnapshot? lastDoc;
      bool hasMore = true;

      while (hasMore) {
        Query query = firestore.collection('patients').limit(pageSize);
        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snapshot = await query.get();
        if (snapshot.docs.isEmpty) break;

        for (var doc in snapshot.docs) {
          if ((doc['isIP'] ?? false) == true) continue;

          final docOp = (doc['opNumber'] ?? '').toString();
          if (docOp.toLowerCase() == opNumber.toLowerCase()) {
            docMap[doc.id] = doc;
          }
        }

        lastDoc = snapshot.docs.last;
        hasMore = snapshot.docs.length == pageSize;
      }
    }

    // 2. Handle Phone Number - phone1 match
    if (phoneNumber.isNotEmpty) {
      DocumentSnapshot? lastDoc;
      bool hasMore = true;

      while (hasMore) {
        Query query = firestore
            .collection('patients')
            .where('phone1', isEqualTo: phoneNumber)
            .limit(pageSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snapshot = await query.get();
        if (snapshot.docs.isEmpty) break;

        for (var doc in snapshot.docs) {
          if ((doc['isIP'] ?? false) == true) continue;

          docMap[doc.id] = doc;
        }

        lastDoc = snapshot.docs.last;
        hasMore = snapshot.docs.length == pageSize;
      }

      // 3. Handle Phone Number - phone2 match
      lastDoc = null;
      hasMore = true;

      while (hasMore) {
        Query query = firestore
            .collection('patients')
            .where('phone2', isEqualTo: phoneNumber)
            .limit(pageSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snapshot = await query.get();
        if (snapshot.docs.isEmpty) break;

        for (var doc in snapshot.docs) {
          if ((doc['isIP'] ?? false) == true) continue;

          docMap[doc.id] = doc;
        }

        lastDoc = snapshot.docs.last;
        hasMore = snapshot.docs.length == pageSize;
      }
    }
    // Convert documents to map list
    for (var doc in docMap.values) {
      patientsList.add({
        'opNumber': doc['opNumber'] ?? 'N/A',
        'name': ((doc['firstName'] ?? 'N/A') + ' ' + (doc['lastName'] ?? 'N/A'))
            .trim(),
        'age': doc['age'] ?? 'N/A',
        'phone': doc['phone1'] ?? 'N/A',
        'phone2': doc['phone2'] ?? 'N/A',
        'address': doc['address1'] ?? 'N/A',
        'city': doc['city'] ?? 'N/A',
        'bloodGroup': doc['bloodGroup'] ?? 'N/A',
        'sex': doc['sex'] ?? 'N/A',
        'dob': doc['dob'] ?? 'N/A',
      });
    }

    return patientsList;
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
    // Get the screen width using MediaQuery
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
              child: ManagementGeneralInformationDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ), // Drawer minimized for mobile
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ManagementGeneralInformationDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ), //, // Sidebar always open for web view
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: buildThreeColumnForm(),
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
        height: screenHeight * 2.5,
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
                        text: "OP Ticket Generation",
                        size: screenWidth * 0.025,
                      ),
                      Row(
                        children: [
                          CustomText(
                            text: "Search Patients",
                            size: screenWidth * 0.015,
                          ),
                        ],
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
                  left: screenWidth * 0.04, right: screenWidth * 0.08),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'OP Number Search '),
                          SizedBox(height: 7),
                          CustomTextField(
                            hintText: '',
                            controller: searchOpNumber,
                            width: screenWidth * 0.15,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            isSearching
                                ? SizedBox(
                                    width: 125,
                                    height: 35,
                                    child: Lottie.asset(
                                      'assets/button_loading.json',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : CustomButton(
                                    width: 125,
                                    height: 35,
                                    label: 'Search',
                                    onPressed: () async {
                                      setState(() {
                                        isSearching = true;
                                      });

                                      final searchResultsFetched =
                                          await searchPatients(
                                        searchOpNumber.text,
                                        searchPhoneNumber.text,
                                      );
                                      final token = await fetchCounterValue();

                                      setState(() {
                                        lastToken = token + 1;
                                        searchResults = searchResultsFetched;
                                        isSearchPerformed = true;
                                        isSearching = false;
                                      });

                                      print('Fetched token: $lastToken');
                                    },
                                  )
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Phone Number Search '),
                          SizedBox(height: 7),
                          CustomTextField(
                            controller: searchPhoneNumber,
                            hintText: '',
                            width: screenWidth * 0.15,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            isSearching2
                                ? SizedBox(
                                    width: 125,
                                    height: 35,
                                    child: Lottie.asset(
                                      'assets/button_loading.json',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : CustomButton(
                                    width: 125,
                                    height: 35,
                                    label: 'Search',
                                    onPressed: () async {
                                      setState(() {
                                        isSearching2 = true;
                                      });

                                      final searchResultsFetched =
                                          await searchPatients(
                                        searchOpNumber.text,
                                        searchPhoneNumber.text,
                                      );
                                      final token = await fetchCounterValue();

                                      setState(() {
                                        lastToken = token + 1;
                                        searchResults = searchResultsFetched;
                                        isSearchPerformed = true;
                                        isSearching2 = false;
                                      });

                                      print('Fetched token: $lastToken');
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (isSearchPerformed) ...[
              CustomText(
                text: 'Search Results: ',
                color: AppColors.blue,
                size: screenWidth * 0.025,
              ),
              Center(
                child: DataTable(
                  columnSpacing: 180,
                  columns: [
                    const DataColumn(label: CustomText(text: 'OP Number')),
                    const DataColumn(label: CustomText(text: 'Name')),
                    const DataColumn(label: CustomText(text: 'Age')),
                    const DataColumn(label: CustomText(text: 'Phone')),
                    const DataColumn(label: CustomText(text: 'Address')),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Patient Info',
            color: AppColors.blue,
            size: screenWidth * 0.025,
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Name : ${selectedPatient?['name']}',
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.2),
                    CustomText(
                      text: 'OP Number : ${selectedPatient?['opNumber']}',
                      size: screenWidth * 0.012,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Age : ${selectedPatient?['age']}',
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.1),
                    CustomText(
                      text: 'DOB : ${selectedPatient?['dob']}',
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.1),
                    CustomText(
                      text: 'Sex : ${selectedPatient?['sex']}',
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.1),
                    CustomText(
                      text: ' Blood Group : ${selectedPatient?['bloodGroup']}',
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.1),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Phone 1 : ${selectedPatient?['phone']}',
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.2),
                    CustomText(
                      text: 'Phone 2 : ${selectedPatient?['phone2']}',
                      size: screenWidth * 0.012,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Address : ${selectedPatient?['address']}',
                      size: screenWidth * 0.012,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 1200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Counter Setup',
                  size: screenWidth * 0.025,
                  color: AppColors.blue,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Date ',
                                    size: screenWidth * 0.013,
                                  ),
                                  SizedBox(height: 7),
                                  CustomTextField(
                                    hintText: '',
                                    controller: TextEditingController(
                                        text: dateTime.year.toString() +
                                            '-' +
                                            dateTime.month
                                                .toString()
                                                .padLeft(2, '0') +
                                            '-' +
                                            dateTime.day
                                                .toString()
                                                .padLeft(2, '0')),
                                    width: screenWidth * 0.2,
                                  ),
                                ],
                              ),
                              SizedBox(width: screenWidth * 0.1),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Counter ',
                                    size: screenWidth * 0.013,
                                  ),
                                  SizedBox(height: 7),
                                  SizedBox(
                                    width: screenWidth * 0.2,
                                    child: CustomDropdown(
                                      width: screenWidth * 0.05,
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
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Doctor ',
                                    size: screenWidth * 0.013,
                                  ),
                                  SizedBox(height: 7),
                                  CustomTextField(
                                    hintText: '',
                                    controller: doctorName,
                                    width: screenWidth * 0.2,
                                  ),
                                ],
                              ),
                              SizedBox(width: screenWidth * 0.1),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Specialization ',
                                    size: screenWidth * 0.013,
                                  ),
                                  SizedBox(height: 7),
                                  CustomTextField(
                                    hintText: '',
                                    controller: specialization,
                                    width: screenWidth * 0.2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Row(
                      children: [
                        Column(
                          children: [
                            CustomText(
                              text: 'Previous',
                              size: screenWidth * 0.02,
                            ),
                            CustomText(
                              text: 'Token',
                              size: screenWidth * 0.023,
                            ),
                          ],
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        CustomText(
                          text: lastToken.toString(),
                          size: screenWidth * 0.055,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            width: 1200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Basic Diagnosis',
                  color: AppColors.blue,
                  size: screenWidth * 0.025,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Temperature ',
                            size: screenWidth * 0.013,
                          ),
                          SizedBox(height: 7),
                          CustomTextField(
                            hintText: '',
                            controller: temperature,
                            width: screenWidth * 0.2,
                          ),
                          SizedBox(height: 4),
                          CustomText(
                            text: 'Ranges ',
                            size: screenWidth * 0.011,
                          ),
                          SizedBox(height: 1),
                          CustomText(
                            text: 'Babies and Children 95.9°F - 99.5°F',
                            size: screenWidth * 0.008,
                          ),
                          SizedBox(height: 1),
                          CustomText(
                            text:
                                'Average Normal Body Temeperature : 98.6°F (37°C)',
                            size: screenWidth * 0.008,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Blood Pressure ',
                            size: screenWidth * 0.013,
                          ),
                          SizedBox(height: 7),
                          CustomTextField(
                            hintText: '',
                            controller: bloodPressure,
                            width: screenWidth * 0.2,
                          ),
                          SizedBox(height: 4),
                          CustomText(
                            text: 'Ranges ',
                            size: screenWidth * 0.011,
                          ),
                          SizedBox(height: 1),
                          CustomText(
                            text: 'Around 120/180mg Hg',
                            size: screenWidth * 0.008,
                          ),
                          SizedBox(height: 1),
                          CustomText(
                            text: ' ',
                            size: screenWidth * 0.008,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Blood Sugar Level ',
                            size: screenWidth * 0.013,
                          ),
                          SizedBox(height: 7),
                          CustomTextField(
                            hintText: '',
                            controller: bloodSugarLevel,
                            width: screenWidth * 0.2,
                          ),
                          SizedBox(height: 4),
                          CustomText(
                            text: 'Ranges ',
                            size: screenWidth * 0.011,
                          ),
                          SizedBox(height: 1),
                          CustomText(
                            text: 'Before meals 80-130 mg/dl',
                            size: screenWidth * 0.008,
                          ),
                          SizedBox(height: 1),
                          CustomText(
                            text: 'After meals(1-2 hours later) 180 mg/dl',
                            size: screenWidth * 0.008,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Presenting Complaints ',
                            size: screenWidth * 0.013,
                          ),
                          SizedBox(height: 7),
                          CustomTextField(
                            hintText: '',
                            controller: otherComments,
                            width: screenWidth * 0.72,
                            verticalSize: screenHeight * 0.07,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            width: 1200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Payments',
                  color: AppColors.blue,
                  size: screenWidth * 0.025,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'OP Ticket Amount ',
                                size: screenWidth * 0.013,
                              ),
                              SizedBox(height: 7),
                              CustomTextField(
                                hintText: '',
                                controller: opTicketTotalAmount,
                                width: screenWidth * 0.2,
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
                              CustomTextField(
                                hintText: '',
                                controller: opTicketCollectedAmount,
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
                              CustomTextField(
                                hintText: '',
                                controller: opTicketBalance,
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
                                child: CustomDropdown(
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
                              CustomTextField(
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
          ),
          const SizedBox(
            height: 50,
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
                        final collectedAmountText =
                            opTicketCollectedAmount.text.trim();
                        final totalAmountText = opTicketTotalAmount.text.trim();

                        // Validate collected amount is not empty
                        if (collectedAmountText.isEmpty) {
                          CustomSnackBar(context,
                              message: 'Please enter the collected amount',
                              backgroundColor: Colors.orange);

                          return;
                        }

                        // Validate total amount is not empty (optional)
                        if (totalAmountText.isEmpty) {
                          CustomSnackBar(context,
                              message: 'Please enter the total amount',
                              backgroundColor: Colors.orange);

                          return;
                        }

                        // Parse and validate amount
                        final collectedAmount =
                            double.tryParse(collectedAmountText);
                        if (collectedAmount == null || collectedAmount < 0) {
                          CustomSnackBar(context,
                              message: 'Please enter a valid collected amount',
                              backgroundColor: Colors.orange);

                          return;
                        }
                        String? selectedPatientId =
                            selectedPatient?['opNumber'];
                        await initializeOpTicketID(selectedPatientId!);
                        print(selectedPatientId);
                        await incrementCounter();
                        await _generateToken(selectedPatientId);
                      },
                      width: 200,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
