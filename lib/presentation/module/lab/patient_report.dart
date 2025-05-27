import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../utilities/constants.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../login/fetch_user.dart';

class PatientReport extends StatefulWidget {
  final String patientID;
  final String name;
  final String age;
  final String sex;
  final String dob;
  final String opTicket;
  final String doctorName;
  final String specialization;
  final String bloodGroup;
  final String phoneNo;
  final String city;
  final String place;
  final String address;
  final String pincode;
  final String primaryInfo;
  final String temperature;
  final String bloodPressure;
  final String sampleDate;

  final String sugarLevel;
  final List<dynamic> medication;

  const PatientReport(
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
      required this.sex,
      required this.medication,
      required this.dob,
      required this.opTicket,
      required this.sampleDate,
      required this.doctorName,
      required this.specialization,
      required this.bloodGroup,
      required this.phoneNo,
      required this.city});

  @override
  State<PatientReport> createState() => _PatientReport();
}

class _PatientReport extends State<PatientReport> {
  final dateTime = DateTime.now();
  final UserModel? currentUser = UserSession.currentUser;

  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();

  TextEditingController _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final TextEditingController _sampleCollectedDateController =
      TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  String reportNO = '';
  int newReportNo = 0;
  final List<String> headers1 = [
    'Test Descriptions',
    'Values',
    'Unit',
    'Reference Range',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  String? selectedPaymentMode;

  String? selectedValue;

  final Map<String, Map<String, String>> testMetadata = {
    'AFC': {
      'Unit': '12',
      'Reference Range': 'AFC	12	Fertility and Sterility. 2006;85(4): 917-922.',
    },
    'Hemoglobin': {
      'Unit': '7.1 g/dl',
      'Reference Range': 'Hemoglobin	7.1 g/dl	14.0-18.0',
    },
    'White blood cell': {
      'Unit': '2.8x10^3/mm^3',
      'Reference Range': '4.0-10.8',
    },
    'DLC': {
      'Unit': '%',
      'Reference Range': '40 – 75 %',
    },
    'Reticulocyte': {
      'Unit': '0.6%',
      'Reference Range': '0.8-2.1',
    },
    'ESR': {
      'Unit': 'mm/hr',
      'Reference Range': '0 – 15 mm/hr',
    },
    'CBC': {
      'Unit': 'g/dL',
      'Reference Range': 'Male: 13.0 – 17.0',
    },
    'BT': {
      'Unit': 'Minutes',
      'Reference Range': '2 – 7 minutes',
    },
    'CT': {
      'Unit': 'Minutes',
      'Reference Range': '4 – 8 minutes',
    },
    'MP SMEAR': {
      'Unit': 'Presence / Absence',
      'Reference Range': 'Positive or Negative',
    },
    'PVC': {
      'Unit': '%',
      'Reference Range': '40 - 50 %',
    },
    'SICKLING TEST': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive / Negative',
    },
    'PT INR': {
      'Unit': 'PT',
      'Reference Range': '11 – 13.5 seconds',
    },
    'Bloog group': {
      'Unit': 'None',
      'Reference Range': 'A, B, AB, O',
    },
    'ICT': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive / Negative',
    },
    'DCT': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive / Negative',
    },
    'ASO': {
      'Unit': 'IU/ml',
      'Reference Range': 'ASO	IU/ml	Adults:<200 IU/mL',
    },
    'RA FACTOR': {
      'Unit': 'IU/ml',
      'Reference Range': 'RA FACTOR	IU/ml	Normal:<14 IU/mL',
    },
    'CRP': {
      'Unit': 'Mg/L',
      'Reference Range': 'Normal:<5 mg/L',
    },
    'VDRL': {
      'Unit': 'Reactive',
      'Reference Range': 'Normal(Negative):Non-reactive',
    },
    'WIDAL SLIDE METHOD': {
      'Unit': 'Dilution ratios(1.40,1.80)',
      'Reference Range': 'Qualitative',
    },
    'WIDAL TUBE METHOD': {
      'Unit': '1:40,1:80',
      'Reference Range': '< 1:80',
    },
    'Blood Sugar': {
      'Unit': '	mg/dL (milligrams per deciliter)',
      'Reference Range': '70 – 99 mg/dL (normal)',
    },
    'GTT [5 SAMPLE]': {
      'Unit': 'mg/dL (milligrams per deciliter)',
      'Reference Range': '70 – 99 mg/dL',
    },
    'GTT [4 SAMPLE]': {
      'Unit': 'mg/dL (milligrams per deciliter)',
      'Reference Range': '70 – 99 mg/dL',
    },
    'GTT [3 SAMPLE]': {
      'Unit': 'mg/dL (milligrams per deciliter)',
      'Reference Range': '70 – 99 mg/dL',
    },
    'Triglycerides': {
      'Unit': 'mg/dL',
      'Reference Range': '< 150 mg/dL (Normal)',
    },
    'GCT (50g glucose, 1-hr)': {
      'Unit': 'mg/dL',
      'Reference Range': '< 140 mg/dL (Normal)',
    },
    'HDL (High-Density Lipoprotein – "Good Cholesterol")': {
      'Unit': 'mg/dL',
      'Reference Range': 'Men: > 40 mg/dL',
    },
    'LDL (Low-Density Lipoprotein – "Bad Cholesterol")': {
      'Unit': 'mg/dL',
      'Reference Range': '< 100 mg/dL (optimal)',
    },
    'CHOLESTEROL-TOTAL': {
      'Unit': 'mg/dL',
      'Reference Range': '< 200 mg/dL (Desirable)',
    },
    'UREA (Blood Urea / BUN)': {
      'Unit': 'mg/dL',
      'Reference Range': '15 – 40 mg/dL',
    },
    'CREATININE': {
      'Unit': 'mg/dL',
      'Reference Range': '0.6 – 1.2 mg/dL (Adults)',
    },
    'URIC ACID': {
      'Unit': 'mg/dL',
      'Reference Range': 'Women: 2.4 – 6.0 mg/dL',
    },
    'CALCIUM': {
      'Unit': 'mg/dL',
      'Reference Range': '8.5 – 10.5 mg/dL',
    },
    'PHOSPHOROUS (Serum Phosphate)': {
      'Unit': 'mg/dL',
      'Reference Range': '2.5 – 4.5 mg/dL',
    },
    'LDH (Lactate Dehydrogenase)': {
      'Unit': 'U/L (units per liter)',
      'Reference Range': '100 – 190 U/L (varies by lab)',
    },
    'CPX (Creatine Phosphokinase / Creatine Kinase, Total)': {
      'Unit': 'U/L',
      'Reference Range': '20 – 200 U/L (varies by lab)',
    },
    'CK-MB (Creatine Kinase – MB Isoenzyme)': {
      'Unit': 'ng/mL or U/L',
      'Reference Range': '0 – 5 ng/mL (or < 25 U/L)',
    },
    'AMYLASE': {
      'Unit': 'U/L',
      'Reference Range': '30 – 110 U/L (varies by lab)',
    },
    'LIPID PROFILE': {
      'Unit': 'mg/dL',
      'Reference Range': '< 200 mg/dL (Desirable)',
    },
    'LFT (Liver Function Test)': {
      'Unit': 'U/L',
      'Reference Range': '7 – 56 U/L',
    },
    'SODIUM': {
      'Unit': 'mEq/L or mmol/L',
      'Reference Range': '135 – 145 mEq/L',
    },
    'POTASSIUM': {
      'Unit': 'mEq/L or mmol/L',
      'Reference Range': '3.5 – 5.0 mEq/L',
    },
    'CHLORIDE': {
      'Unit': 'mEq/L or mmol/L',
      'Reference Range': '98 – 107 mEq/L',
    },
    'BILIRUBIN': {
      'Unit': 'mg/dL',
      'Reference Range': '0.1 – 1.2 mg/dL',
    },
    'SGOT (AST - Aspartate Aminotransferase)': {
      'Unit': 'U/L',
      'Reference Range': '10 – 40 U/L',
    },
    'SGPT (ALT - Alanine Aminotransferase)': {
      'Unit': 'U/L',
      'Reference Range': '7 – 56 U/L',
    },
    'TOTAL PROTEINS': {
      'Unit': 'g/dL',
      'Reference Range': '6.0 – 8.3 g/dL',
    },
    'RFT (Renal Function Test)': {
      'Unit': 'mg/dL',
      'Reference Range': '0.6 – 1.2 mg/dL',
    },
    'RFT [ELECTROLYTES]': {
      'Unit': 'mEq/L or mmol/L',
      'Reference Range': '135 – 145 mEq/L',
    },
    'ALK 904': {
      'Unit': 'U/L',
      'Reference Range': '44 – 147 U/L',
    },
    'GCT (Glucose Challenge Test)': {
      'Unit': 'mg/dL',
      'Reference Range': '< 140 mg/dL (1 hour post 50g glucose load)',
    },
    'HbA1c (Glycated Hemoglobin)': {
      'Unit': '%',
      'Reference Range': '	< 5.7% (Normal)'
    },
    'TROPONIN': {'Unit': 'ng/mL', 'Reference Range': '< 0.04 ng/mL (normal)'},
    'URINE ROUTINE': {
      'Unit': '/HPF (high power field)',
      'Reference Range': '0 – 3/HPF'
    },
    'URINE SUGAR': {'Unit': 'mg/mL', 'Reference Range': 'Negative (0 mg/dL)'},
    'BS SP (Blood Sugar - Spot)': {
      'Unit': 'mg/mL',
      'Reference Range': '70 – 140 mg/dL (varies by timing)'
    },
    'URINE MICROSCOPY': {
      'Unit': '/HPF (high power field)',
      'Reference Range': '0 – 3 /HPF'
    },
    'ACETONES': {'Unit': 'mg/dL', 'Reference Range': 'Negative'},
    'BENCE JONES PROTEIN': {
      'Unit': 'mg/dL or qualitative',
      'Reference Range': 'Negative/Not detected'
    },
    'KETONE BODIES': {
      'Unit': 'mg/dL or mmol/L',
      'Reference Range': 'Negative (0 mg/dL)'
    },
    'URINE SPECIFIC GRAVITY': {
      'Unit': '— (no unit)',
      'Reference Range': '1.005 – 1.030'
    },
    'URINE MICROALBUMIN': {
      'Unit': 'mg/dL or mg/g creatinine',
      'Reference Range': '< 30 mg/g creatinine (normal)'
    },
    'URINE PREGNANCY TEST': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive or Negative result'
    },
    'STOOL ROUTINE(color)': {'Unit': '-----', 'Reference Range': 'Brown'},
    'STOOL REDUCING SUBSTANCES': {
      'Unit': 'Qualitative',
      'Reference Range': 'Negative / Absent'
    },
    'OCCULT BLOOD': {'Unit': 'Qualitative', 'Reference Range': 'Negative'},
    'STOOL MANAGING DROP': {'Unit': '-----', 'Reference Range': '-----'},
    'HBsAg CARD': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive or Negative'
    },
    'HIV CARD': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive or Negative'
    },
    'HCV CARD': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive or Negative'
    },
    'DENGUE CARD': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive or Negative'
    },
    'LEPTOSPIRA CARD': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive or Negative'
    },
    'RAPID MALARIA CARD': {
      'Unit': 'Qualitative',
      'Reference Range': 'Positive or Negative'
    },
    'URINE C/S (Culture and Sensitivity)': {
      'Unit': 'Qualitative',
      'Reference Range': 'No growth (Negative) or Positive (specify organism)'
    },
    'SPUTUM C/S (Culture and Sensitivity)': {
      'Unit': 'Qualitative',
      'Reference Range': 'No growth (Negative) or Positive (specify organism)'
    },
    'STOOL C/S (Culture and Sensitivity)': {
      'Unit': 'Qualitative',
      'Reference Range': 'No growth (Negative) or Positive (specify organism)'
    },
    'PUS C/S (Culture and Sensitivity)': {
      'Unit': 'Qualitative',
      'Reference Range': 'No growth (Negative) or Positive (specify organism)'
    },
    'OTHER FLUIDS C/S (Culture and Sensitivity)': {
      'Unit': 'Qualitative',
      'Reference Range': 'No growth (Negative) or Positive (specify organism)'
    },
    'T3 (Triiodothyronine)': {
      'Unit': 'ng/dL or nmol/L',
      'Reference Range': '80 – 200 ng/dL (1.2 – 3.1 nmol/L)'
    },
    'T4 (Thyroxine)': {
      'Unit': 'ng/dL or nmol/L',
      'Reference Range': '5.0 – 12.0 μg/dL (64 – 154 nmol/L)'
    },
    'TSH (Thyroid Stimulating Hormone)': {
      'Unit': 'μIU/mL',
      'Reference Range': '0.4 – 4.0 μIU/mL'
    },
    'TFT [T3, T4 & TSH] (Thyroid Function Test)': {
      'Unit': 'ng/dL μg/dL μIU/mL',
      'Reference Range': '80 – 200 ng/dL 5.0 – 12.0 μg/dL 0.4 – 4.0 μIU/mL'
    },
    'FT3 (Free Triiodothyronine)': {
      'Unit': 'pg/mL',
      'Reference Range': '2.3 – 4.2 pg/mL'
    },
    'FT4 (Free Thyroxine)': {
      'Unit': 'pg/mL',
      'Reference Range': '0.8 – 1.8 ng/dL'
    },
    'VITAMIN D3': {
      'Unit': 'ng/mL',
      'Reference Range': '30 – 100 ng/mL (sufficient)'
    },
    'B-HCG (Beta Human Chorionic Gonadotropin)': {
      'Unit': 'mIU/mL',
      'Reference Range': '< 5 mIU/mL (non-pregnant)'
    },
    'IGE (Immunoglobulin E)': {
      'Unit': 'IU/mL',
      'Reference Range': '0 – 100 IU/mL (varies by lab)'
    },
    'DENTAL DIGITAL X-RAY': {'Unit': '-----', 'Reference Range': '-----'},
    'ECG (Electrocardiogram)': {'Unit': '-----', 'Reference Range': '-----'},
    'SEMEN ANALYSIS': {'Unit': 'mL', 'Reference Range': '≥ 1.5 mL'},
  };

  @override
  void initState() {
    super.initState();
    getAndIncrementBillNo();
    totalAmountController.addListener(_updateBalance);
    paidController.addListener(_updateBalance);

    if (widget.medication.isNotEmpty) {
      tableData1 = widget.medication.map((med) {
        final meta = testMetadata[med] ?? {'Unit': '', 'Reference Range': ''};
        return {
          'Test Descriptions': med,
          'Values': '',
          'Unit': meta['Unit']!,
          'Reference Range': meta['Reference Range']!,
        };
      }).toList();
    }
  }

  Future<String?> getAndIncrementBillNo() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('billNo').doc('labBillNo');

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        int currentBillNo = data?['billNo'] ?? 0;
        int currentNewBillNo = currentBillNo + 1;

        setState(() {
          reportNO = '${currentNewBillNo}';
          newReportNo = currentNewBillNo;
        });

        return reportNO;
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
        FirebaseFirestore.instance.collection('billNo').doc('labBillNo');

    await docRef.set({'billNo': newBillNo});
  }

  Future<void> submitData() async {
    try {
      final patientRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('opTickets')
          .doc(widget.opTicket);

      Map<String, String> testResults = {};

      await patientRef.set({
        'labTotalAmount': totalAmountController.text.trim(),
        'labCollected': paidController.text.trim(),
        'labBalance': balanceController.text.trim(),
        'reportDate': _dateController.text.trim(),
        'reportNo': reportNO,
        'sampleDate': widget.sampleDate,
        'sampleCollectedDate': _sampleCollectedDateController.text.trim(),
        'tests': tableData1,
        'labTechnician': currentUser?.name ?? '',
        'labTechnicianDegree': currentUser?.degree ?? '',
      }, SetOptions(merge: true));
      await patientRef.collection('labPayments').doc().set({
        'collected': totalAmountController.text,
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
      await updateBillNo(newReportNo);
      CustomSnackBar(context,
          message: 'All values have been successfully submitted',
          backgroundColor: Colors.cyan);
      print('All values have been successfully submitted.');
    } catch (e) {
      CustomSnackBar(context,
          message: 'Error submitting data: $e', backgroundColor: Colors.red);
      print('Error submitting data: $e');
    }
  }

  bool isLoading = false;

  void _updateBalance() {
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    double paidAmount = double.tryParse(paidController.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    balanceController.text = balance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    totalAmountController.dispose();
    paidController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  void clear() {
    totalAmountController.clear();
    paidController.clear();
    balanceController.clear();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _sampleCollectedDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void printData() {
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

                  final List<List<String>> dataRows = tableData1.map((data) {
                    return headers1
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
                                          'Doctor : ${widget.doctorName}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Specialization : ${widget.specialization}',
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
                                          'Phone : ${widget.phoneNo}',
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
                                          'Address : ${widget.address}',
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
                                          'Sample Collected Date : ${_sampleCollectedDateController.text}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Sample Date : ${widget.sampleDate}',
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
                                          'Report Date : ${_dateController.text}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            font: ttf,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          'Report No : ${reportNO.toString()}',
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
                          headers: headers1,
                          data: tableData1,
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
                              '${currentUser!.name}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.Text(
                              '[${currentUser!.degree}]',
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
                      bytes: await pdf.save(),
                      filename: '${widget.opTicket}.pdf');
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final List<Map<String, String>> data = [
      {'title': 'Patient Name', 'subtitle': widget.name},
      {'title': 'OP Number', 'subtitle': widget.patientID},
      {'title': 'OP Ticket', 'subtitle': widget.opTicket},
      {'title': 'Age', 'subtitle': widget.age},
      {'title': 'Sex', 'subtitle': widget.sex},
      {'title': 'DOB', 'subtitle': widget.dob},
      {
        'title': 'Basic Information / Diagnostics',
        'subtitle': widget.primaryInfo
      },
      {'title': 'Refer By', 'subtitle': widget.doctorName},
      {'title': 'Report Date', 'subtitle': _dateController.text},
      {'title': 'Sample Date', 'subtitle': widget.sampleDate},
      {'title': 'Report Number', 'subtitle': reportNO},
      {'title': 'Sample Collected Date', 'subtitle': ''},
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // or any custom action
          },
        ),
        title: Center(
            child: CustomText(
          text: "Patient Tests Report",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        backgroundColor: AppColors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Basic Details of Patients',
                    size: screenHeight * 0.03,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;

                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth > 900) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      shrinkWrap: true,
                      childAspectRatio: 2, // smaller ratio = taller cards
                      physics: const NeverScrollableScrollPhysics(),
                      children: data.map((item) {
                        bool isSampleDate =
                            item['title'] == 'Sample Collected Date';

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Flexible(
                                  child: isSampleDate
                                      ? GestureDetector(
                                          onTap: _selectDate,
                                          child: AbsorbPointer(
                                            child: TextField(
                                              controller:
                                                  _sampleCollectedDateController,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              decoration: InputDecoration(
                                                hintText: 'Select Date',
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          item['subtitle']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                          // remove maxLines and overflow
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                editableColumns: ['Values'],
                tableData: tableData1,
                headers: headers1,
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                onValueChanged: (rowIndex, header, value) async {
                  if (header == 'Values') {
                    setState(() {
                      tableData1[rowIndex][header] = value;
                    });
                  }
                },
              ),
              SizedBox(height: screenHeight * 0.06),
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
                              text: 'Total Amount ',
                              size: screenWidth * 0.013,
                            ),
                            SizedBox(height: 7),
                            CustomTextField(
                              hintText: '',
                              controller: totalAmountController,
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
                              controller: paidController,
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
                              controller: balanceController,
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
              SizedBox(height: screenHeight * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      label: 'Print',
                      onPressed: () {
                        printData();
                      },
                      width: screenWidth * 0.1),
                  SizedBox(
                    width: screenWidth * 0.05,
                  ),
                  Column(
                    children: [
                      isLoading
                          ? SizedBox(
                              width: 60,
                              height: 60,
                              child: Lottie.asset(
                                'assets/button_loading.json',
                                fit: BoxFit.contain,
                              ),
                            )
                          : CustomButton(
                              label: 'Submit',
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                submitData().then((_) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              },
                              width: screenWidth * 0.1,
                            ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
