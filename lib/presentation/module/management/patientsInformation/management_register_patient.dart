import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_ip_admission.dart';
import 'package:foxcare_lite/presentation/module/management/management_dashboard.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/patient_information/management_patient_information.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/secondary_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/textField/long_text_fields.dart';
import 'package:foxcare_lite/utilities/widgets/textField/secondary_text_field.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../utilities/colors.dart';
import '../../../../utilities/constants.dart';
import '../../../../utilities/widgets/buttons/custom_icon_button.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/form_text_field.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import 'edit_delete_patient_information.dart';
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
  final dateTime = DateTime.now();
  int selectedIndex = 0;
  String? selectedSex;
  String? selectedBloodGroup;
  bool isEditing = false;
  bool isRegisterLoading = false;

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
  final TextEditingController opAmountBalance = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();

  String? paymentMode;

  void _updateBalance() {
    double totalAmount = double.tryParse(opAmount.text) ?? 0.0;
    double paidAmount = double.tryParse(opAmountCollected.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    opAmountBalance.text = balance.toStringAsFixed(0);
  }

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

  bool isLoading = false;

  String uid = '';

  Future<void> savePatientDetails() async {
    setState(() {
      isRegisterLoading = true;
    });
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
      'opAmountBalance': opAmountBalance.text,
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
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(uid)
          .collection('opAmountPayments')
          .doc()
          .set({
        'collected': opAmountCollected.text,
        'balance': opAmountBalance.text,
        'paymentMode': paymentMode,
        'paymentDetails': paymentDetails.text,
        'payedDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'payedTime': dateTime.hour.toString() +
            ':' +
            dateTime.minute.toString().padLeft(2, '0'),
      });
      CustomSnackBar(context,
          message: "Patient registered successfully",
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
                        _infoRow('Balance', opAmountBalance.text),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                onPressed: () async {
                  Navigator.of(context).pop();
                  clearForm();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManagementRegisterPatient()),
                  );
                },
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                                    'OP Number: $uid',
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
                  // await Printing.layoutPdf(
                  //   onLayout: (format) async => pdf.save(),
                  // );

                  await Printing.sharePdf(
                      bytes: await pdf.save(), filename: '${uid}.pdf');
                },
                icon: const Icon(
                  Icons.print,
                  color: Colors.white,
                ),
                label: const Text(
                  'Print',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
      setState(() {
        isRegisterLoading = false;
      });
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
    if (opAmount.text.isEmpty ||
        opAmountCollected.text.isEmpty ||
        opAmountBalance.text.isEmpty) {
      CustomSnackBar(
        context,
        message: 'Please fill all required fields',
        backgroundColor: Colors.red,
      );
      return false;
    }
    return true;
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
    opAmount.addListener(_updateBalance);
    opAmountCollected.addListener(_updateBalance);
  }

  int currentStep = 0;
  final int totalSteps = 3;
  double previousProgress = 0;

  double get progress => (currentStep + 0) / totalSteps;

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
              padding: const EdgeInsets.all(10),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
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
                padding: EdgeInsets.only(top: screenWidth * 0.01),
                child: Column(
                  children: [
                    CustomText(
                      text: "Patient Registration",
                      size: screenWidth * 0.03,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        image: const DecorationImage(
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                  CustomButton(
                    label: 'Edit / Delete Patients',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditDeletePatientInformation()));
                    },
                    width: screenWidth * 0.12,
                    height: screenHeight * 0.05,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
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
      height: screenHeight * 0.9,
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
      height: screenHeight * 0.9,
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
      height: screenHeight * 0.9,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.047),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Collected : ',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Balance : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: opAmountBalance,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Payment Mode : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              SecondaryDropdown(
                                verticalSize: screenHeight * 0.02,
                                width: screenWidth * 0.2,
                                hintText: '',
                                items: Constants.paymentMode,
                                onChanged: (value) {
                                  setState(() {
                                    paymentMode = value!;
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Payment Details : ',
                            size: screenWidth * 0.0125,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              FormTextField(
                                verticalSize: screenHeight * 0.02,
                                hintText: '',
                                width: screenWidth * 0.2,
                                controller: paymentDetails,
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
                      isRegisterLoading
                          ? Lottie.asset('assets/button_loading.json',
                              height: 150, width: 150)
                          : CustomButton(
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
