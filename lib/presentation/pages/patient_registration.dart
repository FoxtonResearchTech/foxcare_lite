import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/reception/op_ticket_generate.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pdf/pdf.dart';
import '../../utilities/colors.dart';
import '../../utilities/widgets/buttons/primary_button.dart';
import '../../utilities/widgets/textField/primary_textField.dart';
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
  int selectedIndex = 0;
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
              child: buildDrawerContent(), // Drawer minimized for mobile
            )
          : null, // No AppBar for web view
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Sidebar width for larger screens
              color: Colors.blue.shade100,
              child: buildDrawerContent(), // Sidebar content
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

  // Sidebar content for desktop view
  Widget buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Reception',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Patient Registration', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PatientRegistration()),
          );
        }, Iconsax.mask),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'OP Ticket', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OpTicketPage()),
          );
        }, Iconsax.receipt),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(2, 'IP Admission', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => IpAdmissionPage()),
          );
        }, Iconsax.add_circle),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'OP Counters', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OpCounters()),
          );
        }, Iconsax.square),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(4, 'Admission Status', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdmissionStatus()),
          );
        }, Iconsax.status),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(5, 'Doctor Visit Schedule', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => doctorSchedule()),
          );
        }, Iconsax.hospital),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(6, 'Ip Patients Admission', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => IpPatientsAdmission()),
          );
        }, Icons.approval),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(7, 'Logout', () {
          // Handle logout action
        }, Iconsax.logout),
      ],
    );
  }

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

  Widget buildThreeColumnForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 0),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Patient Information :',
                style: TextStyle(
                    fontFamily: 'SanFrancisco',
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 60),
        Row(
          children: [
            Expanded(
                child: CustomTextField(
              hintText: 'First Name',
              controller: firstname,
              width: null,
            )),
            const SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: 'Middle Name',
              controller: middlename,
              width: null,
            )),
            const SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: 'Last Name',
              controller: lastname,
              width: null,
            )),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            const SizedBox(
              width: 40,
              child: Text(
                'SEX :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            ),
            Expanded(
              child: CustomDropdown(
                label: 'Sex',
                items: ['Male', 'Female', 'Other'],
                selectedItem: selectedSex,
                onChanged: (value) {
                  setState(() {
                    selectedSex = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 20),
            const SizedBox(
              width: 40,
              child: Text(
                'AGE :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            ),
            Expanded(
              child: CustomTextField(
                hintText: '',
                controller: age,
                width: null,
              ),
            ),
            const SizedBox(width: 20),
            const SizedBox(
              width: 40,
              child: Text(
                'DOB :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            ),
            Expanded(
                child: CustomTextField(
              hintText: '(YYYY-MM-DD)',
              controller: dob,
              width: null,
            )),
          ],
        ),
        const SizedBox(height: 40),
        CustomTextField(
          hintText: 'Address Line 1',
          controller: address1,
          width: null,
        ),
        const SizedBox(height: 30),
        CustomTextField(
          hintText: 'Address Line 2',
          controller: address2,
          width: null,
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
                child: CustomTextField(
              hintText: "Land Mark",
              controller: landmark,
              width: null,
            )),
            const SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: "City",
              controller: city,
              width: null,
            )),
            const SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: "State",
              controller: state,
              width: null,
            )),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: CustomTextField(
              hintText: 'Pincode',
              controller: pincode,
              width: null,
            )),
            const SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: 'Phone Number 1',
              controller: phone1,
              width: null,
            )),
            const SizedBox(width: 20),
            Expanded(
                child: CustomTextField(
              hintText: 'Phone Number 2',
              controller: phone2,
              width: null,
            )),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Text(
                'BLOOD GROUP :',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            ),
            CustomDropdown(
                label: 'Blood Group',
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                selectedItem: selectedBloodGroup,
                onChanged: (value) {
                  setState(() {
                    selectedBloodGroup = value!;
                  });
                }),
          ],
        ),
        const SizedBox(height: 20),
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
            items: ['Male', 'Female', 'Other'],
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
            items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
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
