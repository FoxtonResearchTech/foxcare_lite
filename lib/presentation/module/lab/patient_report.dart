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
import 'package:lottie/lottie.dart';

class PatientReport extends StatefulWidget {
  final String patientID;
  final String name;
  final String age;
  final String sex;
  final String dob;
  final String opTicket;
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
      required this.dob,
      required this.opTicket});

  @override
  State<PatientReport> createState() => _PatientReport();
}

class _PatientReport extends State<PatientReport> {
  final TextEditingController reportNo = TextEditingController();

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
      final patientRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('opTickets')
          .doc(widget.opTicket);

      for (var row in tableData1) {
        final testDescription = row['Test Descriptions'];
        final value = row['Values'];

        if (testDescription != null && value != '') {
          await patientRef.collection('tests').doc(testDescription).set({
            'Values': value,
          }, SetOptions(merge: true));
        }
      }

      await patientRef.set({
        'labTotalAmount': totalAmountController.text,
        'labCollected': paidController.text,
        'labBalance': balanceController.text,
        'reportDate': _dateController.text,
        'reportNo': reportNo.text,
      }, SetOptions(merge: true));

      await patientRef.set({
        'reportNo': FieldValue.increment(1),
      }, SetOptions(merge: true));

      CustomSnackBar(context,
          message: 'All values have been successfully submitted',
          backgroundColor: Colors.cyan);
      print('All values have been successfully submitted.');
    } catch (e) {
      CustomSnackBar(context,
          message: 'Error submitting data: $e', backgroundColor: Colors.red);
      print('Error submitting data: $e');
    }
  }

  bool isLoading = false;

  void _updateBalance() {
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    double paidAmount = double.tryParse(paidController.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    balanceController.text = balance.toStringAsFixed(2);
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
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _sampleCollectedDateController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }
  final TextEditingController _sampleCollectedDateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final List<Map<String, String>> dummyData = [
      {'title': 'Patient Name', 'subtitle': widget.name},
      {'title': 'OP Ticket', 'subtitle': widget.opTicket},
      {'title': 'Age', 'subtitle': widget.age},
      {'title': 'Sex', 'subtitle': widget.sex},
      {'title': 'DOB', 'subtitle': widget.dob},
      {
        'title': 'Basic Information / Diagnostics',
        'subtitle': widget.primaryInfo
      },
      {'title': 'Refer By', 'subtitle': 'Test'},
      {'title': 'Report Date', 'subtitle': _dateController.text},
      {'title': 'Sample Date', 'subtitle': _dateController.text},
      {'title': 'Report Number', 'subtitle': '07'},
      {'title': 'Sample Collected Date', 'subtitle': ''},

      // from controller
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // or any custom action
          },
        ),
        title: Center(
            child: CustomText(
          text: "Patient Tests Report",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        backgroundColor: AppColors.blue,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Basic Details of Patients',
                    size: screenHeight * 0.03,
                  ),

                ],
              ),


              SizedBox(height: screenHeight * 0.04),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;

                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth > 900) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      shrinkWrap: true,
                      childAspectRatio: 2, // smaller ratio = taller cards
                      physics: const NeverScrollableScrollPhysics(),
                      children: dummyData.map((item) {
                        bool isSampleDate = item['title'] == 'Sample Collected Date';

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Flexible(
                                  child: isSampleDate
                                      ? GestureDetector(
                                    onTap: _selectDate,
                                    child: AbsorbPointer(
                                      child: TextField(
                                        controller: _sampleCollectedDateController,
                                        style: const TextStyle(fontSize: 14),
                                        decoration: InputDecoration(
                                          hintText: 'Select Date',
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : Text(
                                    item['subtitle']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                    // remove maxLines and overflow
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),


                  );
                },
              ),


              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                editableColumns: ['Values'],
                tableData: tableData1,
                headers: headers1,
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
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
                  Column(
                    children: [
                      isLoading
                          ? SizedBox(
                              width: 60,
                              height: 60,
                              child: Lottie.asset(
                                'assets/button_loading.json',
                                fit: BoxFit.contain,
                              ),
                            )
                          : CustomButton(
                              label: 'Submit',
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                submitData().then((_) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              },
                              width: screenWidth * 0.1,
                            ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
