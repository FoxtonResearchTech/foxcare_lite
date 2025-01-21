import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class RxPrescription extends StatefulWidget {
  final String patientID;
  final String name;
  final String age;
  final String place;
  final String address;
  final String pincode;
  final String primaryInfo;
  final String temperature;
  final String bloodPressure;
  final String sugarLevel;

  const RxPrescription({
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
  }) : super(key: key);
  @override
  State<RxPrescription> createState() => _RxPrescriptionState();
}

class _RxPrescriptionState extends State<RxPrescription> {
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

  Future<void> _savePrescriptionData() async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .set({
        'Medications': _selectedItems,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text(
                'Reception Dashboard',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: buildDrawerContent(), // Drawer minimized for mobile
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: buildDrawerContent(), // Sidebar always open for web view
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: dashboard()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer content reused for both web and mobile
  Widget buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Doctor - Consultation',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Home', () {}, Iconsax.mask),
        const Divider(height: 5, color: Colors.grey),
        buildDrawerItem(1, 'Patient Search', () {}, Iconsax.receipt),
        const Divider(height: 5, color: Colors.grey),
        buildDrawerItem(2, 'Pharmacy Stocks', () {}, Iconsax.add_circle),
        const Divider(height: 5, color: Colors.grey),
        buildDrawerItem(7, 'Logout', () {
          // Handle logout action
        }, Iconsax.logout),
      ],
    );
  }

  // Helper method to build drawer items with the ability to highlight the selected item
  Widget buildDrawerItem(
      int index, String title, VoidCallback onTap, IconData icon) {
    return ListTile(
      selected: selectedIndex == index,
      selectedTileColor: Colors.blueAccent.shade100,
      // Highlight color for the selected item
      leading: Icon(
        icon, // Replace with actual icons
        color: selectedIndex == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
            fontFamily: 'SanFrancisco',
            color: selectedIndex == index ? Colors.blue : Colors.black54,
            fontWeight: FontWeight.w700),
      ),
      onTap: () {
        setState(() {
          selectedIndex = index; // Update the selected index
        });
        onTap();
      },
    );
  }

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: OP Number and Date
          const Text(
            'Dr. Kathiresan',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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
                controller: TextEditingController(text: widget.bloodPressure),
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
          // Row 4: Basic Info
          CustomTextField(
            controller: _patientHistoryController,
            hintText: 'Patient History',
            width: screenWidth * 0.8,
            verticalSize: screenWidth * 0.03,
          ),
          const SizedBox(
            height: 20,
          ),

          // Row 4: Basic Info
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

          SizedBox(
            width: 250,
            child: CustomDropdown(
              label: 'Select',
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
                  width: screenWidth * 0.8,
                  verticalSize: screenHeight * 0.03,
                ),
                const SizedBox(height: 10),
                // ListView inside a SizedBox with fixed height
                SizedBox(
                  height:
                      screenHeight * 0.3, // Adjust height based on your layout
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
    );
  }
}
