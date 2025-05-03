import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/custom_icon_button.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/secondary_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/form_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/secondary_text_field.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/textField/long_text_fields.dart'
    show LongTextField, LongTextFields;
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
  String? selectedSex;
  String? selectedBloodGroup;
  bool isLoading = false;
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

  Future<void> savePatientDetails() async {
    Map<String, dynamic> patientData = {
      'opNumber': uid,
      'firstName': firstname.text,
      'middleName': middlename.text,
      'lastName': lastname.text,
      'sex': selectedSex,
      'age': age.text,
      'dob': dob.text,
      'isIP': false,
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
                        _infoRow('Patient ID', uid),
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  clearForm();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PatientRegistration()),
                  );
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

  bool validateForm1() {
    if (firstname.text.isEmpty ||
        lastname.text.isEmpty ||
        age.text.isEmpty ||
        dob.text.isEmpty ||
        phone1.text.isEmpty ||
        selectedSex == null ||
        selectedBloodGroup == null) {
      CustomSnackBar(
        context,
        message: 'Please fill all required fields',
        backgroundColor: Colors.red,
      );
      return false;
    }
    return true;
  }

  bool validateForm2() {
    if (landmark.text.isEmpty ||
        city.text.isEmpty ||
        state.text.isEmpty ||
        address1.text.isEmpty ||
        pincode.text.isEmpty) {
      CustomSnackBar(
        context,
        message: 'Please fill all required fields',
        backgroundColor: Colors.red,
      );
      return false;
    }
    return true;
  }

  bool validateForm3() {
    if (opAmount.text.isEmpty || opAmountCollected.text.isEmpty) {
      CustomSnackBar(
        context,
        message: 'Please fill all required fields',
        backgroundColor: Colors.red,
      );
      return false;
    }
    return true;
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

  @override
  void initState() {
    super.initState();
    initializeUid();
    phone1.addListener(_validatePhone1);
    phone2.addListener(_validatePhone2);
  }

  int currentStep = 0;
  final int totalSteps = 3;
  double previousProgress = 0;

  double get progress => (currentStep + 0) / totalSteps;

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
        Padding(
          padding: EdgeInsets.only(
              left: screenWidth * 0.02, right: screenWidth * 0.02),
          child: Row(
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
        ),
        Padding(
          padding: const EdgeInsets.only(left: 90, right: 90),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: previousProgress, end: progress),
            duration: const Duration(milliseconds: 750),
            builder: (context, value, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: screenHeight * 0.02,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Container(
                            height: screenHeight * 0.02,
                            width: constraints.maxWidth * value,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                          child: CustomText(
                              text: '${(value * 100).toInt()}% Completed')),
                    ],
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (currentStep == 0) form1(),
                if (currentStep == 1) form2(),
                if (currentStep == 2) form3(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget form1() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth * 2,
      height: screenHeight * 1,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black45,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'First Name : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: firstname,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Middle Name : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: middlename,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: ' ',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Last Name : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: lastname,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Sex : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              SecondaryDropdown(
                                verticalSize: screenHeight * 0.02,
                                width: screenWidth * 0.2,
                                hintText: '',
                                items: ['Male', 'Female', 'Others'],
                                onChanged: (value) {
                                  setState(() {
                                    selectedSex = value!;
                                  });
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Age : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                readOnly: true,
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: age,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'DOB : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                icon: Icon(Icons.date_range_outlined),
                                onTap: () async {
                                  await _selectDate(context, dob);

                                  if (dob.text.isNotEmpty) {
                                    try {
                                      DateTime pickedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .parse(dob.text);
                                      int calculatedAge =
                                          _calculateAge(pickedDate);
                                      age.text = calculatedAge.toString();
                                    } catch (e) {
                                      age.text = '';
                                    }
                                  }
                                },
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: dob,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Blood Group : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              SecondaryDropdown(
                                verticalSize: screenHeight * 0.02,
                                width: screenWidth * 0.2,
                                hintText: '',
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
                                onChanged: (value) {
                                  setState(() {
                                    selectedBloodGroup = value!;
                                  });
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone 1 : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                maxLength: 10,
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: phone1,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          if (phone1Error != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, left: 8.0),
                              child: CustomText(
                                text: phone1Error!,
                                color: Colors.red, // optional: show it in red
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Phone 2 : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                maxLength: 10,
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: phone2,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '  ',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          if (phone2Error != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, left: 8.0),
                              child: CustomText(
                                text: phone2Error!,
                                color: Colors.red, // optional: show it in red
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.2),
                      CustomIconButton(
                          suffixWidth: screenWidth * 0.0125,
                          suffixIcon: Icons.arrow_forward_ios,
                          label: 'Next',
                          onPressed: () async {
                            if (validateForm1()) {
                              setState(() {
                                isLoading = true;
                              });

                              await Future.delayed(
                                  const Duration(milliseconds: 500));

                              if (currentStep < totalSteps - 1) {
                                setState(() {
                                  previousProgress = progress;
                                  currentStep++;
                                  isLoading = false;
                                });
                              }
                            }
                          },
                          width: screenWidth * 0.2)
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget form2() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth * 2,
      height: screenHeight * 0.8,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black45,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Address 1 : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              LongTextField(
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: address1,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.18),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Address 2 : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              LongTextField(
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: address2,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.188),
                                child: CustomText(
                                  text: ' ',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Land Mark : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: landmark,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'City : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: city,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'State : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: state,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Pin code : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: pincode,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomIconButton(
                          prefixWidth: screenWidth * 0.0125,
                          prefixIcon: Icons.arrow_back_ios,
                          label: 'Previous',
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            if (currentStep < totalSteps - 1) {
                              setState(() {
                                currentStep--;
                                isLoading = false;
                              });
                            }
                          },
                          width: screenWidth * 0.2),
                      SizedBox(width: screenWidth * 0.22),
                      CustomIconButton(
                          suffixWidth: screenWidth * 0.0125,
                          suffixIcon: Icons.arrow_forward_ios,
                          label: 'Next',
                          onPressed: () async {
                            if (validateForm2()) {
                              setState(() {
                                isLoading = true;
                              });

                              await Future.delayed(
                                  const Duration(milliseconds: 500));

                              if (currentStep < totalSteps - 1) {
                                setState(() {
                                  previousProgress = progress;
                                  currentStep++;
                                  isLoading = false;
                                });
                              }
                            }
                          },
                          width: screenWidth * 0.2),
                      SizedBox(width: screenWidth * 0.015),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget form3() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth * 2,
      height: screenHeight * 0.8,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black45,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: screenWidth * 0.6,
                        height: screenHeight * 0.3,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/registration.png'))),
                      )
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'OP Amount : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: opAmount,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'OP Amount Collected : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: opAmountCollected,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.008,
                                    bottom: screenHeight * 0.05),
                                child: CustomText(
                                  text: '*',
                                  size: screenWidth * 0.015,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomIconButton(
                          prefixWidth: screenWidth * 0.0125,
                          prefixIcon: Icons.arrow_back_ios,
                          label: 'Previous',
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            if (currentStep > 0) {
                              setState(() {
                                currentStep--;
                                isLoading = false;
                              });
                            }
                          },
                          width: screenWidth * 0.2),
                      SizedBox(width: screenWidth * 0.22),
                      CustomButton(
                          label: 'Register',
                          onPressed: () async {
                            if (validateForm3()) {
                              setState(() {
                                isLoading = true;
                                previousProgress = progress;
                                currentStep++;
                              });

                              await Future.delayed(
                                  const Duration(milliseconds: 600));

                              await savePatientDetails();

                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          width: screenWidth * 0.2),
                      SizedBox(width: screenWidth * 0.015),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Text('$label:',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}
