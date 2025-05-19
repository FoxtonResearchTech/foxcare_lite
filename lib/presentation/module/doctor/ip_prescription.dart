import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxcare_lite/presentation/module/doctor/patient_history_dialog.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../utilities/constants.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/table/editable_drop_down_table.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import '../../login/fetch_user.dart';

class IpPrescription extends StatefulWidget {
  final String patientID;
  final String ipNumber;
  final String doctorName;
  final String roomWard;
  final String ipAdmitDate;
  final String name;
  final String age;
  final String date;
  final String specialization;
  final String city;
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

  const IpPrescription({
    Key? key,
    required this.patientID,
    required this.name,
    required this.age,
    required this.place,
    required this.primaryInfo,
    required this.address,
    required this.pincode,
    required this.temperature,
    required this.bloodPressure,
    required this.sugarLevel,
    required this.ipNumber,
    required this.phone1,
    required this.phone2,
    required this.sex,
    required this.bloodGroup,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.doctorName,
    required this.date,
    required this.specialization,
    required this.city,
    required this.roomWard,
    required this.ipAdmitDate,
  }) : super(key: key);
  @override
  State<IpPrescription> createState() => _IpPrescription();
}

class _IpPrescription extends State<IpPrescription> {
  final UserModel? currentUser = UserSession.currentUser;

  final dateTime = DateTime.timestamp();
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

  int selectedIndex = 1;
  String? selectedValue;
  String? selectedIPAdmissionValue;
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
  bool isLoading = false;

  bool _isSwitched = false;
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

  List<String> medicineNames = [];
  List<String> _filteredMedicine = [];
  List<String> _selectedMedicine = [];
  String _searchMedicine = '';
  final List<String> labHeaders = [
    'Test',
    'Results',
    'Reference',
  ];
  List<Map<String, dynamic>> labTableData = [];
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

  Future<void> endIP(String opNumber, String ipTicket) async {
    try {
      final patientDocRef =
          FirebaseFirestore.instance.collection('patients').doc(opNumber);

      final querySnapshot =
          await patientDocRef.collection('ipPrescription').doc('details').get();

      String roomNumber = querySnapshot['ipAdmission']['roomNumber'];
      String roomType = querySnapshot['ipAdmission']['roomType'];

      int index = int.parse(roomNumber) - 1;

      DocumentReference totalRoomRef =
          FirebaseFirestore.instance.collection('totalRoom').doc('status');

      final totalRoomSnapshot = await totalRoomRef.get();

      if (totalRoomSnapshot.exists) {
        Map<String, dynamic> data =
            totalRoomSnapshot.data() as Map<String, dynamic>;

        List<String> roomStatus = List<String>.from(data['roomStatus']);
        List<String> wardStatus = List<String>.from(data['wardStatus']);
        List<String> viproomStatus = List<String>.from(data['viproomStatus']);
        List<String> ICUStatus = List<String>.from(data['ICUStatus']);

        if (roomType == "Ward Room") {
          wardStatus[index] = 'available';
        } else if (roomType == "VIP Room") {
          viproomStatus[index] = 'available';
        } else if (roomType == "ICU") {
          ICUStatus[index] = 'available';
        } else if (roomType == "Room") {
          roomStatus[index] = 'available';
        }

        await totalRoomRef.update({
          "roomStatus": roomStatus,
          "wardStatus": wardStatus,
          "viproomStatus": viproomStatus,
          "ICUStatus": ICUStatus,
        });

        final ipPrescriptionRef = patientDocRef.collection('ipPrescription');
        final ipDocs = await ipPrescriptionRef.get();

        for (var doc in ipDocs.docs) {
          await doc.reference.delete();
        }

        await patientDocRef.update({'isIP': false});
        await patientDocRef
            .collection('ipTickets')
            .doc(ipTicket)
            .update({'discharged': true});

        CustomSnackBar(context, message: 'IP ended and ipPrescription removed');
      } else {
        CustomSnackBar(context, message: 'Total Room Data Not Found');
      }
    } catch (e) {
      CustomSnackBar(context, message: 'Cannot End IP');
      print("Error ending IP: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadPrescriptionDraft(widget.ipNumber);

    _filteredItems = _allItems;
    _filteredMedicine = medicineNames;

    fetchMedicine();
  }

  @override
  void dispose() {
    super.dispose();
    savePrescriptionDraft(widget.ipNumber);

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

  void _updateSerialNumbers() {
    for (int i = 0; i < medicineTableData.length; i++) {
      medicineTableData[i]['SL No'] = i + 1;
    }
  }

  void _filterItems(String query) {
    setState(() {
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
          ipNumber: widget.ipNumber,
        );
      },
    );
  }

  Future<void> _savePrescriptionData() async {
    try {
      final DateTime now = DateTime.now();
      final String formattedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final patientRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('ipTickets')
          .doc(widget.ipNumber);

      final Map<String, dynamic> patientData = {
        'proceedTo': selectedValue,
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

      await patientRef.set(patientData, SetOptions(merge: true));

      if (_selectedMedicine.isNotEmpty) {
        await patientRef.collection('Medication').doc().set({
          'items': _selectedMedicine,
          'date': formattedDate,
        });
      }

      if (_selectedItems.isNotEmpty) {
        await patientRef.collection('Examination').doc().set({
          'items': _selectedItems,
          'date': formattedDate,
        });
      }

      if (medicineTableData.isNotEmpty) {
        await patientRef.collection('prescribedMedicines').doc().set({
          'items': medicineTableData,
          'date': formattedDate,
        });
      }

      await clearPrescriptionDraft(widget.ipNumber);

      CustomSnackBar(
        context,
        message: 'Details saved successfully!',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      CustomSnackBar(
        context,
        message: 'Failed to save: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  void printPrescription() {
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
                                  pw.Text(
                                    'IP Ticket No : ${widget.ipNumber}',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    'Room / Ward No : ${widget.roomWard}',
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
                                    'Doctor : Dr. ${widget.doctorName}',
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
                                    'Admission Date : ${widget.ipAdmitDate}',
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
                                        'OP Ticket No : ${widget.ipNumber}',
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
                //
                // // await Printing.sharePdf(
                // //     bytes: await pdf.save(),
                // //     filename: '${widget.ipNumber}.pdf');
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

  Future<void> savePrescriptionDraft(String ipNumber) async {
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

    await prefs.setString('rxDraft_$ipNumber', jsonEncode(draftData));
  }

  Future<void> loadPrescriptionDraft(String ipNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('rxDraft_$ipNumber');

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

  Future<void> clearPrescriptionDraft(String ipNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rxDraft_$ipNumber');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: CustomText(
          text: "IP Patient Prescription",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'IP Ticket No : ${widget.ipNumber}',
                    size: screenWidth * 0.012,
                  ),
                  CustomText(
                    text: 'Room Type / No : ${widget.roomWard}',
                    size: screenWidth * 0.012,
                  ),
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
                                                onChanged: _filterItems,
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
                      child: CustomButton(
                        label: 'Process',
                        onPressed: () {
                          _savePrescriptionData();
                        },
                        width: screenWidth * 0.5,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: CustomButton(
                        label: 'Print',
                        onPressed: () {
                          printPrescription();
                        },
                        width: screenWidth * 0.5,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: CustomButton(
                        label: 'Prescribed',
                        onPressed: () {
                          _savePrescriptionData();
                        },
                        width: screenWidth * 0.5,
                      ),
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
