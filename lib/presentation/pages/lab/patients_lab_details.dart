import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/pages/doctor/rx_prescription.dart';
import 'package:foxcare_lite/presentation/pages/lab/patient_report.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';

class PatientsLabDetails extends StatefulWidget {
  const PatientsLabDetails({super.key});

  @override
  State<PatientsLabDetails> createState() => _PatientsLabDetails();
}

class _PatientsLabDetails extends State<PatientsLabDetails> {
  final List<String> headers1 = [
    'Token NO',
    'OP NO',
    'Name',
    'Age',
    'Place',
    'List of Tests',
    'Action',
    'Sample Data',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      // Query to fetch patients with non-empty Medications field
      final QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('Medications',
              isNotEqualTo: null) // Ensures Medications exists
          .where('Medications',
              isNotEqualTo: '') // Ensures Medications is not empty
          .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in patientSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        String tokenNo = '';
        try {
          final tokenSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('tokens')
              .doc('currentToken')
              .get();

          if (tokenSnapshot.exists) {
            final tokenData = tokenSnapshot.data();
            if (tokenData != null && tokenData['tokenNumber'] != null) {
              tokenNo = tokenData['tokenNumber'].toString();
            }
          }
        } catch (e) {
          print('Error fetching tokenNo for patient ${doc.id}: $e');
        }

        fetchedData.add({
          'Token NO': tokenNo,
          'OP NO': data['patientID'] ?? 'N/A',
          'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
              .trim(),
          'Age': data['age'] ?? 'N/A',
          'Place': data['state'] ?? 'N/A',
          'Address': data['address1'] ?? 'N/A',
          'PinCode': data['pincode'] ?? 'N/A',
          'Status': data['status'] ?? 'N/A',
          'List of Tests': data['Medications'] ?? 'N/A',
          'Action': TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientReport(
                      patientID: data['patientID'] ?? 'N/A',
                      name:
                          '${data['firstName'] ?? ''} ${data['lastName'] ?? 'N/A'}'
                              .trim(),
                      age: data['age'] ?? 'N/A',
                      sex: data['sex'] ?? 'N/A',
                      place: data['state'] ?? 'N/A',
                      dob: data['dob'] ?? 'N/A',
                      medication: data['Medications'] ?? 'N/A',
                      address: data['address1'] ?? 'N/A',
                      pincode: data['pincode'] ?? 'N/A',
                      primaryInfo: data['otherComments'] ?? 'N/A',
                      temperature: data['temperature'] ?? 'N/A',
                      bloodPressure: data['bloodPressure'] ?? 'N/A',
                      sugarLevel: data['bloodSugarLevel'] ?? 'N/A',
                    ),
                  ),
                );
              },
              child: const CustomText(text: 'Open')),
          'Sample Data': TextButton(
              onPressed: () async {},
              child: const CustomText(text: 'Enter Sample Data'))
        });
      }

      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Token NO']) ?? 0;
        int tokenB = int.tryParse(b['Token NO']) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData1 = fetchedData;
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: CustomText(
          text: "Patients Lab Test",
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
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                tableData: tableData1,
                headers: headers1,
                rowColorResolver: (row) {
                  return row['Status'] == 'aborted'
                      ? Colors.red.shade200
                      : Colors.transparent;
                },
              ),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
