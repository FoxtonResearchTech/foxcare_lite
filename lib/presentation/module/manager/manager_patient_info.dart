import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

import 'edit_delete_patient_information.dart';
import 'manager_dashboard.dart';
import 'manager_patient_history.dart';

class ManagerPatientInfo extends StatefulWidget {
  final String? opNumberEdit;
  final String? firstNameEdit;
  final String? middleNameEdit;
  final String? lastNameEdit;
  final String? sexEdit;
  final String? ageEdit;
  final String? dobEdit;
  final String? address1Edit;
  final String? address2Edit;
  final String? landmarkEdit;
  final String? cityEdit;
  final String? stateEdit;
  final String? pincodeEdit;
  final String? phone1Edit;
  final String? phone2Edit;
  final String? bloodGroupEdit;
  const ManagerPatientInfo(
      {super.key,
      this.opNumberEdit,
      this.firstNameEdit,
      this.middleNameEdit,
      this.lastNameEdit,
      this.sexEdit,
      this.ageEdit,
      this.dobEdit,
      this.address1Edit,
      this.address2Edit,
      this.landmarkEdit,
      this.cityEdit,
      this.stateEdit,
      this.pincodeEdit,
      this.phone1Edit,
      this.phone2Edit,
      this.bloodGroupEdit});

  @override
  State<ManagerPatientInfo> createState() => _ManagerPatientInfo();
}

int selectedIndex = 1;

class _ManagerPatientInfo extends State<ManagerPatientInfo> {
  String? selectedSex;
  String? selectedBloodGroup;
  bool isEditing = false;
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController middlename = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController address1 = TextEditingController();
  final TextEditingController address2 = TextEditingController();
  final TextEditingController landmark = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController phone1 = TextEditingController();
  final TextEditingController phone2 = TextEditingController();

  String generateNumericUid() {
    var random = Random();
    return 'Fox' +
        List.generate(6, (_) => random.nextInt(10).toString()).join();
  }

  String uid = '';

  Future<void> savePatientDetails() async {
    final patientID = generateNumericUid();

    // Validate input
    if (firstname.text.isEmpty ||
        lastname.text.isEmpty ||
        selectedSex == null ||
        selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    // Create patient data object
    Map<String, dynamic> patientData = {
      'opNumber': patientID,
      'firstName': firstname.text,
      'middleName': middlename.text,
      'lastName': lastname.text,
      'sex': selectedSex,
      'age': age.text,
      'dob': dob.text,
      'address1': address1.text,
      'address2': address2.text,
      'landmark': landmark.text,
      'city': city.text,
      'state': state.text,
      'pincode': pincode.text,
      'phone1': phone1.text,
      'phone2': phone2.text,
      'bloodGroup': selectedBloodGroup,
    };

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientID)
          .set(patientData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Patient registered successfully")),
      );

      // Show a dialog with the entered details
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Patient Details'),
            content: Container(
              width: 350,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(text: 'Patient ID: $patientID'),
                  CustomText(text: 'First Name: ${firstname.text}'),
                  CustomText(text: 'Middle Name: ${middlename.text}'),
                  CustomText(text: 'Last Name: ${lastname.text}'),
                  CustomText(text: 'Sex: ${selectedSex}'),
                  CustomText(text: 'Age: ${age.text}'),
                  CustomText(text: 'DOB: ${dob.text}'),
                  CustomText(
                      text: 'Address: ${address1.text}, ${address2.text}'),
                  CustomText(text: 'Landmark: ${landmark.text}'),
                  CustomText(text: 'City: ${city.text}'),
                  CustomText(text: 'State: ${state.text}'),
                  CustomText(text: 'Pincode: ${pincode.text}'),
                  CustomText(text: 'Phone 1: ${phone1.text}'),
                  CustomText(text: 'Phone 2: ${phone2.text}'),
                  CustomText(text: 'Blood Group: ${selectedBloodGroup}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  final pdf = pw.Document();
                  pdf.addPage(
                    pw.Page(
                      pageFormat: const PdfPageFormat(
                          10 * PdfPageFormat.cm, 7 * PdfPageFormat.cm),
                      build: (pw.Context context) => pw.Center(
                        child: pw.Container(
                          width: 300,
                          height: 200,
                          padding: const pw.EdgeInsets.all(16), // Inner padding
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.grey), // Border color
                            borderRadius:
                                pw.BorderRadius.circular(8), // Rounded corners
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'ABC Hospital ',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Center(
                                child: pw.Text('Care through excelling'),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Divider(),
                              pw.SizedBox(height: 5),
                              pw.Text('Patient ID: $patientID'),
                              pw.Text(
                                  'Name: ${firstname.text + ' ' + middlename.text + ' ' + lastname.text}'),
                              pw.Text('DOB: ${dob.text}'),
                              pw.Text(
                                  'Address: ${address1.text},${city.text},${pincode.text}'),
                              pw.Divider(),
                              pw.Text(
                                  'Please bring your card for every check up'),
                              pw.SizedBox(height: 2),
                              pw.Text('Contact : '),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  await Printing.layoutPdf(
                    onLayout: (format) async => pdf.save(),
                  );
                },
                child: CustomText(
                  text: 'Print',
                  color: AppColors.secondaryColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  clearForm();
                },
                child: CustomText(
                  text: 'Close',
                  color: AppColors.secondaryColor,
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to register patient: $e")),
      );
    }
  }

  Future<void> updatePatientDetails() async {
    if (widget.opNumberEdit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Patient ID is missing")),
      );
      return;
    }

    Map<String, dynamic> updatedData = {
      'firstName': firstname.text,
      'middleName': middlename.text,
      'lastName': lastname.text,
      'sex': selectedSex,
      'age': age.text,
      'dob': dob.text,
      'address1': address1.text,
      'address2': address2.text,
      'landmark': landmark.text,
      'city': city.text,
      'state': state.text,
      'pincode': pincode.text,
      'phone1': phone1.text,
      'phone2': phone2.text,
      'bloodGroup': selectedBloodGroup,
    };

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.opNumberEdit)
          .update(updatedData);

      CustomSnackBar(context,
          message: 'Patients Details Updated Successfully',
          backgroundColor: Colors.green);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Patient Details'),
            content: Container(
              width: 350,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(text: 'Patient ID: ${widget.opNumberEdit}'),
                  CustomText(text: 'First Name: ${firstname.text}'),
                  CustomText(text: 'Middle Name: ${middlename.text}'),
                  CustomText(text: 'Last Name: ${lastname.text}'),
                  CustomText(text: 'Sex: ${selectedSex}'),
                  CustomText(text: 'Age: ${age.text}'),
                  CustomText(text: 'DOB: ${dob.text}'),
                  CustomText(
                      text: 'Address: ${address1.text}, ${address2.text}'),
                  CustomText(text: 'Landmark: ${landmark.text}'),
                  CustomText(text: 'City: ${city.text}'),
                  CustomText(text: 'State: ${state.text}'),
                  CustomText(text: 'Pincode: ${pincode.text}'),
                  CustomText(text: 'Phone 1: ${phone1.text}'),
                  CustomText(text: 'Phone 2: ${phone2.text}'),
                  CustomText(text: 'Blood Group: ${selectedBloodGroup}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  final pdf = pw.Document();
                  pdf.addPage(
                    pw.Page(
                      pageFormat: const PdfPageFormat(
                          10 * PdfPageFormat.cm, 7 * PdfPageFormat.cm),
                      build: (pw.Context context) => pw.Center(
                        child: pw.Container(
                          width: 300,
                          height: 200,
                          padding: const pw.EdgeInsets.all(16), // Inner padding
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.grey), // Border color
                            borderRadius:
                                pw.BorderRadius.circular(8), // Rounded corners
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'ABC Hospital ',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Center(
                                child: pw.Text('Care through excelling'),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Divider(),
                              pw.SizedBox(height: 5),
                              pw.Text('Patient ID: ${widget.opNumberEdit}'),
                              pw.Text(
                                  'Name: ${firstname.text + ' ' + middlename.text + ' ' + lastname.text}'),
                              pw.Text('DOB: ${dob.text}'),
                              pw.Text(
                                  'Address: ${address1.text},${city.text},${pincode.text}'),
                              pw.Divider(),
                              pw.Text(
                                  'Please bring your card for every check up'),
                              pw.SizedBox(height: 2),
                              pw.Text('Contact : '),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  await Printing.layoutPdf(
                    onLayout: (format) async => pdf.save(),
                  );
                },
                child: CustomText(
                  text: 'Print',
                  color: AppColors.secondaryColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  clearForm();
                },
                child: CustomText(
                  text: 'Close',
                  color: AppColors.secondaryColor,
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update patient: $e")),
      );
    }
  }

  void clearForm() {
    firstname.clear();
    lastname.clear();
    middlename.clear();
    age.clear();
    dob.clear();
    address1.clear();
    address2.clear();
    landmark.clear();
    city.clear();
    state.clear();
    pincode.clear();
    phone1.clear();
    phone2.clear();
    setState(() {
      selectedSex = null;
      selectedBloodGroup = null;
    });
  }

  @override
  void initState() {
    uid = generateNumericUid();
    if (widget.opNumberEdit != null) {
      isEditing = true;
      firstname.text = widget.firstNameEdit ?? '';
      middlename.text = widget.middleNameEdit ?? '';
      lastname.text = widget.lastNameEdit ?? '';
      selectedSex = widget.sexEdit;
      age.text = widget.ageEdit ?? '';
      dob.text = widget.dobEdit ?? '';
      address1.text = widget.address1Edit ?? '';
      address2.text = widget.address2Edit ?? '';
      landmark.text = widget.landmarkEdit ?? '';
      city.text = widget.cityEdit ?? '';
      state.text = widget.stateEdit ?? '';
      pincode.text = widget.pincodeEdit ?? '';
      phone1.text = widget.phone1Edit ?? '';
      phone2.text = widget.phone2Edit ?? '';
      selectedBloodGroup = widget.bloodGroupEdit;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Patient Information'),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: buildDrawerContent(),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300,
              color: Colors.blue.shade100,
              child: buildDrawerContent(),
            ),
          Expanded(child: dashboard()),
        ],
      ),
    );
  }

  Widget buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Patient Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Dashboard', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ManagerDashboard()),
          );
        }, Iconsax.mask),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(1, 'Patient Information', () {}, Iconsax.receipt),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(2, 'Patient History', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ManagerPatientHistory()),
          );
        }, Iconsax.check),
      ],
    );
  }

  Widget buildDrawerItem(
    int index,
    String title,
    VoidCallback onTap,
    IconData icon,
  ) {
    return ListTile(
      selected: selectedIndex == index,
      selectedTileColor: Colors.blueAccent.shade100,
      leading: Icon(
        icon,
        color: selectedIndex == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selectedIndex == index ? Colors.blue : Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        onTap();
      },
    );
  }

  Widget dashboard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: 'Patient Registration : ',
                    size: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenWidth * 0.45),
                  CustomButton(
                    label: 'Edit/Delete Patients',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditDeletePatientInformation()));
                    },
                    width: screenWidth * 0.1,
                    height: screenHeight * 0.05,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    hintText: 'First Name',
                    controller: firstname,
                    width: screenWidth * 0.25,
                  ),
                  CustomTextField(
                    hintText: 'Middle Name',
                    controller: middlename,
                    width: screenWidth * 0.25,
                  ),
                  CustomTextField(
                    hintText: 'Last Name',
                    controller: lastname,
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomDropdown(
                      label: 'Sex',
                      items: ['Male', 'Female', 'Other'],
                      selectedItem: selectedSex,
                      onChanged: (value) {
                        setState(() {
                          selectedSex = value!;
                        });
                      }),
                  CustomTextField(
                    hintText: 'Age',
                    controller: age,
                    width: screenWidth * 0.25,
                  ),
                  CustomTextField(
                    hintText: 'DOB (YYYY-MM-DD)',
                    controller: dob,
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Column(
                children: [
                  CustomTextField(
                    hintText: 'Address Line 1',
                    controller: address1,
                    width: screenWidth * 0.9,
                    verticalSize: screenHeight * 0.05,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  CustomTextField(
                    hintText: 'Address Line 2',
                    controller: address2,
                    width: screenWidth * 0.9,
                    verticalSize: screenHeight * 0.05,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    hintText: 'Land Mark',
                    controller: landmark,
                    width: screenWidth * 0.25,
                  ),
                  CustomTextField(
                    hintText: 'City',
                    controller: city,
                    width: screenWidth * 0.25,
                  ),
                  CustomTextField(
                    hintText: 'State',
                    controller: state,
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    hintText: 'Pincode',
                    controller: pincode,
                    width: screenWidth * 0.25,
                  ),
                  CustomTextField(
                    hintText: 'Mobile 1',
                    controller: phone1,
                    width: screenWidth * 0.25,
                  ),
                  CustomTextField(
                    hintText: 'Mobile 2',
                    controller: phone2,
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDropdown(
                  label: 'Blood Group',
                  items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                  selectedItem: selectedBloodGroup,
                  onChanged: (value) {
                    setState(() {
                      selectedBloodGroup = value!;
                    });
                  }),
              SizedBox(height: screenHeight * 0.04),
              Center(
                  child: CustomButton(
                label: isEditing ? 'Update' : 'Register',
                onPressed: () {
                  isEditing ? updatePatientDetails() : savePatientDetails();
                },
                width: screenWidth * 0.1,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
