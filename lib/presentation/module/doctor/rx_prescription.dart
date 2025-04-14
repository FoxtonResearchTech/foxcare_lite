import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/patient_history_dialog.dart';
import 'package:foxcare_lite/presentation/module/doctor/rx_prescription.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class RxPrescription extends StatefulWidget {
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
      required this.ipNumber,
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
      required this.dob});

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

  bool _isSwitched = false;
  bool isMed = false;
  bool isLabTest = false;
  List<String> medicineNames = [];
  List<String> _filteredMedicine = [];
  List<String> _selectedMedicine = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    _filteredMedicine = medicineNames;

    fetchMedicine();
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
    });
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
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .set({
        'Medication': _selectedMedicine,
        'Examination': _selectedItems,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
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
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
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
                    controller: TextEditingController(text: widget.patientID),
                    hintText: 'OP Number',
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
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: CustomTextField(
                    controller: TextEditingController(text: widget.age),
                    hintText: 'Age',
                    obscureText: false,
                    readOnly: true,
                    width: screenWidth * 0.05,
                  )),
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
                          isMedication(selectedValue!);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
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
                                  title: Text('Add Medicines'),
                                  content: SizedBox(
                                    width: screenWidth * 0.5,
                                    height: screenHeight * 0.5,
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
                                                          // ✅ Updates UI inside dialog
                                                          _selectedMedicine
                                                              .remove(item);
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
                                                0.3, // Adjust height as needed
                                            child: ListView.builder(
                                              itemCount:
                                                  _filteredMedicine.length,
                                              itemBuilder: (context, index) {
                                                final item =
                                                    _filteredMedicine[index];
                                                return ListTile(
                                                  title: Text(item),
                                                  onTap: () {
                                                    if (!_selectedMedicine
                                                        .contains(item)) {
                                                      setState(() {
                                                        _selectedMedicine
                                                            .add(item);
                                                      });
                                                    }
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
