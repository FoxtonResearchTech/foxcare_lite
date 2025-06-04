import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxcare_lite/presentation/module/management/patientsInformation/edit_delete_patient_information.dart';
import 'package:foxcare_lite/utilities/constants.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';

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
  bool isUpdating = false;
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

  String? phone1Error;
  String? phone2Error;

  void _validatePhone1() {
    final text = phone1.text;
    final phoneRegex = RegExp(r'^[0-9]{0,10}$');

    setState(() {
      if (text.isEmpty) {
        phone1Error = '';
      } else if (!phoneRegex.hasMatch(text)) {
        phone1Error = 'Only digits are allowed';
      } else if (text.length != 10) {
        phone1Error = 'Phone number must be 10 digits';
      } else {
        phone1Error = null;
      }
    });
  }

  void _validatePhone2() {
    final text = phone2.text;
    final phoneRegex = RegExp(r'^[0-9]{0,10}$');

    setState(() {
      if (text.isEmpty) {
        phone2Error = '';
      } else if (!phoneRegex.hasMatch(text)) {
        phone2Error = 'Only digits are allowed';
      } else if (text.length != 10) {
        phone2Error = 'Phone number must be 10 digits';
      } else {
        phone2Error = null;
      }
    });
  }

  String uid = '';

  Future<void> updatePatientDetails() async {
    if (widget.opNumberEdit == null) {
      CustomSnackBar(context,
          message: 'Patient ID is Missing', backgroundColor: Colors.red);
      return;
    }
    if (firstname.text.isEmpty ||
        lastname.text.isEmpty ||
        selectedSex == null ||
        age.text.isEmpty ||
        dob.text.isEmpty ||
        address1.text.isEmpty ||
        landmark.text.isEmpty ||
        city.text.isEmpty ||
        state.text.isEmpty ||
        pincode.text.isEmpty ||
        phone1.text.isEmpty) {
      CustomSnackBar(context,
          message: 'Please Fill Required Fields',
          backgroundColor: Colors.orange);
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
                                        Constants.hospitalName,
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
                  //   onLayout: (format) async => pdf.save(),
                  // );

                  //
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
      CustomSnackBar(context,
          message: 'Failed to update patient', backgroundColor: Colors.red);
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
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
    phone1.addListener(_validatePhone1);
    phone2.addListener(_validatePhone2);
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
            left: screenWidth * 0.08,
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
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.03),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Edit Patient Information ",
                          size: screenWidth * .03,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.11,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        image: const DecorationImage(
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'First Name',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: firstname,
                        width: screenWidth * 0.25,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Middle Name',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: middlename,
                        width: screenWidth * 0.25,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Last Name',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: lastname,
                        width: screenWidth * 0.25,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Sex',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomDropdown(
                          label: '',
                          items: ['Male', 'Female', 'Other'],
                          selectedItem: selectedSex,
                          onChanged: (value) {
                            setState(() {
                              selectedSex = value!;
                            });
                          }),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Age',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: age,
                        width: screenWidth * 0.25,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'DOB',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: dob,
                        width: screenWidth * 0.25,
                        icon: Icon(Icons.date_range_outlined),
                        onTap: () async {
                          await _selectDate(context, dob);
                          if (dob.text.isNotEmpty) {
                            try {
                              DateTime pickedDate =
                                  DateFormat('yyyy-MM-dd').parse(dob.text);
                              int calculatedAge = _calculateAge(pickedDate);
                              age.text = calculatedAge.toString();
                            } catch (e) {
                              age.text = '';
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Address Lane 1',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: address1,
                        width: screenWidth * 0.9,
                        verticalSize: screenHeight * 0.05,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Address Lane 2',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: address2,
                        width: screenWidth * 0.9,
                        verticalSize: screenHeight * 0.05,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Land Mark',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: landmark,
                        width: screenWidth * 0.25,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'City',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: city,
                        width: screenWidth * 0.25,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'State',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: state,
                        width: screenWidth * 0.25,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Pincode',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: pincode,
                        width: screenWidth * 0.25,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Phone 1',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        controller: phone1,
                        width: screenWidth * 0.25,
                      ),
                      if (phone1Error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                          child: CustomText(
                            text: phone1Error!,
                            color: Colors.red, // optional: show it in red
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Phone 2',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: 'Mobile 2',
                        controller: phone2,
                        width: screenWidth * 0.25,
                      ),
                      if (phone2Error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                          child: CustomText(
                            text: phone2Error!,
                            color: Colors.red, // optional: show it in red
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Blood Group',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomDropdown(
                          label: '',
                          items: [
                            'A+',
                            'A-',
                            'B+',
                            'B-',
                            'O+',
                            'O-',
                            'AB+',
                            'AB-'
                          ],
                          selectedItem: selectedBloodGroup,
                          onChanged: (value) {
                            setState(() {
                              selectedBloodGroup = value!;
                            });
                          }),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                  child: CustomButton(
                label: 'Update',
                onPressed: () async {
                  await updatePatientDetails();
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
