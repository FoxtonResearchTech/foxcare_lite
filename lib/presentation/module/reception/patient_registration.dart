import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/secondary_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/secondary_text_field.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pdf/pdf.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'admission_status.dart';
import 'doctor_schedule.dart';
import 'ip_admission.dart';
import 'ip_patients_admission.dart';
import 'op_counters.dart';
import 'op_ticket.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PatientRegistration extends StatefulWidget {
  @override
  State<PatientRegistration> createState() => _PatientRegistrationState();
}

class _PatientRegistrationState extends State<PatientRegistration> {
  final dateTime = DateTime.timestamp();

  int selectedIndex = 1;
  String? selectedSex; // Default value for Sex
  String? selectedBloodGroup; // Default value for Blood Group
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
      'opAdmissionDate': dateTime.year.toString() +
          '-' +
          dateTime.month.toString().padLeft(2, '0') +
          '-' +
          dateTime.day.toString().padLeft(2, '0'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          : null,
      drawer: isMobile
          ? Drawer(
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No AppBar for web view
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Sidebar width for larger screens
              color: Colors.blue.shade100,
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return buildThreeColumnForm(); // Web view
                  } else {
                    return buildSingleColumnForm(); // Mobile view
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildThreeColumnForm() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenWidth * 0.02),
              child: Column(
                children: [
                  CustomText(
                    text: "Patient Registration",
                    size: screenWidth * 0.03,
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.1,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'First Name : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: firstname,
                  width: screenWidth * 0.25,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Middle Name : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: middlename,
                  width: screenWidth * 0.25,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Last Name : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: lastname,
                  width: screenWidth * 0.25,
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Sex : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryDropdown(
                  width: screenWidth * 0.25,
                  hintText: '',
                  items: const ['Male', 'Female', 'Other'],
                  selectedItem: selectedSex,
                  onChanged: (value) {
                    setState(() {
                      selectedSex = value!;
                    });
                  },
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Age : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: age,
                  width: screenWidth * 0.2,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'DOB (YYYY-MM-DD) : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: dob,
                  width: screenWidth * 0.25,
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: 'Address  Line 1: '),
            SizedBox(height: screenHeight * 0.01),
            SecondaryTextField(
              hintText: '',
              controller: address1,
              width: screenWidth * 0.8,
              verticalSize: screenHeight * 0.025,
            )
          ],
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: 'Address  Line 2: '),
            SizedBox(height: screenHeight * 0.01),
            SecondaryTextField(
              hintText: '',
              controller: address2,
              width: screenWidth * 0.8,
              verticalSize: screenHeight * 0.025,
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Landmark : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: landmark,
                  width: screenWidth * 0.25,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'City : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: city,
                  width: screenWidth * 0.25,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'State : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: state,
                  width: screenWidth * 0.25,
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Pincode : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: pincode,
                  width: screenWidth * 0.25,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Phone Number 1 : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: phone1,
                  width: screenWidth * 0.25,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Phone Number 2 : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: phone2,
                  width: screenWidth * 0.25,
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Blood Group : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryDropdown(
                  hintText: '',
                  width: screenWidth * 0.25,
                  items: const [
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
                  },
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'OP Amount : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: opAmount,
                  width: screenWidth * 0.2,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'OP Amount Collected : '),
                SizedBox(height: screenHeight * 0.01),
                SecondaryTextField(
                  hintText: '',
                  controller: opAmountCollected,
                  width: screenWidth * 0.25,
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 45),
        Center(
          child: SizedBox(
              width: 400,
              child: CustomButton(
                label: 'Register',
                onPressed: () {
                  savePatientDetails();
                },
                width: null,
              )),
        )
      ],
    );
  }

  // Form layout for mobile with one column
  Widget buildSingleColumnForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('OP Number ',
                    style: TextStyle(
                        fontFamily: 'SanFrancisco',
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                    width: 200.0,
                    child: CustomTextField(
                      hintText: 'Enter OP Number',
                      width: null,
                    )),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: 'First Name',
          controller: firstname,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Middle Name',
          controller: middlename,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Last Name',
          controller: lastname,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomDropdown(
            label: 'Sex',
            items: const ['Male', 'Female', 'Other'],
            selectedItem: selectedSex,
            onChanged: (value) {
              setState(() {
                selectedSex = value!;
              });
            }),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Age',
          controller: age,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'DOB (YYYY-MM-DD)',
          controller: dob,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Address Line 1',
          controller: address1,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Address Line 2',
          controller: address2,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Land Mark',
          controller: landmark,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'City',
          controller: city,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'State',
          controller: state,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Pincode',
          controller: pincode,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Mobile 1',
          controller: phone1,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Mobile 2',
          controller: phone2,
          width: null,
        ),
        const SizedBox(height: 16),
        CustomDropdown(
            label: 'Blood Group',
            items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
            selectedItem: selectedBloodGroup,
            onChanged: (value) {
              setState(() {
                selectedBloodGroup = value!;
              });
            }),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
              width: 250,
              child: CustomButton(
                label: 'Register',
                onPressed: () {},
                width: null,
              )),
        ),
      ],
    );
  }
}
