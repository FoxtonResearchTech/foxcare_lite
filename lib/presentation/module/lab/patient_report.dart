import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:intl/intl.dart';

class PatientReport extends StatefulWidget {
  final String patientID;
  final String name;
  final String age;
  final String sex;
  final String dob;

  final String place;
  final String address;
  final String pincode;
  final String primaryInfo;
  final String temperature;
  final String bloodPressure;
  final String sugarLevel;
  final List<dynamic> medication;

  const PatientReport(
      {super.key,
      required this.patientID,
      required this.name,
      required this.age,
      required this.place,
      required this.address,
      required this.pincode,
      required this.primaryInfo,
      required this.temperature,
      required this.bloodPressure,
      required this.sugarLevel,
      required this.sex,
      required this.medication,
      required this.dob});

  @override
  State<PatientReport> createState() => _PatientReport();
}

class _PatientReport extends State<PatientReport> {
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  TextEditingController _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  final List<String> headers1 = [
    'Test Descriptions',
    'Values',
    'Unit',
    'Reference Range',
  ];
  List<Map<String, dynamic>> tableData1 = [];

  String? selectedValue;

  @override
  void initState() {
    super.initState();
    totalAmountController.addListener(_updateBalance);
    paidController.addListener(_updateBalance);
    if (widget.medication.isNotEmpty) {
      tableData1 = widget.medication.map((med) {
        return {
          'Test Descriptions': med,
          'Values': '',
          'Unit': '',
          'Reference Range': '',
        };
      }).toList();
    }
  }

  Future<void> submitData() async {
    try {
      // Reference to the patient's Firestore document
      final patientRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID);

      // Store test descriptions and values in Firestore
      for (var row in tableData1) {
        final testDescription = row['Test Descriptions'];
        final value = row['Values'];

        if (testDescription != null && value != '') {
          await patientRef.collection('tests').doc(testDescription).set({
            'Values': value,
          }, SetOptions(merge: true));
        }
      }

      // Update patient financial details
      await patientRef.set({
        'totalAmount': totalAmountController.text,
        'collected': paidController.text,
        'balance': balanceController.text,
        'reportDate': _dateController.text,
      }, SetOptions(merge: true));

      // Increment the submission counter in Firestore
      await patientRef.set({
        'reportNo': FieldValue.increment(1),
      }, SetOptions(merge: true));

      // Show success message
      CustomSnackBar(context,
          message: 'All values have been successfully submitted',
          backgroundColor: AppColors.secondaryColor);
      print('All values have been successfully submitted.');
    } catch (e) {
      CustomSnackBar(context,
          message: 'Error submitting data: $e', backgroundColor: Colors.red);
      print('Error submitting data: $e');
    }
  }

  void _updateBalance() {
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    double paidAmount = double.tryParse(paidController.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    balanceController.text = balance.toStringAsFixed(2); // Update balance field
  }

  @override
  void dispose() {
    totalAmountController.dispose();
    paidController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  void clear() {
    totalAmountController.clear();
    paidController.clear();
    balanceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: CustomText(
          text: "Patient Tests Report",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        backgroundColor: AppColors.secondaryColor,
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
            children: [
              Row(
                children: [
                  CustomText(
                    text: 'Basic Details of Patients',
                    size: screenHeight * 0.03,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                      controller: TextEditingController(text: widget.name),
                      hintText: 'Patient Name ',
                      readOnly: true,
                      width: screenWidth * 0.2),
                  CustomTextField(
                    controller: TextEditingController(text: widget.patientID),
                    hintText: 'OP Number ',
                    width: screenWidth * 0.2,
                    readOnly: true,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    controller: TextEditingController(text: widget.age),
                    hintText: 'Age ',
                    width: screenWidth * 0.2,
                    readOnly: true,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  CustomTextField(
                    controller: TextEditingController(text: widget.sex),
                    hintText: 'Sex ',
                    width: screenWidth * 0.2,
                    readOnly: true,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  CustomTextField(
                    controller: TextEditingController(text: widget.dob),
                    hintText: 'DOB ',
                    width: screenWidth * 0.2,
                    readOnly: true,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomTextField(
                controller: TextEditingController(text: widget.primaryInfo),
                hintText: 'Basic Information / Diagnostics',
                width: screenWidth,
                verticalSize: screenHeight * 0.03,
                readOnly: true,
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                      hintText: 'Report Number ', width: screenWidth * 0.2),
                  CustomTextField(
                      controller: _dateController,
                      readOnly: true,
                      hintText: 'Report Date ',
                      width: screenWidth * 0.2),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                      hintText: 'Sample Date ', width: screenWidth * 0.2),
                  CustomTextField(
                      hintText: 'Sample Collected Date ',
                      width: screenWidth * 0.2)
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              SizedBox(
                width: screenWidth * 0.5,
                child: CustomDropdown(
                  label: "Refer by Doctor's Name",
                  items: ['Dr.1', 'Dr.2', 'Dr.3', 'Dr.4', 'Dr.5'],
                  selectedItem: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                editableColumns: ['Values'],
                tableData: tableData1,
                headers: headers1,
                onValueChanged: (rowIndex, header, value) async {
                  if (header == 'Values') {
                    setState(() {
                      tableData1[rowIndex][header] = value;
                    });
                  }
                },
              ),
              SizedBox(height: screenHeight * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                      controller: totalAmountController,
                      hintText: 'Total Amount',
                      width: screenWidth * 0.2),
                  SizedBox(width: screenWidth * 0.03),
                  CustomTextField(
                      controller: paidController,
                      hintText: 'Paid',
                      width: screenWidth * 0.2),
                  SizedBox(width: screenWidth * 0.03),
                  CustomText(
                    text: 'Balance : ',
                    size: screenWidth * 0.012,
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  CustomTextField(
                      controller: balanceController,
                      hintText: '',
                      width: screenWidth * 0.2),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      label: 'Print',
                      onPressed: () {},
                      width: screenWidth * 0.1),
                  SizedBox(
                    width: screenWidth * 0.05,
                  ),
                  CustomButton(
                      label: 'Submit',
                      onPressed: () async {
                        await submitData();
                      },
                      width: screenWidth * 0.1)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
