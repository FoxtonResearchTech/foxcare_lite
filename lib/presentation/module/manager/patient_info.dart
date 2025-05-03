import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxcare_lite/presentation/module/manager/edit_delete_patient_information.dart';
import 'package:foxcare_lite/utilities/constants.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class PatientInfo extends StatefulWidget {
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
  final String? opAmountEdit;
  final String? opAmountCollectedEdit;

  const PatientInfo({
    super.key,
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
    this.bloodGroupEdit,
    this.opAmountEdit,
    this.opAmountCollectedEdit,
  });

  @override
  State<PatientInfo> createState() => _PatientInfoState();
}

class _PatientInfoState extends State<PatientInfo> {
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
  final TextEditingController opAmount = TextEditingController();
  final TextEditingController opAmountCollected = TextEditingController();

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
        const SnackBar(content: Text("Please fill all required fields")),
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
      'opAmount': opAmount.text,
      'opAmountCollected': opAmountCollected.text,
    };

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientID)
          .set(patientData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient registered successfully")),
      );

      // Show a dialog with the entered details
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Patient Details'),
            content: Container(
              width: 350,
              height: 350,
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
                  CustomText(text: 'Amount: ${opAmount.text}'),
                  CustomText(text: 'Collected: ${opAmountCollected.text}'),
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
        const SnackBar(content: Text("Error: Patient ID is missing")),
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
      'opAmount': opAmount.text,
      'opAmountCollected': opAmountCollected.text,
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
            title: const CustomText(
              text: 'Patient Details',
              size: 20,
            ),
            content: Container(
              width: 325,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Patient ID', widget.opNumberEdit!),
                        _infoRow('First Name', firstname.text),
                        _infoRow('Middle Name', middlename.text),
                        _infoRow('Last Name', lastname.text),
                        _infoRow('Sex', selectedSex!),
                        _infoRow('Age', age.text),
                        _infoRow('DOB', dob.text),
                        const Divider(),
                        _infoRow(
                            'Address', '${address1.text}, ${address2.text}'),
                        _infoRow('Landmark', landmark.text),
                        _infoRow('City', city.text),
                        _infoRow('State', state.text),
                        _infoRow('Pincode', pincode.text),
                        const Divider(),
                        _infoRow('Phone 1', phone1.text),
                        _infoRow('Phone 2', phone2.text),
                        _infoRow('Blood Group', selectedBloodGroup!),
                        const Divider(),
                        _infoRow('Amount', opAmount.text),
                        _infoRow('Collected', opAmountCollected.text),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  final pdf = pw.Document();
                  final myColor = PdfColor.fromInt(0xFF106ac2); // 0xAARRGGBB

                  final font = await rootBundle
                      .load('Fonts/Poppins/Poppins-Regular.ttf');
                  final ttf = pw.Font.ttf(font);

                  final topImage = pw.MemoryImage(
                    (await rootBundle.load('assets/opAssets/OP_Card_top.png'))
                        .buffer
                        .asUint8List(),
                  );

                  final bottomImage = pw.MemoryImage(
                    (await rootBundle.load('assets/opAssets/OP_Card_back.png'))
                        .buffer
                        .asUint8List(),
                  );
                  final loc = pw.MemoryImage(
                    (await rootBundle.load('assets/location_Icon.png'))
                        .buffer
                        .asUint8List(),
                  );

                  pdf.addPage(
                    pw.Page(
                      pageFormat: const PdfPageFormat(
                          8 * PdfPageFormat.cm, 5 * PdfPageFormat.cm),
                      margin: pw.EdgeInsets.zero,
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
                                        'ABC Hospital',
                                        style: pw.TextStyle(
                                          fontSize: 14,
                                          font: ttf,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.SizedBox(height: 8),
                                  pw.Text(
                                    'OP Number: ${widget.opNumberEdit}',
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        font: ttf,
                                        color: myColor),
                                  ),
                                  pw.Text(
                                    'Name: ${firstname.text} ${middlename.text} ${lastname.text}',
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        font: ttf,
                                        color: myColor),
                                  ),
                                  pw.Text(
                                    'Phone Number: ${phone1.text}',
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        font: ttf,
                                        color: myColor),
                                  ),
                                ],
                              ),
                            ),
                            // Full-width background image at the bottom
                            pw.Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: pw.Image(
                                bottomImage,
                                fit: pw.BoxFit.cover,
                              ),
                            ),
                            // Text content above the bottom image
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(
                                  left: 8, right: 8, top: 6),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Emergency and appointment info (left side)
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

                                      // City + District + Location Icon (right side)
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
                                                '${Constants.hospitalCity}',
                                                style: pw.TextStyle(
                                                    fontSize: 8,
                                                    font: ttf,
                                                    color: PdfColors.white),
                                              ),
                                              pw.Text(
                                                '${Constants.hospitalDistrict}',
                                                style: pw.TextStyle(
                                                    fontSize: 8,
                                                    font: ttf,
                                                    color: PdfColors.white),
                                              ),
                                            ],
                                          ),
                                          pw.SizedBox(width: 4),
                                          pw.Image(loc,
                                              height: 20,
                                              width: 10), // Icon on the right
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
                  //   onLayout: (PdfPageFormat format) async {
                  //     return pdf.save();
                  //   },
                  //   format: const PdfPageFormat(
                  //       8 * PdfPageFormat.cm, 5 * PdfPageFormat.cm),
                  // );

                  await Printing.sharePdf(
                      bytes: await pdf.save(),
                      filename: '${widget.opNumberEdit}.pdf');
                },
                child: CustomText(
                  text: 'Print',
                  color: AppColors.secondaryColor,
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
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
    opAmount.clear();
    opAmountCollected.clear();
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
      opAmount.text = widget.opAmountEdit ?? '';
      opAmountCollected.text = widget.opAmountCollectedEdit ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: CustomText(
            text: 'Patient Information',
            size: screenWidth * 0.02,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.appBar,
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
                    text: isEditing
                        ? 'Edit Patient Information'
                        : 'Patient Registration : ',
                    size: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenWidth * 0.52),
                  isEditing
                      ? const SizedBox()
                      : CustomButton(
                          label: 'Edit/Delete Patients',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const EditDeletePatientInformation()));
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
              Row(
                children: [
                  CustomDropdown(
                      label: 'Blood Group',
                      items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                      selectedItem: selectedBloodGroup,
                      onChanged: (value) {
                        setState(() {
                          selectedBloodGroup = value!;
                        });
                      }),
                  SizedBox(width: screenWidth * 0.12),
                  CustomTextField(
                    hintText: 'OP Amount',
                    width: screenWidth * 0.1,
                    controller: opAmount,
                  ),
                  SizedBox(width: screenWidth * 0.12),
                  CustomTextField(
                    hintText: 'Collected',
                    width: screenWidth * 0.1,
                    controller: opAmountCollected,
                  )
                ],
              ),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}
