import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/manager/patient_info.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class EditDeletePatientInformation extends StatefulWidget {
  const EditDeletePatientInformation({super.key});

  @override
  State<EditDeletePatientInformation> createState() =>
      _EditDeletePatientInformation();
}

class _EditDeletePatientInformation
    extends State<EditDeletePatientInformation> {
  TextEditingController _opNumber = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  final List<String> headers1 = [
    'OP NO',
    'Name',
    'Place',
    'Phone No',
    'DOB',
    'Edit',
    'Delete',
  ];
  List<Map<String, dynamic>> tableData1 = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchData({
    String? opNumber,
    String? phoneNumber,
    int pageSize = 20,
  }) async {
    try {
      Query baseQuery = FirebaseFirestore.instance.collection('patients');
      DocumentSnapshot? lastDocument;
      List<Map<String, dynamic>> fetchedData = [];

      bool filterByPhone = phoneNumber != null && phoneNumber.isNotEmpty;
      bool filterByOpNumber = opNumber != null && opNumber.isNotEmpty;

      while (true) {
        Query query = baseQuery;

        if (filterByPhone) {
          query = query.where(Filter.or(
            Filter('phone1', isEqualTo: phoneNumber),
            Filter('phone2', isEqualTo: phoneNumber),
          ));
        }

        if (lastDocument != null) {
          query = query.startAfterDocument(lastDocument);
        }

        query = query.limit(pageSize);
        final snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final docRef = doc.reference;

          // Case-insensitive OP number filter in Dart
          if (filterByOpNumber) {
            final patientOp = data['opNumber']?.toString().toLowerCase() ?? '';
            if (patientOp != opNumber.toLowerCase()) continue;
          }

          fetchedData.add({
            'OP NO': data['opNumber'] ?? 'N/A',
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'Place': data['city'] ?? 'N/A',
            'Phone No': data['phone1'] ?? 'N/A',
            'DOB': data['dob'] ?? 'N/A',
            'Status': data['status'],
            'Edit': TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientInfo(
                        opNumberEdit: data['opNumber'] ?? 'N/A',
                        firstNameEdit: data['firstName'] ?? 'N/A',
                        middleNameEdit: data['middleName'] ?? 'N/A',
                        lastNameEdit: data['lastName'] ?? 'N/A',
                        sexEdit: data['sex'] ?? 'N/A',
                        ageEdit: data['age'] ?? 'N/A',
                        dobEdit: data['dob'] ?? 'N/A',
                        landmarkEdit: data['landmark'] ?? 'N/A',
                        address1Edit: data['address1'] ?? 'N/A',
                        address2Edit: data['address2'] ?? 'N/A',
                        cityEdit: data['city'] ?? 'N/A',
                        stateEdit: data['state'] ?? 'N/A',
                        pincodeEdit: data['pincode'] ?? 'N/A',
                        phone1Edit: data['phone1'] ?? 'N/A',
                        phone2Edit: data['phone2'] ?? 'N/A',
                        bloodGroupEdit: data['bloodGroup'] ?? 'N/A',
                        opAmountEdit: data['opAmount'] ?? 'N/A',
                        opAmountCollectedEdit:
                            data['opAmountCollected'] ?? 'N/A',
                      ),
                    ),
                  );
                },
                child: const CustomText(text: 'Edit')),
            'Delete': TextButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Confirm Delete'),
                        ],
                      ),
                      content: Text(
                        'Are you sure you want to delete the patient ${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('patients')
                          .doc(data['opNumber'])
                          .collection('ipPrescription')
                          .doc()
                          .delete();
                      await FirebaseFirestore.instance
                          .collection('patients')
                          .doc(data['opNumber'])
                          .collection('sampleData')
                          .doc()
                          .delete();
                      await FirebaseFirestore.instance
                          .collection('patients')
                          .doc(data['opNumber'])
                          .collection('tokens')
                          .doc()
                          .delete();
                      await FirebaseFirestore.instance
                          .collection('patients')
                          .doc(data['opNumber'])
                          .delete();

                      CustomSnackBar(context,
                          message: 'Patient Deleted Successfully',
                          backgroundColor: Colors.green);
                      fetchData();
                    } catch (e) {
                      print('Error deleting patient ${data['opNumber']}: $e');
                      CustomSnackBar(context,
                          message: 'Failed To Delete Patient',
                          backgroundColor: Colors.red);
                    }
                  }
                },
                child: const CustomText(text: 'Delete'))
          });
        }

        lastDocument = snapshot.docs.last;

        // Optional delay if you want to slow down batch loading
        await Future.delayed(const Duration(milliseconds: 100));
      }

      setState(() {
        tableData1 = fetchedData;
      });

      if (fetchedData.isEmpty) {
        print("No records found");
      }
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
          text: "Patient Information ",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    hintText: 'OP Number',
                    width: screenWidth * 0.15,
                    controller: _opNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(opNumber: _opNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  CustomTextField(
                    hintText: 'Phone Number',
                    width: screenWidth * 0.15,
                    controller: _phoneNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(phoneNumber: _phoneNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              LazyDataTable(
                tableData: tableData1,
                headers: headers1,
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
                rowColorResolver: (row) {
                  return row['Status'] == 'abscond'
                      ? Colors.red.shade300
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
