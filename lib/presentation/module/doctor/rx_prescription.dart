import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxcare_lite/presentation/module/doctor/patient_history_dialog.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../utilities/constants.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../utilities/widgets/table/editable_drop_down_table.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'package:http/http.dart' as http;

import '../../login/fetch_user.dart';

class RxPrescription extends StatefulWidget {
  final String opTicket;
  final String patientID;
  final String doctorName;
  final String specialization;
  final String name;
  final String age;
  final String counter;
  final String date;
  final String city;
  final String tokenNo;
  final String place;
  final String address;
  final String pincode;
  final String primaryInfo;
  final String temperature;
  final String bloodPressure;
  final String sugarLevel;
  final String phone1;
  final String phone2;
  final String sex;
  final String bloodGroup;
  final String firstName;
  final String lastName;
  final String dob;

  const RxPrescription(
      {super.key,
      required this.patientID,
      required this.name,
      required this.age,
      required this.place,
      required this.address,
      required this.pincode,
      required this.primaryInfo,
      required this.temperature,
      required this.bloodPressure,
      required this.sugarLevel,
      required this.phone1,
      required this.phone2,
      required this.sex,
      required this.bloodGroup,
      required this.firstName,
      required this.lastName,
      required this.dob,
      required this.date,
      required this.doctorName,
      required this.opTicket,
      required this.specialization,
      required this.counter,
      required this.tokenNo,
      required this.city});

  @override
  State<RxPrescription> createState() => _RxPrescription();
}

class _RxPrescription extends State<RxPrescription> {
  final UserModel? currentUser = UserSession.currentUser;

  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _sugarLevelController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _diagnosisSignsController =
      TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _patientHistoryController =
      TextEditingController();

  final TextEditingController _appointmentTime = TextEditingController();
  final TextEditingController _appointmentDate = TextEditingController();
  bool _isLoading = false;
  int selectedIndex = 1;
  String? selectedValue;
  final List<String> _allItems = [
    'AFC',
    'BLOOD ROUTINE [R/E]',
    'TOTAL WBC COUNT [TC]',
    'DLC',
    'ESR',
    'CBC',
    'BT, CT',
    'MP SMEAR',
    'PVC',
    'RETICULOCYTE COUNT',
    'SICKLING TEST',
    'PT INR',
    'BLOOD GROUP',
    'ICT',
    'DCT',
    'ASO',
    'RA FACTOR',
    'CRP',
    'VDRL',
    'WIDAL SLIDE METHOD',
    'WIDAL TUBE METHOD',
    'BLOOD SUGAR',
    'GTT [5 SAMPLE]',
    'GTT [4 SAMPLE]',
    'GTT [3 SAMPLE]',
    'TRIGLYCERIDES',
    'GCT',
    'HDL',
    'LDL',
    'CHOLESTEROL-TOTAL',
    'UREA',
    'CREATININE',
    'URIC ACID',
    'CALCIUM',
    'PHOSPHOROUS',
    'LDH',
    'CPX',
    'CKMB',
    'AMYLASE',
    'LIPID PROFILE',
    'LFT',
    'SODIUM',
    'POTASSIUM',
    'CHLORIDE',
    'BILIRUBIN',
    'SGOT',
    'SGPT',
    'TOTAL PROTEINS',
    'RFT',
    'RFT [ELECTROLYTES]',
    'ALK 904',
    'GCT',
    'HBA1C',
    'TROPONIN',
    'URINE ROUTINE',
    'URINE SUGAR',
    'BS SP',
    'URINE MICROSCOPY',
    'KETONE BODIES',
    'ACETONES',
    'BENSE JONES PROTEIN',
    'URINE SPECIFIC GRAVITY',
    'URINE MICROALBUMIN',
    'URINE PREGNANCY TEST',
    'STOOL ROUTINE',
    'STOOL REDUCING SUBST',
    'OCCULT BLOOD',
    'STOOL MANAGING DROP',
    'HBSAG CARD',
    'HIV CARD',
    'HCV CARD',
    'DENQUE CARD',
    'LEPTOSPIRA CARD',
    'RAPID MALARIA CARD',
    'URINE C/S',
    'SPUTUM C/S',
    'STOOL C/S',
    'PUS C/S',
    'OTHER FLUIDS C/S',
    'T3',
    'T4',
    'TSH',
    'TFT [T3, T4 & TSH]',
    'FT3',
    'FT4',
    'VITAMIN D3',
    'B-HCG',
    'IGE',
    'DENTAL DIGITAL X-RAY',
    'ECG',
    'SEMEN ANALYSIS',
  ];
  List<String> _filteredItems = [];
  List<String> _selectedItems = [];
  String _searchQuery = '';
  String _searchMedicine = '';

  final dateTime = DateTime.timestamp();

  bool isLoading = false;

  bool isMedLoading = false;

  bool isMedWidget = false;
  bool isLabLoading = false;
  bool isInvestLoading = false;
  bool isAppointment = false;

  void toggleMed(bool value) {
    setState(() {
      isMedWidget = value;
    });
  }

  void toggleLab(bool value) {
    setState(() {
      isLabLoading = value;
    });
  }

  void toggleInvest(bool value) {
    setState(() {
      isInvestLoading = value;
    });
  }

  void toggleAppointment(bool value) {
    setState(() {
      isAppointment = value;
    });
  }

  bool _isSwitched = false;

  List<String> medicineNames = [];
  List<String> _filteredMedicine = [];
  List<String> _selectedMedicine = [];

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
  final List<String> labHeaders = [
    'Test',
    'Results',
    'Reference',
  ];
  List<Map<String, dynamic>> labTableData = [];

  @override
  void initState() {
    super.initState();
    initializeIpTicketID();
    loadPrescriptionDraft(widget.patientID);
    _filteredItems = _allItems;
    _filteredMedicine = medicineNames;
    fetchMedicine();
  }

  @override
  void dispose() {
    super.dispose();
    savePrescriptionDraft(widget.patientID);
    _temperatureController.dispose();
    _bloodPressureController.dispose();
    _sugarLevelController.dispose();
    _notesController.dispose();
    _diagnosisSignsController.dispose();
    _symptomsController.dispose();
  }

  Future<void> fetchMedicine() async {
    try {
      QuerySnapshot<Map<String, dynamic>> distributorsSnapshot =
          await FirebaseFirestore.instance
              .collection('stock')
              .doc('Products')
              .collection('AddedProducts')
              .get();

      List<String> validMedicines = [];

      for (var doc in distributorsSnapshot.docs) {
        Map<String, dynamic> data = doc.data();

        validMedicines.add(data['productName'].toString());
      }
      print(validMedicines);

      setState(() {
        medicineNames = validMedicines;
      });
    } catch (e) {
      print('Error fetching Medicine: $e');
    }
  }

  Future<String> generateUniqueIpTicketId() async {
    const chars = '0123456789';
    Random random = Random.secure();
    String ipTicketId = '';

    bool exists = true;
    while (exists) {
      String randomString =
          List.generate(6, (index) => chars[random.nextInt(chars.length)])
              .join();
      ipTicketId = 'IP$randomString';

      var docSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('ipTickets')
          .doc(ipTicketId)
          .get();

      exists = docSnapshot.exists;
    }

    return ipTicketId;
  }

  Future<void> initializeIpTicketID() async {
    ipTicketId = await generateUniqueIpTicketId();
    setState(() {});
  }

  String ipTicketId = '';

  Future<void> _onToggle(bool value) async {
    var firestore = FirebaseFirestore.instance;
    var docRef = firestore.collection('patients').doc(widget.patientID);

    setState(() {
      docRef.update({'isIP': true});
      docRef.collection('ipTickets').doc(ipTicketId).set({
        'ipTicket': ipTicketId,
        'doctorName': widget.doctorName,
        'specialization': widget.specialization,
        'discharged': false,
        'temperature': widget.temperature,
        'bloodPressure': widget.bloodPressure,
        'bloodSugarLevel': widget.sugarLevel,
        'otherComments': widget.primaryInfo,
        'status': 'waiting',
        'ipAdmitDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0')
      });
      _isSwitched = value;
    });

    if (_isSwitched) {
      CustomSnackBar(context,
          message: 'Patients Marked as IP',
          backgroundColor: AppColors.secondaryColor);
    }
  }

  void _updateSerialNumbers() {
    for (int i = 0; i < medicineTableData.length; i++) {
      medicineTableData[i]['SL No'] = i + 1;
    }
  }

  void _filterItems(
      String query, void Function(VoidCallback fn) localSetState) {
    localSetState(() {
      _searchQuery = query;
      _filteredItems = _allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void showPatientHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PatientHistoryDialog(
          firstName: widget.firstName,
          lastName: widget.lastName,
          sex: widget.sex,
          bloodGroup: widget.bloodGroup,
          phone1: widget.phone1,
          phone2: widget.phone2,
          dob: widget.dob,
          opNumber: widget.patientID,
          ipNumber: '',
        );
      },
    );
  }

  void printRx() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.description_outlined, color: Colors.teal, size: 28),
              SizedBox(width: 10),
              Text(
                'Rx Prescription',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.print_rounded, size: 48, color: Colors.teal),
                SizedBox(height: 16),
                CustomText(
                  text: 'Do you want to print?',

                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
                    pw.SizedBox(height: 6),
                  ];
                }

                pdf.addPage(
                  pw.MultiPage(
                    pageFormat: PdfPageFormat.a4,
                    header: (context) => pw.Column(
                      children: [
                        pw.Stack(
                          children: [
                            pw.Positioned.fill(
                              child: pw.Image(topImage,
                                  fit: pw.BoxFit.cover, width: 300, height: 50),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(
                                  left: 8, right: 8, top: 16),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 20),
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
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                        padding: const pw.EdgeInsets.only(left: 8, right: 8),
                        child: pw.Container(
                          child: pw.Column(
                            children: [
                              pw.SizedBox(height: 20),
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
                                        'Dr. ${widget.doctorName}',
                                        style: pw.TextStyle(
                                          fontSize: 28,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Text(
                                        '${currentUser!.degree}[General Medicine]',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Text(
                                        '${widget.specialization}',
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
                                            '0${widget.counter}',
                                            style: pw.TextStyle(
                                              fontSize: 36,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                          pw.Text(
                                            'Counter Number',
                                            style: pw.TextStyle(
                                              fontSize: 10,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pw.SizedBox(width: 10),
                                      pw.Column(
                                        children: [
                                          pw.Text(
                                            '${widget.tokenNo}',
                                            style: pw.TextStyle(
                                              fontSize: 36,
                                              font: ttf,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.black,
                                            ),
                                          ),
                                          pw.Text(
                                            'Token Number',
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
                                        'OP Ticket No : ${widget.opTicket}',
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
                                        'Name : ${widget.name}',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Text(
                                        'OP Number : ${widget.patientID}',
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
                                        'Age : ${widget.age}',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Text(
                                        'Blood Group : ${widget.bloodGroup}',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Text(
                                        'Place : ${widget.city}',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Text(
                                        'Phone : ${widget.phone1}',
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
                                        'BP : ${widget.bloodPressure}',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Text(
                                        'Temp : ${widget.temperature}',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Text(
                                        'Blood Sugar : ${widget.sugarLevel}',
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
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 8, right: 8),
                        child: pw.Container(
                          child: pw.Column(
                            children: [
                              pw.SizedBox(height: 20),
                              pw.Column(
                                mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'Signs ',
                                        style: pw.TextStyle(
                                          fontSize: 16,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.SizedBox(height: 6),
                                  pw.Row(
                                    mainAxisAlignment:
                                    pw.MainAxisAlignment.start,
                                    children: [
                                      pw.SizedBox(width: 40),
                                      pw.Text(
                                        '*${_diagnosisSignsController.text} ',
                                        style: pw.TextStyle(
                                          fontSize: 12,
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
                              pw.SizedBox(height: 20),
                              pw.Column(
                                mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'Symptoms ',
                                        style: pw.TextStyle(
                                          fontSize: 16,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.SizedBox(height: 6),
                                  pw.Row(
                                    mainAxisAlignment:
                                    pw.MainAxisAlignment.start,
                                    children: [
                                      pw.SizedBox(width: 40),
                                      pw.Text(
                                        '*${_symptomsController.text} ',
                                        style: pw.TextStyle(
                                          fontSize: 12,
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
                              pw.SizedBox(height: 20),
                              pw.Column(
                                mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'Lab Investigations ',
                                        style: pw.TextStyle(
                                          fontSize: 16,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: blue,
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
                        headers: labHeaders,
                        data: labTableData,
                        ttf: ttf,
                        headerColor: lightBlue,
                        rowHeight: 15,
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 8, right: 8),
                        child: pw.Container(
                          child: pw.Column(
                            children: [
                              pw.SizedBox(height: 20),
                              pw.Column(
                                mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'Medications ',
                                        style: pw.TextStyle(
                                          fontSize: 16,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: blue,
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
                        headers: medicineHeaders,
                        data: medicineTableData,
                        ttf: ttf,
                        headerColor: lightBlue,
                        rowHeight: 15,
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 8, right: 8),
                        child: pw.Container(
                          child: pw.Column(
                            children: [
                              pw.SizedBox(height: 20),
                              pw.Column(
                                mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'Investigations ',
                                        style: pw.TextStyle(
                                          fontSize: 16,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.SizedBox(height: 6),
                                  pw.Row(
                                    mainAxisAlignment:
                                    pw.MainAxisAlignment.start,
                                    children: [
                                      pw.SizedBox(width: 40),
                                      pw.Text(
                                        '*${_notesController.text} ',
                                        style: pw.TextStyle(
                                          fontSize: 12,
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
                              pw.SizedBox(height: 20),
                              pw.Column(
                                mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
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
                                              'Dr. ${widget.doctorName}',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              '${currentUser!.degree}[General Medicine]',
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                font: ttf,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                            pw.Text(
                                              '${widget.specialization}',
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
                //     filename: '${widget.opTicket}.pdf');
              },
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
  }


  Future<void> _prescribed() async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('opTickets')
          .doc(widget.opTicket)
          .set({'opTicketStatus': 'completed'}, SetOptions(merge: true));

      await clearPrescriptionDraft(widget.patientID);
      CustomSnackBar(context,
          message: 'OP Ticket : ${widget.opTicket} Ended ',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to save: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> _savePrescriptionData() async {
    try {
      final Map<String, dynamic> patientData = {
        'Medication': _selectedMedicine,
        'Examination': _selectedItems,
        'proceedTo': selectedValue,
        'prescribedMedicines': medicineTableData,
        'basicDiagnosis': {
          'temperature': _temperatureController.text,
          'bloodPressure': _bloodPressureController.text,
          'sugarLevel': _sugarLevelController.text,
        },
        'investigationTests': {
          'notes': _notesController.text,
          'diagnosisSigns': _diagnosisSignsController.text,
          'symptoms': _symptomsController.text,
          'patientHistory': _patientHistoryController.text,
        },
      };

      if (_selectedMedicine.isNotEmpty) {
        patientData['medicinePrescribedDate'] = dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0');
      }
      if (_selectedItems.isNotEmpty) {
        patientData['labExaminationPrescribedDate'] = dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0');
      }

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('opTickets')
          .doc(widget.opTicket)
          .set(patientData, SetOptions(merge: true));

      if (_appointmentDate.text.isNotEmpty &&
          _appointmentTime.text.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientID)
            .collection('appointments')
            .doc('appointment')
            .set({
          'appointmentDate': _appointmentDate.text,
          'appointmentTime': _appointmentTime.text,
        }, SetOptions(merge: true));
      }

      await clearPrescriptionDraft(widget.patientID);
      CustomSnackBar(context,
          message: 'Details saved successfully!',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to save: $e', backgroundColor: Colors.red);
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

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(
        DateTime(
            now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
      );
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  Future<void> savePrescriptionDraft(String opNumber) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> draftData = {
      'Medication': _selectedMedicine,
      'Examination': _selectedItems,
      'appointmentDate': _appointmentDate.text,
      'appointmentTime': _appointmentTime.text,
      'prescribedMedicines': medicineTableData,
      'prescribedLabTests': labTableData,
      'basicDiagnosis': {
        'temperature': _temperatureController.text,
        'bloodPressure': _bloodPressureController.text,
        'sugarLevel': _sugarLevelController.text,
      },
      'investigationTests': {
        'notes': _notesController.text,
        'diagnosisSigns': _diagnosisSignsController.text,
        'symptoms': _symptomsController.text,
        'patientHistory': _patientHistoryController.text,
      },
    };

    await prefs.setString('rxDraft_$opNumber', jsonEncode(draftData));
  }

  Future<void> loadPrescriptionDraft(String opNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('rxDraft_$opNumber');

    if (jsonData != null) {
      final data = jsonDecode(jsonData);

      setState(() {
        _selectedMedicine = List<String>.from(data['Medication'] ?? []);
        _selectedItems = List<String>.from(data['Examination'] ?? []);
        _appointmentDate.text = data['appointmentDate'] ?? '';
        _appointmentTime.text = data['appointmentTime'] ?? '';
        medicineTableData =
            List<Map<String, dynamic>>.from(data['prescribedMedicines'] ?? []);
        labTableData =
            List<Map<String, dynamic>>.from(data['prescribedLabTests'] ?? []);

        final basic = data['basicDiagnosis'] ?? {};
        _temperatureController.text = basic['temperature'] ?? '';
        _bloodPressureController.text = basic['bloodPressure'] ?? '';
        _sugarLevelController.text = basic['sugarLevel'] ?? '';

        final investigation = data['investigationTests'] ?? {};
        _notesController.text = investigation['notes'] ?? '';
        _diagnosisSignsController.text = investigation['diagnosisSigns'] ?? '';
        _symptomsController.text = investigation['symptoms'] ?? '';
        _patientHistoryController.text = investigation['patientHistory'] ?? '';
      });
    }
  }

  Future<void> clearPrescriptionDraft(String opNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rxDraft_$opNumber');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Center(
            child: CustomText(
          text: "RX Prescription",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        backgroundColor: AppColors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.10,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'RX',
                        size: screenWidth * .05,
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          CustomText(
                            text: '0${widget.counter}',
                            size: screenWidth * .04,
                          ),
                          CustomText(
                            text: 'Counter Number',
                            size: screenWidth * .01,
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Column(
                        children: [
                          CustomText(
                            text: '${widget.tokenNo}',
                            size: screenWidth * .04,
                          ),
                          CustomText(
                            text: 'Token Number',
                            size: screenWidth * .01,
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.06,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        image: const DecorationImage(
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                children: [
                  CustomText(
                    text: 'OP Ticket No : ${widget.opTicket}',
                    size: screenWidth * 0.012,
                  ),
                  SizedBox(width: screenWidth * 0.515),
                  CustomText(text: 'OP Number'),
                  SizedBox(width: screenWidth * 0.01),
                  Switch(
                    inactiveThumbColor: AppColors.lightBlue,
                    activeColor: AppColors.blue,
                    value: _isSwitched,
                    onChanged: (bool value) async {
                      final shouldToggle = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            backgroundColor: Colors.white,
                            title: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange, size: 28),
                                const SizedBox(width: 10),
                                Text(
                                  'Please Confirm',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            content: Text(
                              'This action cannot be undone. Are you sure you want to proceed?',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton.icon(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                label: const Text('Cancel'),
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              ElevatedButton.icon(
                                icon: Icon(Icons.check_circle,
                                    color: Colors.white),
                                label: const Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldToggle == true) {
                        _onToggle(value);
                      }
                    },
                  ),

                  /*
                  Switch(
                    inactiveThumbColor: AppColors.lightBlue,
                    activeColor: AppColors.blue,
                    value: _isSwitched,
                    onChanged: (bool value) {
                      _onToggle(value);
                    },
                  ),
                  */
                  SizedBox(width: screenWidth * 0.01),
                  CustomText(text: 'IP Number'),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Name : ${widget.name}',
                    size: screenWidth * 0.012,
                  ),
                  CustomText(
                    text: 'OP No : ${widget.patientID}',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Age : ${widget.age}',
                    size: screenWidth * 0.012,
                  ),
                  CustomText(
                    text: 'Blood Group : ${widget.bloodGroup}',
                    size: screenWidth * 0.012,
                  ),
                  CustomText(
                    text: 'Place : ${widget.city}',
                    size: screenWidth * 0.012,
                  ),
                  CustomText(
                    text: 'Phone : ${widget.phone1}',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Address : ${widget.address}',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.035),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Basic Diagnosis',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomText(
                    text: 'BP : ${widget.bloodPressure}',
                    size: screenWidth * 0.012,
                  ),
                  CustomText(
                    text: 'Temp : ${widget.temperature}',
                    size: screenWidth * 0.012,
                  ),
                  CustomText(
                    text: 'Blood Sugar : ${widget.sugarLevel}',
                    size: screenWidth * 0.012,
                  ),
                  CustomButton(
                    label: 'Patient History',
                    onPressed: () {
                      showPatientHistoryDialog(context);
                    },
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.05,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.035),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Basic Info',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Row(
                children: [
                  SizedBox(width: screenWidth * 0.05),
                  CustomText(
                    text: ''
                        '* ${widget.primaryInfo}',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.035),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Signs & Symptoms',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              CustomTextField(
                controller: _diagnosisSignsController,
                hintText: '',
                width: screenWidth * 0.85,
                verticalSize: screenWidth * 0.03,
              ),
              SizedBox(height: screenHeight * 0.035),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Findings',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              CustomTextField(
                controller: _symptomsController,
                hintText: '',
                width: screenWidth * 0.85,
                verticalSize: screenWidth * 0.03,
              ),
              SizedBox(height: screenHeight * 0.035),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: 'Treatments',
                        size: screenWidth * 0.022,
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth * 0.11,
                    child: Divider(
                      color: AppColors.blue,
                      thickness: 2,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  if (isLabLoading)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: 'Laboratory',
                              size: screenWidth * 0.016,
                              color: AppColors.blue,
                            ),
                            IconButton(
                              onPressed: () {
                                toggleLab(false);
                                setState(() {
                                  labTableData = [];
                                  _selectedItems = [];
                                });
                              },
                              icon: Icon(Icons.close),
                              color: Colors.red,
                            )
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: CustomText(
                                        text: 'Add Tests',
                                        size: screenWidth * 0.013,
                                      ),
                                      content: SizedBox(
                                        width: screenWidth * 0.5,
                                        height: screenHeight * 0.8,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Wrap(
                                                spacing: 8.0,
                                                runSpacing: 4.0,
                                                children: _selectedItems
                                                    .map((item) => Chip(
                                                          shadowColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              AppColors
                                                                  .secondaryColor,
                                                          label: CustomText(
                                                            text: item,
                                                            color: Colors.white,
                                                          ),
                                                          deleteIcon:
                                                              const Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                          ),
                                                          onDeleted: () {
                                                            setState(() {
                                                              labTableData
                                                                  .removeWhere(
                                                                      (row) =>
                                                                          row['Test'] ==
                                                                          item);
                                                              _selectedItems
                                                                  .remove(item);
                                                            });
                                                          },
                                                        ))
                                                    .toList(),
                                              ),
                                              const SizedBox(height: 20),
                                              CustomTextField(
                                                onChanged: (value) =>
                                                    _filterItems(
                                                        value, setState),
                                                hintText: 'Search Tests',
                                                width: screenWidth * 0.8,
                                                verticalSize:
                                                    screenHeight * 0.03,
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                height: screenHeight * 0.7,
                                                child: ListView.builder(
                                                  itemCount:
                                                      _filteredItems.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final item =
                                                        _filteredItems[index];
                                                    return ListTile(
                                                      title: Text(item),
                                                      onTap: () {
                                                        if (!_selectedItems
                                                            .contains(item)) {
                                                          setState(() {
                                                            _selectedItems
                                                                .add(item);
                                                            labTableData.add({
                                                              'Test': item,
                                                              'Results': '',
                                                              'Reference': '',
                                                            });
                                                          });
                                                        }
                                                        print(
                                                            'Selected: $item');
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ).then((_) =>
                                setState(() {})); // Refresh after dialog closes
                          },
                          child: Container(
                            width: screenWidth * 0.85,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: screenWidth * 0.0015,
                                color: AppColors.blue,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _selectedItems.isEmpty
                                ? const Text("Tap to add tests",
                                    style: TextStyle(color: Colors.grey))
                                : Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: _selectedItems
                                        .map((item) => Chip(
                                              label: Text(item),
                                              backgroundColor:
                                                  AppColors.secondaryColor,
                                              labelStyle: const TextStyle(
                                                  color: Colors.white),
                                            ))
                                        .toList(),
                                  ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.035),
                      ],
                    ),
                  if (isMedWidget)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: 'Medicine',
                              size: screenWidth * 0.016,
                              color: AppColors.blue,
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    toggleMed(false);
                                    medicineTableData = [];
                                    _selectedMedicine = [];
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ))
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        GestureDetector(
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return AlertDialog(
                                      title: CustomText(
                                        text: 'Add Medicines',
                                        size: screenWidth * 0.013,
                                      ),
                                      content: SizedBox(
                                        width: screenWidth * 0.5,
                                        height: screenHeight * 0.8,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Wrap(
                                                spacing: 8.0,
                                                runSpacing: 4.0,
                                                children: _selectedMedicine
                                                    .map((item) => Chip(
                                                          shadowColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              AppColors
                                                                  .secondaryColor,
                                                          label: CustomText(
                                                              text: item,
                                                              color:
                                                                  Colors.white),
                                                          deleteIcon:
                                                              const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white),
                                                          onDeleted: () {
                                                            setStateDialog(() {
                                                              _selectedMedicine
                                                                  .remove(item);
                                                              medicineTableData
                                                                  .removeWhere(
                                                                      (row) =>
                                                                          row['Medicine Name'] ==
                                                                          item);
                                                              _updateSerialNumbers();
                                                            });
                                                          },
                                                        ))
                                                    .toList(),
                                              ),
                                              const SizedBox(height: 10),
                                              CustomTextField(
                                                onChanged: (query) {
                                                  setStateDialog(() {
                                                    if (query.isEmpty) {
                                                      _filteredMedicine =
                                                          List.from(
                                                              medicineNames);
                                                    } else {
                                                      _filteredMedicine = medicineNames
                                                          .where((item) => item
                                                              .toLowerCase()
                                                              .contains(query
                                                                  .toLowerCase()))
                                                          .toList();
                                                    }
                                                  });
                                                },
                                                hintText: 'Search Medicine',
                                                width: screenWidth * 0.8,
                                                verticalSize:
                                                    screenHeight * 0.03,
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                height: screenHeight * 0.2,
                                                child: ListView.builder(
                                                  itemCount:
                                                      _filteredMedicine.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final item =
                                                        _filteredMedicine[
                                                            index];
                                                    return ListTile(
                                                      title: Text(item),
                                                      onTap: () async {
                                                        if (!_selectedMedicine
                                                            .contains(item)) {
                                                          setStateDialog(() {
                                                            _selectedMedicine
                                                                .add(item);
                                                            isLoading = true;
                                                            isMedLoading = true;
                                                          });

                                                          await Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      250));

                                                          setStateDialog(() {
                                                            medicineTableData
                                                                .add({
                                                              'SL No':
                                                                  medicineTableData
                                                                          .length +
                                                                      1,
                                                              'Medicine Name':
                                                                  item,
                                                              'Morning': '',
                                                              'Afternoon': '',
                                                              'Evening': '',
                                                              'Night': '',
                                                              'Duration': '',
                                                            });
                                                            isLoading = false;
                                                            isMedLoading =
                                                                false;
                                                          });
                                                        }
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              if (medicineTableData.isNotEmpty)
                                                isLoading
                                                    ? const CircularProgressIndicator()
                                                    : EditableDropDownTable(
                                                        headerColor:
                                                            Colors.white,
                                                        headerBackgroundColor:
                                                            AppColors.blue,
                                                        editableColumns: const [
                                                          'Morning',
                                                          'Afternoon',
                                                          'Evening',
                                                          'Night',
                                                          'Duration'
                                                        ],
                                                        dropdownValues: const {
                                                          'Morning': [
                                                            '0.5 ml',
                                                            '1 ml',
                                                            '1.5 ml',
                                                            '2 ml',
                                                            'ing',
                                                          ],
                                                          'Afternoon': [
                                                            '0.5 ml',
                                                            '1 ml',
                                                            '1.5 ml',
                                                            '2 ml',
                                                            'ing',
                                                          ],
                                                          'Evening': [
                                                            '0.5 ml',
                                                            '1 ml',
                                                            '1.5 ml',
                                                            '2 ml',
                                                            'ing',
                                                          ],
                                                          'Night': [
                                                            '0.5 ml',
                                                            '1 ml',
                                                            '1.5 ml',
                                                            '2 ml',
                                                            'ing',
                                                          ],
                                                        },
                                                        onValueChanged:
                                                            (rowIndex, header,
                                                                value) async {
                                                          if (rowIndex <
                                                              medicineTableData
                                                                  .length) {
                                                            setStateDialog(() {
                                                              medicineTableData[
                                                                      rowIndex][
                                                                  header] = value;
                                                            });
                                                          }
                                                        },
                                                        headers:
                                                            medicineHeaders,
                                                        tableData:
                                                            medicineTableData,
                                                      )
                                              else
                                                const Text(
                                                    "Invalid or incomplete medicine data"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );

                            setState(
                                () {}); // Refresh outer table after dialog closes
                          },
                          child: isMedLoading
                              ? const CircularProgressIndicator()
                              : CustomDataTable(
                                  headers: medicineHeaders,
                                  tableData: medicineTableData,
                                ),
                        ),
                        SizedBox(height: screenHeight * 0.035),
                      ],
                    ),
                  if (isInvestLoading)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: 'Investigations',
                              size: screenWidth * 0.02,
                              color: AppColors.blue,
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  toggleInvest(false);
                                  _notesController.clear();
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        CustomTextField(
                          controller: _notesController,
                          hintText: '',
                          width: screenWidth * 0.85,
                          verticalSize: screenWidth * 0.03,
                        ),
                        SizedBox(height: screenHeight * 0.035),
                      ],
                    ),
                  if (isAppointment)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              label: 'Choose Next Appointment Date and Time',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: CustomText(
                                            text: 'Choose Next Appointment',
                                            size: screenWidth * 0.013,
                                          ),
                                          content: SizedBox(
                                            width: screenWidth * 0.3,
                                            height: screenHeight * 0.2,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.1),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomTextField(
                                                        onTap: () => _selectDate(
                                                            context,
                                                            _appointmentDate),
                                                        hintText:
                                                            'Select Date ',
                                                        width:
                                                            screenWidth * 0.1,
                                                        controller:
                                                            _appointmentDate,
                                                        icon: const Icon(Icons
                                                            .date_range_outlined),
                                                      ),
                                                      CustomTextField(
                                                        onTap: () => _selectTime(
                                                            context,
                                                            _appointmentTime),
                                                        hintText:
                                                            'Select Time ',
                                                        width:
                                                            screenWidth * 0.1,
                                                        controller:
                                                            _appointmentTime,
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
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: CustomText(
                                                text: 'OK',
                                                color: AppColors.blue,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _appointmentDate.clear();
                                                _appointmentTime.clear();
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
                              width: screenWidth * 0.2,
                              height: screenHeight * 0.05,
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  toggleAppointment(false);
                                  _appointmentDate.clear();
                                  _appointmentTime.clear();
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.035),
                      ],
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpandableFAB(
                        toggleMed,
                        toggleLab,
                        toggleInvest,
                        toggleAppointment,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.035),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 300,
                      child:CustomButton(
                        label: 'Process',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 300),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                                      SizedBox(height: 16),
                                      Text(
                                        'Confirm Action',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Are you sure you want to process this prescription?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                      ),
                                      SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.grey[700],
                                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            ),
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text('Cancel', style: TextStyle(fontSize: 16)),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: Text('Confirm', style: TextStyle(fontSize: 16, color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );


                          if (confirmed == true) {
                            await _savePrescriptionData();
                            await clearPrescriptionDraft(widget.patientID);
                          }
                        },
                        width: screenWidth * 0.5,
                      ),


                    ),
                    SizedBox(
                      width: 300,
                      child: CustomButton(
                        label: 'Print',
                        onPressed: () {
                          printRx();
                        },
                        width: screenWidth * 0.5,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: _isLoading
                          ? Center(
                              child: Lottie.asset(
                                'assets/button_loading.json',
                                // Make sure this file exists
                                width: 100,
                                height: 100,
                              ),
                            )
                          : CustomButton(
                              label: 'Prescribed',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      title: Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded,
                                              color: Colors.orange),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'Please Confirm',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      content: const Text(
                                        'This action cannot be undone. Are you sure you want to proceed?',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      actions: [
                                        TextButton.icon(
                                          icon: Icon(Icons.cancel,
                                              color: Colors.red),
                                          label: const Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.check,
                                              color: Colors.white),
                                          label: const Text(
                                            'Proceed',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  await _prescribed(); // Your async function

                                  setState(() {
                                    _isLoading = false;
                                  });
                                  CustomSnackBar(context,
                                      backgroundColor: Colors.green,
                                      message:
                                          'Prescription submitted successfully');
                                }
                              },
                              width: screenWidth * 0.5,
                            ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final TextEditingController _controller = TextEditingController();
          final ScrollController _scrollController = ScrollController();

          List<ChatMessage> _messages = [
            ChatMessage(
              text:
                  "👋 Hello! I'm your FoxCare assistant.\nHow can I help you today?",
              isUser: false,
            )
          ];
          bool _isLoading = false;

          void _scrollToBottom() {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }

          showDialog(
            context: context,
            barrierColor: Colors.black54,
            builder: (context) {
              return Align(
                alignment: Alignment.bottomRight,
                child: FractionallySizedBox(
                  widthFactor: 0.3,
                  heightFactor: 0.9,
                  child: Material(
                    color: Colors.white,
                    elevation: 12,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          children: [
                            // Header
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.lightBlue, AppColors.blue],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.chat_bubble, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    "FoxCare Assistant",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon:
                                        Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),

                            // Chat Body
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount:
                                      _messages.length + (_isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (_isLoading &&
                                        index == _messages.length) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Lottie.asset(
                                            'assets/ai_bot_loading.json',
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                      );
                                    }

                                    final msg = _messages[index];
                                    final isUser = msg.isUser;

                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: isUser
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (!isUser)
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.white,
                                              backgroundImage: AssetImage(
                                                  'assets/fox_doc.png'),
                                            ),
                                          if (!isUser) SizedBox(width: 8),

                                          // Message bubble
                                          Flexible(
                                            child: Container(
                                              padding: EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isUser
                                                      ? [
                                                          Colors.blueAccent,
                                                          Colors.lightBlueAccent
                                                        ]
                                                      : [
                                                          Colors.grey.shade200,
                                                          Colors.grey.shade300
                                                        ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                  bottomLeft: Radius.circular(
                                                      isUser
                                                          ? 16
                                                          : 0), // tail design
                                                  bottomRight: Radius.circular(
                                                      isUser
                                                          ? 0
                                                          : 16), // tail design
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                msg.text,
                                                style: TextStyle(
                                                  color: isUser
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontSize: 15.5,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ),

                                          if (isUser) SizedBox(width: 8),
                                          if (isUser)
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor:
                                                  Colors.blueAccent,
                                              child: Icon(Icons.person,
                                                  color: Colors.white),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Input
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(
                                        hintText: "Type your message...",
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onSubmitted: (userMessage) async {
                                        userMessage = userMessage.trim();
                                        if (userMessage.isEmpty) return;

                                        setState(() {
                                          _messages.add(ChatMessage(
                                              text: userMessage, isUser: true));
                                          _isLoading = true;
                                        });
                                        _scrollToBottom();
                                        _controller.clear();

                                        try {
                                          final response = await http.post(
                                            Uri.parse(
                                                'https://chatbot-api-3ixb.onrender.com/analyze-plant'),
                                            headers: {
                                              'Content-Type': 'application/json'
                                            },
                                            body: jsonEncode(
                                                {'user_input': userMessage}),
                                          );

                                          if (response.statusCode == 200) {
                                            final data =
                                                jsonDecode(response.body);
                                            String botReply = data[
                                                    'response'] ??
                                                "I'm sorry, I didn't understand that.";

                                            setState(() {
                                              _messages.add(ChatMessage(
                                                  text: botReply,
                                                  isUser: false));
                                              _isLoading = false;
                                            });
                                          } else {
                                            setState(() {
                                              _messages.add(ChatMessage(
                                                  text: "Bot is sleeping 😴",
                                                  isUser: false));
                                              _isLoading = false;
                                            });
                                          }
                                        } catch (e) {
                                          setState(() {
                                            _messages.add(ChatMessage(
                                                text:
                                                    "Error: Unable to get a response",
                                                isUser: false));
                                            _isLoading = false;
                                          });
                                        }
                                        _scrollToBottom();
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      String userMessage =
                                          _controller.text.trim();
                                      if (userMessage.isEmpty) return;

                                      setState(() {
                                        _messages.add(ChatMessage(
                                            text: userMessage, isUser: true));
                                        _isLoading = true;
                                      });
                                      _scrollToBottom();
                                      _controller.clear();

                                      try {
                                        final response = await http.post(
                                          Uri.parse(
                                              'https://chatbot-api-3ixb.onrender.com/analyze-plant'),
                                          headers: {
                                            'Content-Type': 'application/json'
                                          },
                                          body: jsonEncode(
                                              {'user_input': userMessage}),
                                        );

                                        if (response.statusCode == 200) {
                                          final data =
                                              jsonDecode(response.body);
                                          String botReply = data['response'] ??
                                              "I'm sorry, I didn't understand that.";

                                          setState(() {
                                            _messages.add(ChatMessage(
                                                text: botReply, isUser: false));
                                            _isLoading = false;
                                          });
                                        } else {
                                          setState(() {
                                            _messages.add(ChatMessage(
                                                text: "Bot is sleeping 😴",
                                                isUser: false));
                                            _isLoading = false;
                                          });
                                        }
                                      } catch (e) {
                                        setState(() {
                                          _messages.add(ChatMessage(
                                              text:
                                                  "Error: Unable to get a response",
                                              isUser: false));
                                          _isLoading = false;
                                        });
                                      }
                                      _scrollToBottom();
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.lightBlue,
                                            AppColors.blue
                                          ],
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.topRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        hoverElevation: 0,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/fox_doc.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _showBotSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Align(
          alignment: Alignment.bottomRight,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: ChatBotWidget(scrollController: controller),
          ),
        ),
      ),
    );
  }
}

class ExpandableFAB extends StatefulWidget {
  final Function(bool) toggleMedLoading;
  final Function(bool) toggleLabLoading;
  final Function(bool) toggleInvestLoading;
  final Function(bool) toggleAppointment;

  ExpandableFAB(this.toggleMedLoading, this.toggleLabLoading,
      this.toggleInvestLoading, this.toggleAppointment);

  @override
  _ExpandableFABState createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB> {
  bool isExpanded = false;

  void toggleFAB() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isExpanded)
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              FloatingActionButton(
                backgroundColor: AppColors.blue,
                heroTag: 'fab1',
                mini: true,
                onPressed: () {
                  widget.toggleLabLoading(true);
                },
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
              FloatingActionButton(
                backgroundColor: AppColors.blue,
                heroTag: 'fab2',
                mini: true,
                onPressed: () {
                  widget.toggleMedLoading(true);
                },
                child: Icon(
                  Icons.medical_information,
                  color: Colors.white,
                ),
              ),
              FloatingActionButton(
                backgroundColor: AppColors.blue,
                heroTag: 'fab3',
                mini: true,
                onPressed: () {
                  widget.toggleInvestLoading(true);
                },
                child: Icon(
                  Icons.child_care,
                  color: Colors.white,
                ),
              ),
              FloatingActionButton(
                backgroundColor: AppColors.blue,
                heroTag: 'fab4',
                mini: true,
                onPressed: () {
                  widget.toggleAppointment(true);
                },
                child: Icon(
                  Icons.meeting_room,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        SizedBox(height: spacing),
        GestureDetector(
          onTap: toggleFAB,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(25),
            padding: EdgeInsets.all(5),
            color: Colors.blue,
            strokeWidth: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              child: Container(
                height: screenHeight * 0.05,
                width: screenWidth * 0.027,
                color: Colors.blue,
                child: Center(
                    child: Icon(
                  Icons.add_outlined,
                  color: Colors.white,
                  size: screenWidth * 0.02,
                )),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChatBotWidget extends StatefulWidget {
  final ScrollController scrollController;

  const ChatBotWidget({Key? key, required this.scrollController})
      : super(key: key);

  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  Future<void> _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('https://chatbot-api-3ixb.onrender.com/analyze-plant'),
        // Replace with your API
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_input': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Safely accessing the 'reply' field
        String botReply = data['response'] ??
            "I'm sorry, I didn't understand that."; // Default reply if null

        setState(() {
          _messages.add(ChatMessage(text: botReply, isUser: false));
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(text: "Bot is sleeping 😴", isUser: false));
        });
      }
    } catch (e) {
      // Handle error if the API call fails
      setState(() {
        _messages.add(ChatMessage(
            text: "Error: Unable to get a response", isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            child: Text("FoxCare Assistant",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[_messages.length - 1 - index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.text,
                        style: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask your health query...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
