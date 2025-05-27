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

import '../../../utilities/constants.dart';

class IpPatientReport extends StatefulWidget {
  final String patientID;
  final String name;
  final String age;
  final String sex;
  final String dob;
  final String ipTicket;
  final String place;
  final String doctorName;
  final String sampleDate;
  final String examDocId;
  final String address;
  final String pincode;
  final String primaryInfo;
  final String temperature;
  final String bloodPressure;
  final String sugarLevel;
  final List<dynamic> medication;

  const IpPatientReport(
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
      required this.ipTicket,
      required this.sampleDate,
      required this.examDocId,
      required this.doctorName});

  @override
  State<IpPatientReport> createState() => _IpPatientReport();
}

class _IpPatientReport extends State<IpPatientReport> {
  final dateTime = DateTime.now();

  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();

  TextEditingController _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final TextEditingController _sampleCollectedDateController =
      TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  final List<String> headers1 = [
    'Test Descriptions',
    'Values',
    'Unit',
    'Reference Range',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  String? selectedPaymentMode;
  String reportNO = '';
  int newReportNo = 0;
  String? selectedValue;

  @override
  void initState() {
    getAndIncrementBillNo();

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

  Future<String?> getAndIncrementBillNo() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('billNo').doc('labBillNo');

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        int currentBillNo = data?['billNo'] ?? 0;
        int currentNewBillNo = currentBillNo + 1;

        setState(() {
          reportNO = '${currentNewBillNo}';
          newReportNo = currentNewBillNo;
        });

        return reportNO;
      } else {
        print('Document does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching or incrementing billNo: $e');
      return null;
    }
  }

  Future<void> updateBillNo(int newBillNo) async {
    final docRef =
        FirebaseFirestore.instance.collection('billNo').doc('labBillNo');

    await docRef.set({'billNo': newBillNo});
  }

  Future<void> submitData() async {
    try {
      final patientRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('ipTickets')
          .doc(widget.ipTicket)
          .collection('Examination')
          .doc(widget.examDocId);

      Map<String, String> testResults = {};

      for (var row in tableData1) {
        final testDescription = row['Test Descriptions']?.toString().trim();
        final value = row['Values']?.toString().trim();

        if (testDescription != null &&
            testDescription.isNotEmpty &&
            value != null &&
            value.isNotEmpty) {
          testResults[testDescription] = value;
        }
      }

      await patientRef.set({
        'labTotalAmount': totalAmountController.text.trim(),
        'labCollected': paidController.text.trim(),
        'labBalance': balanceController.text.trim(),
        'reportDate': _dateController.text.trim(),
        'reportNo': reportNO,
        'sampleDate': widget.sampleDate,
        'sampleCollectedDate': _sampleCollectedDateController.text.trim(),
        'tests': testResults,
      }, SetOptions(merge: true));
      await patientRef.collection('labPayments').doc().set({
        'collected': totalAmountController.text,
        'balance': balanceController.text,
        'paymentMode': selectedPaymentMode,
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
      await updateBillNo(newReportNo);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final List<Map<String, String>> data = [
      {'title': 'Patient Name', 'subtitle': widget.name},
      {'title': 'OP Number', 'subtitle': widget.patientID},
      {'title': 'IP Ticket', 'subtitle': widget.ipTicket},
      {'title': 'Age', 'subtitle': widget.age},
      {'title': 'Sex', 'subtitle': widget.sex},
      {'title': 'DOB', 'subtitle': widget.dob},
      {
        'title': 'Basic Information / Diagnostics',
        'subtitle': widget.primaryInfo
      },
      {'title': 'Refer By', 'subtitle': widget.doctorName},
      {'title': 'Report Date', 'subtitle': _dateController.text},
      {'title': 'Sample Date', 'subtitle': widget.sampleDate},
      {'title': 'Report Number', 'subtitle': reportNO},
      {'title': 'Sample Collected Date', 'subtitle': ''},
    ];
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: CustomText(
          text: "Patient Tests Report",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
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
                      children: data.map((item) {
                        bool isSampleDate =
                            item['title'] == 'Sample Collected Date';

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
                                              controller:
                                                  _sampleCollectedDateController,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              decoration: InputDecoration(
                                                hintText: 'Select Date',
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
              Container(
                padding: const EdgeInsets.only(left: 50, right: 50),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Total Amount ',
                              size: screenWidth * 0.013,
                            ),
                            SizedBox(height: 7),
                            CustomTextField(
                              hintText: '',
                              controller: totalAmountController,
                              width: screenWidth * 0.2,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Collected ',
                              size: screenWidth * 0.013,
                            ),
                            SizedBox(height: 7),
                            CustomTextField(
                              hintText: '',
                              controller: paidController,
                              width: screenWidth * 0.2,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Balance ',
                              size: screenWidth * 0.013,
                            ),
                            SizedBox(height: 7),
                            CustomTextField(
                              hintText: '',
                              controller: balanceController,
                              width: screenWidth * 0.2,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Payment Mode ',
                              size: screenWidth * 0.013,
                            ),
                            SizedBox(height: 7),
                            SizedBox(
                              width: screenWidth * 0.2,
                              child: CustomDropdown(
                                width: screenWidth * 0.05,
                                label: '',
                                items: Constants.paymentMode,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      selectedPaymentMode = value;
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Payment Details ',
                              size: screenWidth * 0.013,
                            ),
                            SizedBox(height: 7),
                            CustomTextField(
                              hintText: '',
                              controller: paymentDetails,
                              width: screenWidth * 0.2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
