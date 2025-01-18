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

  const RxPrescription({
    Key? key,
    required this.patientID,
    required this.name,
    required this.age,
    required this.place,
    required this.primaryInfo,
    required this.address,
    required this.pincode,
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
  String selectedValue = 'Medication';
  final List<String> _allItems = [
    'Paracetamol',
    'Ibuprofen',
    'Amoxicillin',
    'Metformin',
    'Aspirin',
    'Omeprazole',
    'Lisinopril',
    'Atorvastatin',
    'Albuterol',
    'Cetirizine',
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
        SnackBar(content: Text('Details saved successfully!')),
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
              title: Text(
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
        DrawerHeader(
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
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(1, 'Patient Search', () {}, Iconsax.receipt),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(2, 'Pharmacy Stocks', () {}, Iconsax.add_circle),
        Divider(height: 5, color: Colors.grey),
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
    bool isMobile = screenWidth < 600;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: OP Number and Date
          Text(
            'Dr. Kathiresan',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
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
              SizedBox(width: 100),
              Expanded(
                  child: CustomTextField(
                hintText: 'Date',
                readOnly: true,
                obscureText: false,
                width: screenWidth * 0.05,
              )),
            ],
          ),
          SizedBox(height: 26),

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
              SizedBox(width: 10),
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
          SizedBox(height: 26),

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
              SizedBox(width: 10),
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
          SizedBox(height: 26),

          // Row 4: Basic Info
          CustomTextField(
            controller: TextEditingController(),
            hintText: 'Basic Info',
            width: screenWidth * 0.8,
            verticalSize: screenWidth * 0.03,
          ),
          SizedBox(
            height: 35,
          ),
          Text(
            'Basic Diagnosis :',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomTextField(
                hintText: 'Temperature ',
                width: screenWidth * 0.085,
                controller: _temperatureController,
              ),
              CustomTextField(
                hintText: 'Blood Pressure ',
                width: screenWidth * 0.1,
                controller: _bloodPressureController,
              ),
              CustomTextField(
                hintText: 'Sugar Level ',
                width: screenWidth * 0.085,
                controller: _sugarLevelController,
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          // Row 4: Basic Info
          CustomTextField(
            controller: _patientHistoryController,
            hintText: 'Patient History',
            width: screenWidth * 0.8,
            verticalSize: screenWidth * 0.03,
          ),
          SizedBox(
            height: 20,
          ),

          // Row 4: Basic Info
          CustomTextField(
            controller: _diagnosisSignsController,
            hintText: 'Diagnosis Sign',
            width: screenWidth * 0.8,
            verticalSize: screenWidth * 0.03,
          ),
          SizedBox(
            height: 20,
          ),

          // Row 4: Basic Info
          CustomTextField(
            controller: _symptomsController,
            hintText: 'Symptoms',
            width: screenWidth * 0.8,
            verticalSize: screenWidth * 0.03,
          ),
          SizedBox(
            height: 35,
          ),
          Text(
            'Investigation Tests :',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
          ),

          CustomTextField(
            controller: _notesController,
            hintText: 'Enter notes',
            width: screenWidth * 0.8,
            verticalSize: screenWidth * 0.03,
          ),
          SizedBox(
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
          SizedBox(
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
                TextField(
                  onChanged: _filterItems,
                  decoration: InputDecoration(
                    labelText: 'Search Medication',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 10),
                // ListView inside a SizedBox with fixed height
                SizedBox(
                  height: 100, // Adjust height based on your layout
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
              Text(
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
          SizedBox(
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
