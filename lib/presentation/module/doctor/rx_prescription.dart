import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/patient_history_dialog.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../utilities/widgets/table/editable_drop_down_table.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'package:http/http.dart' as http;

class RxPrescription extends StatefulWidget {
  final String opTicket;
  final String patientID;
  final String doctorName;
  final String specialization;
  final String name;
  final String age;
  final String date;
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
      required this.specialization});

  @override
  State<RxPrescription> createState() => _RxPrescription();
}

class _RxPrescription extends State<RxPrescription> {
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
  bool _isSwitched = false;
  bool isMed = false;
  bool isInvestigation = false;
  bool isAppointment = false;
  bool isLabTest = false;
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

        // Convert quantity to integer safely
        int quantity = int.tryParse(data['quantity'].toString()) ?? 0;

        if (data.containsKey('mrp') && quantity > 0) {
          validMedicines.add(data['productName'].toString());
        }
      }
      print(validMedicines);

      setState(() {
        medicineNames = validMedicines;
      });
    } catch (e) {
      print('Error fetching Medicine: $e');
    }
  }

  void isMedication(String value) {
    setState(() {
      isMed = value == 'Medication';
      isLabTest = value == 'Examination';
      isInvestigation = value == 'Investigation';
      isAppointment = value == 'Appointment';
    });
  }

  Future<String> generateUniqueOpTicketId() async {
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
    ipTicketId = await generateUniqueOpTicketId();
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

  void _filterMedicine(String query) {
    setState(() {
      _searchMedicine = query;
      _filteredMedicine = medicineNames
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addSelectedMedicine(String item) {
    if (!_selectedMedicine.contains(item)) {
      setState(() {
        _selectedMedicine.add(item);
      });
    }
  }

  void _removeSelectedMedicine(String item) {
    setState(() {
      _selectedMedicine.remove(item);
    });
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
          ipNumber: '',
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
            left: screenWidth * 0.11,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: 'Dr. ${widget.doctorName}',
                    size: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenWidth * 0.47),
                  CustomText(text: 'OP Number'),
                  SizedBox(width: screenWidth * 0.01),
                  Switch(
                    activeColor: AppColors.secondaryColor,
                    value: _isSwitched,
                    onChanged: (bool value) {
                      _onToggle(value);
                    },
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  CustomText(text: 'IP Number'),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    readOnly: true,
                    controller: TextEditingController(text: widget.opTicket),
                    hintText: 'OP Ticket Number',
                    obscureText: false,
                    width: screenWidth * 0.46,
                  ),
                  CustomTextField(
                    controller: TextEditingController(text: widget.date),
                    hintText: 'Date',
                    readOnly: true,
                    obscureText: false,
                    width: screenWidth * 0.3,
                  ),
                  const SizedBox(width: 0.0),
                ],
              ),
              const SizedBox(height: 26),

              // Row 2: Full Name and Age
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    controller: TextEditingController(text: widget.name),
                    hintText: 'Full Name',
                    obscureText: false,
                    readOnly: true,
                    width: screenWidth * 0.46,
                  ),
                  CustomTextField(
                    controller: TextEditingController(text: widget.age),
                    hintText: 'Age',
                    obscureText: false,
                    readOnly: true,
                    width: screenWidth * 0.3,
                  ),
                  const SizedBox(width: 0.0),
                ],
              ),
              const SizedBox(height: 26),
              // Row 3: Address and Pincode
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    controller: TextEditingController(text: widget.address),
                    hintText: 'Address',
                    readOnly: true,
                    obscureText: false,
                    width: screenWidth * 0.46,
                    verticalSize: screenWidth * 0.01,
                  ),
                  CustomTextField(
                    controller: TextEditingController(text: widget.pincode),
                    hintText: 'Pincode',
                    readOnly: true,
                    obscureText: false,
                    width: screenWidth * 0.3,
                  ),
                  const SizedBox(width: 0.0),
                ],
              ),
              const SizedBox(height: 26),

              // Row 4: Basic Info
              CustomTextField(
                controller: TextEditingController(text: widget.primaryInfo),
                readOnly: true,
                obscureText: false,
                hintText: 'Basic Info',
                width: screenWidth * 0.8,
                verticalSize: screenWidth * 0.03,
              ),
              const SizedBox(
                height: 35,
              ),
              const Text(
                'Basic Diagnosis :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    label: 'Patient History',
                    onPressed: () {
                      showPatientHistoryDialog(context);
                    },
                    width: screenWidth * 0.12,
                    height: screenHeight * 0.05,
                  ),
                  CustomTextField(
                    controller: TextEditingController(text: widget.temperature),
                    hintText: 'Temperature ',
                    width: screenWidth * 0.085,
                    readOnly: true,
                    obscureText: false,
                  ),
                  CustomTextField(
                    hintText: 'Blood Pressure ',
                    width: screenWidth * 0.1,
                    readOnly: true,
                    controller:
                        TextEditingController(text: widget.bloodPressure),
                    obscureText: false,
                  ),
                  CustomTextField(
                    hintText: 'Sugar Level ',
                    width: screenWidth * 0.085,
                    readOnly: true,
                    controller: TextEditingController(text: widget.sugarLevel),
                    obscureText: false,
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              CustomTextField(
                controller: _diagnosisSignsController,
                hintText: 'Diagnosis Sign',
                width: screenWidth * 0.8,
                verticalSize: screenWidth * 0.03,
              ),
              const SizedBox(
                height: 20,
              ),

              // Row 4: Basic Info
              CustomTextField(
                controller: _symptomsController,
                hintText: 'Symptoms',
                width: screenWidth * 0.8,
                verticalSize: screenWidth * 0.03,
              ),
              const SizedBox(
                height: 35,
              ),

              Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: CustomDropdown(
                      label: 'Proceed To',
                      items: const [
                        'Medication',
                        'Examination',
                        'Appointment',
                        'Investigation',
                      ],
                      selectedItem: selectedValue,
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value!;
                          isMedication(selectedValue!);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  if (isAppointment)
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
                                          SizedBox(height: screenHeight * 0.1),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomTextField(
                                                onTap: () => _selectDate(
                                                    context, _appointmentDate),
                                                hintText: 'Select Date ',
                                                width: screenWidth * 0.1,
                                                controller: _appointmentDate,
                                                icon: const Icon(
                                                    Icons.date_range_outlined),
                                              ),
                                              CustomTextField(
                                                onTap: () => _selectTime(
                                                    context, _appointmentTime),
                                                hintText: 'Select Time ',
                                                width: screenWidth * 0.1,
                                                controller: _appointmentTime,
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
                  if (isMed)
                    CustomButton(
                      label: 'Add Medicines',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
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
                                                      shadowColor: Colors.white,
                                                      backgroundColor: AppColors
                                                          .secondaryColor,
                                                      label: CustomText(
                                                          text: item,
                                                          color: Colors.white),
                                                      deleteIcon: const Icon(
                                                          Icons.close,
                                                          color: Colors.white),
                                                      onDeleted: () {
                                                        setState(() {
                                                          _selectedMedicine
                                                              .remove(item);
                                                          medicineTableData
                                                              .removeWhere((row) =>
                                                                  row['Medicine Name'] ==
                                                                  item);
                                                          _updateSerialNumbers();
                                                        });
                                                      },
                                                    ))
                                                .toList(),
                                          ),
                                          const SizedBox(height: 10),
                                          // Search field
                                          CustomTextField(
                                            onChanged: (query) {
                                              setState(() {
                                                if (query.isEmpty) {
                                                  _filteredMedicine =
                                                      List.from(medicineNames);
                                                } else {
                                                  _filteredMedicine =
                                                      medicineNames
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
                                            verticalSize: screenHeight * 0.03,
                                          ),
                                          const SizedBox(height: 10),
                                          // ListView inside a SizedBox with fixed height
                                          SizedBox(
                                            height: screenHeight *
                                                0.2, // Adjust height as needed
                                            child: ListView.builder(
                                              itemCount:
                                                  _filteredMedicine.length,
                                              itemBuilder: (context, index) {
                                                final item =
                                                    _filteredMedicine[index];
                                                return ListTile(
                                                  title: Text(item),
                                                  onTap: () async {
                                                    if (!_selectedMedicine
                                                        .contains(item)) {
                                                      setState(() {
                                                        _selectedMedicine
                                                            .add(item);
                                                        isLoading = true;
                                                      });
                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  250));

                                                      setState(() {
                                                        medicineTableData.add({
                                                          'SL No':
                                                              medicineTableData
                                                                      .length +
                                                                  1,
                                                          'Medicine Name': item,
                                                          'Morning': '',
                                                          'Afternoon': '',
                                                          'Evening': '',
                                                          'Night': '',
                                                          'Duration': '',
                                                        });
                                                        isLoading = false;
                                                      });
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          if (medicineTableData.isNotEmpty) ...[
                                            isLoading
                                                ? CircularProgressIndicator()
                                                : Column(
                                                    children: [
                                                      EditableDropDownTable(
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
                                                        // Editable columns
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
                                                          if (header ==
                                                                  'Duration' &&
                                                              rowIndex <
                                                                  medicineTableData
                                                                      .length) {
                                                            setState(() {
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
                                                      ),
                                                    ],
                                                  ),
                                          ] else
                                            const Text(
                                                "Invalid or incomplete medicine data")
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      width: screenWidth * 0.2,
                      height: screenHeight * 0.05,
                    ),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              isLabTest
                  ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: _selectedItems
                                .map((item) => Chip(
                                      shadowColor: Colors.white,
                                      backgroundColor: AppColors.secondaryColor,
                                      label: CustomText(
                                        text: item,
                                        color: Colors.white,
                                      ),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onDeleted: () {
                                        // Remove item from selected items
                                        setState(() {
                                          _selectedItems.remove(item);
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          // Search field
                          CustomTextField(
                            onChanged: _filterItems,
                            hintText: 'Search Tests',
                            width: screenWidth * 0.8,
                            verticalSize: screenHeight * 0.03,
                          ),
                          const SizedBox(height: 10),
                          // ListView inside a SizedBox with fixed height
                          SizedBox(
                            height: screenHeight *
                                0.3, // Adjust height based on your layout
                            child: ListView.builder(
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                return ListTile(
                                  title: Text(item),
                                  onTap: () {
                                    // Add item to selected items
                                    if (!_selectedItems.contains(item)) {
                                      setState(() {
                                        _selectedItems.add(item);
                                      });
                                    }
                                    print('Selected: $item');
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              if (isInvestigation)
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CustomText(
                            text: 'Investigation Tests :',
                            size: screenWidth * 0.011,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          CustomTextField(
                            controller: _notesController,
                            hintText: 'Enter notes',
                            width: screenWidth * 0.8,
                            verticalSize: screenWidth * 0.03,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(
                height: 35,
              ),
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
                        label: 'Prescribed',
                        onPressed: () {
                          _prescribed();
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
