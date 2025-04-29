import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/patient_information/management_patient_information.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/secondary_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/textField/secondary_text_field.dart';

import 'package:iconsax/iconsax.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../../manager/edit_delete_patient_information.dart';
import '../generalInformation/general_information_admission_status.dart';
import 'management_patient_history.dart';
import 'management_patients_list.dart';

class ManagementRegisterPatient extends StatefulWidget {
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
  const ManagementRegisterPatient(
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
      this.bloodGroupEdit,
      this.opAmountEdit,
      this.opAmountCollectedEdit});
  @override
  State<ManagementRegisterPatient> createState() =>
      _ManagementRegisterPatient();
}

class _ManagementRegisterPatient extends State<ManagementRegisterPatient> {
  final dateTime = DateTime.timestamp();
  int selectedIndex = 0;
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

  Future<String> generateUniquePatientId() async {
    const chars = '0123456789';
    Random random = Random.secure();
    String patientId = '';

    bool exists = true;
    while (exists) {
      String randomString =
          List.generate(6, (index) => chars[random.nextInt(chars.length)])
              .join();
      patientId = 'Fox$randomString';

      var docSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .get();

      exists = docSnapshot.exists;
    }

    return patientId;
  }

  Future<void> initializeUid() async {
    uid = await generateUniquePatientId();
    setState(() {});
  }

  String uid = '';

  Future<void> savePatientDetails() async {
    if (firstname.text.isEmpty ||
        lastname.text.isEmpty ||
        selectedSex == null ||
        selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    Map<String, dynamic> patientData = {
      'opNumber': uid,
      'firstName': firstname.text,
      'middleName': middlename.text,
      'lastName': lastname.text,
      'sex': selectedSex,
      'age': age.text,
      'isIP': false,
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
          .doc(uid)
          .set(patientData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient registered successfully")),
      );

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
                  CustomText(text: 'Patient ID: $uid'),
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
                              pw.Text('Patient ID: $uid'),
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
      await initializeUid();
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
    super.initState();
    initializeUid();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
                text: 'Patient Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ManagementPatientInformation(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ManagementPatientInformation(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // First Name Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'First Name : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: firstname,
                          width: double
                              .infinity, // Takes up the full available space
                        ),
                      ],
                    ),
                  ),

                  // Middle Name Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Middle Name : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: middlename,
                          width: double
                              .infinity, // Takes up the full available space
                        ),
                      ],
                    ),
                  ),

                  // Last Name Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Last Name : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: lastname,
                          width: double
                              .infinity, // Takes up the full available space
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Sex Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Sex : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryDropdown(
                          width: double.infinity, // Take full available width
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
                  ),

                  // Age Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Age : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: age,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
                  ),

                  // DOB Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'DOB (YYYY-MM-DD) : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: dob,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Landmark Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Landmark : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: landmark,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
                  ),

                  // City Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'City : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: city,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
                  ),

                  // State Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'State : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: state,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Pincode Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Pincode : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: pincode,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
                  ),

                  // Phone Number 1 Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Phone Number 1 : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: phone1,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
                  ),

                  // Phone Number 2 Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Phone Number 2 : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: phone2,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Blood Group Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'Blood Group : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryDropdown(
                          hintText: '',
                          width: double.infinity, // Take full available width
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
                  ),

                  // OP Amount Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'OP Amount : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: opAmount,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
                  ),

                  // OP Amount Collected Column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: 'OP Amount Collected : '),
                        SizedBox(height: screenHeight * 0.01),
                        SecondaryTextField(
                          hintText: '',
                          controller: opAmountCollected,
                          width: double.infinity, // Take full available width
                        ),
                      ],
                    ),
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
          ),
        ),
      ),
    );
  }
}
