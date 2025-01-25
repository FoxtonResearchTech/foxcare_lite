import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/pages/doctor/rx_prescription.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

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

  @override
  void dispose() {
    super.dispose();
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
                      hintText: 'Report Date ', width: screenWidth * 0.2)
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
                tableData: tableData1,
                headers: headers1,
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      label: 'Print',
                      onPressed: () {
                        print(widget.medication);
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
