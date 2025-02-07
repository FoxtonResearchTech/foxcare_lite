import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/patient_history_dialog.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class IpPrescription extends StatefulWidget {
  final String patientID;
  final String ipNumber;

  final String name;
  final String age;
  final String place;
  final String address;
  final String pincode;
  final String primaryInfo;
  final String temperature;
  final String bloodPressure;
  final String sugarLevel;

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
  }) : super(key: key);
  @override
  State<IpPrescription> createState() => _IpPrescription();
}

class _IpPrescription extends State<IpPrescription> {
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
  bool _isSwitched = false;
  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
  }

  @override
  void dispose() {
    super.dispose();
    _temperatureController.dispose();
    _bloodPressureController.dispose();
    _sugarLevelController.dispose();
    _notesController.dispose();
    _diagnosisSignsController.dispose();
    _symptomsController.dispose();
  }

  Future<void> _onToggle(bool value) async {
    var firestore = FirebaseFirestore.instance;
    var docRef = firestore.collection('patients').doc(widget.patientID);

    setState(() {
      _isSwitched = value;
    });

    if (_isSwitched) {
      // Move 'opNumber' value to 'ipNumber' and delete 'opNumber'
      await docRef.update({
        'ipNumber': widget.patientID,
        'opNumber': FieldValue.delete(),
      });
      CustomSnackBar(context,
          message: 'Patients Marked as IP',
          backgroundColor: AppColors.secondaryColor);
    } else {
      // Move 'ipNumber' value back to 'opNumber' and delete 'ipNumber'
      await docRef.update({
        'opNumber': widget.patientID,
        'ipNumber': FieldValue.delete(),
      });
      CustomSnackBar(context,
          message: 'Patients Marked as OP',
          backgroundColor: AppColors.secondaryColor);
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

  void _addSelectedItem(String item) {
    if (!_selectedItems.contains(item)) {
      setState(() {
        _selectedItems.add(item);
      });
    }
  }

  void _removeSelectedItem(String item) {
    setState(() {
      _selectedItems.remove(item);
    });
  }

  void showPatientHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PatientHistoryDialog();
      },
    );
  }

  Future<void> _savePrescriptionData() async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.ipNumber)
          .collection('ipPrescription')
          .doc('details')
          .set({
        'date': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'time': dateTime.hour.toString() +
            '-' +
            dateTime.minute.toString().padLeft(2, '0') +
            '-' +
            dateTime.second.toString().padLeft(2, '0'),
        'Medications': _selectedItems,
        'proceedTo': selectedValue,
        'ipAdmission': selectedIPAdmissionValue,
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
      }, SetOptions(merge: true));

      CustomSnackBar(context,
          message: 'Details saved successfully!',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to save: $e', backgroundColor: Colors.red);
    }
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
        backgroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: 'Dr. Kathiresan',
                    size: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenWidth * 0.47),
                  CustomText(text: 'OP Number'),
                  SizedBox(width: screenWidth * 0.01),
                  Switch(
                    activeColor: AppColors.secondaryColor,
                    value: _isSwitched,
                    onChanged: _onToggle,
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  CustomText(text: 'IP Number'),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: CustomTextField(
                    readOnly: true,
                    controller: TextEditingController(text: widget.ipNumber),
                    hintText: 'IP Number',
                    obscureText: false,
                    width: screenWidth * 0.05,
                  )),
                  const SizedBox(width: 100),
                  Expanded(
                      child: CustomTextField(
                    hintText: 'Date',
                    readOnly: true,
                    obscureText: false,
                    width: screenWidth * 0.05,
                  )),
                ],
              ),
              const SizedBox(height: 26),

              // Row 2: Full Name and Age
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: TextEditingController(text: widget.name),
                      hintText: 'Full Name',
                      obscureText: false,
                      readOnly: true,
                      width: screenWidth * 0.05,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: TextEditingController(text: widget.age),
                      hintText: 'Age',
                      obscureText: false,
                      readOnly: true,
                      width: screenWidth * 0.05,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // Row 3: Address and Pincode
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: TextEditingController(text: widget.address),
                        hintText: 'Address',
                        readOnly: true,
                        obscureText: false,
                        width: screenWidth * 0.05,
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: CustomTextField(
                    controller: TextEditingController(text: widget.pincode),
                    hintText: 'Pincode',
                    readOnly: true,
                    obscureText: false,
                    width: screenWidth * 0.05,
                  )),
                ],
              ),
              const SizedBox(height: 26),
              CustomTextField(
                controller: TextEditingController(text: widget.primaryInfo),
                readOnly: true,
                obscureText: false,
                hintText: 'Basic Info',
                width: screenWidth * 0.9,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                height: 20,
              ),
              CustomTextField(
                controller: _diagnosisSignsController,
                hintText: 'Diagnosis Sign',
                width: screenWidth * 0.9,
                verticalSize: screenWidth * 0.03,
              ),
              const SizedBox(
                height: 20,
              ),

              // Row 4: Basic Info
              CustomTextField(
                controller: _symptomsController,
                hintText: 'Symptoms',
                width: screenWidth * 0.9,
                verticalSize: screenWidth * 0.03,
              ),
              const SizedBox(
                height: 35,
              ),
              const Text(
                'Investigation Tests :',
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

              CustomTextField(
                controller: _notesController,
                hintText: 'Enter notes',
                width: screenWidth * 0.9,
                verticalSize: screenWidth * 0.03,
              ),
              const SizedBox(
                height: 35,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 250,
                  child: CustomDropdown(
                    label: 'Proceed To',
                    items: [
                      'Medication',
                      'Examination',
                      'Appointment',
                      'Investigation'
                    ],
                    selectedItem: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value!;
                      });
                    },
                  ),
                ),
              ]),
              const SizedBox(
                height: 35,
              ),
              Container(
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
                      hintText: 'Search Medications',
                      width: screenWidth * 0.9,
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Prescribed By : Dr Kathiresan ',
                    style: TextStyle(
                      fontFamily: 'SanFrancisco',
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: CustomButton(
                      label: 'Change',
                      onPressed: () {},
                      width: screenWidth * 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  child: CustomButton(
                    label: 'Prescribe',
                    onPressed: () {
                      _savePrescriptionData();
                    },
                    width: screenWidth * 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
